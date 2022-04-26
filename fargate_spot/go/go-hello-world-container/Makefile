include env/makefile.env
EVENT_FILE=local_message.json
WAIT_SECONDS=5

invoke:
	docker compose up -d
	aws sqs send-message --cli-input-json file://event/${EVENT_FILE} --endpoint-url http://localhost:9324
	sleep ${WAIT_SECONDS}
	docker logs ${CONTAINER_NAME}

remove:
	docker stop ${CONTAINER_NAME} elasticmq
	docker rm ${CONTAINER_NAME} elasticmq
	docker rmi ${IMAGE_NAME}:local softwaremill/elasticmq

login:
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

build:
	docker build --target runner -t ${IMAGE_NAME}:${IMAGE_TAG} -f ./docker/app/Dockerfile .

tag:
	docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}

push:
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}

clean:
	docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}

deploy: login build tag push clean
