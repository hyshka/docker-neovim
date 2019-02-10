.PHONY: build

CONTAINERNAME=nvim-env
IMAGENAME=hyshka/neovim

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup: ## Clone down additional repos that are needed for building
	rm -rf nvim vim-options vim
	cp -rL ~/.config/nvim .
	git clone https://github.com/hyshka/vim-options.git

build: ## Build the base image
	docker build -t $(IMAGENAME) .

build-nocache: ## Build the base image with no cache
	docker build --no-cache=true -t $(IMAGENAME) .

up: ## Bring the container up
	docker run -dP -v $(CURDIR):/root/app --name $(CONTAINERNAME) $(IMAGENAME) /bin/bash -c 'while true; do echo hi; sleep 1; done;'

down: ## Stop the container
	docker stop $(CONTAINERNAME) || echo 'No container to stop'

enter: ## Enter the running container
	docker exec -it $(CONTAINERNAME) /bin/bash

clean: down ## Remove the image and any stopped containers
	docker rm $(CONTAINERNAME) || echo 'No container to remove'

push: ## Push the container to dockerhub
	docker push $(IMAGENAME)
