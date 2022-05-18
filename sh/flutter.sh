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

    SAVE_PATH="${HOME}/.flutter" 

    PROJECT_URL="https://storage.googleapis.com/"
    PROJECT_URL_CN="https://storage.flutter-io.cn/"
}

install() {
    get_latest_github "flutter/flutter"
    LATEST_VERSION=$(get_latest_github "flutter/flutter")
    echo ${LATEST_VERSION}

    if [[ -n "${IN_CHINA}" ]]; then
        PROJECT_URL_JSON="${PROJECT_URL_CN}flutter_infra_release/releases/releases_linux.json"
        PROJECT_URL="${PROJECT_URL_CN}"
    else
        PROJECT_URL_JSON="${PROJECT_URL}flutter_infra_release/releases/releases_linux.json"
    fi
    echo ${PROJECT_URL_JSON}

    FILE_URI=$(curl -sL "${PROJECT_URL_JSON}" \
        | head -n 20 \
        | sed 's/,/\n/g' \
        | grep 'archive' \
        | sed 's/:/\n/g' \
        | sed 1d \
        | sed 's/"//g' \
        | sed 's/ //g')

    DOWNLOWD_URL="${PROJECT_URL}flutter_infra_release/releases/${FILE_URI}"
    TMPFILE="/tmp/flutter.tar.xz"

    [[ -f "${TMPFILE}" ]] || curl -sL -o "${TMPFILE}" "${DOWNLOWD_URL}"

    [[ -f "${TMPFILE}" ]] || err_message "No Found ${TMPFILE}"

    cd /tmp
    tar -xJf ${TMPFILE} 
    mv flutter "${HOME}/.flutter"
}

set_environment() {
    if [[ -z "`grep '## Flutter' ${PROFILE}`" ]];then
            echo -e "\n## Flutter" >> ${PROFILE}
    fi

    if [[ -z "`grep 'export\sPATH=\"\$PATH:\$HOME/.flutter/bin\"' ${PROFILE}`" ]];then
        echo "export PATH=\"\$PATH:\$HOME/.flutter/bin\"" >> ${PROFILE}
    fi

    show_info
}

show_info() {
    source "${PROFILE}"

    flutter --version
}

main() {
    realpath=$(dirname "`readlink -f $0`")
    . ${realpath}/include.sh

    load_vars

    [[ "${1}" = "upgrade" ]] && rm -rf "${SAVE_PATH}"

	if command_exists flutter; then
		pass_message "flutter has installed"

        if [[ -z "${1}" ]]; then
    		show_info
		    return
        fi
	else
        install
    fi	

    set_environment
}

main "$@" || exit 1