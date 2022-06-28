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
