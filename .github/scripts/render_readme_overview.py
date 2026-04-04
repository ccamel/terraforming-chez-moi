#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import hcl2
from tabulate import tabulate

BEGIN_MARKER = "<!-- BEGIN_DEPLOYED_OVERVIEW -->"
END_MARKER = "<!-- END_DEPLOYED_OVERVIEW -->"
EXPR_RE = re.compile(r"\${([^}]+)}")
FULL_EXPR_RE = re.compile(r"^\${([^}]+)}$")
ROOT = Path(__file__).resolve().parents[2]


@dataclass
class EvalContext:
    variables: dict[str, Any]
    default_variables: set[str]
    locals: dict[str, Any]


@dataclass
class ServiceRecord:
    project: str
    name: str
    image: str
    image_repository: str
    exposure: str
    persistence: str
    is_runtime: bool
    networks: list[str]


def load_tf_directory(directory: Path) -> dict[str, list[Any]]:
    combined: dict[str, list[Any]] = {}
    for path in sorted(directory.glob("*.tf")):
        with path.open("r", encoding="utf-8") as handle:
            data = hcl2.load(handle)
        for key, value in data.items():
            combined.setdefault(key, []).extend(value)
    return combined


def collect_variable_defaults(module_data: dict[str, list[Any]]) -> dict[str, Any]:
    defaults: dict[str, Any] = {}
    for block in module_data.get("variable", []):
        for name, attrs in block.items():
            if "default" in attrs:
                defaults[name] = attrs["default"]
    return defaults


def build_context(
    module_data: dict[str, list[Any]], overrides: dict[str, Any] | None = None
) -> EvalContext:
    variables = collect_variable_defaults(module_data)
    default_variables = set(variables)
    if overrides:
        variables.update(overrides)

    ctx = EvalContext(
        variables=variables, default_variables=default_variables, locals={}
    )
    for block in module_data.get("locals", []):
        for name, value in block.items():
            ctx.locals[name] = evaluate(value, ctx)
    return ctx


def evaluate(value: Any, ctx: EvalContext) -> Any:
    if isinstance(value, list):
        return [evaluate(item, ctx) for item in value]
    if isinstance(value, dict):
        return {key: evaluate(item, ctx) for key, item in value.items()}
    if not isinstance(value, str):
        return value

    full_match = FULL_EXPR_RE.match(value)
    if full_match:
        resolved = resolve_expression(full_match.group(1), ctx)
        if resolved is not None:
            return resolved

    return EXPR_RE.sub(
        lambda match: stringify(
            resolve_expression(match.group(1), ctx), match.group(0)
        ),
        value,
    )


def resolve_expression(expression: str, ctx: EvalContext) -> Any | None:
    expression = expression.strip()
    if expression.startswith("var."):
        return ctx.variables.get(expression[4:])
    if expression.startswith("local."):
        return ctx.locals.get(expression[6:])
    return None


def stringify(value: Any, fallback: str | None = None) -> str:
    if value is None:
        return fallback or ""
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def render_variable_binding(value: Any, ctx: EvalContext) -> str:
    if isinstance(value, str) and value.startswith("${var.") and value.endswith("}"):
        name = value[6:-1]
        if name in ctx.default_variables:
            default = ctx.variables.get(name)
            return f"{name} (default: {default})"
        return stringify(ctx.variables.get(name, name))
    return stringify(evaluate(value, ctx))


def extract_image_repository(image: str) -> str:
    return image.split("@", 1)[0].split(":", 1)[0]


def extract_image_family(image_repository: str) -> str:
    return image_repository.rsplit("/", 1)[-1]


def render_exposure(service: dict[str, Any], ctx: EvalContext) -> str:
    ports = service.get("ports", [])
    if not ports:
        return "internal only"

    rendered = []
    for port in ports:
        published = render_variable_binding(port.get("published"), ctx)
        target = stringify(evaluate(port.get("target"), ctx))
        rendered.append(f"`{published}` -> `{target}`")
    return "<br>".join(rendered)


def render_persistence(service: dict[str, Any], ctx: EvalContext) -> str:
    volumes = service.get("volumes", [])
    if not volumes:
        return "none"

    targets = []
    for volume in volumes:
        if volume.get("type") != "bind":
            continue
        targets.append(f"`{stringify(evaluate(volume.get('target'), ctx))}`")

    return "<br>".join(targets) if targets else "none"


def render_networks(
    service: dict[str, Any], project_networks: dict[str, Any], ctx: EvalContext
) -> list[str]:
    rendered = []
    for network_alias in sorted(service.get("networks", {}).keys()):
        network_attrs = project_networks.get(network_alias, {})
        network_name = stringify(
            evaluate(network_attrs.get("name", network_alias), ctx)
        )
        rendered.append(network_name)
    return rendered


