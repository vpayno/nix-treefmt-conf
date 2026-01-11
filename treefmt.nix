# treefmt.nix
{
  pkgs,
  scripts,
  ...
}:
let
  data = {
    lineLength = 80;
  };
in
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  # Enable the nix formatter
  programs = {
    actionlint.enable = true; # github workflows
    alejandra.enable = false; # using nixfmt
    black.enable = false; # using ruff-format in pyfmt
    cmake-format.enable = true; # cmake
    deno.enable = true; # web, md, json, yaml
    gofmt.enable = false; # in goformatter wrapper
    gofumpt.enable = false; # in goformatter wrapper
    goimports.enable = false; # in goformatter wrapper
    isort.enable = false; # in pyfmt wrapper
    jsonfmt.enable = true; # json
    mdformat.enable = true;
    nixfmt.enable = true; # nixfmt-rfc-style is now the default for the 'nix fmt' formatter
    ruff-check.enable = true; # python linter
    ruff-format.enable = false; # in pyfmt
    rustfmt.enable = true; # rust
    shellcheck.enable = true; # shell
    shfmt.enable = false; # shell, use shellfmt
    taplo.enable = true; # toml
  };

  settings = {
    global = {
      excludes = [
        "LICENSE"
        "devbox.json" # jsonfmt keeps re-including it
        ".devbox/*"
        ".venv/*"
      ];
    };
    formatter = {
      goformatter = {
        args = [
          "-w"
        ];
        command = "${pkgs.lib.getExe scripts.goFormatter}";
        includes = [
          "*.go"
        ];
        excludes = [
          "vedor/*"
        ];
      };

      gomodtidy = {
        args = [
        ];
        command = "${pkgs.lib.getExe scripts.goModTidy}";
        includes = [
          "*go.mod"
          "*go.sum"
          "*go.work"
          "*go.work.sum"
        ];
      };

      jsonfmt = {
        excludes = [
          "devbox.json"
        ];
      };

      mdformat = {
        end-of-line = "lf";
        number = true;
        wrap = data.lineLength; # length, keep, no
      };

      pyfmt = {
        args = [
        ];
        command = "${pkgs.lib.getExe scripts.pyFormatter}";
        includes = [
          "*.py"
          "*.pyi"
        ];
        excludes = [
          ".venv/*"
        ];
      };

      shellfmt = {
        args = [
        ];
        command = "${pkgs.lib.getExe scripts.shFormatter}";
        includes = [
          "*.sh"
          "*.bash"
          "*.ebuild"
          "*.envrc"
          "*.envrc.*"
        ];
      };

      taplo = {
        includes = [
          ".editorconfig"
        ];
      };
    };
  };
}
