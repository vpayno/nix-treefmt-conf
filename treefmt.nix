# treefmt.nix
{
  pkgs,
  ...
}:
let
  scripts = {
    goformatter = pkgs.writeShellApplication {
      name = "goformatter";
      runtimeInputs = with pkgs; [
        go
        goimports-reviser
        golines
        gofumpt
      ];
      text = builtins.readFile ./resources/scripts/goformatter.bash;
    };

    gomodtidy = pkgs.writeShellApplication {
      name = "go-mod-tidy";
      runtimeInputs = with pkgs; [
        go
      ];
      text = builtins.readFile ./resources/scripts/gomodtidy.bash;
    };

    pyformatter = pkgs.writeShellApplication {
      name = "pyfmt";
      runtimeInputs = with pkgs; [
        isort
        ruff
      ];
      text = builtins.readFile ./resources/scripts/pyformatter.bash;
    };

    shformatter = pkgs.writeShellApplication {
      name = "shellfmt";
      runtimeInputs = with pkgs; [
        shfmt
      ];
      text = builtins.readFile ./resources/scripts/shformatter.bash;
    };
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
    deno.enable = true; # markdown
    goimports.enable = false; # in goformatter wrapper
    gofumpt.enable = false; # in goformatter wrapper
    gofmt.enable = false; # in goformatter wrapper
    isort.enable = false; # in pyfmt wrapper
    jsonfmt.enable = true; # json
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
        command = "${pkgs.lib.getExe scripts.goformatter}";
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
        command = "${pkgs.lib.getExe scripts.gomodtidy}";
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
      pyfmt = {
        args = [
        ];
        command = "${pkgs.lib.getExe scripts.pyformatter}";
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
        command = "${pkgs.lib.getExe scripts.shformatter}";
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
