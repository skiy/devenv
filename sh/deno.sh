#!/bin/bash

load_vars() {
    # Set environmental
    PROFILE="${HOME}/.bashrc"

    # Set DENO PATH
    DENO_PATH="\$HOME/.deno"

    CHINA_MIRROR_URL="https://ghproxy.com/"
    INSTALL_URL="https://raw.githubusercontent.com/denoland/deno_install/master/install.sh"
}

set_environment() {
    if [ -z "`grep '## DENO' ${PROFILE}`" ];then
        echo -e "\n## DENO" >> $PROFILE
    fi

    if [ -z "`grep 'export\sDENO_INSTALL' ${PROFILE}`" ];then
        echo "export DENO_INSTALL=\"${DENO_PATH}\"" >> $PROFILE
    else
        sed -i "s@^export DENO_INSTALL.*@export DENO_INSTALL=\"${DENO_PATH}\"@" $PROFILE
    fi

    if [ -z "`grep 'export\sPATH=\"\$PATH:\$DENO_INSTALL/bin\"' ${PROFILE}`" ];then
        echo "export PATH=\"\$PATH:\$DENO_INSTALL/bin\"" >> $PROFILE
    fi
}

install() {
    if [ "${IN_CHINA}" == "1" ]; then
        trap 'rm -f "${TMPFILE}"' EXIT
        # echo "Save file to ${TMPFILE}"

        TMPFILE=$(mktemp) || exit 1

        curl -sL -o "${TMPFILE}" "${CHINA_MIRROR_URL}${BASH_URL}"
        sed -i "s@deno_uri=\"https://github.com@deno_uri=\"${CHINA_MIRROR_URL}https://github.com@" "${TMPFILE}"
        bash ${TMPFILE}
    else
        curl -fsL "${BASH_URL}" | bash
    fi
}

main() {
    realpath=$(dirname "`readlink -f $0`")
    . ${realpath}/include.sh

	load_vars

	if command_exists deno; then
		pass_message "deno has installed"

        if [ "${1}x" = "x" ]; then
    		deno --version
		    return
        fi
	else
        install
    fi	

    set_environment
}

main "$@" || exit 1