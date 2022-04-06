#/bin/bash

load_vars() {
	# Mirror ustc
	# Set RUSTUP SERVER URL
	RUSTUP_DIST_SERVER="https://rsproxy.cn"

	# Set environmental
	PROFILE="${HOME}/.bashrc"

	# Set RUST ENV PATH
	#ENV_PATH="\$HOME/.cargo/env"

	# Is GWF
	IN_CHINA=0
}

# check in china
check_in_china() {
    urlstatus=$(curl -s -m 3 -IL https://google.com | grep 200)
    if [ "$urlstatus" == "" ]; then
        IN_CHINA=1
    fi
}

# set environment
set_environment() {
	if [ -z "`grep '## RUST' ${PROFILE}`" ];then
			echo -e "\n## RUST" >> $PROFILE
	fi	
	
    if [ "${IN_CHINA}" == "1" ]; then 

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
	curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh
	
	tee ${HOME}/.cargo/config <<-'EOF'
[source.crates-io]
replace-with = 'rsproxy'

[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"

[net]
git-fetch-with-cli = true
EOF

    else
	curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh
    fi
}

main() {
	load_vars

	check_in_china

	set_environment

	#if [ -z "`grep '\$HOME/.cargo/env' ${PROFILE}`" ];then
	#        echo "source \"\$HOME/.cargo/env\"" >> $PROFILE
	#fi 
	install
}

main "$@" || exit 1
