#!/usr/bin/env bash

####
##
## Jetsung Chan <jetsungchan@gmail.com>
##
## https://framagit.org/jetsung/devenv
## https://github.com/jetsung/devenv
##
####

set -e
set -u
set -o pipefail

exec 3>&1

script_name=$(basename "$0")

if [ -t 1 ] && command -v tput >/dev/null; then
	ncolors=$(tput colors || echo 0)
	if [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
		bold="$(tput bold || echo)"
		normal="$(tput sgr0 || echo)"
		black="$(tput setaf 0 || echo)"
		red="$(tput setaf 1 || echo)"
		green="$(tput setaf 2 || echo)"
		yellow="$(tput setaf 3 || echo)"
		blue="$(tput setaf 4 || echo)"
		magenta="$(tput setaf 5 || echo)"
		cyan="$(tput setaf 6 || echo)"
		white="$(tput setaf 7 || echo)"
	fi
fi

say_warning() {
	printf "%b\n" "${yellow:-}${script_name}: Warning: $1${normal:-}" >&3
}

say_err() {
	printf "%b\n" "${red:-}${script_name}: Error: $1${normal:-}" >&2
	exit 1
}

say() {
	printf "%b\n" "${cyan:-}${script_name}:${normal:-} $1" >&3
}

## golang
install_golang() {
	if [ -e "${golang_path}" ]; then
		say "\n\nInstalling Go"
		${SHELL} ${golang_path} up

		# shellcheck disable=SC2086 source=/dev/null
		source $PROFILE
		go version
	fi
}

## nodejs
install_nodejs() {
	if [ -e "${node_path}" ]; then
		say "\n\nInstalling Node"
		${SHELL} ${node_path} up

		npm config list
		#     	printf "
		# npm version: %s
		# node version: %s
		# " $(npm --version) $(node --version)
	fi
}

## deno
install_deno() {
	if [ -e "${deno_path}" ]; then
		say "\n\nInstalling deno"
		${SHELL} ${deno_path} up

		# shellcheck source=/dev/null
		source "$PROFILE"
		deno --version
	fi
}

## flutter
install_flutter() {
	if [ -e "${flutter_path}" ]; then
		say "\n\nInstalling Flutter"
		${SHELL} ${flutter_path} up

		# shellcheck disable=SC2086 source=/dev/null
		source $PROFILE
		flutter --version
	fi
}

## dotnet
install_dotnet() {
	if [ -e "${dotnet_path}" ]; then
		say "\n\nInstalling dotnet"
		${SHELL} ${dotnet_path} up

		# shellcheck disable=SC2086 source=/dev/null
		source $PROFILE
		__VER=$(dotnet --version)
		printf "dotnet: %s\n" "$__VER"
	fi
}

## python
install_python() {
	if [ -e "${python_path}" ]; then
		say "\n\nInstalling Anaconda(Python)"
		${SHELL} ${python_path} up

		# shellcheck disable=SC2086 source=/dev/null
		source $PROFILE
		python --version
	fi
}

## composer
install_composer() {
	if [ -e "${composer_path}" ]; then
		say "\n\nInstalling Composer"
		${SHELL} ${composer_path} up

		if ! command_exists composer; then
			err_message "Composer is not installed"
		fi
	fi
}

## docker
install_docker() {
	if [ -e "${docker_path}" ]; then
		say "\n\nInstalling Docker"
		${SHELL} ${docker_path} up

		# shellcheck disable=SC2086 source=/dev/null
		source $PROFILE
		docker info
	fi
}

## rust
install_rust() {
	if [ -e "${rust_path}" ]; then
		say "\n\nInstalling Rust"
		${SHELL} ${rust_path} up

		# shellcheck source=/dev/null
		source "${HOME}"/.cargo/env
		rustc --version
		rustup --version
	fi
}

IN_CHINA=""

AUTHOR="Jetsung Chan <jetsungchan@gmail.com>"
PROJECT_URL="https://github.com/jetsung/devenv"
PROJ_URL="https://framagit.org/jetsung/devenv"

# base
golang_path="sh/go.sh"
dotnet_path="sh/dotnet.sh"
node_path="sh/node.sh"
deno_path="sh/deno.sh"
flutter_path="sh/flutter.sh"

# need root
python_path="sh/python.sh"
docker_path="sh/docker.sh"
composer_path="sh/composer.sh"

# need enter any key
rust_path="sh/rust.sh"

# shellcheck source=/dev/null
[ -f ./sh/include.sh ] && . ./sh/include.sh

if [ -n "$IN_CHINA" ]; then
	PROJECT_URL="${PROJ_URL}"
fi

printf "
###############################################################
###  DevEnv Install
###
###  Project: %s
###
###  Author:  %s
###
###############################################################
\n" "${PROJECT_URL}" "${AUTHOR}"

## custom
install_golang
install_nodejs
install_deno
install_flutter
install_dotnet

## need root
install_composer
install_docker

## need enter any key
install_python
install_rust
