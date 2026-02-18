# Building Medical Imaging and Computing Kubernetes Platform on WSL

## Pre-requirements

### Windows

* get size of a directory
  ```
  sudo du -hs /usr | sort -rh
  ```
* docker images are stored in: /var/lib/docker
  * ```
    docker ps
    docker inspect
    ```
* auto-mount file system into /var/lib/docker


WSL

compress vhdx file in powershell

```
wsl --shutdown
diskpart
select vdisk file="path-to-vdhx"
compact vdisk
exit
```
# path-to-vdhx: C:\Users\username\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu20.04onWindows_79rhkp1fndgsc\LocalState

# link: https://blog.csdn.net/u014175785/article/details/118181230

# list all installed instances
wsl -l -v
# export instance into tar
wsl --export Ubuntu D:\Ubuntu_bk.tar
# unregister instance
wsl --unregister Ubuntu
# import new instance from tar file
wsl --import Ubuntu_new path-to-new-vxhx path-to-tar --version 2

# login ubuntu @ wsl with default user
@ login into ubuntu and add below information into /etc/wsl.conf

[user]
default=username

wsl --terminate ubuntu
wsl --shutdown

# supported until wsl after 2022.10 release
[boot]
systemd=true

netsh winsock reset