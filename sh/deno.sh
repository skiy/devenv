#!/usr/bin/env bash

load_vars() {
    DENO_PATH="\$HOME/.deno"

    INSTALL_URL="https://raw.githubusercontent.com/denoland/deno_install/master/install.sh"
}

set_environment() {
    if [ -z "`grep '## DENO' ${PROFILE}`" ];then
        echo -e "\n## DENO" >> "${PROFILE}"
    fi

    if [ -z "`grep 'export\sDENO_INSTALL' ${PROFILE}`" ];then
        echo "export DENO_INSTALL=\"${DENO_PATH}\"" >> "${PROFILE}"
    else
        sedi "s@^export DENO_INSTALL.*@export DENO_INSTALL=\"${DENO_PATH}\"@" $PROFILE
    fi

    if [ -z "`grep 'export\sPATH=\"\$PATH:\$DENO_INSTALL/bin\"' ${PROFILE}`" ];then
        echo "export PATH=\"\$PATH:\$DENO_INSTALL/bin\"" >> "${PROFILE}"
    fi
}

show_info() {
    source "${PROFILE}"
    deno --version
}

install() {
    if [ -n "${IN_CHINA}" ]; then
        trap 'rm -f "${TMPFILE}"' EXIT
        # echo "Save file to ${TMPFILE}"

        TMPFILE=$(mktemp) || exit 1

        curl -sL -o "${TMPFILE}" "${CHINA_MIRROR_URL}${INSTALL_URL}"
        sedi "s@deno_uri=\"https://github.com@deno_uri=\"${CHINA_MIRROR_URL}https://github.com@" "${TMPFILE}"
        bash ${TMPFILE}
    else
        curl -fsL "${INSTALL_URL}" | bash
    fi
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

    [ "${1}" = "upgrade" ] && rm -rf "${HOME}/.deno"

    set_environment
    source "${PROFILE}"

	if command_exists deno; then
		pass_message "deno has installed"

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