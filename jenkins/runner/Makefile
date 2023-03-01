TAG=runner-v0.1.0
NAME=registry.gitlab.com/super001/infra
IMAGE=$(NAME):$(TAG)

build:
	@echo "Building the image"
	@docker build -t $(IMAGE) .
	@echo "Done"

push:
	@echo "Push image to $(IMAGE) docker hub"
	@docker push $(IMAGE)
	@echo "Done"
