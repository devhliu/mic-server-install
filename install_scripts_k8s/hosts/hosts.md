# HOSTS

## Harbor
add below config into hosts

    10.8.95.2       harbor.image.local.com
    10.8.95.84      umic.image.local.com

### Windows

    C:\Windows\System32\drivers\etc\hosts

### Ubuntu

    /etc/hosts

### Microk8s

https://microk8s.io/docs/registry-built-in

MicroK8s 1.23 and newer versions use separate hosts.toml files for each image registry. For registry http://10.141.241.175:32000, this would be at 
    
    /var/snap/microk8s/current/args/certs.d/10.141.241.175:32000/hosts.toml 
    
First, create the directory if it does not exist:

    sudo mkdir -p /var/snap/microk8s/current/args/certs.d/10.141.241.175:32000
    sudo touch /var/snap/microk8s/current/args/certs.d/10.141.241.175:32000/hosts.toml

Then, edit the file we just created and make sure the contents are as follows:
    
    # /var/snap/microk8s/current/args/certs.d/10.141.241.175:32000/hosts.toml
    server = "http://10.141.241.175:32000"

    [host."http://10.141.241.175:32000"]
    capabilities = ["pull", "resolve"]

Then

    microk8s stop
    microk8s start

### Docker

https://microk8s.io/docs/registry-built-in

    /etc/docker/daemon.json
    
    {
        "insecure-registries" : ["localhost:32000",
                                 "harbor.image.local.com"]
    }

    sudo systemctl restart docker

# updated at 2024 11 06
/etc/docker/daemon.json
{
  "registry-mirrors": ["https://2a6bf1988cb6428c877f723ec7530dbc.mirror.swr.myhuaweicloud.com",
    "https://docker.m.daocloud.io",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://your_preferred_mirror",
    "https://dockerhub.icu",
    "https://docker.registry.cyou",
    "https://docker-cf.registry.cyou",
    "https://dockercf.jsdelivr.fyi",
    "https://docker.jsdelivr.fyi",
    "https://dockertest.jsdelivr.fyi",
    "https://mirror.aliyuncs.com",
    "https://dockerproxy.com",
    "https://mirror.baidubce.com",
    "https://docker.m.daocloud.io",
    "https://docker.nju.edu.cn",
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://docker.mirrors.ustc.edu.cn",
    "https://mirror.iscas.ac.cn",
    "https://docker.rainbond.cc"]
}