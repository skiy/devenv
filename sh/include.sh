#!/usr/bin/env bash

set -e
set -u
set -o pipefail

exec 3>&1

script_name=$(basename "$0")

if [ -t 1 ] && command -v tput >/dev/null; then
  ncolors=$(tput colors || echo 0)
  if [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    bold="$(tput bold || echo)"
    normal="$(tput sgr0 || echo)"
    black="$(tput setaf 0 || echo)"
    red="$(tput setaf 1 || echo)"
    green="$(tput setaf 2 || echo)"
    yellow="$(tput setaf 3 || echo)"
    blue="$(tput setaf 4 || echo)"
    magenta="$(tput setaf 5 || echo)"
    cyan="$(tput setaf 6 || echo)"
    white="$(tput setaf 7 || echo)"
  fi
fi

say_warning() {
  printf "%b\n" "${yellow:-}${script_name}: Warning: $1${normal:-}" >&3
}

say_err() {
  printf "%b\n" "${red:-}${script_name}: Error: $1${normal:-}" >&2
  exit 1
}

say() {
  printf "%b\n" "${cyan:-}${script_name}:${normal:-} $1" >&3
}

# try profile
try_profile() {
  if [ -z "${1-}" ] || [ ! -f "${1}" ]; then
    return 1
  fi
  sh_echo "${1}"
}

# sh echo
sh_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

# Get PROFILE
detect_profile() {
  if [ "${PROFILE-}" = '/dev/null' ]; then
    # the user has specifically requested NOT to have nvm touch their profile
    return
  fi

  if [ -n "${PROFILE}" ] && [ -f "${PROFILE}" ]; then
    sh_echo "${PROFILE}"
    return
  fi

  local DETECTED_PROFILE
  DETECTED_PROFILE=''

  if [ "${SHELL#*bash}" != "$SHELL" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [ "${SHELL#*zsh}" != "$SHELL" ]; then
    if [ -f "$HOME/.zshrc" ]; then
      DETECTED_PROFILE="$HOME/.zshrc"
    fi
  fi

  if [ -z "$DETECTED_PROFILE" ]; then
    for EACH_PROFILE in ".profile" ".bashrc" ".bash_profile" ".zshrc"; do
      if DETECTED_PROFILE="$(try_profile "${HOME}/${EACH_PROFILE}")"; then
        break
      fi
    done
  fi

  if [ -n "$DETECTED_PROFILE" ]; then
    sh_echo "$DETECTED_PROFILE"
  fi
}

# fix macos
sedi() {
  if [[ "${OS}" = "darwin" ]]; then
    sed -i "" "$@"
  else
    sed -i "$@"
  fi
}

# get OS
get_os() {
  OS=$(uname | tr '[:upper:]' '[:lower:]')
  case $OS in
  darwin) OS='darwin' ;;
  linux) OS='linux' ;;
  freebsd) OS='freebsd' ;;
    #        mingw*) OS='windows';;
    #        msys*) OS='windows';;
  *)
    printf "\e[1;31mOS %s is not supported by this installation script\e[0m\n" "${OS}"
    exit 1
    ;;
  esac
}

# get Arch
get_arch() {
  ARCH=$(uname -m)
  ARCH_BIT="${ARCH}"
  case "${ARCH}" in
  i386) ARCH="386" ;;
  amd64) ARCH="x64" ;;
  x86_64) ARCH="x64" ;;
  armv6l) ARCH="armv6l" ;;
  armv7l) ARCH="armv7l" ;;
  arm64) ARCH="arm64" ;;
  aarch64) ARCH="arm64" ;;
  *)
    printf "\e[1;31mArchitecture %s is not supported by this installation script\e[0m\n" "${ARCH}"
    exit 1
    ;;
  esac
}

# get github latest
get_latest_github() {
  curl -sL "https://api.github.com/repos/${1}/releases/latest" | grep '"tag_name":' | cut -d'"' -f4
}

