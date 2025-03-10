# nix-treefmt-conf

Centralized [treefmt](https://github.com/numtide/treefmt-nix) configuration repo
for my flakes/projects.

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
