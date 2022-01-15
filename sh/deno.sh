#!/bin/bash

load_vars() {
    # Set environmental
    PROFILE="${HOME}/.bashrc"

    # Set DENO PATH
    DENO_PATH="\$HOME/.deno"

    # Is GWF
    IN_CHINA=0
}

# check_in_china
check_in_china() {
    urlstatus=$(curl -s -m 3 -IL https://google.com | grep 200)
    if [ "$urlstatus" == "" ]; then
        IN_CHINA=1
    fi
}

set_env() {
    if [ -z "`grep '## DENO' ${PROFILE}`" ];then
        echo -e "\n## DENO" >> $PROFILE
    fi

    if [ -z "`grep 'export\sDENO_INSTALL' ${PROFILE}`" ];then
        echo "export DENO_INSTALL=\"${DENO_PATH}\"" >> $PROFILE
    else
        sed -i "" -e "s@^export DENO_INSTALL.*@export DENO_INSTALL=\"${DENO_PATH}\"@" $PROFILE
    fi

    if [ -z "`grep 'export\sPATH=\"\$PATH:\$DENO_INSTALL/bin\"' ${PROFILE}`" ];then
        echo "export PATH=\"\$PATH:\$DENO_INSTALL/bin\"" >> $PROFILE
    fi
}

main() {
    load_vars

    set_env

    check_in_china

    BASH_URL="https://raw.githubusercontent.com/denoland/deno_install/master/install.sh"

    if [ "${IN_CHINA}" == "1" ]; then
        trap 'rm -f "${TMPFILE}"' EXIT
        # echo "Save file to ${TMPFILE}"

        TMPFILE=$(mktemp) || exit 1
        CHINA_MIRROR_URL="https://ghproxy.com/"

        curl -sL -o "${TMPFILE}" "${CHINA_MIRROR_URL}${BASH_URL}"
        sed -i "" -e "s@deno_uri=\"https://github.com@deno_uri=\"${CHINA_MIRROR_URL}https://github.com@" "${TMPFILE}"
        bash ${TMPFILE}
    else
        curl -fsL "${BASH_URL}" | sh
    fi
}

main "$@" || exit 1