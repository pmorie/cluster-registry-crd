#!/bin/bash

PROJECT_ROOT=$(dirname "${BASH_SOURCE}")/..

# Register function to be called on EXIT to remove generated binary.
function cleanup {
  rm "${PROJECT_ROOT}/artifacts/simple-image/clusterregistry-admission-server"
}
trap cleanup EXIT

pushd "${PROJECT_ROOT}"
cp -v _output/bin/clusterregistry-admission-server ./artifacts/simple-image/clusterregistry-admission-server
docker build -t ${REPO:-clusterregistry-admission-server}:latest ./artifacts/simple-image
popd

