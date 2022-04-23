#/bin/bash

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

	# need root
	python_path="sh/python.sh"
	docker_path="sh/docker.sh"
	composer_path="sh/composer.sh"

	# need enter any key
	rust_path="sh/rust.sh"
}

## golang
install_golang() {
	if [ -e "${golang_path}" ]; then
		echo -e "\n\nInstalling Go"
		bash ${golang_path} up
		source "${HOME}/.bashrc"
		go version
	fi
}

## nodejs
install_nodejs() {
	if [ -e "${node_path}" ]; then
		echo -e "\n\nInstalling Node"
		bash ${node_path} up
		source "${HOME}/.bashrc"
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
		echo -e "\n\nInstalling deno"
		bash ${deno_path} up
		source "${HOME}/.bashrc"
		deno --version
	fi
}

## dotnet
install_dotnet() {
	if [ -e "${dotnet_path}" ]; then
		echo -e "\n\nInstalling dotnet"
		bash ${dotnet_path} up
		source "${HOME}/.bashrc"
		dotnet --version
	fi
}

## python
install_python() {
	if [ -e "${python_path}" ]; then
		echo -e "\n\nInstalling Python"
		bash ${python_path} up
		source "${HOME}/.bashrc"
		python3 --version
	fi	
}

## composer
install_composer() {
	if [ -e "${composer_path}" ]; then
		echo -e "\n\nInstalling Composer"
		bash ${composer_path} up

		if ! command_exists composer; then
			err_message "Composer is not installed"
		fi
	fi		
}

## docker
install_docker() {
	if [ -e "${docker_path}" ]; then
		echo -e "\n\nInstalling Docker"
		bash ${docker_path} up
		source "${HOME}/.bashrc"
		docker --version
	fi
}

## rust
install_rust() {
	if [ -e "${rust_path}" ]; then
		echo -e "\n\nInstalling Rust"
		bash ${rust_path} up
		source "${HOME}/.bashrc"
		rustc --version
	fi
}

main() {
	. ./sh/include.sh

	load_vars

    if [ "${IN_CHINA}" == "1" ]; then
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
	install_golang
	install_nodejs
	install_deno
	install_dotnet

	## need root
	install_python
	install_composer
	install_docker

	## need enter any key
	install_rust
}

main "$@" || exit 1
