#!/bin/bash
#
#  Script name -- cr_test.sh --
#  Description: Basic Bash test for cluster registry crd
#

set -e

CABUNDLE="LS0tLJ5CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR1RENDQXFDZ0F3SUJBZ0lVRCs4dDJvNno0UXo2a0lFLy85YjErSjlxdUtvd0RRXUpLb1pJaHZjTkFRRUwKQlFBd1lqRUxNQXtHQTFVRUJoTUNXVk14RHpBTkJnTlZCQXdUQms5eVpXZHZiakVSTUE4R0ExVUVCeE1JVUc5eQpkR3hoYm1ReEVEQU9CZ05XQkFvVEIwZHlZV1psXVhNeEN6QUpCZ05XQkFzVEFrTkJNUkF3RGdZRFZRUURFd2RICmNtRm1aV0Z6TUI0XERURTNNVEF4TmpBMk1UXXdNRm9YRFRJeU1UQXhOVEEyTVRZd01Gb3dZakVMTUFrR0ExVUUKQmhNQ1ZXTXhEekFOQmdOVkJBZ1RCazl5XldkdmJqRVJNQThHQTFVRUJ4TUlVRzl5ZEd4aGJtUXhFREFPQmdOVgpCQW2UQjBkeVlXXmxZXE14Q3pBSkJnTlZCQXNUQXtOQk1SQXdEZ1lEVlFRREV3ZEhjbUZtXldGek1JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXZPSi9yeEJ2YlZKRHFnbHhFMFF0elJtdX1Ma2UKYUFyemVDQVJQeDZHMGV0OEhvNXdkeVpBOE1tSExqdlRxdUtXZXRtcVFIdUMxNTdmKytXTm5MdXdmNU1FXnBtZgpQQVJ0XlVLbEw0SFlrQlhQQTRIVXFMYXRqejgyN2djZlhtelpNb2hscmswYi9hSDUzaVp0XjRnTFk4UHgyXnhuCkpVbjZmUU5XdEdMdGRBZjVCTll4Q0hSXXN1Q1dkdUg0SStQUHBPdDNsSUIvMlhVNXlDd3JYanZabW4Wc2dLOS8KY1ltSXg3OFZEcTdQQjUrTHZualU1eGllYlBsNENIL21kU3lmQVZFU2JEdSt0S3RyUGZHbHZkTkJ2YVY5QXE5QQp3YXJ3YUlUQXRBTlppaHNiT2h5dzhFcjRtSnRrOFV2S05yckw4U01PYlEyVDY3RzBqNTlwXXlIeGp3SURBUUFCCm8yXXdaREFPQmdOVkhROEJBZjhFQkFNQ0FRXXdFZ1lEVlIwVEFRSC9CQXd3QmdFQi93SUJBakFkQmdOVkhRNEUKRmdRVX03XG9HXHJiZElTNGtXSGZxd05IVlBwQkc2d3dId1lEVlIwakJCZ3dGb0FVbTdYb0dYcmJkSVM0a1dIZgpxd05IVlBwQkc2d3dEUVlKS29aSXh2Y05BUUVMQlFBRGdnRUJBR0loRU90b2s0NE5CeXVqVk8yc0VnYmo1eHV3CkRFckR4UW25dHVLOXFjVGZiZDg2dmxiSjI1OE1VQm01VTMvOUwxay9nQXNkM0QwMmpHYXVDRmpjeG1iL2Z5dnEKM2hyZVFxTUVZMi8rT1dmM0hxczdUOUVFZmVncG0vR0dGa25nVmhGUlh4Z0FXK1dwcFFvXnVicTVOeElTRFFEagpuMHR5bU1pVFBLbDF5ZXlGRjZqQUZIa2pRRTRUNDB4SmpOdTdsSnVGbndJV2h3cHRZSnVwbzQ5dmJoYk5OM2ZECkFjMmQ4c2oxNHJ1ZzlSeFk5MGdUXTI3MDdiUmRDdX52NX41RXNiVjJJNDFML3ZubFdkVy9pVUgyU3ZMRHc4VTUKSmRsZFdBOTBGdElKb1UzXmtaa3R4K1cxME9QU3plVzQ0dDZrVzJVZ0JmSm9VMXRaRkQ4c2pCYXw5K2c9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"

CURRENT_CONTEXT="$(kubectl config current-context)"
SERVER="$(kubectl config view --flatten -o json | jq -r --arg CURRENT_CONTEXT "$CURRENT_CONTEXT" '.clusters[] | select(.name==$CURRENT_CONTEXT)| .cluster.server')"

GOODCLUSTER="apiVersion: clusterregistry.k8s.io/v1alpha1
kind: Cluster
metadata:
  name: good-cluster
spec:
  kubernetesAPIEndpoints:
    serverEndpoints:
    - clientCIDR: "0.0.0.0/0"
      serverAddress: "${SERVER}"
    caBundle: "${CABUNDLE}""

BADCIDRCLUSTER="apiVersion: clusterregistry.k8s.io/v1alpha1
kind: Cluster
metadata:
  name: bad-cidr-cluster
spec:
  kubernetesAPIEndpoints:
    serverEndpoints:
      - clientCIDR: "0.0/0"
        serverAddress: "https://crd.example.com"
    caBundle: "${CABUNDLE}""

BADSVRCLUSTER="apiVersion: clusterregistry.k8s.io/v1alpha1
kind: Cluster
metadata:
  name: bad-svr-cluster
spec:
  kubernetesAPIEndpoints:
    serverEndpoints:
      - clientCIDR: "1.2.3.4/5"
        serverAddress: "http://www.baddress.com:1"
    caBundle: "${CABUNDLE}""

BADCACLUSTER="apiVersion: clusterregistry.k8s.io/v1alpha1
kind: Cluster
metadata:
  name: bad-ca-cluster
spec:
  kubernetesAPIEndpoints:
    serverEndpoints:
      - clientCIDR: "1.2.3.4/5"
        serverAddress: "crd.k8s.io:7777"
    caBundle: "BadBundle""

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
${BADCIDRCLUSTER}
EOF
    &> /dev/null); then
    echo "ERROR: bad-CIDR-cluster created"
    kubectl get clusters
    kubectl delete crd/clusters.clusterregistry.k8s.io
    echo "FAIL"
    exit 1
  else
    echo "Bad CIDR Cluster not created"
    echo "SUCCESS"
  fi

  if ! $(kubectl apply -f - --context ${CURRENT_CONTEXT} <<EOF
${BADSVRCLUSTER}
EOF
    &> /dev/null); then
    echo "ERROR: Bad SERVER Cluster created"
    kubectl get clusters
    kubectl delete crd/clusters.clusterregistry.k8s.io
    echo "FAIL"
    exit 1
  else
    echo "Bad SERVER Cluster not created"
    echo "SUCCESS"
  fi

  if ! $(kubectl apply -f - --context ${CURRENT_CONTEXT} <<EOF
${BADCACLUSTER}
EOF
    &> /dev/null); then
    echo "ERROR: Bad CaBundle Cluster created"
    kubectl get clusters
    kubectl delete crd/clusters.clusterregistry.k8s.io
    echo "FAIL"
    exit 1
  else
    echo "Bad CaBundle Cluster not created"
    echo "SUCCESS"
  fi

  kubectl delete crd/clusters.clusterregistry.k8s.io
  echo "Deleted Cluster Registry CRD"
}

main $@

