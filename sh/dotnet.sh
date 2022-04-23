#!/bin/bash

load_vars() {
	# Set environmental
	PROFILE="${HOME}/.bashrc"

	# DOTNET_PATH
	DOTNET_ROOT="\$HOME/.dotnet"

	INSTALL_URL="https://dot.net/v1"
}

install() {
	bash <(curl -fsSL ${INSTALL_URL}/dotnet-install.sh) -c 6.0
}

set_environment() {
	if [ -z "`grep '## DOTNET' ${PROFILE}`" ];then
			echo -e "\n## DOTNET" >> $PROFILE
	fi

	if [ -z "`grep 'export\sDOTNET_ROOT' ${PROFILE}`" ];then
		echo "export DOTNET_ROOT=\"${DOTNET_ROOT}\"" >> $PROFILE
	else
		sed -i "s@^export DOTNET_ROOT.*@export DOTNET_ROOT=\"${DOTNET_ROOT}\"@" $PROFILE
	fi

	if [ -z "`grep 'export\sPATH=\"\$PATH:\$DOTNET_ROOT\"' ${PROFILE}`" ];then
		echo "export PATH=\"\$PATH:\$DOTNET_ROOT\"" >> $PROFILE
	fi
}

main() {
    realpath=$(dirname "`readlink -f $0`")
    . ${realpath}/include.sh

	load_vars

	if command_exists dotnet; then
		pass_message "dotnet has installed"

        if [ "${1}x" = "x" ]; then
			dotnet --version
		    return
        fi
	else
        install
    fi	

	set_environment
}

main "$@" || exit 1
