#!/bin/bash

# Node-Install
# Project Home Page:
# https://github.com/jetsung/devenv
# https://jihulab.com/jetsung/devenv
#
# Author: Jetsung Chan <skiy@jetsung.com>

load_vars() {
    # Mirror ustc
    USTC_MIRROR="https://mirrors.ustc.edu.cn"
    NVM_NODEJS_ORG_MIRROR="${USTC_MIRROR}/node/"
    NODE_MIRROR="${USTC_MIRROR}/node/"

    # Official Download url
    DOWNLOAD_URL="https://nodejs.org/dist/"

    # Is GWF
    IN_CHINA=0

    # Set environmental
    PROFILE="${HOME}/.bashrc"

    # Set NODE PATH
    NODE_PATH="\$HOME/.node"    
}

# check in china
check_in_china() {
    urlstatus=$(curl -s -m 3 -IL https://google.com | grep 200)
    if [ "$urlstatus" == "" ]; then
        IN_CHINA=1
        DOWNLOAD_URL=${NODE_MIRROR}
    fi
}

# init arch
init_arch() {
    ARCH=$(uname -m)
    BIT=$ARCH
    case $ARCH in
        amd64) ARCH="x64";;
        x86_64) ARCH="x64";;
        armv7l) ARCH="armv7l";; 
        arm64) ARCH="arm64";; 
        *) printf "\e[1;31mArchitecture %s is not supported by this installation script\e[0m\n" $ARCH; exit 1;;
    esac
    echo "ARCH = ${ARCH}"
}

# get os
init_os() {
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    case $OS in
        darwin) OS='darwin';;
        linux) OS='linux';;
        freebsd) OS='freebsd';;
        *) printf "\e[1;31mOS %s is not supported by this installation script\e[0m\n" $OS; exit 1;;
    esac
    echo "OS = ${OS}"
}

init_args() {
    custom_version "${1}"
}

# custom version
custom_version() {
    if [ -n "${1}" ] ;then
        RELEASE_TAG="v${1}"
        echo "Custom Version = ${RELEASE_TAG}"
    fi
}

# if RELEASE_TAG was not provided, assume latest
latest_version() {
    if [ -z "${RELEASE_TAG}" ]; then
        RELEASE_TAG="$(curl -sL https://nodejs.org/en/ | sed -n '/home-downloadbutton/p' | head -n 1 | cut -d '"' -f 8)"
        echo "Latest Version = ${RELEASE_TAG}"
    fi
}

