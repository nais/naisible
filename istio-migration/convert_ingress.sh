#!/bin/bash

CLUSTER_DOMAIN="istio-dev.devillo.no"
INGRESS_TEMPLATE_FILE="./istio_ingress_template.yaml"
TARGET_DIR="./target"
BACKUP_DIR="${TARGET_DIR}/backup"
NEW_DIR="${TARGET_DIR}/new"

mkdir -p ${BACKUP_DIR} ${NEW_DIR}

#for NAMESPACE in $(kubectl get namespace --output=custom-columns=NAME:.metadata.name | tail -n+2 | tr "\n" " "); do 
for NAMESPACE in $(echo default); do 
    for INGRESS_NAME in $(kubectl get ingress --namespace ${NAMESPACE} --output=custom-columns=NAME:.metadata.name | tail -n+2 | tr "\n" " "); do
        # backup old traefik ingress
        kubectl get ingress ${INGRESS_NAME} --namespace=${NAMESPACE} --output=yaml \
                            | tee ${BACKUP_DIR}/${NAMESPACE}-${INGRESS_NAME}.yaml \
                            | sed -e "s/name: ${INGRESS_NAME}/name: ${INGRESS_NAME}-traefik/g" \
                            | kubectl create -f - 

		# update with new istio ingress
        cat ${INGRESS_TEMPLATE_FILE} | sed -e "s/@APP_NAME@/${INGRESS_NAME}/g" \
                                     | sed -e "s/@CLUSTER_DOMAIN@/${CLUSTER_DOMAIN}/g" \
                                     | sed -e "s/@NAMESPACE@/${NAMESPACE}/g" \
                                     | tee ${NEW_DIR}/${INGRESS_NAME}.yaml \
                                     | kubectl apply -f -
    done
done