# pkg manager tool
pkg_manager_tool() {
  PKG_TOOL_NAME=""
  if command_exists yum; then
    PKG_TOOL_NAME="yum"
  elif command_exists apt-get; then
    PKG_TOOL_NAME="apt"
  elif command_exists brew; then
    PKG_TOOL_NAME="brew"
  fi
}

# command_exists
command_exists() {
  # shell script can't found.
  # which "$@" > /dev/null 2>&1
  command -v "$@" >/dev/null 2>&1
  # command not found: xxx
}

# check in china
check_in_china() {
  if ! curl -s -m 3 -IL https://google.com | grep -q "200 OK"; then
    IN_CHINA=1
  fi
}

# install curl,wget command
install_dl_command() {
  if ! command_exists curl; then
    if [[ "${PKG_TOOL_NAME}" = "yum" ]]; then
      sudo yum install -y curl wget
    elif [[ "${PKG_TOOL_NAME}" = "apt" ]]; then
      sudo apt install -y curl wget
    else
      err_message "You must pre-install the curl,wget tool"
      exit 1
    fi
  fi
}

# compare version size
version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "${1}"; }

# download file
download_file() {
  url="${1}"
  destination="${2}"

  # printf "Fetching ${url} \n\n"

  if command_exists curl; then
    code=$(curl --connect-timeout 15 -w '%{http_code}' -L "${url}" -o "${destination}")
  elif command_exists wget; then
    code=$(wget -t2 -T15 -O "${destination}" --server-response "${url}" 2>&1 | awk '/^  HTTP/{print $2}' | tail -1)
  else
    printf "\e[1;31mNeither curl nor wget was available to perform http requests.\e[0m\n"
    exit 1
  fi

  if [[ "${code}" != "200" ]]; then
    printf "\e[1;31mRequest failed with code %s\e[0m\n" "$code"
    exit 1
    # else
    #     printf "\n\e[1;33mDownload succeeded\e[0m\n"
  fi
}

sedi() {
  if [[ "${OS}" = "darwin" ]]; then
    sed -i "" "$@"
  else
    sed -i "$@"
  fi
}

detect_profile() {
  if [[ "${PROFILE-}" = '/dev/null' ]]; then
    # the user has specifically requested NOT to have nvm touch their profile
    return
  fi

  if [[ -n "${PROFILE}" ]] && [[ -f "${PROFILE}" ]]; then
    sh_echo "${PROFILE}"
    return
  fi

  local DETECTED_PROFILE
  DETECTED_PROFILE=''

  if [[ "${SHELL#*bash}" != "$SHELL" ]]; then
    if [[ -f "$HOME/.bashrc" ]]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [[ -f "$HOME/.bash_profile" ]]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [[ "${SHELL#*zsh}" != "$SHELL" ]]; then
    if [[ -f "$HOME/.zshrc" ]]; then
      DETECTED_PROFILE="$HOME/.zshrc"
    fi
  fi

  if [[ -z "$DETECTED_PROFILE" ]]; then
    for EACH_PROFILE in ".profile" ".bashrc" ".bash_profile" ".zshrc"; do
      if DETECTED_PROFILE="$(try_profile "${HOME}/${EACH_PROFILE}")"; then
        break
      fi
    done
  fi

  if [[ -n "$DETECTED_PROFILE" ]]; then
    sh_echo "$DETECTED_PROFILE"
  fi
}

# try profile
try_profile() {
  if [[ -z "${1-}" ]] || [[ ! -f "${1}" ]]; then
    return 1
  fi
  sh_echo "${1}"
}

# sh echo
sh_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

OS=""
ARCH=""
ARCH_BIT=""
PKG_TOOL_NAME=""
IN_CHINA=""
PROFILE=""

if [ -z "$OS" ]; then
  get_os
fi

if [ -z "$ARCH" ] || [ -z "$ARCH_BIT" ]; then
  get_arch
fi

if [ -z "$PKG_TOOL_NAME" ]; then
  pkg_manager_tool
fi

if [ -z "${IN_CHINA}" ]; then
  check_in_china
fi

install_dl_command

PROFILE="$(detect_profile)"

# shellcheck disable=SC2034
CHINA_MIRROR_URL="https://ghproxy.com/"
