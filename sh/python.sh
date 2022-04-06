#!/bin/bash

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

    if !(test -x "$(command -v pip)"); then
        curl -fSL https://bootstrap.pypa.io/get-pip.py | sudo python
    fi

    if [ "${IN_CHINA}" == "1" ]; then
        # pip install pip -U
        pip install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U  
        pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
    fi    
}

main "$@"
