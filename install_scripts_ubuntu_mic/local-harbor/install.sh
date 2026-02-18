#!/bin/bash

# kubectl apply -f uih-harbor-datastorage-pv.yaml
# helm install uih-registry -n uih-registry bitnami-harbor
helm -n uih-registry install uih-registry goharbor/harbor -f uih-harbor-values.yaml