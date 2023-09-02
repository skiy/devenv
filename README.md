# Linux 平台软件开发环境配置

`Linux` 平台软件开发环境配置 For `Jetsung Chan`

## 支持开发环境

- go
- rust
- dotnet
- deno
- node
- docker
- python (anaconda)
- composer (need php)

### 使用

```
git clone https://github.com/jetsung/devenv.git
# 或
git clone https://jihulab.com/jetsung/devenv.git

cd devenv && ./install.sh
```

## 开发环境

- **GO**

```sh
## GOLANG
export GOROOT="$HOME/.go"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export GO111MODULE=on
export GOSUMDB=off
export GOPROXY="https://goproxy.cn,https://goproxy.io,direct"
export PATH="$PATH:$GOROOT/bin:$GOBIN"
export ASSUME_NO_MOVING_GC_UNSAFE_RISK_IT_WITH=go1.18
```

- **~~RUST~~**

```sh
# (已使用 crm 作为镜像管理工具)
## RUST
export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"
export RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup"
## 此项会自动添加
#. "$HOME/.cargo/env"
```

- **DOTNET**

```sh
## DOTNET
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$PATH:$DOTNET_ROOT"
```

- **Flutter**

```sh
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn/"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export PATH="$PATH:$HOME/.flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
```

- **DENO**

```sh
## DENO
export DENO_INSTALL="$HOME/.deno"
export PATH="$PATH:$DENO_INSTALL/bin"
```

- **~~NODE~~**

```sh
# (已使用 volta 作为版本管理工具)
## NODE
export NVM_NODEJS_ORG_MIRROR="https://mirrors.ustc.edu.cn/node/"
export NODE_MIRROR="https://mirrors.ustc.edu.cn/node/"
## 使用 volta 管理，故此项移除。
#export NODE_INSTALL="$HOME/.node"
#export PATH="$PATH:$NODE_INSTALL/bin"
```

> **淘宝源:** `npm config set registry https://registry.npmmirror.com`

- **Qt**
  > QT_INSTALL_PREFIX 变量注意编译环境：`clang_64` / `gcc_64`

```sh
# (安装脚本未配置 Qt)
## QT
export QT_VERSION="5.15.2"
export QT_PATH="$HOME/Qt"
export QT_DIR="$QT_PATH/$QT_VERSION"
export QT_INSTALL_PREFIX="$QT_DIR/gcc_64"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$QT_INSTALL_PREFIX/lib"
export PATH="$PATH:$QT_INSTALL_PREFIX/bin"
export PATH=$QT_PATH/Tools/QtCreator/bin:$PATH
# 可能可以忽略
export QT_PLUGIN_PATH="$QT_INSTALL_PREFIX/plugins"
export QML2_IMPORT_PATH="$QT_INSTALL_PREFIX/qml"
```

需要修正使用的是 `gcc` 还是 `clang`

```
# MacOS zsh
[ -d "$QT_DIR/clang_64" ] && sed -i '' 's/^export QT_INSTALL_PREFIX.*/export QT_INSTALL_PREFIX="$QT_DIR\/clang_64"/' ~/.zshrc
# Linux bash
[ -d "$QT_DIR/clang_64" ] && sed -i 's/^export QT_INSTALL_PREFIX.*/export QT_INSTALL_PREFIX="$QT_DIR\/clang_64"/' ~/.bashrc
```

- **Docker**
  > `/etc/docker/daemon.json` (root)  
  > `~/.config/docker.daemon.json` (rootless)

```
{
  "registry-mirrors": ["https://05f073ad3c0010ea0f4bc00b7105ec20.mirror.swr.myhuaweicloud.com","https://mirror.ccs.tencentyun.com","http://f1361db2.m.daocloud.io", "http://hub-mirror.c.163.com"]
}
```

- **~~Python~~**

```sh
# (已使用 anaconda 作为环境管理工具)
pip config set global.index-url  http://mirrors.cloud.tencent.com/pypi/simple  --trusted-host mirrors.cloud.tencent.com
```

> `$HOME/.pip/pip.conf` (Linux) or `$HOME/.config/pip/pip.conf` (MacOS)

```
[global]
timeout = 6000
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
```

- **Composer**

```sh
# (需要 PHP)
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
```

- **Brew**
- 中科大源: http://mirrors.ustc.edu.cn/help/brew.git.html

```sh
## BREW
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
```
