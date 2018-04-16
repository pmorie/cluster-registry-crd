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
  kubernetesAPIEndpoints:
    serverEndpoints:
    - clientCIDR: "0.0.0.0/0"
      serverAddress: "${SERVER}""

BADCLUSTER="kind: Cluster
apiVersion: clusterregistry.k8s.io/v1alpha1
metadata:
  name: bad-cluster
spec:
  kubernetesAPIEndpoints:
    serverEndpoints:
      - clientCIDR: "0.0/0"
        serverAddress: "${SERVER}""

function main {
  if $(kubectl api-versions | grep "clusterregistry.k8s.io/v1alpha1" &> /dev/null); then
    kubectl delete crd/clusters.clusterregistry.k8s.io
    echo "Deleted Cluster Registry CRD"
  fi
  kubectl create -f crd/cluster-registry.yaml
  echo "Created Cluster Registry CRD"
  kubectl apply -f - --context ${CURRENT_CONTEXT} <<EOF
${GOODCLUSTER}
EOF
if ! $(kubectl get clusters | grep "good-cluster" &> /dev/null); then
  echo "ERROR: good-cluster wasn't created"
  echo "FAIL"
  exit 1
else
  kubectl delete cluster good-cluster
fi
if ! $(kubectl apply -f - --context ${CURRENT_CONTEXT} <<EOF
${BADCLUSTER}
EOF
&> /dev/null); then
echo "ERROR: bad-cluster created"
  kubectl get clusters
  kubectl delete crd/clusters.clusterregistry.k8s.io
echo "FAIL"
exit 1
else
  echo "Bad Cluster not created"
  echo "Deleted Cluster Registry CRD"
  echo "SUCCESS"
fi
}

main $@

