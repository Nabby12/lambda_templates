IMAGE_NAME = build-image
CONTAINER_NAME = build-container

build:
	docker build --target runtime -t julia-app -f ./docker/Dockerfile .

build-local:
	docker build --target runtime -t ${IMAGE_NAME} -f docker/Dockerfile .
	docker run --name ${CONTAINER_NAME} -d \
		-p 9000:8080 \
		--env-file=./env/.local.env \
		${IMAGE_NAME}

run:
	curl -d @event/event.json http://localhost:9000/2015-03-31/functions/function/invocations

log:
	docker logs -t ${CONTAINER_NAME}

remove:
	docker stop ${CONTAINER_NAME}
	docker rm ${CONTAINER_NAME}
	docker rmi ${IMAGE_NAME}

invoke: build-local run log remove
