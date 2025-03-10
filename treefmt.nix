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
