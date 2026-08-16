{
  description = "Terraforming Chez Moi development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.actionlint
              pkgs.ansible
              pkgs.ansible-lint
              pkgs.docker
              pkgs.docker-compose
              pkgs.git
              pkgs.go
              pkgs.just
              pkgs.python3
              pkgs.python3Packages.pip
              pkgs.python3Packages.virtualenv
              pkgs.shellcheck
              pkgs.terraform
              pkgs.tflint
              pkgs.yamllint
            ];

            shellHook = ''
              echo "terraforming-chez-moi development environment loaded"
              echo "Run 'just' to see available recipes"
            '';
          };
        }
      );
    };
}
