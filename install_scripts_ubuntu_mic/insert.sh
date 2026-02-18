#!/bin/bash

function insert_text {
    search_string=$(echo "$1" | sed "s/--//")
    search_string=$(echo "$search_string" | sed "s/help/--help/")
    insert_string=$1
    filepath=$2
    rc=1

    echo "${YELLOW}Checking $insert_string in $filepath.. ${NC}"
    [ -f $filepath ] || { echo "$filepath does not exist! -> abort." && exit 1; }
    grep -q "$search_string" $filepath && echo "${YELLOW}SKIPPED: $insert_string ....${NC}" || { echo "${GREEN}Setting: $insert_string >> $filepath ${NC}" && rc=0 && sh -c "echo '$insert_string' >> $filepath"; }
    return $rc
}

set +e
echo "Enable node_port-range=80-32000 ...";
insert_text "--service-node-port-range=80-32000" /var/snap/microk8s/current/args/kube-apiserver
# echo "Disable insecure port ...";
# insert_text "--insecure-port=0" /var/snap/microk8s/current/args/kube-apiserver

echo "Set limit of completed pods to 200 ...";
insert_text "--terminated-pod-gc-threshold=200" /var/snap/microk8s/current/args/kube-controller-manager
set -e

echo "Set vm.max_map_count=262144"
sysctl -w vm.max_map_count=262144
sh -c "echo 'vm.max_map_count=262144' >> /etc/sysctl.conf"

echo "Reload systemct daemon ..."
systemctl daemon-reload
