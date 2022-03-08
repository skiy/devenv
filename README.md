## Linux 平台软件开发环境配置

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

cd devent && ./install.sh
```

### 开发环境
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
```

- **RUST**
```sh
## RUST
export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"
export RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup"
#. "$HOME/.cargo/env"
```

- **DOTNET**
```sh
## DOTNET
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$PATH:$DOTNET_ROOT"
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
export NODE_INSTALL="$HOME/.node"
export PATH="$PATH:$NODE_INSTALL/bin"
```
> **淘宝源:** `npm config set registry https://registry.npmmirror.com`

- **Qt**
```sh
## QT
export QT_DIR="5.15.2"
export QT_INSTALL_PREFIX="$HOME/Qt/$QT_DIR/gcc_64"
export QT_PLUGIN_PATH="$QT_INSTALL_PREFIX/plugins"
export QML2_IMPORT_PATH="$QT_INSTALL_PREFIX/qml"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$QT_INSTALL_PREFIX/lib"
export PATH="$PATH:$QT_INSTALL_PREFIX/bin"
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

> `~/.pip/pip.conf`
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
