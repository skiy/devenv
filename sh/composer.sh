#!/bin/bash

# check in china
check_in_china() {
    urlstatus=$(curl -s -m 5 -IL https://google.com | grep 200)
    if [ "$urlstatus" == "" ]; then
        echo 0
    else
        echo 1
    fi
}

latest_version() {
    RELEASE_TAG=$(curl -sL https://getcomposer.org | sed -n '/latest/p' | head -n 1 | cut -d '<' -f 3 | cut -d '>' -f 2)
}

set_mirror() {
    composer_url="https://mirrors.aliyun.com/composer/composer.phar"
    

    if [ "${IN_CHINA}" == "0" ]; then
        latest_version

        composer_url="https://getcomposer.org/download/${RELEASE_TAG}/composer.phar"
    fi
}

main() {
    path="/usr/local/bin/composer"

    IN_CHINA=$(check_in_china)

    set_mirror
	
	if [ ! -f "${path}" ]; then
        sudo curl -o "${path}" "${composer_url}"
        sudo chmod +x "${path}"
    fi	

    if [ "${IN_CHINA}" == "0" ]; then
        composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
    fi
}

main "$@" || exit 1
