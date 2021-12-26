#/bin/bash

# check_in_china
check_in_china() {
    urlstatus=$(curl -s -m 5 -IL https://google.com | grep 200)
    if [ "$urlstatus" == "" ]; then
        IN_CHINA=1
    fi
}

# https://mirrors.ustc.edu.cn/help/dockerhub.html
set_docker_mirror() {
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn/"]
}
EOF

    sudo systemctl daemon-reload
    sudo systemctl restart docker    
}

main () {
    IN_CHINA=0

    check_in_china

    if [ "${IN_CHINA}" == "1" ]; then 
        curl -fsSL https://get.docker.com | sudo bash -s docker --mirror Aliyun
        
        set_docker_mirror
    else
        curl -s https://get.docker.com/ | sudo sh
    fi
}

main "$@"