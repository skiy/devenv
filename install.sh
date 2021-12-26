#/bin/bash

####
## https://github.com/jetsung/devenv
## https://gitcode.net/jetsung/devenv
####

# get OS version
init_os() {
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    case $OS in
        darwin) OS='darwin';;
        linux) OS='linux';;
        freebsd) OS='freebsd';;
#        mingw*) OS='windows';;
#        msys*) OS='windows';;
        *) printf "\e[1;31mOS %s is not supported by this installation script\e[0m\n" $OS; exit 1;;
    esac
}

# install curl,wget command
install_dl_command() {
    if !(test -x "$(command -v curl)"); then
        if test -x "$(command -v yum)"; then
            sudo yum install -y curl wget
        elif test -x "$(command -v apt)"; then
            sudo apt install -y curl wget
        else 
            printf "\e[1;31mYou must pre-install the curl,wget tool\e[0m\n"
            exit 1
        fi
    fi  
}

message() {
	echo -e "\n\e[1;31m${1}\e[0m"
}

load_vars() {
	# base
	golang_path="sh/go.sh"
	dotnet_path="sh/dotnet.sh"
	node_path="sh/node.sh"
	deno_path="sh/deno.sh"
	python_path="sh/python.sh"

	# need root
	docker_path="sh/docker.sh"
	composer_path="sh/composer.sh"

	# need enter any key
	rust_path="sh/rust.sh"
}

## golang
install_golang() {
	if [ -e "${golang_path}" ]; then
		echo -e "\n\nInstalling Go\n"
		bash ${golang_path}
		source "${HOME}/.bashrc"
		go version
	fi
}

## dotnet
install_dotnet() {
	if test -x "$(command -v dotnet)"; then
		message "dotnet has installed"
		dotnet --version
		return
	fi

	if [ -e "${dotnet_path}" ]; then
		echo -e "\n\nInstalling Dotnet\n"
		bash ${dotnet_path}
		source "${HOME}/.bashrc"
		dotnet --version
	fi
}

## nodejs
install_nodejs() {
	if test -x "$(command -v node)"; then
		message "NodeJS has installed"
		node --version
		return
	fi

	if [ -e "${node_path}" ]; then
		echo -e "\n\nInstalling NodeJS\n"
		bash ${node_path}
		source "${HOME}/.bashrc"
		node --version
	fi
}

## deno
install_deno() {
	if test -x "$(command -v deno)"; then
		message "deno has installed"
		deno --version
		return
	fi

	if [ -e "${deno_path}" ]; then
		echo -e "\n\nInstalling Deno\n"
		bash ${deno_path}
		source "${HOME}/.bashrc"
		deno --version
	fi
}

## rust
install_rust() {
	if test -x "$(command -v rustc)"; then
		message "Rust has installed"
		rustc --version
		return
	fi

	if [ -e "${rust_path}" ]; then
		echo -e "\n\nInstalling Rust\n"
		bash ${rust_path}
		source "${HOME}/.bashrc"
		rustc --version
	fi
}

## docker
install_docker() {
	if test -x "$(command -v docker)"; then
		message "Docker has installed"
		docker --version
		return
	fi

	if [ -e "${docker_path}" ]; then
		echo -e "\n\nInstalling Docker\n"
		bash ${docker_path}
		source "${HOME}/.bashrc"
		docker --version
	fi
}

## python
install_python() {
	if test ! -x "$(command -v python3)"; then
		message "Python3 is not installed"
		return
	fi

	if [ -e "${python_path}" ]; then
		echo -e "\n\nInstalling Python\n"
		bash ${python_path}
		source "${HOME}/.bashrc"
		python3 --version
	fi	
}

## composer
install_composer() {
	if test ! -x "$(command -v php)"; then
		message "PHP is not installed"
		return
	fi

	if [ -e "${composer_path}" ]; then
		echo -e "\n\nInstalling Composer\n"
		bash ${composer_path}
		composer --version
	fi		
}

main() {
	init_os
	install_dl_command
	load_vars

	install_golang

	install_nodejs

	install_deno

	install_python

	install_dotnet

	## need root
	install_composer
	install_docker

	## need enter any key
	install_rust
}

main "$@" || exit 1
