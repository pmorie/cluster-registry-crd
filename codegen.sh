#!/bin/bash

vendor/k8s.io/code-generator/generate-groups.sh all \
github.com/pmorie/cluster-registry-crd/pkg/client \ github.com/pmorie/cluster-registry-crd/pkg/apis \
clusterregistry.k8s.io/v1alpha1