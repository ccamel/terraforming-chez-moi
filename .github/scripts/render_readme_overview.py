#!/usr/bin/env python3
from __future__ import annotations

import ast
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import hcl2
import yaml
from tabulate import tabulate

BEGIN_MARKER = "<!-- BEGIN_DEPLOYED_OVERVIEW -->"
END_MARKER = "<!-- END_DEPLOYED_OVERVIEW -->"
EXPR_RE = re.compile(r"\${([^}]+)}")
FULL_EXPR_RE = re.compile(r"^\${([^}]+)}$")
TEMPLATE_PATH_RE = re.compile(r"templates/[^\"')]+\.tftpl")
ROOT = Path(__file__).resolve().parents[2]


@dataclass
class EvalContext:
    variables: dict[str, Any]
    locals: dict[str, Any]


@dataclass
class ServiceRecord:
    project: str
    name: str
    image: str
    image_repository: str
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


def normalize_hcl_string(value: str) -> str:
    value = value.strip()
    if len(value) < 2 or value[0] != '"' or value[-1] != '"':
        return value

    try:
        unquoted = ast.literal_eval(value)
    except (SyntaxError, ValueError):
        return value

    return unquoted if isinstance(unquoted, str) else value


def normalize_hcl_value(value: Any) -> Any:
    if isinstance(value, list):
        return [normalize_hcl_value(item) for item in value]
    if isinstance(value, dict):
        return {
            normalize_hcl_string(key)
            if isinstance(key, str)
            else key: normalize_hcl_value(item)
            for key, item in value.items()
        }
    if isinstance(value, str):
        return normalize_hcl_string(value)
    return value


def collect_variable_defaults(module_data: dict[str, list[Any]]) -> dict[str, Any]:
    defaults: dict[str, Any] = {}
    for block in module_data.get("variable", []):
        for name, attrs in block.items():
            if "default" in attrs:
                defaults[normalize_hcl_string(name)] = normalize_hcl_value(
                    attrs["default"]
                )
    return defaults


def build_context(
    module_data: dict[str, list[Any]], overrides: dict[str, Any] | None = None
) -> EvalContext:
    variables = collect_variable_defaults(module_data)
    if overrides:
        variables.update(overrides)

    ctx = EvalContext(variables=variables, locals={})
    for block in module_data.get("locals", []):
        for name, value in block.items():
            ctx.locals[normalize_hcl_string(name)] = evaluate(value, ctx)
    return ctx


def evaluate(value: Any, ctx: EvalContext) -> Any:
    if isinstance(value, list):
        return [evaluate(item, ctx) for item in value]
    if isinstance(value, dict):
        return {key: evaluate(item, ctx) for key, item in value.items()}
    if not isinstance(value, str):
        return value

    value = normalize_hcl_string(value)

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


def extract_image_repository(image: str) -> str:
    return image.split("@", 1)[0].split(":", 1)[0]


def extract_image_family(image_repository: str) -> str:
    return image_repository.rsplit("/", 1)[-1]


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
                        is_runtime=service.get("restart") != "no",
                        networks=render_networks(service, project_networks, ctx),
                    )
                )
    return services


def extract_template_path(value: Any) -> Path | None:
    rendered = stringify(value, "")
    match = TEMPLATE_PATH_RE.search(rendered)
    if not match:
        return None
    return ROOT / match.group(0)


def render_compose_template(template_path: Path, variables: dict[str, Any]) -> str:
    content = template_path.read_text(encoding="utf-8")
    escaped_compose_vars = "__ESCAPED_COMPOSE_VAR__"
    content = content.replace("$${", escaped_compose_vars)
    rendered = EXPR_RE.sub(
        lambda match: stringify(variables.get(match.group(1)), match.group(0)),
        content,
    )
    return rendered.replace(escaped_compose_vars, "${")


def render_compose_networks(
    service: dict[str, Any], project_networks: dict[str, Any]
) -> list[str]:
    rendered = []
    for network_alias in service.get("networks", []):
        network_attrs = project_networks.get(network_alias, {})
        network_name = stringify(network_attrs.get("name", network_alias))
        rendered.append(network_name)
    return rendered


def collect_compose_template_services(
    project_name: str, template_path: Path, template_variables: dict[str, Any]
) -> list[ServiceRecord]:
    compose_data = yaml.safe_load(
        render_compose_template(template_path, template_variables)
    )
    project_networks = compose_data.get("networks", {})

    services: list[ServiceRecord] = []
    for service_name, service in sorted(compose_data.get("services", {}).items()):
        image = stringify(service.get("image", ""))
        image_repository = extract_image_repository(image)
        services.append(
            ServiceRecord(
                project=project_name,
                name=service_name,
                image=image,
                image_repository=image_repository,
                is_runtime=service.get("restart") != "no",
                networks=render_compose_networks(service, project_networks),
            )
        )
    return services


