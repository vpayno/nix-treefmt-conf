# flake.nix
{
  description = "Centralized treefmt configuration repo for my flakes/projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        version = "v0.1.2";

        pkgs = nixpkgs.legacyPackages.${system};

        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

        commonPkgs = with pkgs; [
          bashInteractive
          coreutils
          moreutils
          git
          tig
          glow
          runme
        ];

        darwinOnlyBuildInputs =
          if pkgs.stdenv.isDarwin then
            with pkgs;
            [
              darwin.apple_sdk.frameworks.Security
            ]
          else
            [ ];

        metadata = {
          meta = {
            homepage = "https://github.com/vpayno/nix-treefmt-conf";
            description = "Centralized treefmt configuration repo for my flakes/projects";
            platforms = pkgs.lib.platforms.linux;
            license = with pkgs.lib.licenses; [ mit ];
            # maintainers = with pkgs.lib.maintainers; [vpayno];
            maintainers = [
              {
                email = "vpayno@users.noreply.github.com";
                github = "vpayno";
                githubId = 3181575;
                name = "Victor Payno";
              }
            ];
            mainProgram = "fmt";
            available = true;
            broken = false;
            insecure = false;
            outputsToInstall = [ "out" ];
            unfree = false;
            unsupported = false;
          };
        };
      in
      rec {
        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        packages = rec {
          fmt =
            formatter
            // {
              inherit version;
            }
            // metadata
            // {
              meta = {
                mainProgram = "treefmt";
              };
            };

          default = fmt;
        };

        apps = rec {
          fmt = {
            type = "app";
            program = "${pkgs.lib.getExe packages.default}";
            meta = metadata.meta;
          };
          default = fmt;
        };

        devShells = {
          default = pkgs.mkShell {
            packages =
              commonPkgs
              ++ (with packages; [
                fmt
              ]);

            buildInputs = darwinOnlyBuildInputs;

            GREETING = "Starting nix develop shell...";

            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "$GREETING"
            '';
          };
        };
      }
    );
}
