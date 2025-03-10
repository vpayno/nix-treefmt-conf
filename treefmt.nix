# treefmt.nix
{
  pkgs,
  ...
}:
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  # Enable the nix formatter
  programs = {
    alejandra.enable = false; # using nixfmt
    black.enable = false; # using isort + ruff-format
    deno.enable = true; # markdown
    jsonfmt.enable = true; # json
    nixfmt.enable = true; # nixfmt-rfc-style is now the default for the 'nix fmt' formatter
    ruff-format.enable = true; # isort + ruff-format
    rustfmt.enable = true; # rust
    shellcheck.enable = true; # shell
    shfmt = {
      enable = true; # shell
    };
    taplo.enable = true; # toml
  };

  settings = {
    global = {
      excludes = [
        "LICENSE"
        "devbox.json" # jsonfmt keeps re-including it
      ];
    };
    formatter = {
      jsonfmt = {
        excludes = [
          "devbox.json"
        ];
      };
      ruff-format = {
        args = [
          "format"
          "--line-length=240"
        ];
        command = pkgs.writeShellApplication {
          name = "pyfmt";
          runtimeInputs = with pkgs; [
            isort
            ruff
          ];
          text = ''
            isort_args="--profile black --multi-line 3 --wrap-length 10 --line-length 11 --dont-follow-links --ensure-newline-before-comments"
            printf "Running %s\n" "isort $isort_args $*"
            # shellcheck disable=SC2086
            isort $isort_args "$@"
            printf "\n"

            printf "Running %s\n" "ruff $*"
            ruff "$@"
            printf "\n"
          '';
        };
      };
      shfmt = {
        args = [
          "--indent"
          "0" # 0 for tabs
          "--case-indent"
          "--space-redirects"
          "--keep-padding"
          "--write"
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
