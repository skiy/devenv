#!/usr/bin/env bash

load_vars() {
	DOTNET_PATH="\$HOME/.dotnet"
	INSTALL_URL="https://dot.net/v1"
}

show_info() {
	# shellcheck source=/dev/null
	source "${PROFILE}"
	printf "dotnet: %s\n" "$(dotnet --version)"
}

install() {
	VER="${1}"
	if [ -z "$VER" ]; then
		VER="7.0"
	fi
	curl -sSL "$INSTALL_URL/dotnet-install.sh" | bash /dev/stdin -c "$VER"
}

set_environment() {
	if ! grep -q '## DOTNET' "$PROFILE"; then
		echo -e "\n## DOTNET" >>"$PROFILE"
	fi

	if ! grep -q 'export\sDOTNET_ROOT' "$PROFILE"; then
		echo "export DOTNET_ROOT=\"${DOTNET_PATH}\"" >>"$PROFILE"
	else
		sedi "s@^export DOTNET_ROOT.*@export DOTNET_ROOT=\"${DOTNET_PATH}\"@" "$PROFILE"
	fi

	if ! grep -q "export\sPATH=\"\$PATH:\$DOTNET_ROOT\"" "$PROFILE"; then
		echo "export PATH=\"\$PATH:\$DOTNET_ROOT\"" >>"$PROFILE"
	fi

	[ -z "${1}" ] || show_info
}

load_include() {
	realpath=$(dirname "$(readlink -f "$0")")
	include_tmp_path="/tmp/include_devenv.sh"
	include_file_url="https://jihulab.com/jetsung/devenv/raw/main/sh/include.sh"

	if [[ -f "$realpath/include.sh" ]]; then
		# shellcheck source=/dev/null
		. "$realpath"/include.sh
	elif [[ -f "$include_tmp_path" ]]; then
		# shellcheck source=/dev/null
		. "$include_tmp_path"
	else
		curl -sL -o "$include_tmp_path" "$include_file_url"
		# shellcheck source=/dev/null
		[ -f "$include_tmp_path" ] && . "$include_tmp_path"
	fi
}

load_include
load_vars

[ "${1}" = "upgrade" ] && rm -rf "$HOME/.dotnet"

set_environment ""
# shellcheck source=/dev/null
source "$PROFILE"

if command_exists dotnet; then
	pass_message "dotnet has installed"

	if [[ -z "${1}" ]]; then
		show_info
		exit
	fi
else
	install "${2}"
fi

set_environment
