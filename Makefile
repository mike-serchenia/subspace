.DEFAULT_GOAL := help
.PHONY: help clean

BINDATA=${GOPATH}/bin/go-bindata
BUILD_VERSION?=unknown


help:  ## Display this help message and exit
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# GOOS=linux GOARCH=amd64  
build: 
	@echo "Compiling subspace..."
	cd web \
	&& go run github.com/jteeuwen/go-bindata/go-bindata --pkg main static/... templates/... email/.. \
	&& mv bindata.go ../cmd/subspace/ \
	&& cd - \
	&& CGO_ENABLED=0 \
		go build -v --compiler gc --ldflags "-extldflags -static -s -w -X main.version=${BUILD_VERSION}" -o subspace ./cmd/subspace
	rm cmd/subspace/bindata.go
	@echo "+++ subspace compiled"
