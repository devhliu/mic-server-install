kubectl get pvc

kubectl get pvc <pvc name> -o yaml
kubectl delete pvc <pvc name>

# https://microk8s.io/docs/addon-mayastor

- sudo sysctl vm.nr_hugepages=1024
- echo 'vm.nr_hugepages=1024' | sudo tee -a /etc/sysctl.conf

- sudo apt install linux-modules-extra-$(uname -r)

- sudo modprobe nvme_tcp
- echo 'nvme-tcp' | sudo tee -a /etc/modules-load.d/microk8s-mayastor.conf
- sudo microk8s enable core/mayastor --default-pool-size 200G


https://zero-to-jupyterhub.readthedocs.io/en/latest/kubernetes/other-infrastructure/step-zero-microk8s.html

# Configure Storage for OpenEBS
sudo systemctl enable iscsid.service

- microk8s enable community
- microk8s enable openebs


When using OpenEBS with a single node MicroK8s, it is recommended to use the openebs-hostpath StorageClass
An example of creating a PersistentVolumeClaim utilizing the openebs-hostpath StorageClass


kind: PersistentVolumeClaim 
apiVersion: v1
metadata:
  name: local-hostpath-pvc
spec:
  storageClassName: openebs-hostpath
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5G



-----------------------

If you are planning to use OpenEBS with multi nodes, you can use the openebs-jiva-csi-default StorageClass.
An example of creating a PersistentVolumeClaim utilizing the openebs-jiva-csi-default StorageClass


kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: jiva-volume-claim
spec:
  storageClassName: openebs-jiva-csi-default
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5G

- pullk8s pull k8s.gcr.io/sig-storage/livenessprobe:v2.3.0 --microk8s
- pullk8s pull k8s.gcr.io/sig-storage/csi-attacher:v3.1.0 --microk8s
- pullk8s pull k8s.gcr.io/sig-storage/snapshot-controller:v3.0.3 --microk8s
- pullk8s pull k8s.gcr.io/sig-storage/csi-provisioner:v3.0.0 --microk8s
- pullk8s pull k8s.gcr.io/sig-storage/csi-resizer:v1.2.0 --microk8s
- pullk8s pull k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.3 --microk8s