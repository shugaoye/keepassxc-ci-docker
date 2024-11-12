all: build

.PHONY: build
build:
	docker build --platform linux/amd64 $(BUILD_ARGS) -t devcontainers1/qt5:noble-qt5.15 .

.PHONY: push
push:
	docker push devcontainers1/qt5:noble-qt5.15

