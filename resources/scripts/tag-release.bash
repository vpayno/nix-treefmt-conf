# shellcheck shell=bash

declare current_branch
current_branch="$(git branch --show-current)"

if [[ ${current_branch} != main ]]; then
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
declare version="${1:-}"
declare note="${2:-}"

if [[ -z ${version} ]] || [[ -z ${note} ]]; then
	printf "\n"
	printf "Usage: nix run github:vpayno/nix-treefmt-conf#tag-release -- %s \"%s\"\n" 1.2.3 "fixed blah blah"
	printf "\n"
	exit 1
fi

if [[ ! ${version} =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]]; then
	printf "\n"
	printf "ERROR: version string \"%s\" doesn't match the format \"^[0-9]+[.][0-9]+[.][0-9]+$\"\n" "${version}"
	printf "\n"
	exit 1
fi

if git tag | grep -q -E "^${version}$"; then
	printf "\n"
	printf "ERROR: tag %s already exists in the local checkout.\n" "${version}"
	printf "\n"
	git show "${version}"
	printf "\n"
	exit 1
fi

if git ls-remote --exit-code --tags --quiet origin | grep -q -E "refs/tags/${version}$"; then
	printf "\n"
	printf "ERROR: tag %s already exists on the remote.\n" "${version}"
	printf "\n"
	git show origin "${version}"
	printf "\n"
	exit 1
fi

declare last_version
last_version="$(git tag --list -n0 | sort -V | tail -n 1)"

printf "\n"
printf " Tag: %s\n" "${version}"
printf "Note: %s\n" "${note}"
printf "\n"

# flake.nix:        version = "v0.1.5";
# flake.nix:        version = "0.1.5";
sed -r -i -e "s/^( +version = \")v?[0-9]+.[0-9]+.[0-9]+(\")/\1${version}\2/g" ./flake.nix
printf "\n"

git add ./flake.nix
printf "\n"

git-cliff --tag="${version}" --output=CHANGELOG.md
git add ./CHANGELOG.md
printf "\n"

git commit -m "release(${version}): ${note}

                $(git-cliff "${last_version}".. --tag "${version}")
                "
printf "\n"

git tag -a -m "release(${version}): ${note}" "${version}"
printf "\n"

git show "${version}"
printf "\n"

if gum confirm "Push tag ${version}?"; then
	git push origin main
	printf "\n"
	git push origin tag "${version}"
	printf "\n"
else
	printf "\n"
	printf "Run \"%s\" to push commits and tags.\n" "git push --follow-tags"
	printf "\n"
fi
