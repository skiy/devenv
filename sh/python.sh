#!/usr/bin/env bash

load_vars() {
    # mirrors.bfsu.edu.cn/pypi/web
    # pypi.tuna.tsinghua.edu.cn
    MIRROR_PYTHON="mirrors.bfsu.edu.cn/pypi/web"
}

set_environment() {
    if command_exists pip; then
        if [ -n "${IN_CHINA}" ]; then
            # pip install pip -U
            pip install -i "https://${MIRROR_PYTHON}/simple" pip -U  
            pip config set global.index-url "https://${MIRROR_PYTHON}/simple" --trusted-host ${MIRROR_PYTHON}
        fi    
    fi

    [[ -z "${1}" ]] || show_info
}


show_info() {
    source ${PROFILE}
	python3 --version
}

install_conda() {
    # http://mirrors.aliyun.com/anaconda
    # https://mirrors.bfsu.edu.cn/anaconda
    # https://mirrors.tuna.tsinghua.edu.cn/anaconda

    echo "Anaconda installing"

    local RepoURL
    [[ -n "${IN_CHINA}" ]] && RepoURL="https://mirrors.bfsu.edu.cn/anaconda"

    if command_exists conda; then
        conda_channel_mirror "${RepoURL}"
        return
    fi

    local Arch="x86_64"
    local ArchOS="Linux"
    local Version="2022.10"
    local RepoURL="https://repo.anaconda.com"

    [[ "${OS}" == "darwin" ]] && ArchOS="MacOSX"
    [[ "${ARCH}" == "arm64" ]] && Arch="arm64"

    local AnacondaURL="${RepoURL}/archive/Anaconda3-${Version}-${ArchOS}-${Arch}.sh"
    local TMPFILE="/tmp/anaconda.sh"

    if [[ ! -f "${TMPFILE}" ]]; then
        # echo "Save file to ${TMPFILE}"
        curl -fL "${AnacondaURL}" -o "${TMPFILE}"
    fi

    ${SHELL} ${TMPFILE} 

    source ${PROFILE}
    if ! command_exists conda; then
        echo "not found conda"
        return
    fi
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

    show_info
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

	set_environment
	source ${PROFILE}

    install_conda
    set_environment
}

main $@ || exit 1
