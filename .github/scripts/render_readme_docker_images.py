#!/usr/bin/env python3
from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

from tabulate import tabulate

BEGIN_MARKER = "<!-- BEGIN_BUILT_DOCKER_IMAGES -->"
END_MARKER = "<!-- END_BUILT_DOCKER_IMAGES -->"
ROOT = Path(__file__).resolve().parents[2]
GITHUB_REMOTE_RE = re.compile(
    r"(?:git@github\.com:|https://github\.com/)(?P<repo>[^/]+/[^/.]+)(?:\.git)?$"
)


def detect_github_repository() -> str | None:
    if repository := os.environ.get("GITHUB_REPOSITORY"):
        return repository

    try:
        remote_url = subprocess.check_output(
            ["git", "remote", "get-url", "origin"],
            cwd=ROOT,
            text=True,
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return None

    match = GITHUB_REMOTE_RE.search(remote_url)
    if match is None:
        return None
    return match.group("repo")


def collect_docker_images() -> list[dict[str, str]]:
    repository = detect_github_repository()
    repository_owner = repository.split("/", 1)[0] if repository else ""
    images: list[dict[str, str]] = []

    for dockerfile in sorted(ROOT.glob("docker/*/*/Dockerfile")):
        tag_dir = dockerfile.parent
        image_dir = tag_dir.parent
        platforms_file = tag_dir / ".platforms"

        platforms = "linux/amd64"
        if platforms_file.exists():
            platforms = platforms_file.read_text(encoding="utf-8").strip() or platforms

        images.append(
            {
                "image": image_dir.name,
                "tag": tag_dir.name,
                "platforms": platforms,
                "dockerfile": str(dockerfile.relative_to(ROOT)),
                "package_url": (
                    f"https://github.com/{repository}/pkgs/container/{image_dir.name}"
                    if repository
                    else ""
                ),
                "image_ref": (
                    f"ghcr.io/{repository_owner}/{image_dir.name}:{tag_dir.name}"
                    if repository_owner
                    else ""
                ),
            }
        )

    return images


def render_block(images: list[dict[str, str]]) -> str:
    lines = [
        "Docker images are defined under `docker/<image-name>/<image-tag>/Dockerfile`.",
        "",
        "These are the image build contexts currently present in the repo:",
        "",
    ]

    if not images:
        lines.append("_No Docker image build contexts found._")
        return "\n".join(lines)

    lines.append(
        tabulate(
            [
                [
                    f"`{image['image']}`",
                    f"`{image['tag']}`",
                    f"`{image['platforms']}`",
                    (
                        f"[`{image['image_ref']}`]({image['package_url']})"
                        if image["package_url"]
                        else "n/a"
                    ),
                    f"[`{image['dockerfile']}`]({image['dockerfile']})",
                ]
                for image in images
            ],
            headers=["Image", "Tag", "Platforms", "Package", "Dockerfile"],
            tablefmt="github",
            disable_numparse=True,
        )
    )
    return "\n".join(lines)


def update_readme(readme_path: Path, rendered: str) -> None:
    content = readme_path.read_text(encoding="utf-8")
    begin = content.find(BEGIN_MARKER)
    end = content.find(END_MARKER)
    if begin == -1 or end == -1 or end < begin:
        raise SystemExit(f"Could not locate README markers in {readme_path}")

    insert_at = begin + len(BEGIN_MARKER)
    updated_content = (
        content[:insert_at] + "\n" + rendered.rstrip() + "\n" + content[end:]
    )
    readme_path.write_text(
        updated_content + ("\n" if not updated_content.endswith("\n") else ""),
        encoding="utf-8",
    )


def main() -> int:
    readme_path = (
        Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT / "README.md"
    )
    update_readme(readme_path, render_block(collect_docker_images()))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