def collect_compose_stack_services(
    root_data: dict[str, list[Any]], root_ctx: EvalContext
) -> list[ServiceRecord]:
    services: list[ServiceRecord] = []

    for module_block in root_data.get("module", []):
        for _, attrs in module_block.items():
            source = stringify(evaluate(attrs.get("source"), root_ctx))
            if source == "./modules/compose_stack":
                project_name = stringify(
                    evaluate(
                        attrs.get("project_name", attrs.get("stack_name")), root_ctx
                    )
                )
                template_path = extract_template_path(attrs.get("compose_yaml"))
                if template_path is None:
                    continue
                services.extend(
                    collect_compose_template_services(
                        project_name=project_name,
                        template_path=template_path,
                        template_variables=root_ctx.variables,
                    )
                )
            elif source == "./modules/zeroclaw":
                module_dir = (ROOT / source).resolve()
                module_data = load_tf_directory(module_dir)
                overrides = {}
                for key, value in attrs.items():
                    if key == "source":
                        continue
                    overrides[key] = evaluate(value, root_ctx)

                module_ctx = build_context(module_data, overrides)
                services.extend(
                    collect_compose_template_services(
                        project_name=stringify(module_ctx.locals["project_name"]),
                        template_path=module_dir / "templates/compose.yaml.tftpl",
                        template_variables={
                            "project_name": module_ctx.locals["project_name"],
                            "edge_network_name": module_ctx.variables[
                                "edge_network_name"
                            ],
                            "image": module_ctx.variables["image"],
                            "published_port": module_ctx.variables["published_port"],
                        },
                    )
                )

    return services


def collect_services(
    root_data: dict[str, list[Any]], root_ctx: EvalContext
) -> list[ServiceRecord]:
    services = collect_project_services(root_data, root_ctx)
    services.extend(collect_compose_stack_services(root_data, root_ctx))

    for module_block in root_data.get("module", []):
        for _, attrs in module_block.items():
            source = stringify(evaluate(attrs.get("source"), root_ctx))
            if (
                not isinstance(source, str)
                or not source.startswith("./")
                or source
                in {
                    "./modules/compose_stack",
                    "./modules/zeroclaw",
                }
            ):
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
    discovered: dict[str, str | None] = {}

    def walk(node: Any) -> None:
        if isinstance(node, list):
            for item in node:
                walk(item)
            return

        if not isinstance(node, dict):
            return

        for name, attrs in node.items():
            if isinstance(attrs, dict) and ("source" in attrs or "version" in attrs):
                source = stringify(normalize_hcl_value(attrs.get("source", name)))
                version = attrs.get("version")
                discovered[source] = (
                    stringify(normalize_hcl_value(version))
                    if version is not None
                    else None
                )
            else:
                walk(attrs)

    for terraform_block in root_data.get("terraform", []):
        walk(terraform_block.get("required_providers", []))

    providers = []
    for source, version in discovered.items():
        if version:
            providers.append(f"`{source}` ({version})")
        else:
            providers.append(f"`{source}`")

    return sorted(set(providers))


def build_table(headers: list[str], rows: list[list[str]]) -> str:
    return tabulate(rows, headers=headers, tablefmt="github", disable_numparse=True)


def render_overview(services: list[ServiceRecord], providers: list[str]) -> str:
    runtime_services = [service for service in services if service.is_runtime]

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
        ]
        for service in runtime_services
    ]

    lines = [
        f"This repository manages **{len(runtime_services)} self-hosted services** on my Synology NAS.",
        "",
        "### Runtime Services",
        "",
        build_table(["Project", "Service", "Image Repo", "Image"], runtime_rows),
        "",
        "### Platform Building Blocks",
        "",
        (
            "- Infrastructure state is managed by `Terraform` via "
            + ", ".join(providers)
            + "."
        ),
        (
            "- Runtime is rendered as Docker Compose stacks and applied remotely "
            "over SSH via `Ansible`."
        ),
        "- Synology-specific state is mostly limited to DSM folders provisioned through Terraform.",
        "- Runtime technologies currently in play: "
        + ", ".join(f"`{item}`" for item in technologies)
        + ".",
    ]

    if networks:
        lines.append(
            "- Shared runtime networks: "
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
    if not services:
        raise SystemExit(
            "No runtime services found; refusing to render an empty overview"
        )

    providers = collect_provider_versions(root_data)
    overview = render_overview(services, providers)
    update_readme(readme_path, overview)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
