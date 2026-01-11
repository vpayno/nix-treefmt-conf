# shellcheck shell=bash

declare -a args=("${@:-}")

declare -a shfmt_args=("--indent=0" "--case-indent" "--space-redirects" "--keep-padding" "--write")

printf "Running %s\n" "shfmt ${shfmt_args[*]} ${args[*]}"
# shellcheck disable=SC2086
shfmt "${shfmt_args[@]}" "${args[@]}"
printf "\n"
