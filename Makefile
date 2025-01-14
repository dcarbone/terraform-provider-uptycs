TEST?=$$(go list ./uptycs/...)
HOSTNAME=registry.terraform.io
NAMESPACE=uptycslabs
NAME=uptycs
BINARY=terraform-provider-${NAME}
VERSION = 0.0.20
GOOS = darwin
GOARCH = amd64

default: install

bump_version:
	find _examples -type f -name '*.tf' -exec sed -i.bak "s/version = \".*\"/version = \"$(VERSION)\"/g" {} +
	sed -i.bak "s/version = \".*\"/version = \"$(VERSION)\"/g" README.md
	sed -i.bak -e '1s/VERSION = .*/VERSION = $(VERSION)/;t' -e '1,/VERSION = .*/s//VERSION = $(VERSION)/' Makefile
	find . -name '*.bak' -delete


build:
	GOOS="" GOARCH="" go build -o ${BINARY}

release:
	GOOS=darwin GOARCH=amd64 go build -o ./bin/${BINARY}_$(VERSION)_darwin_amd64
	GOOS=freebsd GOARCH=386 go build -o ./bin/${BINARY}_$(VERSION)_freebsd_386
	GOOS=freebsd GOARCH=amd64 go build -o ./bin/${BINARY}_$(VERSION)_freebsd_amd64
	GOOS=freebsd GOARCH=arm go build -o ./bin/${BINARY}_$(VERSION)_freebsd_arm
	GOOS=linux GOARCH=386 go build -o ./bin/${BINARY}_$(VERSION)_linux_386
	GOOS=linux GOARCH=amd64 go build -o ./bin/${BINARY}_$(VERSION)_linux_amd64
	GOOS=linux GOARCH=arm go build -o ./bin/${BINARY}_$(VERSION)_linux_arm
	GOOS=openbsd GOARCH=386 go build -o ./bin/${BINARY}_$(VERSION)_openbsd_386
	GOOS=openbsd GOARCH=amd64 go build -o ./bin/${BINARY}_$(VERSION)_openbsd_amd64
	GOOS=solaris GOARCH=amd64 go build -o ./bin/${BINARY}_$(VERSION)_solaris_amd64
	GOOS=windows GOARCH=386 go build -o ./bin/${BINARY}_$(VERSION)_windows_386
	GOOS=windows GOARCH=amd64 go build -o ./bin/${BINARY}_$(VERSION)_windows_amd64

install: build
	mkdir -p ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/$(VERSION)/$(GOOS)_$(GOARCH)
	mv ${BINARY} ~/.terraform.d/plugins/${HOSTNAME}/${NAMESPACE}/${NAME}/$(VERSION)/$(GOOS)_$(GOARCH)

test:
	go test -i $(TEST) || exit 1
	echo $(TEST) | xargs -t -n4 go test $(TESTARGS) -timeout=30s -parallel=4

testacc:
	TF_ACC=1 go test $(TEST) -v $(TESTARGS) -timeout 120m
