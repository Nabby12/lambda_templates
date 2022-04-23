IMAGE_NAME = build-image
CONTAINER_NAME = build-container
EVENT_FILE = event/event.json

build:
	docker build --target runner -t ${IMAGE_NAME} -f docker/Dockerfile .
	docker run --name ${CONTAINER_NAME} -d \
		-p 9000:8080 \
		--env-file=./env/local.env \
		-v $(CURDIR)/credentials/:/root/.aws/ \
		${IMAGE_NAME} ./bootstrap

run:
	curl -d @${EVENT_FILE} http://localhost:9000/2015-03-31/functions/function/invocations

log:
	docker logs -t ${CONTAINER_NAME}

remove:
	docker stop ${CONTAINER_NAME}
	docker rm ${CONTAINER_NAME}
	docker rmi ${IMAGE_NAME}

invoke: build run log remove
