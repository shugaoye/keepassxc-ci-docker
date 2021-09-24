all: build

.PHONY: build
build:
	docker build --build-arg QT5_MINOR=15 --build-arg QT5_PATCH=2 . -t keepassxc/keepassxc-ci:bionic-qt5.15-ppa

.PHONY: push
push:
	docker push keepassxc/keepassxc-ci:bionic-qt5.15-ppa
