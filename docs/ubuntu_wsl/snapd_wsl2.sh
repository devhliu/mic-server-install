# https://discourse.ubuntu.com/t/using-snapd-in-wsl2/12113?_ga=2.150870963.443658128.1655275193-1153904216.1655275193

sudo apt install daemonize
sudo daemonize /usr/bin/unshare --fork --pid --mount-proc /lib/systemd/systemd --system-unit=basic.target
exec sudo nsenter -t $(pidof systemd) -a su - $LOGNAME
