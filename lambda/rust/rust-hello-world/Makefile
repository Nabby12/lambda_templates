IMAGE_NAME = build-image
CONTAINER_NAME = build-container

build:
	docker build --target runner -t ${IMAGE_NAME} -f docker/Dockerfile .
	docker run --name ${CONTAINER_NAME} -d \
		-p 9000:8080 \
		--env-file=./env/local.env \
		${IMAGE_NAME} ./bootstrap

## aws credentials をマウントする場合 docker run コマンドに下記を追加
## 対象ユーザーがmfa必須の場合は疎通されない
## -v $(HOME)/.aws/:/root/.aws/

run:
	curl -d @event/event.json http://localhost:9000/2015-03-31/functions/function/invocations

log:
	docker logs -t ${CONTAINER_NAME}

remove:
	docker stop ${CONTAINER_NAME}
	docker rm ${CONTAINER_NAME}
	docker rmi ${IMAGE_NAME}

invoke: build run log remove
