#!/bin/bash

# get OS
get_os() {
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    case $OS in
        darwin) OS='darwin';;
        linux) OS='linux';;
        freebsd) OS='freebsd';;
#        mingw*) OS='windows';;
#        msys*) OS='windows';;
        *) printf "\e[1;31mOS %s is not supported by this installation script\e[0m\n" ${OS}; exit 1;;
    esac
}

# get Arch
get_arch() {
    ARCH=$(uname -m)
    ARCH_BIT="${ARCH}"
    case "${ARCH}" in
        i386) ARCH="386";;
        amd64) ARCH="x64";;
        x86_64) ARCH="x64";;
        armv6l) ARCH="armv6l";; 
        armv7l) ARCH="armv7l";; 
        arm64) ARCH="arm64";; 
        aarch64) ARCH="arm64";; 
        *) printf "\e[1;31mArchitecture %s is not supported by this installation script\e[0m\n" ${ARCH}; exit 1;;
    esac
}

# pkg manager tool
pkg_manager_tool() {
	PKG_TOOL_NAME=""
	if command_exists yum; then  
		PKG_TOOL_NAME="yum"
	elif command_exists apt; then
		PKG_TOOL_NAME="apt"
	fi
}

# command_exists
command_exists() {
    which "$@" > /dev/null 2>&1
	# command -v "$@" > /dev/null 2>&1
}

# check in china
check_in_china() {
    urlstatus=$(curl -s -m 2 -IL https://google.com | grep 200)
    if [ "${urlstatus}"x == "x" ]; then
        IN_CHINA=1
    fi
}

# install curl,wget command
install_dl_command() {
    if ! command_exists curl; then
        if [ "${PKG_TOOL_NAME}" = "yum" ]; then  
            sudo yum install -y curl wget
        elif [ "${PKG_TOOL_NAME}" = "apt" ]; then  
            sudo apt install -y curl wget
        else 
            err_message "You must pre-install the curl,wget tool"
            exit 1
        fi
    fi  
}

# compare version size 
version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }

# download file
download_file() {
    url="${1}"
    destination="${2}"

    # printf "Fetching ${url} \n\n"

    if command_exists curl; then
        code=$(curl --connect-timeout 15 -w '%{http_code}' -L "${url}" -o "${destination}")
    elif command_exists wget; then
        code=$(wget -t2 -T15 -O "${destination}" --server-response "${url}" 2>&1 | awk '/^  HTTP/{print $2}' | tail -1)
    else
        printf "\e[1;31mNeither curl nor wget was available to perform http requests.\e[0m\n"
        exit 1
    fi

    if [ "${code}" != "200" ]; then
        printf "\e[1;31mRequest failed with code %s\e[0m\n" $code
        exit 1
    # else 
	#     printf "\n\e[1;33mDownload succeeded\e[0m\n"
    fi
}

# pass message
pass_message() {
	echo -e "\n\e[1;92m■■■ ${1} \e[0m"
}

# err message
err_message() {
	echo -e "\n\e[1;31m${1}\e[0m"
}

load() {
    if [ "${OS}x" = "x" ]; then  
        get_os
    fi

    if [ "${ARCH}x" = "x" ] || [ "${ARCH_BIT}x" = "x" ] ; then
        get_arch
    fi

    if [ "${PKG_TOOL_NAME}x" = "x" ]; then  
        pkg_manager_tool
    fi

    if [ "${IN_CHINA}x" = "x" ]; then
        check_in_china
    fi

    install_dl_command
}

load "$@"