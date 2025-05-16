{
  description = "Python project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Use the same version of pyproject.toml
        python = pkgs.python313;
        uv = pkgs.uv;

        loadEnv = ''
          # shellcheck disable=SC1091
          source .env
        '';

        groupDebug = ''
          GROUP_DEBUG=$([ "''${ENV:-dev}" = "dev" ] && echo "--group debug" || echo "")
        '';

        # Custom shell app using writeShellApplication
        app = pkgs.writeShellApplication {
          name = "app";
          #runtimeInputs = [ python uv ];
          text = ''
            ${loadEnv}
            echo "Running my Python app..."
            uv run example
          '';
        };
      in {
        devShells = {
          default = pkgs.mkShell {
            #buildInputs = [uv python];
            shellHook = ''
              ${loadEnv}
            '';
          };
        };
        packages.default = app;
        apps.app = {
          type = "app";
          program = "${app}/bin/app";
        };

        apps.ruff = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "ruff";
            text = ''
              uvx ruff check app tests
              uvx ruff format --check app tests
            '';
          }}/bin/ruff";
        };

        apps.ruff-fix = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "ruff-fix";
            text = ''
              uvx ruff check app tests --fix
              uvx ruff format app tests
            '';
          }}/bin/ruff-fix";
        };

        apps.tests = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "tests";
            text = ''
              uv run --group test --group debug pytest -ssvv tests
            '';
          }}/bin/tests";
        };

        apps.typing = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "typing";
            text = ''
              uvx ty check
              # uv run --group test --group debug mypy --strict app tests
            '';
          }}/bin/typing";
        };

      });
}