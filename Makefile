.PHONY: build

CONTAINERNAME=neovim
IMAGENAME=hyshka/neovim
SHELLCHECK_IMAGENAME=hyshka/shellcheck

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build_shellcheck: ## Build the shellcheck binaries
	docker build -t $(SHELLCHECK_IMAGENAME) shellcheck-builder
	docker run --rm -it -v $(CURDIR):/app $(SHELLCHECK_IMAGENAME)

build: build_shellcheck ## Build the base image
	rm -Rf nvim
	cp -rL ~/.config/nvim .
	docker build -t $(IMAGENAME) .
	docker push $(IMAGENAME)

up: build ## Bring the container up
	docker run -dP -v $(CURDIR):/root/app --name $(CONTAINERNAME) $(IMAGENAME) /bin/bash -c 'while true; do echo hi; sleep 1; done;'

down: ## Stop the container
	docker stop $(CONTAINERNAME) || echo 'No container to stop'

enter: ## Enter the running container
	docker exec -it $(CONTAINERNAME) /bin/bash

clean: down ## Remove the image and any stopped containers
	docker rm $(CONTAINERNAME) || echo 'No container to remove'
