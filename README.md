[![Build Status](https://api.travis-ci.org/pmorie/cluster-registry-crd.svg?branch=master)](https://travis-ci.org/pmorie/cluster-registry-crd "Travis")
# cluster-registry-crd

This repo contains a CRD implementation of
[kubernetes/cluster-registry](https://github.com/kubernetes/cluster-registry)
and exists to be a place to prototype what the cluster-registry looks like as
implemented as a set of CRDs.

# installation

```shell
$ kubectl create -f crd/cluster-registry.yaml
```
