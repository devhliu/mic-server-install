#!/bin/bash

#------------------------------------------------------------------------------------
#
# version
#
#------------------------------------------------------------------------------------
SNAP_VERSION=

#------------------------------------------------------------------------------------
#
# install docker
#
#------------------------------------------------------------------------------------

# install intructions:
# https://docs.docker.com/engine/install/ubuntu/

# remove old installations
apt-get remove docker docker-engine docker.io containerd runc

# install dependencies
apt-get update
apt-get upgrade
apt-get install ca-certificates curl gnupg lsb-release
# add docker's offical GPG key:
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# install docker engine
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# post-installation
groupadd docker
usermod -aG docker $USER
chown "$USER":"$USER" /home/"$USER"/.docker -R
chmod g+rwx "$HOME/.docker" -R
# start on boot
systemctl enable docker.service
systemctl enable containerd.service
systemctl restart docker

#------------------------------------------------------------------------------------
#
# install nvidia-docker
#
#------------------------------------------------------------------------------------

# setup GPG package respository key
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt-get update
apt-get install -y nvidia-docker2
systemctl restart docker

#------------------------------------------------------------------------------------
#
# install docker-comoose
#
#------------------------------------------------------------------------------------
docker-compose-version = 'v2.15.1'
curl -L "https://github.com/docker/compose/releases/download/${docker-compose-version}/docker-compose-$(uname -s)-$(uname -m)" \
     -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#------------------------------------------------------------------------------------
#
# install snapd
#
#------------------------------------------------------------------------------------

# default: installed
# apt-get install snapd -y
# snap version
# output will be
# - snap    2.55.5+20.04
# - snapd   2.55.5+20.04
# - series  16
# - ubuntu  20.04
# - kernel  5.4.0-122-generic
# snapd_2.55.5+20.04_amd64.deb can be downloaded by sudo apt-get download snapd and installed using dpkg -i


#------------------------------------------------------------------------------------
#
# install microk8s
#
#   Name      Version Publisher     Notes     Summary
#   microk8s  v1.24.0 canonical✓   classic    Kubernetes for workstations and appliances
#
#------------------------------------------------------------------------------------

# download microk8s
# snap download microk8s  --channel=1.24/stable
# - 3272 represents v1.24.0 classic
# snap ack microk8s_3272.assert
# snap install microk8s_3272.snap


# install microk8s with offline mode
curl -H 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/microk8s -o microk8s-info.json
curl -o microk8s-amd64-1.24-stable.snap  https://api.snapcraft.io/api/v1/snaps/download/EaXqgt1lyCaxKaQCU349mlodBkDCXRcg_3272.snap
sudo snap install microk8s-amd64-1.24-stable.snap  --classic --dangerous
groupadd microk8s
usermod -aG microk8s $USER
chown -f -R $USER ~/.kube

microk8s config view -> ~/.kube/config

# using mirror in CN
# install pullk8s
curl -L "https://raw.githubusercontent.com/OpsDocker/pullk8s/main/pullk8s.sh" -o /usr/local/bin/pullk8s
chmod +x /usr/local/bin/pullk8s

pullk8s check --microk8s
# pullk8s from k8s.gcr.io
pullk8s pull k8s.gcr.io/pause:3.1 --microk8s
pullk8s pull k8s.gcr.io/nfd/node-feature-discovery:v0.8.2 --microk8s
pullk8s pull k8s.gcr.io/cuda-vector-add:v0.1 --microk8s
pullk8s pull k8s.gcr.io/metrics-server/metrics-server:v0.5.2 --microk8s
pullk8s pull k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.0.0
pullk8s pull k8s.gcr.io/ingress-nginx/controller:v1.2.0 --microk8s
pullk8s check --microk8s


# enable addons
microk8s enable dns:10.6.2.6
# microk8s enable dashboard
# microk8s enable istio 
microk8s enable gpu
microk8s enable helm3 
# microk8s enable prometheus 
microk8s enable rbac 
# microk8s enable ingress
# microk8s enable metallb:10.8.95.2-10.8.95.253
# microk8s enable metallb:10.8.95.84

# microk8s helm3 plugin - kubeval
# 0.13.0
microk8s helm3 plugin install https://github.com/instrumenta/helm-kubeval

# alias
snap alias microk8s.kubectl kubectl
snap alias microk8s.helm3 helm

# configire firewall to allow pod-to-pod and pod-to-internet communication
ufw allow in on cni0
ufw allow out on cni0
ufw default allow routed

microk8s start

# testing for ok status with microk8s
microk8s status --wait-ready

microk8s kubectl get nodes
microk8s kubectl get services
microk8s kubectl get pods

# examples:

# microk8s kubectl get nodes
# NAME        STATUS   ROLES    AGE     VERSION
# p-mirecon   Ready    <none>   2d21h   v1.24.0-2+59bbb3530b6769

# microk8s kubectl get pods
# NAME                                                          READY   STATUS    RESTARTS      AGE
# gpu-operator-node-feature-discovery-master-5b6bdcbddf-ckn97   1/1     Running   2 (87s ago)   88m
# gpu-operator-node-feature-discovery-worker-nzmdj              1/1     Running   2 (86s ago)   88m
# gpu-operator-7c5c97c849-dx4bk                                 1/1     Running   3 (87s ago)   88m

# microk8s kubectl get services
# NAME                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
# kubernetes                                   ClusterIP   10.152.183.1    <none>        443/TCP    2d21h
# gpu-operator-node-feature-discovery-master   ClusterIP   10.152.183.22   <none>        8080/TCP   88m
# gpu-operator                                 ClusterIP   10.152.183.24   <none>        8080/TCP   87m

# microk8s kubectl get namespace
# NAME                     STATUS   AGE
# kube-system              Active   2d21h
# kube-public              Active   2d21h
# kube-node-lease          Active   2d21h
# default                  Active   2d21h
# gpu-operator-resources   Active   89m
# monitoring               Active   5m23s

# microk8s kubectl get all --all-namespaces

# access to dashboard in localhost
token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl -n kube-system describe secret $token

# Add the following lines to /etc/docker/daemon.json: 
{
    "insecure-registries" : ["localhost:32000"] 
}
# and then restart docker with: sudo systemctl restart docker

# hosting the first demo service in microk8s
# microk8s kubectl create deployment microbot --image=dontrebootme/microbot:v1
# microk8s kubectl scale deployment microbot --replicas=2
# kubectl port-forward *podname-here* 8080:8080
# microk8s kubectl expose deployment microbot --type=NodePort --port=80 --name=microbot-service