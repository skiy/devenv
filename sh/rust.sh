#/bin/bash

load_vars() {
	# Mirror ustc
	# Set RUSTUP SERVER URL
	RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"

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
			sed -i "" -e "s@^export RUSTUP_DIST_SERVER.*@export RUSTUP_DIST_SERVER=\"${RUSTUP_DIST_SERVER}\"@" $PROFILE
		fi

		if [ -z "`grep 'export\sRUSTUP_UPDATE_ROOT' ${PROFILE}`" ];then
			echo "export RUSTUP_UPDATE_ROOT=\"${RUSTUP_DIST_SERVER}/rustup\"" >> $PROFILE
		else
			sed -i "" -e "s@^export RUSTUP_UPDATE_ROOT.*@export RUSTUP_UPDATE_ROOT=\"${RUSTUP_DIST_SERVER}/rustup\"@" $PROFILE
		fi

		source ${PROFILE}	
    fi	
}

# set China CDN
set_china_cdn() {
	if [ "${IN_CHINA}" == "1" ]; then 
tee ${HOME}/.cargo/config <<-'EOF'
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = "ustc"

[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"
EOF

	fi
}

main() {
	load_vars

	check_in_china

	set_environment

	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

	#if [ -z "`grep '\$HOME/.cargo/env' ${PROFILE}`" ];then
	#        echo "source \"\$HOME/.cargo/env\"" >> $PROFILE
	#fi 

	set_china_cdn
}

main "$@" || exit 1