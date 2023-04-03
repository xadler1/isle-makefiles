.PHONY: lindat-dan
.SILENT: lindat-dan
## This is the help description that comes up when using the 'make help` command. This needs to be placed with 2 # characters, after .PHONY & .SILENT but before the function call. And only take up a single line.
lindat-dan: QUOTED_CURDIR = "$(CURDIR)"
lindat-dan: generate-secrets
	echo "building lindat-dan"
	$(MAKE) lindat-dan-init ENVIRONMENT=starter_dev
	if [ -z "$$(ls -A $(QUOTED_CURDIR)/codebase)" ]; then \
		docker container run --rm -v $(CURDIR)/codebase:/home/root $(REPOSITORY)/nginx:$(TAG) with-contenv bash -lc 'git clone -b main https://github.com/xadler1/dan-test.git /home/root;'; \
		docker container run --rm -v $(CURDIR)/codebase:/home/root $(REPOSITORY)/nginx:$(TAG) with-contenv bash -lc 'git clone -b main https://github.com/xadler1/digitalia-modules-test.git /tmp/codebase; mv /tmp/codebase/* /home/root/'; \
	fi
	$(MAKE) set-files-owner SRC=$(CURDIR)/codebase ENVIRONMENT=starter_dev
	docker-compose up -d --remove-orphans
	docker-compose exec -T drupal with-contenv bash -lc 'composer install'
	$(MAKE) lindat-dan-finalize ENVIRONMENT=starter_dev

.PHONY: lindat-dan-init
lindat-dan-init:
	$(MAKE) starter-init ENVIRONMENT=starter_dev

.PHONY: lindat-dan-finalize
lindat-dan-finalize:
	$(MAKE) starter-finalize ENVIRONMENT=starter_dev
	$(MAKE) lindat-dan-theme

.PHONY: lindat-dan-theme
lindat-dan-theme:
	docker-compose exec -T drupal with-contenv bash -lc "git clone -b dan https://github.com/xadler1/digitalia-themes-test.git /tmp/themes; cp -r /tmp/themes/* /var/www/drupal/; chown -R nginx:nginx /var/www/drupal/web/themes/* ; rm -rf /tmp/themes; drush cr"
