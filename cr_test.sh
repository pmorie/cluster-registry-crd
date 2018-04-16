#!/bin/bash
#
#  Script name -- cr_test.sh --
#  Description: Basic Bash test for cluster registry crd
#

set -e

CABUNDLE="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR1RENDQXFDZ0F3SUJBZ0lVRCs4dDJvNno0UXo2a0lFLy85YjErSjlxdUtvd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lqRUxNQWtHQTFVRUJoTUNWVk14RHpBTkJnTlZCQWdUQms5eVpXZHZiakVSTUE4R0ExVUVCeE1JVUc5eQpkR3hoYm1ReEVEQU9CZ05WQkFvVEIwZHlZV1psWVhNeEN6QUpCZ05WQkFzVEFrTkJNUkF3RGdZRFZRUURFd2RICmNtRm1aV0Z6TUI0WERURTNNVEF4TmpBMk1UWXdNRm9YRFRJeU1UQXhOVEEyTVRZd01Gb3dZakVMTUFrR0ExVUUKQmhNQ1ZWTXhEekFOQmdOVkJBZ1RCazl5WldkdmJqRVJNQThHQTFVRUJ4TUlVRzl5ZEd4aGJtUXhFREFPQmdOVgpCQW9UQjBkeVlXWmxZWE14Q3pBSkJnTlZCQXNUQWtOQk1SQXdEZ1lEVlFRREV3ZEhjbUZtWldGek1JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXZPSi9yeEJ2YlZKRHFnbHhFMFF0elJtdW1Ma2UKYUFyemVDQVJQeDZHMGV0OEhvNXdkeVpBOE1tSExqdlRxdUtWZWRtcVFIdUMxNTdmKytWTm5MdXdmNU1FWnBtZgpQQVJ0WlVLbEw0SFlrQlhQQTRIVXFMYXRqejgyN2djZlhtelpNb2hscmswYi9hSDUzaVp0WjRnTFk4UHgyWnhuCkpVbjZmUU5WdEdMdGRBZjVCTll4Q0hSWWN1Q1dkdUg0SStQUHBPdDNsSUIvMlhVNWlDd3JYanZabW9Xc2dLOS8KY1ltSXg3OFZEcTdQQjUrTHZualU1eGllYlBsNENIL21kU3lmQVZFU2JEdSt0S3RyUGZHbHZkTkJ2YVY5QXE5QQp3YWJ3YUlUQWRBTlppaHNiT2h5dzhFcjRtSnRrOFV2S05yckw4U01PYlEyVDY3RzBqNTlwWWlIeGp3SURBUUFCCm8yWXdaREFPQmdOVkhROEJBZjhFQkFNQ0FRWXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBakFkQmdOVkhRNEUKRmdRVW03WG9HWHJiZElTNGtXSGZxd05IVlBwQkc2d3dId1lEVlIwakJCZ3dGb0FVbTdYb0dYcmJkSVM0a1dIZgpxd05IVlBwQkc2d3dEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBR0loRU90b2s0NE5CeXVqVk8yc0VnYmo1eHV3CkRFckR4UW95dHVLOXFjVGZiZDg2dmxiSjI1OE1VQm01VTMvOUwxay9nQXNkM0QwMmpHYXVDRmpjeG1iL2Z5dnEKM2hyZVFxTUVZMi8rT1dmM0hxczdUOUVFZmVncG0vR0dGa25nVmhGUlh4Z0FXK1dwcFFvWnVicTVOeElTRFFEagpuMHR5bU1pVFBLbDF5ZWlGRjZqQUZIa2pRRTRUNDB4SmpOdTdsSnVGbndJV2h3cHRZSnVwbzQ5dmJoYk5OM2ZECkFjMmQ4c2oxNHJ1ZzlSeFk5MGdUWTI3MDdiUmRDdW52NW41RWNiVjJJNDFML3ZubFdkVy9pVUgyU3ZMRHc4VTUKSmRsZFdBOTBGdElKb1UzWmtaa3R4K1cxME9QU3plVzQ0dDZrVzJVZ0JmSm9VMXRaRkQ4c2pCYWw5K2c9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"

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
    serverAddress: "${SERVER}"
  caBundle: "${CABUNDLE}""

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
  kubectl delete crd/clusters.clusterregistry.k8s.io
fi
}

main $@

