#!/bin/bash
#
#  Script name -- cr_test.sh --
#  Description: Basic Bash test for cluster registry crd
#

set -e


CURRENT_CONTEXT="$(kubectl config current-context)"
SERVER="$(kubectl config view --flatten -o json | jq -r --arg CURRENT_CONTEXT "$CURRENT_CONTEXT" '.clusters[] | select(.name==$CURRENT_CONTEXT)| .cluster.server')"

GOODCLUSTER="kind: Cluster
apiVersion: clusterregistry.k8s.io/v1alpha1
metadata:
  name: good-cluster
spec:
  kubernetesApiEndpoints:
    serverEndpoints:
    - clientCidr: "0.0.0.0/0"
      serverAddress: "${SERVER}""

BADCLUSTER="kind: Cluster
apiVersion: clusterregistry.k8s.io/v1alpha1
metadata:
  name: bad-cluster
spec:
  kubernetesApiEndpoints:
    serverEndpoints:
      - clientCidr: "0.0.0.0/0"
        serverAddress: "${SERVER}""

function main {
  if $(kubectl api-versions | grep "clusterregistry.k8s.io/v1alpha1" &> /dev/null); then
    kubectl delete crd/clusters.clusterregistry.k8s.io
    echo "Deleted Cluster Registry CRD"
  fi
  kubectl create -f crd/cluster-registry.yaml
  echo "Created Cluster Registry CRD"
  kubectl apply -f - --context ${CURRENT_CONTEXT} --validate=false <<EOF
${GOODCLUSTER}
EOF
  kubectl get clusters
  kubectl apply -f - --context ${CURRENT_CONTEXT} --validate=false <<EOF
${BADCLUSTER}
EOF
  kubectl get clusters
  kubectl delete crd/clusters.clusterregistry.k8s.io
  echo "Deleted Cluster Registry CRD"
  echo "SUCCESS"
}


main $@

