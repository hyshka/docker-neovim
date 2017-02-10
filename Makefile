.PHONY: build

CONTAINERNAME=nvim-env
IMAGENAME=hyshka/neovim

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the base image
	docker build -t hyshka/shellcheck shellcheck-builder
	docker run --rm -it -v $(CURDIR):/mnt hyshka/shellcheck
	git clone https://github.com/hyshka/nvim.git
	docker build -t hyshka/neovim .
	docker push $(IMAGENAME)

up: build ## Bring the container up
	docker run -dP -v $(CURDIR):/app --name $(CONTAINERNAME) $(IMAGENAME) /bin/bash -c 'while true; do echo hi; sleep 1; done;'

down: ## Stop the container
	docker stop $(CONTAINERNAME) || echo 'No container to stop'

enter: ## Enter the running container
	docker exec -it $(CONTAINERNAME) /bin/bash

clean: down ## Remove the image and any stopped containers
	docker rm $(CONTAINERNAME) || echo 'No container to remove'
