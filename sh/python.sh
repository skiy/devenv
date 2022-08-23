#!/usr/bin/env bash

load_vars() {
    # mirrors.bfsu.edu.cn/pypi/web
    # pypi.tuna.tsinghua.edu.cn
    MIRROR_PYTHON="mirrors.bfsu.edu.cn/pypi/web"
}

set_environment() {
    if [ "${PKG_TOOL_NAME}" = "apt" ]; then  
        if test -x "$(dpkg -l | grep python3-distutils)"; then
            sudo apt install -y python3-distutils
        fi
    fi

    if ! command_exists pip3; then
        curl -fSL https://bootstrap.pypa.io/get-pip.py | sudo python3
    fi

    if command_exists pip3; then
        if [ -n "${IN_CHINA}" ]; then
            # pip3 install pip -U
            pip3 install -i "https://${MIRROR_PYTHON}/simple" pip -U  
            pip3 config set global.index-url "https://${MIRROR_PYTHON}/simple" --trusted-host ${MIRROR_PYTHON}
        fi    
    fi
}

show_info() {
    source "${PROFILE}"

	python3 --version
}

install() {
    if ! command_exists python3; then
        if [ "${PKG_TOOL_NAME}" = "yum" ]; then  
            sudo yum install -y python3
        elif [ "${PKG_TOOL_NAME}" = "apt" ]; then  
            sudo apt install -y python3
        elif [ "${PKG_TOOL_NAME}" = "brew" ]; then  
            brew install python3            
        else 
            err_message "What's pkg manager tool?"
            exit 1
        fi	
    fi
}

install_conda() {
    # http://mirrors.aliyun.com/anaconda
    # https://mirrors.bfsu.edu.cn/anaconda
    # https://mirrors.tuna.tsinghua.edu.cn/anaconda
    local RepoURL
    [ "${IN_CHINA}" == "1" ] && RepoURL="https://mirrors.bfsu.edu.cn/anaconda"

    if command_exists conda; then
        conda_channel_mirror "${RepoURL}"
        return
    fi

    local Arch="x86_64"
    local ArchOS="Linux"
    local Version="2022.05"
    local RepoURL="https://repo.anaconda.com"

    [ "${OS}" = "darwin" ] && ArchOS="MacOSX"
    [ "${ARCH}" = "arm64" ] && Arch="arm64"

    local AnacondaURL="${RepoURL}/archive/Anaconda3-${Version}-${ArchOS}-${Arch}.sh"
    local TMPFILE="/tmp/anaconda.sh"

    if [ ! -f "${TMPFILE}" ]; then
        #   echo "Save file to ${TMPFILE}"
        curl -sL -o "${TMPFILE}" "${AnacondaURL}"
    fi

    bash ${TMPFILE} 

    [ -f "${HOME}/.bash_profile" ] && source "${HOME}/.bash_profile"
    conda_channel_mirror "${RepoURL}"
}

conda_channel_mirror() {
    conda --version
    conda init $(basename $SHELL)

    local RepoURL="${1}"

    # set channels mirror
    conda config --set show_channel_urls true

    conda config --remove-key default_channels
    conda config --add default_channels.0 "${RepoURL}/pkgs/main"
    conda config --add default_channels.1 "${RepoURL}/pkgs/r"
    conda config --add default_channels.2 "${RepoURL}/pkgs/msys2"

    conda config --remove-key custom_channels
    conda config --set custom_channels.conda-forge "${RepoURL}/cloud"
    conda config --set custom_channels.msys2 "${RepoURL}/cloud"
    conda config --set custom_channels.bioconda "${RepoURL}/cloud"
    conda config --set custom_channels.menpo "${RepoURL}/cloud"
    conda config --set custom_channels.pytorch "${RepoURL}/cloud"
    conda config --set custom_channels.pytorch-lts "${RepoURL}/cloud"
    conda config --set custom_channels.simpleitk "${RepoURL}/cloud"

    conda clean -i    
    conda config --show-sources
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

    set_environment

	if command_exists python3; then
		pass_message "Python has installed"

        install_conda

        if [ -z "${1}" ]; then
    		show_info
		    return
        fi
	else
        install
    fi

    install_conda

    show_info
}

main "$@" || exit 1
