#/bin/bash

# check_in_china
check_in_china() {
    urlstatus=$(curl -s -m 3 -IL https://google.com | grep 200)
    if [ "$urlstatus" == "" ]; then
        IN_CHINA=1
    fi
}

main() {
    IN_CHINA=0

    check_in_china

    PIP_CONF_PATH=$HOME/.pip/

    if [ "${IN_CHINA}" == "1" ]; then
        if [ ! -d $PIP_CONF_PATH ]; then
            mkdir $PIP_CONF_PATH
        fi

        tee "${PIP_CONF_PATH}/pip.conf" <<-'EOF'
[global]
timeout = 6000
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
    fi    
}

main "$@"