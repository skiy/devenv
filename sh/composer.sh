#!/bin/bash

load_vars() {
    PROFILE="${HOME}/.bashrc"
    
    MIRROR_COMPOSER="https://mirrors.aliyun.com/composer/"

    COMPOSER_DOWNLOAD_URL="https://mirrors.aliyun.com/composer/composer.phar"
    COMPOSER_PATH="/usr/local/bin/composer"
}

set_environment() {
    if [ "${IN_CHINA}" == "1" ]; then
        composer config -g repo.packagist composer "${MIRROR_COMPOSER}"
    fi

    if [ -z "`grep '\$HOME/.config/composer/vendor/bin' ${PROFILE}`" ];then
        echo -e "\n## PHP" >> "${PROFILE}"
        echo "export PATH=\"\$PATH:\$HOME/.config/composer/vendor/bin\"" >> "${PROFILE}"
    fi  
}

latest_version() {
    RELEASE_TAG=$(curl -sL https://getcomposer.org | sed -n '/latest/p' | head -n 1 | cut -d '<' -f 3 | cut -d '>' -f 2)
}

install() {
    if [ "${IN_CHINA}x" == "x" ]; then
        latest_version

        COMPOSER_DOWNLOAD_URL="https://getcomposer.org/download/${RELEASE_TAG}/composer.phar"
    fi

	if [ ! -f "${path}" ]; then
        sudo curl -o "${COMPOSER_PATH}" -fsL "${COMPOSER_DOWNLOAD_URL}"
        sudo chmod +x "${COMPOSER_PATH}"
    fi	
}

main() {
    realpath=$(dirname "`readlink -f $0`")
    . ${realpath}/include.sh

	if ! command_exists php; then
		err_message "PHP is not installed"
		return
	fi

	load_vars

	if command_exists composer; then
		pass_message "composer has installed"

        if [ "${1}x" = "x" ]; then
    		composer --version
		    return
        fi
	else
        install
    fi	

    set_environment
}

main "$@" || exit 1
