#!/usr/bin/env bash
#########################################################
# Function : NodeJS Install                             #
# Platform : Linux                                      #
# Version  : 1.0.1                                      #
# Date     : 2022-08-24                                 #
# Author   : Jetsung Chan                               #
# Contact  : jetsungchan@gmail.com                      #
#########################################################

load_vars() {
	MIRROR_SERVER="https://mirrors.ustc.edu.cn"
	NVM_NODEJS_ORG_MIRROR="${MIRROR_SERVER}/node/"
	MIRROR_NODE="${MIRROR_SERVER}/node/"

	# Official Download url
	DOWNLOAD_URL="https://nodejs.org/dist/"

	# Taobao Mirror
	NPM_MIRROR_URL="https://registry.npmmirror.com"

	CHINA_MIRROR_URL="https://ghproxy.com/"    

	# Set NODE PATH
	NODE_PATH="\$HOME/.node" 
}


# https://mirrors.ustc.edu.cn/help/dockerhub.html
set_environment() {
	if [[ ! -f "${PROFILE}" ]];then
		echo -e "\n No found file: ${PROFILE}"
		return
	fi

	if [[ -z "`grep '## NODE' ${PROFILE}`" ]];then
		echo -e "\n## NODE" >> ${PROFILE}
	fi

	if [[ "${IN_CHINA}" == "1" ]]; then 
		if [[ -z "`grep 'export\sNVM_NODEJS_ORG_MIRROR' ${PROFILE}`" ]];then
			echo "export NVM_NODEJS_ORG_MIRROR=\"${NVM_NODEJS_ORG_MIRROR}\"" >> ${PROFILE}
		else
			sedi "s@^export NVM_NODEJS_ORG_MIRROR.*@export NVM_NODEJS_ORG_MIRROR=\"${NVM_NODEJS_ORG_MIRROR}\"@" "${PROFILE}"
		fi

		if [[ -z "`grep 'export\sNODE_MIRROR' ${PROFILE}`" ]]; then
			echo "export NODE_MIRROR=\"${MIRROR_NODE}\"" >> ${PROFILE}
		else
			sedi "s@^export NODE_MIRROR.*@export NODE_MIRROR=\"${MIRROR_NODE}\"@" "${PROFILE}"
		fi
	fi
    
	## 使用 fnm
	# if [[ -z "`grep 'export\sNODE_INSTALL' ${PROFILE}`" ]];then
	#     echo "export NODE_INSTALL=\"${NODE_PATH}\"" >> ${PROFILE}
	# else
	#     sed -i "s@^export NODE_INSTALL.*@export NODE_INSTALL=\"${NODE_PATH}\"@" $PROFILE
	# fi

	# if [[ -z "`grep 'export\sPATH=\"\$PATH:\$NODE_INSTALL/bin\"' ${PROFILE}`" ]];then
	#     echo "export PATH=\"\$PATH:\$NODE_INSTALL/bin\"" >> ${PROFILE}
	# fi

	if [[ SHOW_INFO = "1" ]]; then
		show_info
		SHOW_INFO="0"
	fi
}

# if RELEASE_TAG was not provided, assume latest
latest_version() {
	if [[ -z "${RELEASE_TAG}" ]]; then
		RELEASE_TAG="$(curl -sL https://nodejs.org/en/ | sed -n '/home-downloadbutton/p' | head -n 1 | cut -d '"' -f 8)"
	fi
}

install() {
	latest_version

	[[ -n "${IN_CHINA}" ]] && DOWNLOAD_URL="${MIRROR_NODE}"

	BINARY_URL="${DOWNLOAD_URL}${RELEASE_TAG}/node-${RELEASE_TAG}-${OS}-${ARCH}.tar.xz"
	DOWNLOAD_FILE="$(mktemp).tar.gz"
	download_file $BINARY_URL $DOWNLOAD_FILE

	if [[ "${PKG_TOOL_NAME}" = "apt" ]]; then  
		if test -x "$(dpkg -l | grep tar)"; then
			sudo apt install -y tar
		fi

		if test -x "$(dpkg -l | grep xz-utils)"; then
			sudo apt install -y xz-utils
		fi
	fi

	if [[ ! -d "${HOME}/.node" ]]; then
		mkdir "${HOME}/.node"
	fi

	tar -xJf ${DOWNLOAD_FILE}
	cp -r node-${RELEASE_TAG}-${OS}-${ARCH}/* ${HOME}/.node 
	rm -rf node-${RELEASE_TAG}-${OS}-${ARCH} $DOWNLOAD_FILE
}

# show info
show_info() {
	source "${PROFILE}"

	if command_exists node; then
		npm config list
#     printf "
# npm version: %s
# node version: %s
# " $(npm --version) $(node --version)
	fi
}

load_include() {
	realpath=$(dirname "`readlink -f $0`")
	include_tmp_path="/tmp/include_devenv.sh"
	include_file_url="https://jihulab.com/jetsung/devenv/raw/main/sh/include.sh"
	
	if [[ -f "${realpath}/include.sh" ]]; then
    		. ${realpath}/include.sh
	elif [[ -f "${include_tmp_path}" ]]; then
		. "${include_tmp_path}"
	else
		curl -sL -o "${include_tmp_path}" "${include_file_url}"
		[[ -f "${include_tmp_path}" ]] && . "${include_tmp_path}"
	fi
}

# install fnm
install_fnm() {
	# cargo install fnm

	TMPFILE="fnm-linux.zip"
	if [[ "${IN_CHINA}" == "1" ]]; then
		curl -sL -o "${TMPFILE}" "${CHINA_MIRROR_URL}https://github.com/Schniz/fnm/releases/download/v1.31.1/fnm-linux.zip"
	else
		curl -sL -o "${TMPFILE}" "https://github.com/Schniz/fnm/releases/download/v1.31.1/fnm-linux.zip"
	fi

	unzip fnm-linux.zip
	rm -rf fnm-linux.zip
	chmod +x fnm
	sudo mv fnm /usr/local/bin/
}

main() {
	load_include
	load_vars

	set_environment
	source "${PROFILE}"

	if command_exists fnm; then
		echo "fnm (installed) $(fnm --version)"
	else
		install_fnm
		echo "fnm (install) $(fnm --version)"
		source "${PROFILE}"
	fi

	if command_exists node; then
		pass_message "Node has installed"
		if [[ -z "${1}" ]]; then
			show_info
			return
		fi
	else
		fnm install 16

		if [[ -z "`grep 'fnm env' ${PROFILE}`" ]]; then
			tee -a ${PROFILE} <<-EOF
			eval "\$(fnm env --use-on-cd)"
EOF
			source "${PROFILE}"
		fi
	fi

	eval "$(fnm env --use-on-cd)"

	# installl latest npm
	npm install -g npm 
	if [[ "${IN_CHINA}" == "1" ]]; then
        	npm config set registry "${NPM_MIRROR_URL}"
	fi

	show_info
}

main "$@" || exit 1
