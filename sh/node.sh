#!/usr/bin/env bash
#########################################################
# Function : NodeJS Install                             #
# Platform : Linux                                      #
# Version  : 1.0.1                                      #
# Date     : 2023-03-12                                 #
# Author   : Jetsung Chan                               #
# Contact  : jetsungchan@gmail.com                      #
#########################################################

set -e
set -u
set -o pipefail

set_environment() {
	if [ ! -f "$PROFILE" ]; then
		printf "\n No found file: %s" "$PROFILE"
		return
	fi

	if ! grep -q '## NODE' "$PROFILE"; then
		printf "\n## NODE\n" >>"$PROFILE"
	fi

	if [ -n "$IN_CHINA" ]; then
		if ! grep -q 'export\sNVM_NODEJS_ORG_MIRROR' "$PROFILE"; then
			echo "export NVM_NODEJS_ORG_MIRROR=\"${NVM_NODEJS_ORG_MIRROR}\"" >>"$PROFILE"
		else
			sedi "s@^export NVM_NODEJS_ORG_MIRROR.*@export NVM_NODEJS_ORG_MIRROR=\"${NVM_NODEJS_ORG_MIRROR}\"@" "$PROFILE"
		fi

		if ! grep -q 'export\sNODE_MIRROR' "$PROFILE"; then
			echo "export NODE_MIRROR=\"${MIRROR_NODE}\"" >>"$PROFILE"
		else
			sedi "s@^export NODE_MIRROR.*@export NODE_MIRROR=\"${MIRROR_NODE}\"@" "$PROFILE"
		fi

	fi

	[ -z "${1}" ] || show_info
}

# if RELEASE_TAG was not provided, assume latest
latest_version() {
	if [ -z "$RELEASE_TAG" ]; then
		RELEASE_TAG="$(curl -sL https://nodejs.org/en/ | sed -n '/home-downloadbutton/p' | head -n 1 | cut -d '"' -f 8)"
	fi
}

# show info
show_info() {
	source_volta

	if command_exists node; then
		npm config list
		#     printf "
		# npm version: %s
		# node version: %s
		# " $(npm --version) $(node --version)
	fi
}

load_include() {
	realpath=$(dirname "$(readlink -f "$0")")
	include_tmp_path="/tmp/include_devenv.sh"
	include_file_url="https://jihulab.com/jetsung/devenv/raw/main/sh/include.sh"

	if [ -f "$realpath/include.sh" ]; then
		# shellcheck source=/dev/null
		. "$realpath"/include.sh
	elif [ -f "$include_tmp_path" ]; then
		# shellcheck source=/dev/null
		. "$include_tmp_path"
	else
		curl -sL -o "$include_tmp_path" "$include_file_url"
		# shellcheck source=/dev/null
		[ -f "$include_tmp_path" ] && . "$include_tmp_path"
	fi
}

# install volta
install_volta() {
	curl https://get.volta.sh | bash

	source_volta
}

install_node() {
	# install node
	if command_exists node; then
		pass_message "Node has installed"

		if [ -z "${1}" ]; then
			show_info
			exit
		fi
	else
		volta install node@lts
	fi
}

source_volta() {
	export VOLTA_HOME="$HOME/.volta"
	export PATH="$VOLTA_HOME/bin:$PATH"
}

source_env() {
	if [ -n "$IN_CHINA" ]; then
		export NVM_NODEJS_ORG_MIRROR="$NVM_NODEJS_ORG_MIRROR"
		export NODE_MIRROR="$MIRROR_NODE"
	fi
}

OS=""
ARCH=""
ARCH_BIT=""
PKG_TOOL_NAME=""
IN_CHINA=""
PROFILE=""

load_include

MIRROR_SERVER="https://mirrors.ustc.edu.cn"
NVM_NODEJS_ORG_MIRROR="$MIRROR_SERVER/node/"
MIRROR_NODE="$MIRROR_SERVER/node/"

# Taobao Mirror
NPM_MIRROR_URL="https://registry.npmmirror.com"
set_environment ""

if [ -n "$VOLTA_HOME" ]; then
	source_volta
	echo "volta (installed) $(volta --version)"
else
	# install volta
	install_volta
	echo "volta (installing) $(volta --version)"
fi

if [ "${1}" = "upgrade" ]; then
	volta install node@lts
else
	install_node "${1}"
fi

source_volta

# installl latest npm
if [ -n "$IN_CHINA" ]; then
	npm config set registry "$NPM_MIRROR_URL"
fi
npm install -g npm

set_environment ""
