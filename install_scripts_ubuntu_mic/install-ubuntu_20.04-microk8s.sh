#!/bin/bash

function insert_text {
    search_string=$(echo "$1" | sed "s/--//")
    search_string=$(echo "$search_string" | sed "s/help/--help/")
    insert_string=$1
    filepath=$2
    rc=1

    echo "${YELLOW}Checking $insert_string in $filepath.. ${NC}"
    if sudo [ ! -f "$filepath" ]; then
         echo "$filepath does not exist! -> abort."
         exit 1
    fi
    
    if sudo grep -q "$search_string" "$filepath"; then
        echo "${YELLOW}SKIPPED: $insert_string ....${NC}"
    else
        echo "${GREEN}Setting: $insert_string >> $filepath ${NC}"
        rc=0
        sudo sh -c "echo '$insert_string' >> '$filepath'"
    fi
    return $rc
}

DEFAULT_MICRO_VERSION=1.24/stable
DNS="10.6.2.6"
IPRANGE=10.8.95.2-10.8.95.253

# remove all previously install packages
sudo snap remove --purge microk8s
# sudo apt autoremove --purge snapd

# sudo apt install snapd

# install microk8s & helm3
sudo snap install microk8s --classic --channel=$DEFAULT_MICRO_VERSION
sudo snap alias microk8s.kubectl kubectl
# sudo snap install helm --classic --channel=$DEFAULT_HELM_VERSION

sudo groupadd microk8s
sudo usermod -aG microk8s $USER
mkdir $USER/.kube
# sudo chown -f -R $USER/.kube

# enable add-ons
microk8s enable helm3
sudo snap alias microk8s.helm3 helm
microk8s enable dns:$DNS
microk8s enable gpu
microk8s enable rbac
microk8s enable metallb:$IPRANGE
# microk8s enable registry:size=200Gi

# helm env
# https://helm.sh/docs/topics/plugins/
helm plugin install https://github.com/instrumenta/helm-kubeval

# install container images from k8s.gcr.io
# pullk8s check --microk8s

# pullk8s from k8s.gcr.io
pullk8s pull k8s.gcr.io/pause:3.1 --microk8s
# gpu
pullk8s pull k8s.gcr.io/nfd/node-feature-discovery:v0.10.1 --microk8s
pullk8s pull k8s.gcr.io/cuda-vector-add:v0.1 --microk8s
# nvcr.io/nvidia/gpu-feature-discovery:v0.4.1
# nvcr.io/nvidia/cloud-native/gpu-operator-validator:v1.8.2

# pullk8s pull k8s.gcr.io/metrics-server/metrics-server:v0.5.2 --microk8s
# pullk8s pull k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.0.0 --microk8s
# pullk8s pull k8s.gcr.io/ingress-nginx/controller:v1.2.0 --microk8s

pullk8s check --microk8s

# microk8s enable metallb:10.8.95.2-10.8.95.253
# microk8s enable ingress
# microk8s enable prometheus
# microk8s enable dashboard
# microk8s enable istio

microk8s stop

set +e
echo "Enable node_port-range=80-32000 ...";
insert_text "--service-node-port-range=80-32000" /var/snap/microk8s/current/args/kube-apiserver
# echo "Disable insecure port ...";
# insert_text "--insecure-port=0" /var/snap/microk8s/current/args/kube-apiserver

echo "Set limit of completed pods to 200 ...";
insert_text "--terminated-pod-gc-threshold=200" /var/snap/microk8s/current/args/kube-controller-manager
set -e

echo "Set vm.max_map_count=262144"
sudo sysctl -w vm.max_map_count=262144
# sh -c "echo 'vm.max_map_count=262144' >> /etc/sysctl.conf"

echo "Reload systemct daemon ..."
sudo systemctl daemon-reload

# command to disable iptables
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
# sudo iptables -F

microk8s start

#------------------------------------------------------------------------------
#
# install a local register
#
#------------------------------------------------------------------------------
# kubectl create namespace umic
# helm install  umic-harbor -n umic bitnami/harbor


#------------------------------------------------------------------------------
#
# install kaapana-mic
#
#------------------------------------------------------------------------------

# python build-scripts/start_build.py --username umic --password mirecon