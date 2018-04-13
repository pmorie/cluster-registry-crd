all: build
.PHONY: all

build:
	go build -o _output/bin/clusterregistry-admission-server github.com/pmorie/cluster-registry-crd/clusterregistry-admission-server/cmd
.PHONY: build

build-image:
	CGO_ENABLED=0 GOOS=linux go build -o _output/bin/clusterregistry-admission-server github.com/pmorie/cluster-registry-crd/clusterregistry-admission-server/cmd
	REPO=$(REPO) hack/build-image.sh
.PHONY: build-image

push-image:
	docker push $(REPO):latest

clean:
	rm -rf _output
.PHONY: clean

update-deps:
	hack/update-deps.sh
.PHONY: generate
