#!/bin/bash

#------------------------------------------------------------------------------------
#
# config token to run dashboard
#
#------------------------------------------------------------------------------------

# https://microk8s.io/docs/addon-dashboard

# for microk8s 1.24 or newer
microk8s.kubectl create token default

# for MicroK8s 1.23 or older
token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl -n kube-system describe secret $token

# with rbac enabled:
