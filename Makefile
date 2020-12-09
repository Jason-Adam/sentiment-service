.PHONY: build deploy docker-build install test

build:
	bash bin/build.sh

deploy:
	bash bin/deploy.sh

docker-build:
	bash bin/docker-build.sh

install:
	bash bin/install.sh

test:
	bash bin/test.sh

template:
	bash bin/preview.sh