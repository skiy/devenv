#!/usr/bin/env bash
#########################################################
# Function : NodeJS Install                             #
# Platform : Linux                                      #
# Version  : 1.0.0                                      #
# Date     : 2022-05-18                                 #
# Author   : Jetsung Chan                               #
# Contact  : jetsungchan@gmail.com                      #
#########################################################

load_vars() {
    # Set environmental
    PROFILE="${HOME}/.bashrc"

    MIRROR_SERVER="https://mirrors.ustc.edu.cn"
    NVM_NODEJS_ORG_MIRROR="${MIRROR_SERVER}/node/"
    MIRROR_NODE="${MIRROR_SERVER}/node/"

    # Official Download url
    DOWNLOAD_URL="https://nodejs.org/dist/"

    NPM_URL="https://registry.npmmirror.com"

    # Set NODE PATH
    NODE_PATH="\$HOME/.node" 
}

# https://mirrors.ustc.edu.cn/help/dockerhub.html
set_environment() {
    # installl new npm
    npm install -g npm 

    if [[ "${IN_CHINA}" == "1" ]]; then
        npm config set registry "${NPM_URL}"
    fi

    if [[ -z "`grep '## NODE' ${PROFILE}`" ]];then
            echo -e "\n## NODE" >> ${PROFILE}
    fi

    if [[ "${IN_CHINA}" == "1" ]]; then 
        if [[ -z "`grep 'export\sNVM_NODEJS_ORG_MIRROR' ${PROFILE}`" ]];then
            echo "export NVM_NODEJS_ORG_MIRROR=\"${NVM_NODEJS_ORG_MIRROR}\"" >> ${PROFILE}
        fi

        if [[ -z "`grep 'export\sNODE_MIRROR' ${PROFILE}`" ]];then
            echo "export NODE_MIRROR=\"${NODE_MIRROR}\"" >> ${PROFILE}
        fi
    fi
    
    if [[ -z "`grep 'export\sNODE_INSTALL' ${PROFILE}`" ]];then
        echo "export NODE_INSTALL=\"${NODE_PATH}\"" >> ${PROFILE}
    else
        sed -i "s@^export NODE_INSTALL.*@export NODE_INSTALL=\"${NODE_PATH}\"@" $PROFILE
    fi

    if [[ -z "`grep 'export\sPATH=\"\$PATH:\$NODE_INSTALL/bin\"' ${PROFILE}`" ]];then
        echo "export PATH=\"\$PATH:\$NODE_INSTALL/bin\"" >> ${PROFILE}
    fi

    [[ -n "${1}" ]] || show_info
}

# if RELEASE_TAG was not provided, assume latest
latest_version() {
    if [[ -z "${RELEASE_TAG}" ]]; then
        RELEASE_TAG="$(curl -sL https://nodejs.org/en/ | sed -n '/home-downloadbutton/p' | head -n 1 | cut -d '"' -f 8)"
    fi
}

install() {
    latest_version

    [[ -n "${IN_CHINA}" ]] && DOWNLOAD_URL="${MIRROR_NODE}"

    BINARY_URL="${DOWNLOAD_URL}${RELEASE_TAG}/node-${RELEASE_TAG}-${OS}-${ARCH}.tar.xz"
    DOWNLOAD_FILE="$(mktemp).tar.gz"
    download_file $BINARY_URL $DOWNLOAD_FILE

    if [ "${PKG_TOOL_NAME}" = "apt" ]; then  
        if test -x "$(dpkg -l | grep tar)"; then
            sudo apt install -y tar
        fi

        if test -x "$(dpkg -l | grep xz-utils)"; then
            sudo apt install -y xz-utils
        fi
    fi

    if [[ ! -d "${HOME}/.node" ]]; then
        mkdir "${HOME}/.node"
    fi

    tar -xJf ${DOWNLOAD_FILE}
    cp -r node-${RELEASE_TAG}-${OS}-${ARCH}/* ${HOME}/.node 
    rm -rf node-${RELEASE_TAG}-${OS}-${ARCH} $DOWNLOAD_FILE
}

show_info() {
    source "${PROFILE}"

    npm config list
#     printf "
# npm version: %s
# node version: %s
# " $(npm --version) $(node --version)
}

main () {
    realpath=$(dirname "`readlink -f $0`")
    . ${realpath}/include.sh

	load_vars

    [[ "${1}" = "upgrade" ]] && rm -rf "${HOME}/.node"

	if command_exists node; then
		pass_message "Node has installed"

        if [[ -z "${1}" ]]; then
    		show_info
		    return
        fi
	else
        install
    fi	

    set_environment "${1}"
}

main "$@" || exit 1