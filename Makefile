#   Copyright 2020 The Compose Specification Authors.

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

.DEFAULT_GOAL := help

IMAGE_PREFIX=composespec/compose-ref-

GOFLAGS=-mod=vendor

.PHONY: build
build: ## Build compose-ref binary
	@mkdir -p bin/
	GOFLAGS=$(GOFLAGS) go build -o bin/compose-ref compose-ref.go

.PHONY: lib
lib: ## Build compose-ref binary
	@mkdir -p lib/
	GOFLAGS=$(GOFLAGS) go build -o lib/libparse.so -buildmode=c-shared compose-parse.go

.PHONY: test
test: ## Run tests
	GOFLAGS=$(GOFLAGS) go test ./... -v

.PHONY: fmt
fmt: ## Format go files
	@goimports -e -w ./

.PHONY: build-validate-image
build-validate-image:
	docker build . -f ci/Dockerfile -t $(IMAGE_PREFIX)validate

.PHONY: lint
lint: build-validate-image
	docker run --rm $(IMAGE_PREFIX)validate bash -c "golangci-lint run --config ./golangci.yml ./"

.PHONY: check-license
check-license: build-validate-image
	docker run --rm $(IMAGE_PREFIX)validate bash -c "./scripts/validate/fileheader"

.PHONY: setup
setup: ## Setup the precommit hook
	@which pre-commit > /dev/null 2>&1 || (echo "pre-commit not installed see README." && false)
	@pre-commit install

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
