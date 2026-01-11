# flake.nix
{
  description = "Centralized treefmt configuration repo for my flakes/projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    systems.url = "github:vpayno/nix-systems-default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

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
        pname = "nix-treefmt-conf";
        version = "0.4.0";
        name = "${pname}-${version}";

        pkgs = nixpkgs.legacyPackages.${system};

        treefmt = import ./treefmt.nix {
          inherit pkgs scripts;
        };

        treefmtEval = treefmt-nix.lib.evalModule pkgs treefmt;

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
            inherit pname version name;

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

        usageMessagePre = ''
          Available ${name} flake commands:

            nix run .#flakeShowUsage | .#default     # this message
        '';

        generatePackagesFromScripts = pkgs.lib.mapAttrs (
          name: _:
          scripts."${name}"
          // {
            inherit (scriptMetadata."${name}") pname;
            inherit version;
            name = "${self.packages.${system}."${name}".pname}-${self.packages.${system}."${name}".version}";
          }
        ) scripts;

        generateAppsFromScripts = pkgs.lib.mapAttrs (name: _: {
          type = "app";
          program = "${pkgs.lib.getExe self.packages.${system}.${name}}";
          inherit (self.packages.${system}.${name}) meta;
        }) scripts;

        scriptMetadata = {
          flakeShowUsage = rec {
            pname = "flake-show-usage";
            inherit version;
            name = "${pname}-${version}";
            description = "Show Nix flake usage text";
          };

          tagRelease = rec {
            pname = "tag-release";
            inherit version;
            name = "${pname}-${version}";
            description = "Tags a new version of the flake";
          };

          goFormatter = rec {
            pname = "goformatter";
            inherit version;
            name = "${pname}-${version}";
            description = "Custom Golang formatter/linter";
          };

          goModTidy = rec {
            pname = "gomodtidy";
            inherit version;
            name = "${pname}-${version}";
            description = "Runs go mod tidy";
          };

          pyFormatter = rec {
            pname = "pyformatter";
            inherit version;
            name = "${pname}-${version}";
            description = "Custom Python formatter/linter";
          };

          shFormatter = rec {
            pname = "shformatter";
            inherit version;
            name = "${pname}-${version}";
            description = "Custom Shell formatter/linter";
          };
        };

        scripts = {
          flakeShowUsage = pkgs.writeShellApplication {
            name = scriptMetadata.flakeShowUsage.pname;
            runtimeInputs = with pkgs; [
              coreutils
              jq
              gnugrep
              nix
            ];
            text = ''
              declare json_text
              declare -a commands
              declare -a comments
              declare -i i

              printf "\n"
              printf "%s" "${usageMessagePre}"
              printf "\n"

              json_text="$(nix flake show --json 2>/dev/null | jq --sort-keys .)"

              mapfile -t commands < <(printf "%s" "$json_text" | jq -r --arg system "${system}" '.apps[$system] | to_entries[] | select(.key | test("^(default|flakeShowUsage)$") | not) | "\("nix run .#")\(.key)"')
              mapfile -t comments < <(printf "%s" "$json_text" | jq -r --arg system "${system}" '.apps[$system] | to_entries[] | select(.key | test("^(default|flakeShowUsage)$") | not) | "\("# ")\(.value.description)"')

              for ((i = 0; i < ''${#commands[@]}; i++)); do
                printf "  %-40s %s\n" "''${commands[$i]}" "''${comments[$i]}"
              done

              printf "\n"

              mapfile -t commands < <(printf "%s" "$json_text" | jq -r --arg system "${system}" '.devShells[$system] | to_entries[] | "\("nix develop .#")\(.key)"')
              mapfile -t comments < <(printf "%s" "$json_text" | jq -r --arg system "${system}" '.devShells[$system] | to_entries[] | "\("# ")\(.value.name)"')

              for ((i = 0; i < ''${#commands[@]}; i++)); do
                printf "  %-40s %s\n" "''${commands[$i]}" "''${comments[$i]}"
              done

              printf "\n"
            '';
            meta = scriptMetadata.flakeShowUsage;
          };

          tagRelease = pkgs.writeShellApplication {
            name = scriptMetadata.tagRelease.pname;
            runtimeInputs = with pkgs; [
              coreutils
              deno
              git
              git-cliff
              gnugrep
              gnused
              gum
              mdformat
            ];
            text = builtins.readFile ./resources/scripts/tag-release.bash;
            meta = scriptMetadata.tagRelease;
          };

          goFormatter = pkgs.writeShellApplication {
            name = scriptMetadata.goFormatter.pname;
            runtimeInputs = with pkgs; [
              go
              goimports-reviser
              golines
              gofumpt
            ];
            text = builtins.readFile ./resources/scripts/goformatter.bash;
            meta = scriptMetadata.goFormatter;
          };

          goModTidy = pkgs.writeShellApplication {
            name = scriptMetadata.goModTidy.pname;
            runtimeInputs = with pkgs; [
              go
            ];
            text = builtins.readFile ./resources/scripts/gomodtidy.bash;
            meta = scriptMetadata.goModTidy;
          };

          pyFormatter = pkgs.writeShellApplication {
            name = scriptMetadata.pyFormatter.pname;
            runtimeInputs = with pkgs; [
              isort
              ruff
            ];
            text = builtins.readFile ./resources/scripts/pyformatter.bash;
            meta = scriptMetadata.pyFormatter;
          };

          shFormatter = pkgs.writeShellApplication {
            name = scriptMetadata.shFormatter.pname;
            runtimeInputs = with pkgs; [
              shfmt
            ];
            text = builtins.readFile ./resources/scripts/shformatter.bash;
            meta = scriptMetadata.shFormatter;
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
            // metadata.meta
            // {
              meta = {
                mainProgram = "treefmt";
              };
            };

          default = fmt;
        }
        // generatePackagesFromScripts;

        apps = rec {
          default = self.apps.${system}.flakeShowUsage;

          fmt = {
            type = "app";
            program = "${pkgs.lib.getExe packages.fmt}";
            inherit (metadata) meta;
          };
        }
        // generateAppsFromScripts;

        devShells = {
          default = pkgs.mkShell {
            packages =
              commonPkgs
              ++ (with packages; [
                fmt
                tagRelease
              ]);

            buildInputs = darwinOnlyBuildInputs;

            GREETING = "Starting nix develop shell for ${name}...";

            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "$GREETING"
            '';
          };
        };
      }
    );
}
