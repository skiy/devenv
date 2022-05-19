#!/usr/bin/env bash

load_vars() {
    # Set environmental
    PROFILE="${HOME}/.bashrc"

    MIRROR_PYTHON="pypi.tuna.tsinghua.edu.cn"
}

set_environment() {
    if test -x "$(dpkg -l | grep python3-distutils)"; then
        if [[ "${PKG_TOOL_NAME}" = "apt" ]]; then  
            sudo apt install -y python3-distutils
        fi
    fi

    if ! command_exists pip; then
        curl -fSL https://bootstrap.pypa.io/get-pip.py | sudo python3
    fi

    if command_exists pip; then
        if [[ -n "${IN_CHINA}" ]]; then
            # pip install pip -U
            pip install -i "https://${MIRROR_PYTHON}/simple" pip -U  
            pip config set global.index-url "https://${MIRROR_PYTHON}/simple" --trusted-host ${MIRROR_PYTHON}
        fi    
    fi
}

show_info() {
    source "${PROFILE}"

	python3 --version
}

install() {
    if ! command_exists python3; then
        if [[ "${PKG_TOOL_NAME}" = "yum" ]]; then  
            sudo yum install -y python3
        elif [[ "${PKG_TOOL_NAME}" = "apt" ]]; then  
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
