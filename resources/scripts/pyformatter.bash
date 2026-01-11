# shellcheck shell=bash

declare -a args=("${@}")

declare -a isort_args=("--profile=black" "--multi-line=3" "--wrap-length=10" "--line-length=11" "--dont-follow-links" "--ensure-newline-before-comments")
declare -a ruff_args=("--line-length=120")

printf "Running %s\n" "isort ${isort_args[*]} ${*}"
isort "${isort_args[@]}" "${@}"
printf "\n"

printf "Running %s\n" "ruff format ${ruff_args[*]} ${args[*]}"
ruff format "${ruff_args[@]}" "${args[@]}"
printf "\n"
