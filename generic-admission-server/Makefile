all: build
.PHONY: all

build:
	go build -o _output/bin/generic-admission-server src/github.com/onyiny-ang/cluster-registry-crd/generic-admission-server/pkg/cmd
.PHONY: build

clean:
	rm -rf _output
.PHONY: clean

update-deps:
	hack/update-deps.sh
.PHONY: generate
