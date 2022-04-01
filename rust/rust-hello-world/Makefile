SHELL=/bin/bash

export IMAGE_NAME = rust-build-image
export CONTAINER_NAME = rust-build-container

build:
	docker build -t ${IMAGE_NAME} -f docker/Dockerfile .
	docker run --name ${CONTAINER_NAME} -itd ${IMAGE_NAME}

check:
	echo "--- start function logs ---"
	docker logs ${CONTAINER_NAME}
	echo "---  end function logs  ---"

remove:
	docker stop ${CONTAINER_NAME}
	docker rm ${CONTAINER_NAME}
	docker rmi ${IMAGE_NAME}

invoke: build check remove
