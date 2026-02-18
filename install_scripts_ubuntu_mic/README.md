https://docs.microsoft.com/zh-cn/azure/architecture/operator-guides/aks/choose-bare-metal-kubernetes

# Installation Steps for MIC @ Ubuntu24.04 LTS Server
1. Install Ubuntu-20.04
2. Install NVIDIA-GPU Drivers + Utils
   2.1 Driver Version: 510.73.08  - corresponding to CUDA 11.6
   
3. Install Docker + Docker-NVIDIA
4. Install pullk8s for gcr access from CN: https://github.com/OpsDocker/pullk8s.git
   1. pullk8s pull k8s.gcr.io/cuda-vector-add:v0.1 --microk8s
   2. pullk8s pull k8s.gcr.io/nfd/node-feature-discovery:v0.8.2 --microk8s
   3. pullk8s pull k8s.gcr.io/pause:3.1 --microk8s
   4. pullk8s pull k8s.gcr.io/kube-state-metrics/kube-state-metrics: --microk8s
5.

> hostnamectl status
   Static hostname: mirecon-umic
         Icon name: computer-server
           Chassis: server
        Machine ID: bf3159134bfc433db73d931876442f9b
           Boot ID: 9a6653d85bd149cd96e49c23442835b0
  Operating System: Ubuntu 20.04.4 LTS
            Kernel: Linux 5.4.0-121-generic
      Architecture: x86-64


# snap alias
sudo snap alias microk8s.kubectl kubectl

# Install Microk8s @ CN

> link: https://cloud.tencent.com/developer/article/2000534

> sudo vi /var/snap/microk8s/current/args/containerd-template.toml 

# merge branchB -> branchA
cd branchA
git merge --no-ff branchB

# config timezone
dpkg-reconfigure tzdata