# shellcheck shell=bash

printf "Running %s\n" "go mod tidy"
go mod tidy
printf "\n"
