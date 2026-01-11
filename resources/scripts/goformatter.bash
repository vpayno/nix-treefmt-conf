# shellcheck shell=bash

declare -a args=("${@:- -w}")

printf "Running %s\n" "gofmt ${args[*]}"
gofmt "${args[@]}"
printf "\n"

printf "Running %s\n" "goimports-reviser ${args[*]}"
goimports-reviser "${args[@]}"
printf "\n"

printf "Running %s\n" "golines ${args[*]}"
golines "${args[@]}"
printf "\n"

printf "Running %s\n" "gofumpt ${args[*]}"
gofumpt "${args[@]}"
printf "\n"
