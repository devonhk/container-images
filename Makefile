.PHONY: help build push

# Defaults can be overridden, e.g. `make build TAG=dev TARGET=deluge`
REGISTRY ?= docker.io
NAMESPACE ?= devonhk
TAG ?= latest
TARGET ?= local       # Loads images locally via bake group "local"
PUSH_TARGET ?= default

# Optional bake flags; override if you want to reuse CI cache (e.g., CACHE_FLAGS="--set *.cache-from=type=gha --set *.cache-to=type=gha,mode=max")
CACHE_FLAGS ?=

help:
	@echo "make build [TARGET=name] [TAG=tag]     Build images with docker buildx bake"
	@echo "make push  [TARGET=name] [TAG=tag]     Build and push images with docker buildx bake"
	@echo "Vars: REGISTRY (default docker.io), NAMESPACE (default devonhk), TAG (default latest), CACHE_FLAGS (optional)"
	@echo "Defaults: TARGET=local (loads), PUSH_TARGET=default (pushes)"

build:
	@REGISTRY=$(REGISTRY) NAMESPACE=$(NAMESPACE) TAG=$(TAG) \
	docker buildx bake $(CACHE_FLAGS) $(TARGET)

push:
	@REGISTRY=$(REGISTRY) NAMESPACE=$(NAMESPACE) TAG=$(TAG) \
	docker buildx bake $(CACHE_FLAGS) --push $(PUSH_TARGET)
