VERSION=0.9.25_x-$(shell git rev-parse --short HEAD)

GOOS?=linux
GOARCH?=amd64

PROVIDER=terraform-provider-exoscale
PKG=github.com/exoscale/$(PROVIDER)

SRCS=main.go $(wildcard exoscale/*.go)

DEST=build
OSES=windows darwin linux
S=_v$(VERSION)
ifeq ($(GOOS),windows)
	SUFFIX=$(S).exe
endif
ifeq ($(GOOS),darwin)
	SUFFIX=$(S)_$(GOOS)-$(GOARCH)
endif
ifeq ($(GOOS),linux)
	SUFFIX=$(S)
endif

BIN= $(DEST)/$(PROVIDER)$(SUFFIX)
DEBUG_BIN = $(PROVIDER)_v$(VERSION)


GOPATH := $(CURDIR)/.gopath
export GOPATH
export PATH := $(PATH):$(GOPATH)/bin

.PHONY: default
default: $(DEBUG_BIN)

$(DEBUG_BIN): $(SRCS)
	(cd $(GOPATH)/src/$(PKG) && \
		go build \
			-o $@ \
			$<)

$(GOPATH)/src/$(PKG):
	mkdir -p $(GOPATH)
	go get -u github.com/golang/dep/cmd/dep
	mkdir -p $(shell dirname $(GOPATH)/src/$(PKG))
	ln -sf ../../../.. $(GOPATH)/src/$(PKG)

.PHONY: deps
deps: $(GOPATH)/src/$(PKG)
	(cd $(GOPATH)/src/$(PKG) && dep ensure)

.PHONY: deps-status
deps-status: $(GOPATH)/src/$(PKG)
	(cd $(GOPATH)/src/$(PKG) && dep status)
	
.PHONY: deps-update
deps-update: deps
	(cd $(GOPATH)/src/$(PKG) && dep ensure -update)

.PHONY: test
test:
	(cd $(GOPATH)/src/$(PKG)/exoscale && go test -v)

.PHONY: testacc
testacc:
	(cd $(GOPATH)/src/$(PKG)/exoscale && TF_ACC=1 go test -v)

.PHONY: clean
clean:
	rm -f $(PROVIDER)_v*
	rm -rf $(DEST)
