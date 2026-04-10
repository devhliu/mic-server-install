docker container rm $(docker container ps -q -a)
docker rmi $(docker image ls | grep none | awk '{print $3}')
microk8s.ctr image rm $(microk8s.ctr image ls | grep none | awk '{print $1}')
