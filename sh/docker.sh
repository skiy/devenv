#!/usr/bin/env bash

load_vars() {
    MIRROR_DOCKER='"https://05f073ad3c0010ea0f4bc00b7105ec20.mirror.swr.myhuaweicloud.com","https://mirror.ccs.tencentyun.com","http://f1361db2.m.daocloud.io", "http://hub-mirror.c.163.com"'
}

set_environment() {
    if [[ $(id -u) -eq 0 ]]; then
        set_environment_root
    else
        set_environment_rootless
    fi

    [[ -n "${1}" ]] || show_info
}

set_environment_root() {
    if [[ -n "${IN_CHINA}" ]]; then
        [[ -d /etc/docker ]] || mkdir -p /etc/docker
        tee /etc/docker/daemon.json >/dev/null 2>&1 <<-EOF
{
  "registry-mirrors": [${MIRROR_DOCKER}]
}
EOF

        systemctl daemon-reload
        systemctl restart docker    
    fi
}

set_environment_rootless() {
    if [[ -n "${IN_CHINA}" ]]; then
        [[ -d /etc/docker ]] || mkdir -p ${HOME}/.config/docker
        tee ${HOME}/.config/docker/daemon.json >/dev/null 2>&1 <<-EOF
{
  "registry-mirrors": [${MIRROR_DOCKER}]
}
EOF

        systemctl --user restart docker    
    fi
}

show_info() {
    docker info
}

install() {
    if [[ -n "${IN_CHINA}" ]]; then 
        curl -fsSL https://get.docker.com | sudo bash -s docker --mirror Aliyun
    else
        curl -s https://get.docker.com/ | sudo bash
    fi

    # rootless
    if [[ $(id -u) -ne 0 ]]; then
        dockerd-rootless-setuptool.sh install
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

    if [[ "${OS}" != "linux" ]]; then
        err_message "Only support linux. \nYour OS: ${OS}"
        exit 1
    fi

	if command_exists docker; then
		pass_message "Docker has installed"

        if [[ -z "${1}" ]]; then
    		show_info
		    exit
        fi
	else
        install
    fi	

    set_environment "${1}"
}

main $@ || exit 1