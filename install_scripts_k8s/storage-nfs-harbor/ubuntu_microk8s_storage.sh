#!/bin/bash

# using NFS for PV

# ref: https://microk8s.io/docs/nfs

# install csi driver for NFS
# using kubectl
# ref: https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-csi-driver-v4.1.0.md

sudo apt-get install nfs-kernel-server
microk8s.helm3 install --namespace kube-system --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet \
               csi-driver-nfs /home/umic/workspace/projects/kubernetes-csi/csi-driver-nfs/charts/v4.0.0/csi-driver-nfs

# To check CSI NFS Driver pods status, please run:
kubectl --namespace=kube-system get pods --selector="release=csi-driver-nfs" --watch

UIH_HARBOR_HOST_PATH=/data02/nfsstorage
sudo mkdir -p $UIH_HARBOR_HOST_PATH
sudo chown nobody:nogroup $UIH_HARBOR_HOST_PATH
sudo chmod 0777  $UIH_HARBOR_HOST_PATH

# sudo mv /etc/exports /etc/exports-no-nfs.bak
# define 10.152.183.0 for microk8s clusterIP
# /var/snap/microk8s/current/certs/csr.conf.template

echo '/data02/nfsstorage 10.152.183.0/24(insecure,rw,sync,no_root_squash,no_subtree_check)' | sudo tee /etc/exports
echo '/data02/nfsstorage 10.8.95.0/24(insecure,rw,sync,no_root_squash,no_subtree_check)' | sudo tee /etc/exports
# https://www.jianshu.com/p/eced793e2ce0
sudo systemctl restart nfs-kernel-server


# install k8s from google images using hub.docker


microk8s kubectl apply -f - < sc-nfs.yaml
microk8s kubectl apply -f - < pvc-nfs.yaml

# wait for a while then done