def collect_project_services(
    module_data: dict[str, list[Any]], ctx: EvalContext
) -> list[ServiceRecord]:
    services: list[ServiceRecord] = []
    for resource_block in module_data.get("resource", []):
        container_projects = resource_block.get("synology_container_project", {})
        for _, attrs in container_projects.items():
            project_name = stringify(evaluate(attrs["name"], ctx))
            project_networks = attrs.get("networks", {})
            for service_name, service in sorted(attrs.get("services", {}).items()):
                image = stringify(evaluate(service.get("image", ""), ctx))
                image_repository = extract_image_repository(image)
                services.append(
                    ServiceRecord(
                        project=project_name,
                        name=service_name,
                        image=image,
                        image_repository=image_repository,
                        exposure=render_exposure(service, ctx),
                        persistence=render_persistence(service, ctx),
                        is_runtime=service.get("restart") != "no",
                        networks=render_networks(service, project_networks, ctx),
                    )
                )
    return services


def collect_services(
    root_data: dict[str, list[Any]], root_ctx: EvalContext
) -> list[ServiceRecord]:
    services = collect_project_services(root_data, root_ctx)

    for module_block in root_data.get("module", []):
        for _, attrs in module_block.items():
            source = attrs.get("source")
            if not isinstance(source, str) or not source.startswith("./"):
                continue

            module_dir = (ROOT / source).resolve()
            module_data = load_tf_directory(module_dir)
            overrides = {}
            for key, value in attrs.items():
                if key == "source":
                    continue
                overrides[key] = evaluate(value, root_ctx)

            module_ctx = build_context(module_data, overrides)
            services.extend(collect_project_services(module_data, module_ctx))

    return sorted(
        services, key=lambda item: (item.project, item.is_runtime is False, item.name)
    )


def collect_provider_versions(root_data: dict[str, list[Any]]) -> list[str]:
    providers = []
    for terraform_block in root_data.get("terraform", []):
        for provider_block in terraform_block.get("required_providers", []):
            for name, attrs in provider_block.items():
                source = attrs.get("source", name)
                version = attrs.get("version")
                if version:
                    providers.append(f"`{source}` ({version})")
                else:
                    providers.append(f"`{source}`")
    return sorted(set(providers))


def build_table(headers: list[str], rows: list[list[str]]) -> str:
    return tabulate(rows, headers=headers, tablefmt="github", disable_numparse=True)


def render_overview(services: list[ServiceRecord], providers: list[str]) -> str:
    runtime_services = [service for service in services if service.is_runtime]
    project_count = len({service.project for service in runtime_services})

    technologies = sorted(
        {extract_image_family(service.image_repository) for service in runtime_services}
    )
    networks = sorted(
        {network for service in runtime_services for network in service.networks}
    )

    runtime_rows = [
        [
            f"`{service.project}`",
            f"`{service.name}`",
            f"`{service.image_repository}`",
            f"`{service.image}`",
            service.exposure,
            service.persistence,
        ]
        for service in runtime_services
    ]

    lines = [
        (
            f"This repository currently declares **{project_count} Synology container projects** "
            f"and **{len(runtime_services)} exposed runtime services**."
        ),
        "",
        "### Runtime Services",
        "",
        build_table(
            ["Project", "Service", "Image Repo", "Image", "Exposure", "Persistence"],
            runtime_rows,
        ),
        "",
        "### Platform Building Blocks",
        "",
        (
            "- Infrastructure state is managed by `Terraform` via "
            + ", ".join(providers)
            + "."
        ),
        (
            "- Runtime is organized as Synology Container Manager projects with "
            "bind-mounted DSM folders for persistence."
        ),
        "- Declared runtime technologies: "
        + ", ".join(f"`{item}`" for item in technologies)
        + ".",
    ]

    if networks:
        lines.append(
            "- Declared runtime networks: "
            + ", ".join(f"`{item}`" for item in networks)
            + "."
        )

    return "\n".join(lines)


def update_readme(readme_path: Path, rendered_overview: str) -> None:
    content = readme_path.read_text(encoding="utf-8")
    begin = content.find(BEGIN_MARKER)
    end = content.find(END_MARKER)
    if begin == -1 or end == -1 or end < begin:
        raise SystemExit(f"Could not locate README markers in {readme_path}")

    insert_at = begin + len(BEGIN_MARKER)
    updated_content = (
        content[:insert_at] + "\n" + rendered_overview.rstrip() + "\n" + content[end:]
    )

    readme_path.write_text(
        updated_content + ("\n" if not updated_content.endswith("\n") else ""),
        encoding="utf-8",
    )


def main() -> int:
    readme_path = (
        Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT / "README.md"
    )
    root_data = load_tf_directory(ROOT)
    root_ctx = build_context(root_data)
    services = collect_services(root_data, root_ctx)
    providers = collect_provider_versions(root_data)
    overview = render_overview(services, providers)
    update_readme(readme_path, overview)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
