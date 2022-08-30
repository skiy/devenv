# Linux 平台软件开发环境配置

`Linux` 平台软件开发环境配置 For `Jetsung Chan`

## 支持开发环境
- go
- rust
- dotnet
- deno
- node
- docker
- python
- composer

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

- **RUST**
```sh
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
```bash
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn/"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export PATH="$PATH:$HOME/.flutter/bin"
```

- **DENO**
```sh
## DENO
export DENO_INSTALL="$HOME/.deno"
export PATH="$PATH:$DENO_INSTALL/bin"
```

- **NODE**
```sh
## NODE
export NVM_NODEJS_ORG_MIRROR="https://mirrors.ustc.edu.cn/node/"
export NODE_MIRROR="https://mirrors.ustc.edu.cn/node/"
## 使用 nvm 管理，故此项移除。
#export NODE_INSTALL="$HOME/.node"
#export PATH="$PATH:$NODE_INSTALL/bin"
```
> **淘宝源:** `npm config set registry https://registry.npmmirror.com`

- **Qt**
> QT_INSTALL_PREFIX 变量注意编译环境：`clang_64` / `gcc_64`   
```sh
## QT
export QT_VERSION="5.15.2"
export QT_DIR="$HOME/Qt/$QT_VERSION"
export QT_INSTALL_PREFIX="$QT_DIR/gcc_64"
export QT_PLUGIN_PATH="$QT_INSTALL_PREFIX/plugins" # 可能可以忽略, QT_INSTALL_PLUGINS
export QML2_IMPORT_PATH="$QT_INSTALL_PREFIX/qml" # 可能可以忽略, QT_INSTALL_QML
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$QT_INSTALL_PREFIX/lib"
export PATH="$PATH:$QT_INSTALL_PREFIX/bin"
```
需要修正使用的是 `gcc` 还是 `clang`
```bash
# MacOS zsh
[ -d "$QT_DIR/clang_64" ] && sed -i '' 's/^export QT_INSTALL_PREFIX.*/export QT_INSTALL_PREFIX="$QT_DIR\/clang_64"/' ~/.zshrc
# Linux bash
[ -d "$QT_DIR/clang_64" ] && sed -i 's/^export QT_INSTALL_PREFIX.*/export QT_INSTALL_PREFIX="$QT_DIR\/clang_64"/' ~/.bashrc
```

- **Docker**
需要 **root**
> `/etc/docker/daemon.json`
```
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn/"]
}
```

- **Python**
```bash
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
