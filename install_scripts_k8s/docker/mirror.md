timezone
TZ=Asia/Shanghai ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

dpkg-reconfigure tzdata

debian
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

pip
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simples
pip install package --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple

alpinelinux
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

ubuntu
sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list 
sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

npm
npm install xxx --registry=https://registry.npm.taobao.org yarn config set registry http://registry.npm.taobao.org/

centos
https://mirrors.tuna.tsinghua.edu.cn/help/centos/
/etc/yum.repos.d/
for CentOS 7
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g'
-e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g'
-i.bak
/etc/yum.repos.d/CentOS-*.repo

for CentOS 8
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g'
-e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g'
-i.bak
/etc/yum.repos.d/CentOS-*.repo

sudo yum makecache

# Mirrors for Docker Hub

## https://xuanyuan.me/blog/archives/1154
-> /etc/docker/daemon.json
-> {"registry-mirrors":[
        "https://docker.xuanyuan.me", 
        "https://docker.1ms.run",
        ]}
-> sudo systemctl restart docker
