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

This is an example of `shellcheck` finding errors in `treefmt.nix`:

```text
$ nix flake check
error: builder for '/nix/store/6a25mxwc5jl5jhr1hd4p2wwmwp4y7j4i-pyfmt.drv' failed with exit code 1;
       last 25 log lines:
       > Did you mean:
       > isort "$isort_args" "$@"
       >
       >
       > In /nix/store/cvyl68b69s9927m84vwhgnlqpjff8c3l-pyfmt/bin/pyfmt line 13:
       > black_args="--line-length=240"
       > ^--------^ SC2034 (warning): black_args appears unused. Verify use (or export if used externally).
       >
       >
       > In /nix/store/cvyl68b69s9927m84vwhgnlqpjff8c3l-pyfmt/bin/pyfmt line 16:
       > printf "Running %s\n" "ruff $ruff_args $@"
       >                                        ^-- SC2145 (error): Argument mixes string and array. Use * or separate argument.
       >
       >
       > In /nix/store/cvyl68b69s9927m84vwhgnlqpjff8c3l-pyfmt/bin/pyfmt line 17:
       > ruff $ruff_args "$@"
       >      ^--------^ SC2086 (info): Double quote to prevent globbing and word splitting.
       >
       > Did you mean:
       > ruff "$ruff_args" "$@"
       >
       > For more information:
       >   https://www.shellcheck.net/wiki/SC2145 -- Argument mixes string and array. ...
       >   https://www.shellcheck.net/wiki/SC2034 -- black_args appears unused. Verify...
       >   https://www.shellcheck.net/wiki/SC2086 -- Double quote to prevent globbing ...
       For full logs, run 'nix log /nix/store/6a25mxwc5jl5jhr1hd4p2wwmwp4y7j4i-pyfmt.drv'.
error: 1 dependencies of derivation '/nix/store/ahqwp7ralhy0s0aw3zyqgz22aasm12nw-treefmt.toml.drv' failed to build
error: 1 dependencies of derivation '/nix/store/9xy3i55xm789kni8ig1y7x5rfabkywqy-treefmt.drv' failed to build
error: 1 dependencies of derivation '/nix/store/wps3282zl52g1dqp5yi47srczvcsacws-treefmt-check.drv' failed to build
```

## Releases

This flake includes a `tag-release` script used to bump the version in
`flake.nix` and create the tag.

To run it type: `nix run .#tag-release -- v1.2.3 "fix blah blah"`

Example output:

```bash
$ nix run .#tag-release -- v1.2.3 "fix blah blah"
nix run github:vpayno/nix-treefmt-conf?ref=tr-app#tag-release v1.2.3 "fix blah blah"

 Tag: v1.2.3
Note: fix blah blah



[main 597a5a8] release v1.2.3: fix blah blah
 1 file changed, 1 insertion(+), 1 deletion(-)


tag v1.2.3
Tagger: Victor Payno <vpayno@users.noreply.github.com>
Date:   Tue Mar 11 22:10:03 2025 -0700

release v1.2.3: fix blah blah

commit 597a5a86edd1793139ca618f2ee5a0e6fe16f8e2 (HEAD -> main, tag: v1.2.3)
Author: Victor Payno <vpayno@users.noreply.github.com>
Date:   Tue Mar 11 22:10:03 2025 -0700

    release v1.2.3: fix blah blah

diff --git a/flake.nix b/flake.nix
index 9e552cb..dfc5845 100644
--- a/flake.nix
+++ b/flake.nix
@@ -21,7 +21,7 @@
     flake-utils.lib.eachDefaultSystem (
       system:
       let
-        version = "v0.1.5";
+        version = "v1.2.3";

         pkgs = nixpkgs.legacyPackages.${system};


 Push tag v1.2.3?

    Yes        No

←→ toggle • enter submit • y Yes • n No
```
