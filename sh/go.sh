#!/usr/bin/env bash

# load var
load_vars() {
    # Set environmental for golang
    PROFILE="${HOME}/.bashrc"

    # Release link
    RELEASE_URL="https://go.dev/dl/"

    # Downlaod link
    DOWNLOAD_URL="https://dl.google.com/go/"

    # GOPROXY
    GOPROXY_TEXT="https://proxy.golang.org"

    # Set GOPATH PATH
    GO_PATH="\$HOME/go"
}

# set golang environment
set_environment() {
    # check .zshrc on MacOS
    if [[ -f "${HOME}"/.zshrc ]] && [[ -z "`grep \~\/\.bashrc ${HOME}/.zshrc`" ]];then
        echo -e "\n. ~/.bashrc" >> "${HOME}/.zshrc"
	fi

    [ ! -f "~/.bashrc" ] && touch ~/.bashrc

    ## Update params
    if version_ge $RELEASE_TAG "go1.13"; then
        GOPROXY_TEXT="${GOPROXY_TEXT},direct"
    fi

    if [[ -z "`grep 'export\sGOROOT' ${PROFILE}`" ]];then
        echo -e "\n## GOLANG" >> "${PROFILE}"
        echo "export GOROOT=\"\$HOME/.go\"" >> "${PROFILE}"
    else
        sed -i "s@^export GOROOT.*@export GOROOT=\"\$HOME/.go\"@" "${PROFILE}"
    fi

    if [[ -z "`grep 'export\sGOPATH' ${PROFILE}`" ]];then
        echo "export GOPATH=\"${GO_PATH}\"" >> "${PROFILE}"
    else
        sed -i "s@^export GOPATH.*@export GOPATH=\"${GO_PATH}\"@" "${PROFILE}"
    fi
    
    if [[ -z "`grep 'export\sGOBIN' ${PROFILE}`" ]];then
        echo "export GOBIN=\"\$GOPATH/bin\"" >> "${PROFILE}"
    else 
        sed -i "s@^export GOBIN.*@export GOBIN=\$GOPATH/bin@" "${PROFILE}"     
    fi   

    if [[ -z "`grep 'export\sGO111MODULE' ${PROFILE}`" ]];then
        if version_ge "${RELEASE_TAG}" "go1.11.1"; then
            echo "export GO111MODULE=on" >> "${PROFILE}"
        fi
    fi   
    
    if [ -z "`grep 'export\sASSUME_NO_MOVING_GC_UNSAFE_RISK_IT_WITH' ${PROFILE}`" ];then
        if version_ge "${RELEASE_TAG}" "go1.17"; then
            echo "export ASSUME_NO_MOVING_GC_UNSAFE_RISK_IT_WITH=go1.18" >> "${PROFILE}"
        fi
    fi      

    if [[ -n "${IN_CHINA}" ]]; then 
        if [ -z "`grep 'export\sGOSUMDB' ${PROFILE}`" ];then
            echo "export GOSUMDB=off" >> "${PROFILE}"
        fi      
    fi

    if [[ -z "`grep 'export\sGOPROXY' ${PROFILE}`" ]];then
        echo "export GOPROXY=\"${GOPROXY_TEXT}\"" >> "${PROFILE}"
    else
        sed -i "s@^export GOPROXY.*@export GOPROXY=\"${GOPROXY_TEXT}\"@" "${PROFILE}"
    fi

    if [[ -z "`grep '\$GOROOT/bin:\$GOBIN' ${PROFILE}`" ]];then
        echo "export PATH=\"\$PATH:\$GOROOT/bin:\$GOBIN\"" >> "${PROFILE}"
    fi        

    [[ -n "${1}" ]] || show_info
}

# create GOPATH folder
create_gopath() {
    if [[ ! -d "${GO_PATH}" ]]; then
        if [ "${GO_PATH}" = "\$HOME/go" ]; then
            mkdir -p ~/go
        else
            mkdir -p "${GO_PATH}"
        fi
    fi
}

# if RELEASE_TAG was not provided, assume latest
latest_version() {
    RELEASE_TAG="$(curl -sL --retry 5 ${RELEASE_URL} | sed -n '/toggleVisible/p' | head -n 1 | cut -d '"' -f 4)"
}

# Download file and unpack
download_unpack() {
    rm -rf ~/.go

    curl -Lk --retry 3 "${1}" | gunzip | tar xf - -C /tmp

    mv /tmp/go ~/.go
}

show_info() {
    source "${PROFILE}"

    go version
}

install() {
    latest_version

    if [[ "${ARCH}" = "x64" ]]; then
        ARCH="amd64"
    fi

    # Download File
    BINARY_URL="${DOWNLOAD_URL}${RELEASE_TAG}.${OS}-${ARCH}.tar.gz"

    # Create GOPATH
    create_gopath

    # Download and unpack
    download_unpack "${BINARY_URL}"
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

    if [[ -n "${IN_CHINA}" ]]; then 
        RELEASE_URL="https://golang.google.cn/dl/"
        GOPROXY_TEXT="https://goproxy.cn,https://goproxy.io"  
    fi

	if command_exists go; then
		pass_message "Go has installed"

        if [[ -z "${1}" ]]; then
    		show_info
		    return
        fi
	else
        install
    fi	

    set_environment "${1}"
}

main "$@" || exit 1
