#!/bin/bash

load_vars() {
    MIRROR_PYTHON="pypi.tuna.tsinghua.edu.cn"
}

set_environment() {
    if test -x "$(dpkg -l | grep python3-distutils)"; then
        if [ "${PKG_TOOL_NAME}" = "apt" ]; then  
            sudo apt install -y python3-distutils
        fi
    fi

    if ! command_exists pip; then
        curl -fSL https://bootstrap.pypa.io/get-pip.py | sudo python3
    fi

    if command_exists pip; then
        if [ "${IN_CHINA}" == "1" ]; then
            # pip install pip -U
            pip install -i "https://${MIRROR_PYTHON}/simple" pip -U  
            pip config set global.index-url "https://${MIRROR_PYTHON}/simple" --trusted-host ${MIRROR_PYTHON}
        fi    
    fi
}

install() {
    if ! command_exists python3; then
        if [ "${PKG_TOOL_NAME}" = "yum" ]; then  
            sudo yum install -y python3
        elif [ "${PKG_TOOL_NAME}" = "apt" ]; then  
            sudo apt install -y python3
        else 
            err_message "What's pkg manager tool?"
            exit 1
        fi	
    fi
}

main() {
    realpath=$(dirname "`readlink -f $0`")
    . ${realpath}/include.sh

	load_vars

	if command_exists python3; then
		pass_message "Python has installed"

        if [ "${1}x" = "x" ]; then
		    python3 --version
		    return
        fi
	else
        install
    fi

	set_environment
}

main "$@" || exit 1
