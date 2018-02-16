#!/bin/bash

CLUSTER_DOMAIN=istio-dev.devillo.no
INGRESS_TEMPLATE_FILE=istio_ingress_template.yaml

for NAMESPACE in $(kubectl get namespace | tail -n+2 | cut -d" " -f1 | tr "\n" " "); do 
    for INGRESS_NAME in $(kubectl get ingress --namespace ${NAMESPACE} | tail -n+2 | cut -d " " -f1 | tr "\n" " "); do
        cat ${INGRESS_TEMPLATE_FILE} | sed -e "s/@APP_NAME@/${INGRESS_NAME}/g" \
                                     | sed -e "s/@CLUSTER_DOMAIN@/${CLUSTER_DOMAIN}/g" \
                                     | sed -e "s/@NAMESPACE@/${NAMESPACE}/g" \
                                     > target/${NAMESPACE}-${INGRESS_NAME}.yaml
    done
done
