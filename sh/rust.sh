#!/usr/bin/env bash

load_vars() {
	# Mirror ustc
	# Set RUSTUP SERVER URL
	RUSTUP_DIST_SERVER="https://rsproxy.cn"

	INSTALL_URL="https://sh.rustup.rs"
}

# set environment
set_environment_default() {
	if [[ -z "`grep '## RUST' ${PROFILE}`" ]]; then
			echo -e "\n## RUST" >> "${PROFILE}"
	fi	
	
    if [[ -n "${IN_CHINA}" ]]; then 
		tee ${HOME}/.cargo/config > /dev/null 2>&1 <<-EOF
[source.crates-io]
replace-with = 'rsproxy'

[source.rsproxy]
registry = "${RUSTUP_DIST_SERVER}/crates.io-index"

[registries.rsproxy]
index = "${RUSTUP_DIST_SERVER}/crates.io-index"

[net]
git-fetch-with-cli = true
EOF

		if [[ -z "`grep 'export\sRUSTUP_DIST_SERVER' ${PROFILE}`" ]]; then
			echo "export RUSTUP_DIST_SERVER=\"${RUSTUP_DIST_SERVER}\"" >> "${PROFILE}"
		else
			sedi "s@^export RUSTUP_DIST_SERVER.*@export RUSTUP_DIST_SERVER=\"${RUSTUP_DIST_SERVER}\"@" "${PROFILE}"
		fi

		if [[ -z "`grep 'export\sRUSTUP_UPDATE_ROOT' ${PROFILE}`" ]]; then
			echo "export RUSTUP_UPDATE_ROOT=\"${RUSTUP_DIST_SERVER}/rustup\"" >> "${PROFILE}"
		else
			sedi "s@^export RUSTUP_UPDATE_ROOT.*@export RUSTUP_UPDATE_ROOT=\"${RUSTUP_DIST_SERVER}/rustup\"@" "${PROFILE}"
		fi
    fi	
}

set_environment() {
	RUSTUP_DIST_SERVER="${RUSTUP_DIST_SERVER}"

	source ${HOME}/.cargo/env
	cargo install crm
	crm best
}

show_info() {
	PS1='$ '
	source ${HOME}/.cargo/env

	rustc --version
	rustup --version
}

install() {
    if [[ -n "${IN_CHINA}" ]]; then 
		INSTALL_URL="${RUSTUP_DIST_SERVER}/rustup-init.sh"
    fi
	
	curl --proto '=https' --tlsv1.2 -sSf "${INSTALL_URL}" | sh
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

main() {
	load_include
	load_vars

	[[ "${1}" = "upgrade" ]] && rustup self uninstall

	if command_exists rustc; then
		pass_message "Rust has installed"

        if [[ -z "${1}" ]]; then
    		show_info
		    exit
        fi
	else
        install
		
    fi	

	set_environment
}

main $@ || exit 1
