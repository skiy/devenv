#!/usr/bin/env bash

load_vars() {
    MIRROR_COMPOSER="https://mirrors.aliyun.com/composer/"

    COMPOSER_DOWNLOAD_URL="https://mirrors.aliyun.com/composer/composer.phar"
    COMPOSER_PATH="/usr/local/bin/composer"
}

set_environment() {
    if [ -z "`grep '\$HOME/.config/composer/vendor/bin' ${PROFILE}`" ];then
        echo -e "\n## PHP" >> "${PROFILE}"
        echo "export PATH=\"\$PATH:\$HOME/.config/composer/vendor/bin\"" >> "${PROFILE}"
    fi  
}

latest_version() {
    RELEASE_TAG=$(curl -sL https://getcomposer.org | sed -n '/latest/p' | head -n 1 | cut -d '<' -f 3 | cut -d '>' -f 2)
}

show_info() {
    composer --version
}

set_mirror() {
    if [ -n "${IN_CHINA}" ]; then
        composer config -g repo.packagist composer "${MIRROR_COMPOSER}"
    fi
}

install() {
     if [ "${OS}" = "darwin" ]; then
        brew install composer
        return
     fi

    if [ -z "${IN_CHINA}" ]; then
        latest_version

        COMPOSER_DOWNLOAD_URL="https://getcomposer.org/download/${RELEASE_TAG}/composer.phar"
    fi

	if [ ! -f "${COMPOSER_PATH}" ]; then
        sudo curl -o "${COMPOSER_PATH}" -fsL "${COMPOSER_DOWNLOAD_URL}"
        sudo chmod +x "${COMPOSER_PATH}"
    fi	
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

	if ! command_exists php; then
		err_message "PHP is not installed"
		return
	fi

	load_vars

    set_environment

	if command_exists composer; then
		pass_message "composer has installed"
        set_mirror

        if [ -z "${1}" ]; then
    		show_info
		    return
        fi
	else
        install
    fi	

    set_mirror
    
    show_info
}

main "$@" || exit 1
