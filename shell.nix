{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "terraforming-chez-moi";

  buildInputs = with pkgs; [
    terraform
    just
    ansible
    ansible-lint
    go
    docker
    docker-compose
    actionlint
    shellcheck
    yamllint
    tflint
    python3
    python3Packages.pip
    python3Packages.virtualenv
    git
  ];

  shellHook = ''
    echo "🏠 terraforming-chez-moi development environment"
    echo ""
    echo "Available commands:"
    echo "  - terraform: Manage infrastructure"
    echo "  - just: Run project tasks (see 'just --list')"
    echo "  - ansible-playbook: Deploy compose stacks"
    echo "  - actionlint: Lint GitHub Actions workflows"
    echo "  - tflint: Lint Terraform files"
    echo ""
    echo "Run 'just' to see available recipes"
  '';
}
