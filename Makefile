CONTROLLER_NAME=172.22.50.227/arm64/controller
SPEAKER_NAME=172.22.50.227/arm64/speaker
VERSION=0.11

.PHONY: arm64
arm64:
	make build -e ARCH=linux/arm64

.PHONY: build
build: build_controller build_speaker  #build arm image

.PHONY: build_controller
build_controller:
	docker buildx build --platform=${ARCH} -f controller.Dockerfile -t ${CONTROLLER_NAME}:${VERSION} . --load

.PHONY: build_speaker
build_speaker:
	docker buildx build --platform=${ARCH} -f speaker.Dockerfile -t ${SPEAKER_NAME}:${VERSION} . --load

