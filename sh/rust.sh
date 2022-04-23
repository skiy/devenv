#/bin/bash

load_vars() {
	# Set environmental
	PROFILE="${HOME}/.bashrc"

	# Mirror ustc
	# Set RUSTUP SERVER URL
	RUSTUP_DIST_SERVER="https://rsproxy.cn"

	INSTALL_URL="https://sh.rustup.rs"
}

# set environment
set_environment() {
	if [ -z "`grep '## RUST' ${PROFILE}`" ];then
			echo -e "\n## RUST" >> $PROFILE
	fi	
	
    if [ "${IN_CHINA}" == "1" ]; then 
		tee ${HOME}/.cargo/config <<-EOF
[source.crates-io]
replace-with = 'rsproxy'

[source.rsproxy]
registry = "${RUSTUP_DIST_SERVER}/crates.io-index"

[registries.rsproxy]
index = "${RUSTUP_DIST_SERVER}/crates.io-index"

[net]
git-fetch-with-cli = true
EOF

		if [ -z "`grep 'export\sRUSTUP_DIST_SERVER' ${PROFILE}`" ];then
			echo "export RUSTUP_DIST_SERVER=\"${RUSTUP_DIST_SERVER}\"" >> $PROFILE
		else
			sed -i -e "s@^export RUSTUP_DIST_SERVER.*@export RUSTUP_DIST_SERVER=\"${RUSTUP_DIST_SERVER}\"@" $PROFILE
		fi

		if [ -z "`grep 'export\sRUSTUP_UPDATE_ROOT' ${PROFILE}`" ];then
			echo "export RUSTUP_UPDATE_ROOT=\"${RUSTUP_DIST_SERVER}/rustup\"" >> $PROFILE
		else
			sed -i -e "s@^export RUSTUP_UPDATE_ROOT.*@export RUSTUP_UPDATE_ROOT=\"${RUSTUP_DIST_SERVER}/rustup\"@" $PROFILE
		fi

		source ${PROFILE}	
    fi	
}

install() {
    if [ "${IN_CHINA}" == "1" ]; then 
		INSTALL_URL="${RUSTUP_DIST_SERVER}/rustup-init.sh"
    fi
	
	curl --proto '=https' --tlsv1.2 -sSf "${INSTALL_URL}" | sh
}

main() {
    realpath=$(dirname "`readlink -f $0`")
    . ${realpath}/include.sh

	load_vars

	if command_exists rustc; then
		pass_message "Rust has installed"

        if [ "${1}x" = "x" ]; then
			rustc --version
		    return
        fi
	else
        install
    fi

	set_environment

	#if [ -z "`grep '\$HOME/.cargo/env' ${PROFILE}`" ];then
	#        echo "source \"\$HOME/.cargo/env\"" >> $PROFILE
	#fi 
}

main "$@" || exit 1
