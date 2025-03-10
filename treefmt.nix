# treefmt.nix
{ ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  # Enable the nix formatter
  programs = {
    alejandra.enable = false; # using nixfmt
    deno.enable = true; # markdown
    jsonfmt.enable = true; # json
    nixfmt.enable = true; # nixfmt-rfc-style is now the default for the 'nix fmt' formatter
    rustfmt.enable = true; # rust
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
      taplo = {
        includes = [
          ".editorconfig"
        ];
      };
    };
  };
}
