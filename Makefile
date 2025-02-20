SHELL := /bin/bash

all: \
	commitlint \
	stringer-generate \
	mockgen-generate \
	testdata \
	go-lint \
	go-review \
	go-test \
	go-mod-tidy \
	git-verify-nodiff

include tools/commitlint/rules.mk
include tools/git-verify-nodiff/rules.mk
include tools/golangci-lint/rules.mk
include tools/goreview/rules.mk
include tools/semantic-release/rules.mk
include tools/stringer/rules.mk

.PHONY: clean
clean:
	$(info [$@] removing build files...)
	@rm -rf tools/*/*/ build

.PHONY: mockgen-generate
mockgen-generate: \
	internal/gen/mock/mockcanrunner/mocks.go \
	internal/gen/mock/mockclock/mocks.go \
	internal/gen/mock/mocksocketcan/mocks.go

internal/gen/mock/mockcanrunner/mocks.go: pkg/canrunner/run.go go.mod
	go run github.com/golang/mock/mockgen \
		-destination $@ -package mockcanrunner github.com/toitware/can-go/pkg/canrunner \
		Node,TransmittedMessage,ReceivedMessage,FrameTransmitter,FrameReceiver

internal/gen/mock/mockclock/mocks.go: internal/clock/clock.go go.mod
	go run github.com/golang/mock/mockgen \
		-destination $@ -package mockclock github.com/toitware/can-go/internal/clock \
		Clock,Ticker

internal/gen/mock/mocksocketcan/mocks.go: pkg/socketcan/fileconn.go go.mod
	go run github.com/golang/mock/mockgen \
		-destination $@ -package mocksocketcan -source $<

.PHONY: stringer-generate
stringer-generate: \
	pkg/descriptor/sendtype_string.go \
	pkg/socketcan/errorclass_string.go \
	pkg/socketcan/protocolviolationerrorlocation_string.go \
	pkg/socketcan/protocolviolationerror_string.go \
	pkg/socketcan/controllererror_string.go \
	pkg/socketcan/transceivererror_string.go

%_string.go: %.go $(stringer)
	go generate $<

.PHONY: testdata
testdata:
	go run cmd/cantool/main.go generate testdata/dbc testdata/gen/go

.PHONY: go-test
go-test:
	$(info [$@] running Go tests...)
	@mkdir -p build/coverage
	@go test -short -race -coverprofile=build/coverage/$@.txt -covermode=atomic ./...

.PHONY: go-mod-tidy
go-mod-tidy:
	go mod tidy -v
