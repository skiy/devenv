#

## 单文件安装

- 国内

```bash
# go
curl -SL https://jihulab.com/jetsung/devenv/-/raw/main/sh/go.sh | bash

# python anaconda
curl -SL https://jihulab.com/jetsung/devenv/-/raw/main/sh/python.sh | bash
# python miniconda
curl -SL https://jihulab.com/jetsung/devenv/-/raw/main/sh/python.sh | bash -s -- mini
```

- 国外

```bash
# go
curl -SL https://github.com/jetsung/devenv/raw/main/sh/go.sh | bash

# python anaconda
curl -SL https://github.com/jetsung/devenv/raw/main/sh/python.sh | bash
# python miniconda
curl -SL https://github.com/jetsung/devenv/raw/main/sh/python.sh | bash -s -- mini

REPO=https://mirrors.aliyun.com/anaconda bash ./python.sh
```

## 修改日志

### Version: 2023.04.23

- composer.sh
- deno.sh
- docker.sh
- dotnet.sh
- flutter.sh
- go.sh
- node.sh
- python.sh
- rust.sh