# compare version
compare_version() {
    OLD_VERSION="none"
    NEW_VERSION="${RELEASE_TAG}"
    if test -x "$(command -v node)"; then
        OLD_VERSION="$(node --version)"
    fi
    if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
       printf "\n\e[1;31mYou have installed this version: %s\e[0m\n" $OLD_VERSION; exit 1;
    fi

printf "
Current version: \e[1;33m %s \e[0m 
Target version: \e[1;33m %s \e[0m
" $OLD_VERSION $NEW_VERSION
}

# install curl command
install_curl_command() {
    if !(test -x "$(command -v curl)"); then
        if test -x "$(command -v yum)"; then
            yum install -y curl
        elif test -x "$(command -v apt)"; then
            apt install -y curl
        else 
            printf "\e[1;31mYou must pre-install the curl tool\e[0m\n"
            exit 1
        fi
    fi  
}

# download file
download_file() {
    url="${1}"
    destination="${2}"

    printf "Fetching ${url} \n\n"

    if test -x "$(command -v curl)"; then
        code=$(curl --connect-timeout 15 -w '%{http_code}' -L "${url}" -o "${destination}")
    elif test -x "$(command -v wget)"; then
        code=$(wget -t2 -T15 -O "${destination}" --server-response "${url}" 2>&1 | awk '/^  HTTP/{print $2}' | tail -1)
    else
        printf "\e[1;31mNeither curl nor wget was available to perform http requests.\e[0m\n"
        exit 1
    fi

    if [ "${code}" != 200 ]; then
        printf "\e[1;31mRequest failed with code %s\e[0m\n" $code
        exit 1
    else 
	    printf "\n\e[1;33mDownload succeeded\e[0m\n"
    fi
}

# show copyright
show_copyright() {
    clear

printf "
###############################################################
###
###  NodeJS Install
###
###############################################################
\n"
}

# show system information
show_system_information() {
printf "
###############################################################
###  System: %s 
###  Bit: %s 
###  Version: %s 
###############################################################
\n" $OS $BIT $RELEASE_TAG
}

# show success message
show_success_message() {
printf "
###############################################################
# Install success, please execute again \e[1;33msource %s\e[0m
###############################################################
\n" $PROFILE
}

# set environment
set_environment() {
    if [ -z "`grep '## NODE' ${PROFILE}`" ];then
            echo -e "\n## NODE" >> $PROFILE
    fi

    if [ "${IN_CHINA}" == "1" ]; then 
        if [ -z "`grep 'export\sNVM_NODEJS_ORG_MIRROR' ${PROFILE}`" ];then
            echo "export NVM_NODEJS_ORG_MIRROR=\"${NVM_NODEJS_ORG_MIRROR}\"" >> $PROFILE
        fi

        if [ -z "`grep 'export\sNODE_MIRROR' ${PROFILE}`" ];then
            echo "export NODE_MIRROR=\"${NODE_MIRROR}\"" >> $PROFILE
        fi
    fi
    
    if [ -z "`grep 'export\sNODE_INSTALL' ${PROFILE}`" ];then
        echo "export NODE_INSTALL=\"${NODE_PATH}\"" >> $PROFILE
    else
        sed -i "" -e "s@^export NODE_INSTALL.*@export NODE_INSTALL=\"${NODE_PATH}\"@" $PROFILE
    fi

    if [ -z "`grep 'export\sPATH=\"\$NODE_INSTALL/bin:\$PATH\"' ${PROFILE}`" ];then
        echo "export PATH=\"\$PATH:\$NODE_INSTALL/bin\"" >> $PROFILE
    fi
}

# set cnpm cdn
## https://npmmirror.com/
set_cnpm_cdn() {
    source "${PROFILE}"

    # installl new npm
    npm install -g npm 

    if [ "${IN_CHINA}" == "1" ]; then 
    NPM_URL="https://registry.npmmirror.com"

    printf "
###############################################################
# Setting Chinese Registry: %s
###############################################################
npm config set registry %s
\n" "${NPM_URL}" "${NPM_URL}"
        npm config set registry https://registry.npmmirror.com "${NPM_URL}"
    fi
}

###################### Script Start ################################################
main() {
    load_vars
    
    init_args "$@"

    show_copyright

    check_in_china

    set -e

    init_arch

    init_os

    install_curl_command

    latest_version

    custom_version

    show_system_information

    # Download File
    BINARY_URL="${DOWNLOAD_URL}${RELEASE_TAG}/node-${RELEASE_TAG}-${OS}-${ARCH}.tar.xz"
    DOWNLOAD_FILE="$(mktemp).tar.gz"
    download_file $BINARY_URL $DOWNLOAD_FILE

    # Tar file and move file
    #rm -rf ${HOME}/.node  

    if test $(which /usr/bin/apt); then
        apt install tar xz-utils
    fi

    if [ ! -d "${HOME}/.node" ]; then
        mkdir "${HOME}/.node"
    fi

    tar -xJf ${DOWNLOAD_FILE}
    cp -r node-${RELEASE_TAG}-${OS}-${ARCH}/* ${HOME}/.node 
    rm -rf node-${RELEASE_TAG}-${OS}-${ARCH} $DOWNLOAD_FILE

    set_environment

    set_cnpm_cdn

    npm config list

    printf "
npm version: %s
node version: %s
" $(npm --version) $(node --version)

    show_success_message
}

main "$@" || exit 1