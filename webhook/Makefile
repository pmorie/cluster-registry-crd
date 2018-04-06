# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


IMAGE = gcr.io/jiji-168714/cr-crd-webhook-amd64
TAG = 1.10v2

build:
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o webhook .
	docker build --no-cache -t $(IMAGE):$(TAG) .
	docker push $(IMAGE):$(TAG)
	rm -rf webhook
deploy-only:
	kubectl delete clusterrolebinding crd-validating-webhook || true
	kubectl delete -f deployment/crd-validating-webhook.yaml || true
	kubectl delete validatingwebhookconfiguration.admissionregistration.k8s.io crd-validating-webhook || true
	kubectl create -f deployment/crd-validating-webhook.yaml
	# It's necessary because the webhook needs to access the extension-apiserver-authentication configmap
	kubectl create clusterrolebinding crd-validating-webhook --clusterrole=cluster-admin --serviceaccount=default:default
	sleep 5
	kubectl create -f deployment/admissionregistration.yaml --validate=false
deploy: build deploy-only

