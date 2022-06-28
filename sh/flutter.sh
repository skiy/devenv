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

    STORAGE_BASE_URL="https://storage.googleapis.com/"

    FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn/"
    PUB_HOSTED_URL="https://pub.flutter-io.cn"
}

install() {
    get_latest_github "flutter/flutter"
    LATEST_VERSION=$(get_latest_github "flutter/flutter")

    if [[ -n "${IN_CHINA}" ]]; then
        PROJECT_URL_JSON="${FLUTTER_STORAGE_BASE_URL}flutter_infra_release/releases/releases_linux.json"
        STORAGE_BASE_URL="${FLUTTER_STORAGE_BASE_URL}"
    else
        PROJECT_URL_JSON="${STORAGE_BASE_URL}flutter_infra_release/releases/releases_linux.json"
    fi

    FILE_URI=$(curl -sL "${PROJECT_URL_JSON}" \
        | head -n 20 \
        | sed 's/,/\n/g' \
        | grep 'archive' \
        | sed 's/:/\n/g' \
        | sed 1d \
        | sed 's/"//g' \
        | sed 's/ //g')

    DOWNLOWD_URL="${STORAGE_BASE_URL}flutter_infra_release/releases/${FILE_URI}"
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

    if [[ -n "${IN_CHINA}" ]]; then
        if [[ -z "`grep 'export\sFLUTTER_STORAGE_BASE_URL' ${PROFILE}`" ]];then
            echo "export FLUTTER_STORAGE_BASE_URL=\"${FLUTTER_STORAGE_BASE_URL}\"" >> ${PROFILE}
        fi  

        if [[ -z "`grep 'export\sPUB_HOSTED_URL' ${PROFILE}`" ]];then
            echo "export PUB_HOSTED_URL=\"${PUB_HOSTED_URL}\"" >> ${PROFILE}
        fi  
    fi

    if [[ -z "`grep 'export\sPATH=\"\$PATH:\$HOME/.flutter/bin\"' ${PROFILE}`" ]];then
        echo "export PATH=\"\$PATH:\$HOME/.flutter/bin\"" >> ${PROFILE}
    fi

    [[ -n "${1}" ]] || show_info
}

show_info() {
    source "${PROFILE}"

    flutter --version
}

load_include() {
    realpath=$(dirname "`readlink -f $0`")

	include_tmp_path="/tmp/include_devenv.sh"
	include_file_url="https://jihulab.com/jetsung/devenv/raw/main/sh/include.sh"
	if [[ -f "${realpath}/include.sh" ]]; then
    	. ${realpath}/include.sh
	elif [[ -f "${include_tmp_path}" ]]; then
		. "${include_tmp_path}"
	else
		curl -sL -o "${include_tmp_path}" "${include_file_url}"
		[[ -f "${include_tmp_path}" ]] && . "${include_tmp_path}"
	fi
}

main() {
	load_include

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

    set_environment "${1}"
}

main "$@" || exit 1