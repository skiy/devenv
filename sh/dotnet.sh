#!/bin/bash

main() {
	# Set environmental
	PROFILE="${HOME}/.bashrc"

	# DOTNET_PATH
	DOTNET_ROOT="\$HOME/.dotnet"

	if [ -z "`grep '## DOTNET' ${PROFILE}`" ];then
			echo -e "\n## DOTNET" >> $PROFILE
	fi

	if [ -z "`grep 'export\sDOTNET_ROOT' ${PROFILE}`" ];then
		echo "export DOTNET_ROOT=\"${DOTNET_ROOT}\"" >> $PROFILE
	else
		sed -i "" -e "s@^export DOTNET_ROOT.*@export DOTNET_ROOT=\"${DOTNET_ROOT}\"@" $PROFILE
	fi

	if [ -z "`grep 'export\sPATH=\"\$DOTNET_ROOT:\$PATH\"' ${PROFILE}`" ];then
		echo "export PATH=\"\$PATH:\$DOTNET_ROOT\"" >> $PROFILE
	fi

	bash <(curl -fsSL https://dot.net/v1/dotnet-install.sh) -c 6.0
}

main "$@" || exit 1
