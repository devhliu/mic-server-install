
# using tsinghua mirror
# ref to https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/

# edit /etc/apt/sources.list.d/ubuntu.sources
sudo vim /etc/apt/sources.list.d/ubuntu.sources

# add the following content
# """
# Types: deb
# URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
# Suites: noble noble-updates noble-backports
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
# """
