#!/usr/bin/env bash

####
##
## Jetsung Chan <jetsungchan@gmail.com>
##
## https://jihulab.com/jetsung/devenv
## https://github.com/jetsung/devenv
## 
####

load_vars() {
	AUTHOR="Jetsung Chan <jetsungchan@gmail.com>"
	PROJECT_URL="https://github.com/jetsung/devenv"
	JIHULAB_URL="https://jihulab.com/jetsung/devenv"

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
}

## golang
install_golang() {
	if [[ -e "${golang_path}" ]]; then
		echo -e "\n\nInstalling Go"
		${SHELL} ${golang_path} up
		source ${PROFILE}
		go version
	fi
}

## nodejs
install_nodejs() {
	if [ -e "${node_path}" ]; then
		echo -e "\n\nInstalling Node"
		${SHELL} ${node_path} up
		source ${PROFILE}
	    npm config list
#     	printf "
# npm version: %s
# node version: %s
# " $(npm --version) $(node --version)
	fi
}

## deno
install_deno() {
	if [[ -e "${deno_path}" ]]; then
		echo -e "\n\nInstalling deno"
		${SHELL} ${deno_path} up
		source ${PROFILE}
		deno --version
	fi
}

## flutter
install_flutter() {
	if [[ -e "${flutter_path}" ]]; then
		echo -e "\n\nInstalling Flutter"
		${SHELL} ${flutter_path} up
		source ${PROFILE}
		flutter --version
	fi
}

## dotnet
install_dotnet() {
	if [[ -e "${dotnet_path}" ]]; then
		echo -e "\n\nInstalling dotnet"
		${SHELL} ${dotnet_path} up
		source ${PROFILE}
		printf "dotnet: %s\n" $(dotnet --version)
	fi
}

## python
install_python() {
	if [[ -e "${python_path}" ]]; then
		echo -e "\n\nInstalling Anaconda(Python)"
		${SHELL} ${python_path} up
		source ${PROFILE}
		python --version
	fi	
}

## composer
install_composer() {
	if [[ -e "${composer_path}" ]]; then
		echo -e "\n\nInstalling Composer"
		${SHELL} ${composer_path} up

		if ! command_exists composer; then
			err_message "Composer is not installed"
		fi
	fi		
}

## docker
install_docker() {
	if [[ -e "${docker_path}" ]]; then
		echo -e "\n\nInstalling Docker"
		${SHELL} ${docker_path} up
		source ${PROFILE}
		docker info
	fi
}

## rust
install_rust() {
	if [[ -e "${rust_path}" ]]; then
		echo -e "\n\nInstalling Rust"
		${SHELL} ${rust_path} up
		source ${HOME}/.cargo/env
		rustc --version
		rustup --version
	fi
}

main() {
	. ./sh/include.sh

	load_vars

    if [[ -n "${IN_CHINA}" ]]; then
		PROJECT_URL="${JIHULAB_URL}"
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
	# install_golang
	# install_nodejs
	# install_deno
	# install_flutter
	# install_dotnet

	# ## need root
	# install_composer
	# install_docker

	# ## need enter any key
	# install_python
	install_rust
}

main $@ || exit 1
