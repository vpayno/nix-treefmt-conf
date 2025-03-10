# nix-treefmt-conf

Centralized [treefmt](https://github.com/numtide/treefmt-nix) configuration repo
for my flakes/projects.

## Documentation

- [treefmt-nix repo](https://github.com/numtide/treefmt-nix)
- [treefmt-nix website](https://treefmt.com/latest/)
- [treefmt formatter configurations](https://treefmt.com/formatters/)

## Usage

This project can be used as a standalone formatter for in a flake via `nix fmt`.

### Standalone

```bash
nix run github:vpayno/nix-treefmt-conf --
```

Example output:

```text
$ nix run github:vpayno/nix-treefmt-conf --
2025/03/09 21:44:26 INFO using config file: /nix/store/q1sndm1zc30fx8wykvc8rbgch6j2czs3-treefmt.toml
traversed 7 files
emitted 5 files for processing
formatted 2 files (0 changed) in 59ms
```

### Flake

Example diff showing how to add it to a flake.

```diff
diff --git a/flake.nix b/flake.nix
--- a/flake.nix
+++ b/flake.nix
@@ -21,6 +21,11 @@
       inputs.uv2nix.follows = "uv2nix";
       inputs.nixpkgs.follows = "nixpkgs";
     };
+
+    treefmt-conf ={
+      url = "github:vpayno/nix-treefmt-conf";
+      inputs.nixpkgs.follows = "nixpkgs";
+    };
   };

   outputs = {
@@ -29,6 +34,7 @@
     pyproject-nix,
     uv2nix,
     pyproject-build-systems,
+    treefmt-conf,
     ...
   }: let
     system = "x86_64-linux";
@@ -97,7 +103,7 @@
       mainProgram = "pysay";
     };
   in {
-    formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
+    formatter.${system} = treefmt-conf.formatter.${system};

     # Package a virtual environment as our main application.
     #
```

## Linting

### shellcheck

`treefmt` can also use linters before formatting and fail when lint errors are
detected.

This example shows `shellcheck` failing `nix fmt` after lint errors are
detected.

```text
$ nix run ~/git_vpayno/nix-treefmt-conf?ref=fmt-conf-shell; cat test.sh
2025/03/10 08:49:22 INFO using config file: /nix/store/bcf68bh38y7gdp3cxpgbl3g8q5pn70sv-treefmt.toml
ERRO formatter | shellcheck: failed to apply with options '[]': exit status 1


In test.sh line 5:
echo $one
     ^--^ SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean:
echo "$one"

For more information:
  https://www.shellcheck.net/wiki/SC2086 -- Double quote to prevent globbing ...

traversed 8 files
emitted 5 files for processing
formatted 0 files (1 changed) in 42ms
Error: formatting failures detected
#!/usr/bin/env bash

one="1 7"

echo $one

if true; then # one
  true        # two
else
  false
fi

true >/tmp/true.txt
```
