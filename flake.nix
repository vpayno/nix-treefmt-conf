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
        pname = "nix-treefmt-conf";
        version = "v0.3.1";
        name = "${pname}-${version}";

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

          tag-release =
            pkgs.writeShellApplication {
              name = "tag-release";
              runtimeInputs = with pkgs; [
                coreutils
                git
                git-cliff
                gnugrep
                gnused
                gum
              ];
              text = ''
                declare current_branch
                current_branch="$(git branch --show-current)"

                if [[ $current_branch != main ]]; then
                  printf "\n"
                  printf "ERROR: you must be on the main branch before running this script.\n"
                  printf "\n"
                  exit 1
                fi

                if ! git diff-index --quiet HEAD; then
                  printf "\n"
                  printf "ERROR: git repo is dirty, commit or stash all of your changes before running this script.\n"
                  printf "\n"
                  exit 1
                fi

                # the double single quotes escape the $ so we can use it as a bash variable instead of a nix variable
                declare version="''${1:-}"
                declare note="''${2:-}"

                if [[ -z $version ]] || [[ -z $note ]]; then
                  printf "\n"
                  printf "Usage: nix run github:vpayno/nix-treefmt-conf#tag-release -- %s \"%s\"\n" v1.2.3 "fixed blah blah"
                  printf "\n"
                  exit 1
                fi

                if [[ ! $version =~ ^v[0-9]+[.][0-9]+[.][0-9]+$ ]]; then
                  printf "\n"
                  printf "ERROR: version string \"%s\" doesn't match the format \"^v[0-9]+[.][0-9]+[.][0-9]+$\"\n" "$version"
                  printf "\n"
                  exit 1
                fi

                if git tag | grep -q -E "^$version$"; then
                  printf "\n"
                  printf "ERROR: tag %s already exists in the local checkout.\n" "$version"
                  printf "\n"
                  git show "$version"
                  printf "\n"
                  exit 1
                fi

                if git ls-remote --exit-code --tags --quiet origin | grep -q -E "refs/tags/$version$"; then
                  printf "\n"
                  printf "ERROR: tag %s already exists on the remote.\n" "$version"
                  printf "\n"
                  git show origin "$version"
                  printf "\n"
                  exit 1
                fi

                declare last_version
                last_version="$(git tag --list -n0 | sort -V | tail -n 1)"

                printf "\n"
                printf " Tag: %s\n" "$version"
                printf "Note: %s\n" "$note"
                printf "\n"

                # flake.nix:        version = "v0.1.5";
                sed -r -i -e "s/^( +version = \")v[0-9]+.[0-9]+.[0-9]+(\")/\1$version\2/g" ./flake.nix
                printf "\n"

                git add ./flake.nix
                printf "\n"

                git-cliff --tag="$version" --output=CHANGELOG.md
                git add ./CHANGELOG.md
                printf "\n"

                git commit -m "release($version): $note

                $(git-cliff "$last_version".. --tag "$version")
                "
                printf "\n"

                git tag -a -m "release($version): $note" "$version"
                printf "\n"

                git show "$version"
                printf "\n"

                if gum confirm "Push tag $version?"; then
                  git push origin main
                  printf "\n"
                  git push origin tag "$version"
                  printf "\n"
                else
                  printf "\n"
                  printf "Run \"%s\" to push commits and tags.\n" "git push --follow-tags"
                  printf "\n"
                fi
              '';
            }
            // metadata.meta
            // {
              meta = {
                pname = "tag-release";
                name = "${name}-${version}";
                mainProgram = "tag-release";
              };
            };
        };

        apps = rec {
          fmt = {
            type = "app";
            program = "${pkgs.lib.getExe packages.default}";
            inherit (metadata) meta;
          };
          default = fmt;

          tag-release = {
            type = "app";
            program = "${pkgs.lib.getExe packages.tag-release}";
            meta = metadata.meta // {
              pname = "tag-release";
              name = "${pname}-${version}";
            };

          };
        };

        devShells = {
          default = pkgs.mkShell {
            packages =
              commonPkgs
              ++ (with packages; [
                fmt
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
