# timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# added for mirrors in CN

# ubuntu
RUN sed -i 's#http://archive.ubuntu.com/ubuntu#https://mirrors.tuna.tsinghua.edu.cn/ubuntu#' /etc/apt/sources.list
# there is no ca-certificate requried
RUN sed -i 's#http://archive.ubuntu.com/ubuntu#http://mirrors.tuna.tsinghua.edu.cn/ubuntu#' /etc/apt/sources.list

# alpinelinux
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
# debian
RUN sed -i 's#http://deb.debian.org/debian#http://mirrors.ustc.edu.cn/debian#' /etc/apt/sources.list

# pip
RUN python -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# npm

# yarn
RUN yarn config set registry https://registry.npm.taobao.org/

编辑 /var/snap/microk8s/current/args/containerd-template.toml 文件
在 endpoint 添加 新的 国内 registry.mirrors ， 如 "https://docker.mirrors.ustc.edu.cn"
[plugins.cri.registry]
      [plugins.cri.registry.mirrors]
        [plugins.cri.registry.mirrors."docker.io"]
          endpoint = [
                "https://bpbtkqdl.mirror.aliyuncs.com"
          ]

# Time Zone
dpkg-reconfigure tzdata

# UIH
RUN python -m pip install --upgrade pip -i https://nexus.united-imaging.com/pypi/simple \
    && pip config set global.index-url https://nexus.united-imaging.com/pypi/simple \
# ubuntu
RUN sed -i 's#http://archive.ubuntu.com/ubuntu#https://nexus.united-imaging.com/ubuntu/#' /etc/apt/sources.list
# debian
RUN sed -i 's#http://deb.debian.org/debian#https://nexus.united-imaging.com/debian#' /etc/apt/sources.list

# go
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn