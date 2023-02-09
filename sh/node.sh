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

	if [[ -n "${IN_CHINA}" ]]; then 
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

	[[ -z "${1}" ]] || show_info
}

# if RELEASE_TAG was not provided, assume latest
latest_version() {
	if [[ -z "${RELEASE_TAG}" ]]; then
		RELEASE_TAG="$(curl -sL https://nodejs.org/en/ | sed -n '/home-downloadbutton/p' | head -n 1 | cut -d '"' -f 8)"
	fi
}

# show info
show_info() {
	source ${PROFILE}

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
	DL_URL="https://github.com/Schniz/fnm/releases/latest/download/${TMPFILE}"
	[[ -n "${IN_CHINA}" ]] && DL_URL="${CHINA_MIRROR_URL}${DL_URL}"
	curl -fsL -o "${TMPFILE}" "${DL_URL}"

	sudo unzip -f ${TMPFILE} -d /usr/local/bin/
	sudo chmod +x /usr/local/bin/fnm
	rm -rf ${TMPFILE}
}

install_node() {
	# install node with fnm
	if command_exists node; then
		pass_message "Node has installed"

		if [[ -z "${1}" ]]; then
			show_info
			exit
		fi
	else
		fnm install --lts
	fi
}

main() {
	load_include
	load_vars

	# china mirror
	if [[ -n "${IN_CHINA}" ]]; then
		DOWNLOAD_URL="${MIRROR_NODE}"
	fi

	set_environment
	source ${PROFILE}

	# install fnm
	if command_exists fnm; then
		echo "fnm (installed) $(fnm --version)"
	else
		install_fnm
		echo "fnm (installing) $(fnm --version)"
		source ${PROFILE}
	fi

	# set node mirror
	eval "$(fnm env --use-on-cd --node-dist-mirror ${DOWNLOAD_URL})"

	if [[ "${1}" = "upgrade" ]]; then
		fnm install --lts
	else
		install_node $@
	fi

	# set node env with fnm
	if [[ -z "`grep 'fnm env' ${PROFILE}`" ]]; then
		if [[ -n "${IN_CHINA}" ]]; then
			tee -a ${PROFILE} <<-EOF
eval "\$(fnm env --use-on-cd --node-dist-mirror $MIRROR_NODE)"
EOF
		else
			tee -a ${PROFILE} <<-EOF
eval "\$(fnm env --use-on-cd)"
EOF
		fi
	fi	

	source ${PROFILE}
	# installl latest npm
	if [[ -n "${IN_CHINA}" ]]; then
        	npm config set registry "${NPM_MIRROR_URL}"
	fi
	npm install -g npm 

	set_environment
}

main $@ || exit 1
