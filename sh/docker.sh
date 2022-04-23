#/bin/bash

load_vars() {
    MIRROR_DOCKER="https://docker.mirrors.ustc.edu.cn/"
}

# https://mirrors.ustc.edu.cn/help/dockerhub.html
set_environment() {
    if [ "${IN_CHINA}" == "1" ]; then

        sudo mkdir -p /etc/docker
        sudo tee /etc/docker/daemon.json <<-EOF
{
  "registry-mirrors": ["${MIRROR_DOCKER}"]
}
EOF

        sudo systemctl daemon-reload
        sudo systemctl restart docker    
    fi
}

install() {
    if [ "${IN_CHINA}" == "1" ]; then 
        curl -fsSL https://get.docker.com | sudo bash -s docker --mirror Aliyun
    else
        curl -s https://get.docker.com/ | sudo bash
    fi
}

main () {
    realpath=$(dirname "`readlink -f $0`")
    . ${realpath}/include.sh

	load_vars

    if [ "${OS}" != "linux" ]; then
        err_message "Only support linux. \nYour OS: ${OS}"
        exit 1
    fi

	if command_exists docker; then
		pass_message "Docker has installed"

        if [ "${1}x" = "x" ]; then
    		docker version
		    return
        fi
	else
        install
    fi	

    set_environment
}

main "$@" || exit 1