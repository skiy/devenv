#!/usr/bin/env bash
#########################################################
# Function : Flutter Install                            #
# Platform : Linux                                      #
# Version  : 1.0.1                                      #
# Date     : 2022-08-24                                 #
# Author   : Jetsung Chan                               #
# Contact  : jetsungchan@gmail.com                      #
#########################################################

load_vars() {
    STORAGE_BASE_URL="https://storage.googleapis.com/"

    FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn/"
    PUB_HOSTED_URL="https://pub.flutter-io.cn"
}

install() {
    get_latest_github "flutter/flutter"
    LATEST_VERSION=$(get_latest_github "flutter/flutter")

    local ArchOS="linux"
    [ "${OS}" = "darwin" ] && ArchOS="macos"

    if [ -n "${IN_CHINA}" ]; then
        PROJECT_URL_JSON="${FLUTTER_STORAGE_BASE_URL}flutter_infra_release/releases/releases_${ArchOS}.json"
        STORAGE_BASE_URL="${FLUTTER_STORAGE_BASE_URL}"
    else
        PROJECT_URL_JSON="${STORAGE_BASE_URL}flutter_infra_release/releases/releases_${ArchOS}.json"
    fi

    FILE_URI=$(curl -sL "${PROJECT_URL_JSON}" \
        | sed 's/,/\n/g' \
        | grep 'stable' \
        | grep 'archive' \
        | sed 's/:/\n/g' \
        | grep -v archive)

    if [ "${ARCH}" = "x64" ]; then
        FILE_URI=$(echo ${FILE_URI} \
            | sed 's/ /\n/g' \
            | grep -v arm \
            | head -n 1 \
            | sed 's/"//g')
    else
        FILE_URI=$(echo ${FILE_URI} \
            | sed 's/ /\n/g' \
            | grep arm \
            | head -n 1 \
            | sed 's/"//g')
    fi

    DOWNLOWD_URL="${STORAGE_BASE_URL}flutter_infra_release/releases/${FILE_URI}"

    local TMPFILE="/tmp/flutter.tar.xz"
    [ "${OS}" = "darwin" ] && TMPFILE="/tmp/flutter.zip"

    [ -f "${TMPFILE}" ] || curl -sL -o "${TMPFILE}" "${DOWNLOWD_URL}"
    [ -f "${TMPFILE}" ] || err_message "No Found ${TMPFILE}"

    cd /tmp
    if [ "${OS}" = "darwin" ]; then
        unzip -qq ${TMPFILE}
    else
        tar -xJf ${TMPFILE} 
    fi
    mv flutter "${HOME}/.flutter"
}

set_environment() {
    if [ -z "`grep '## Flutter' ${PROFILE}`" ];then
            echo -e "\n## Flutter" >> ${PROFILE}
    fi

    if [ -n "${IN_CHINA}" ]; then
        if [ -z "`grep 'export\sFLUTTER_STORAGE_BASE_URL' ${PROFILE}`" ];then
            echo "export FLUTTER_STORAGE_BASE_URL=\"${FLUTTER_STORAGE_BASE_URL}\"" >> ${PROFILE}
        else
            sedi "s@^export FLUTTER_STORAGE_BASE_URL.*@export FLUTTER_STORAGE_BASE_URL=\"${FLUTTER_STORAGE_BASE_URL}\"@" "${PROFILE}"
        fi
        
        if [ -z "`grep 'export\sPUB_HOSTED_URL' ${PROFILE}`" ];then
            echo "export PUB_HOSTED_URL=\"${PUB_HOSTED_URL}\"" >> ${PROFILE}
        else
            sedi "s@^export PUB_HOSTED_URL.*@export PUB_HOSTED_URL=\"${PUB_HOSTED_URL}\"@" "${PROFILE}"
        fi
    fi

    if [ -z "`grep 'export\sPATH=\"\$PATH:\$HOME/.flutter/bin\"' ${PROFILE}`" ];then
        echo "export PATH=\"\$PATH:\$HOME/.flutter/bin\"" >> ${PROFILE}
    fi
}

show_info() {
    source "${PROFILE}"

    flutter --version
}

load_include() {
    realpath=$(dirname "`readlink -f $0`")
	include_tmp_path="/tmp/include_devenv.sh"
	include_file_url="https://jihulab.com/jetsung/devenv/raw/main/sh/include.sh"
	if [ -f "${realpath}/include.sh" ]; then
    	. ${realpath}/include.sh
	elif [ -f "${include_tmp_path}" ]; then
		. "${include_tmp_path}"
	else
		curl -sL -o "${include_tmp_path}" "${include_file_url}"
		[ -f "${include_tmp_path}" ] && . "${include_tmp_path}"
	fi
}

main() {
	load_include
    load_vars

    [ "${1}" = "upgrade" ] && rm -rf "${HOME}/.flutter"

    set_environment
    source "${PROFILE}"

	if command_exists flutter; then
		pass_message "Flutter has installed"

        if [ -z "${1}" ]; then
    		show_info
		    return
        fi
	else
        install
    fi

    show_info
}

main "$@" || exit 1