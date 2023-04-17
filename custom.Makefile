.PHONY: lindat-bp
.SILENT: lindat-bp
## This is the help description that comes up when using the 'make help` command. This needs to be placed with 2 # characters, after .PHONY & .SILENT but before the function call. And only take up a single line.
lindat-bp: QUOTED_CURDIR = "$(CURDIR)"
lindat-bp: generate-secrets
	echo "building lindat-bp"
	$(MAKE) lindat-bp-init ENVIRONMENT=starter_dev
	if [ -z "$$(ls -A $(QUOTED_CURDIR)/codebase)" ]; then \
		docker container run --rm -v $(CURDIR)/codebase:/home/root $(REPOSITORY)/nginx:$(TAG) with-contenv bash -lc 'git clone -b main https://github.com/xadler1/bp-test.git /home/root;'; \
		docker container run --rm -v $(CURDIR)/codebase:/home/root $(REPOSITORY)/nginx:$(TAG) with-contenv bash -lc 'git clone -b main https://github.com/xadler1/digitalia-modules-test.git /tmp/codebase; mv /tmp/codebase/* /home/root/'; \
		docker container run --rm -v $(CURDIR)/codebase:/home/root $(REPOSITORY)/nginx:$(TAG) with-contenv bash -lc 'git clone -b bp https://github.com/xadler1/digitalia-themes-test.git /tmp/codebase; mv /tmp/codebase/web/themes/* /home/root/web/themes/'; \
	fi
	$(MAKE) set-files-owner SRC=$(CURDIR)/codebase ENVIRONMENT=starter_dev
	docker-compose up -d --remove-orphans
	docker-compose exec -T drupal with-contenv bash -lc 'composer install'
	$(MAKE) lindat-bp-finalize ENVIRONMENT=starter_dev

.PHONY: lindat-bp-init
lindat-bp-init:
	$(MAKE) starter-init ENVIRONMENT=starter_dev

.PHONY: lindat-bp-finalize
lindat-bp-finalize:
	$(MAKE) starter-finalize ENVIRONMENT=starter_dev
