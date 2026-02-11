# Copyright 2016 The Kubernetes Authors.
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

BIN := nfs-subdir-external-provisioner
VERSION := $(shell grep '^appVersion:' charts/nfs-subdir-external-provisioner/Chart.yaml | awk '{print $$2}')
IMAGE_NAME := obegron/nfs-subdir-external-provisioner
DOCKERFILE := Dockerfile
LOCAL_PLATFORM ?= linux/amd64

.PHONY: build
build:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o $(BIN) ./cmd/nfs-subdir-external-provisioner

.PHONY: run
run:
	go run ./cmd/nfs-subdir-external-provisioner

.PHONY: docker-build
docker-build:
	docker buildx build --platform linux/amd64,linux/arm64 -f $(DOCKERFILE) -t $(IMAGE_NAME):$(VERSION) -t $(IMAGE_NAME):latest .

.PHONY: docker-build-local
docker-build-local:
	docker buildx build --platform $(LOCAL_PLATFORM) --load -f $(DOCKERFILE) -t $(IMAGE_NAME):$(VERSION) -t $(IMAGE_NAME):latest .

.PHONY: docker-push
docker-push:
	docker buildx build --platform linux/amd64,linux/arm64 --provenance=true --sbom=true -f $(DOCKERFILE) -t $(IMAGE_NAME):$(VERSION) -t $(IMAGE_NAME):latest . --push

.PHONY: trivy-image
trivy-image:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image $(IMAGE_NAME):$(VERSION)

.PHONY: trivy-local
trivy-local: docker-build-local trivy-image

.PHONY: show-version
show-version:
	@echo $(VERSION)

.PHONY: clean
clean:
	rm -f $(BIN)

.PHONY: help
help:
	@echo "nfs-subdir-external-provisioner build targets:"
	@echo "  make build        - Build local binary (stripped)"
	@echo "  make run          - Run locally"
	@echo "  make docker-build - Build multi-arch Docker image"
	@echo "  make docker-build-local - Build local image and load into Docker"
	@echo "  make docker-push  - Build and push to registry"
	@echo "  make trivy-image  - Scan image with Trivy via Docker socket"
	@echo "  make trivy-local  - Build locally and scan with Trivy"
	@echo "  make show-version - Show current version"
	@echo "  make clean        - Remove built binaries"
