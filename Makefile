########################################################################################################################
#
#
########################################################################################################################
.DEFAULT_GOAL := help

# Execute everything on same shell, so the active of the virtualenv works on the next command
#.ONESHELL:

.PHONY: install

#SHELL=./make-venv

# include *.mk

_venv: _venv/touchfile
	
_venv/touchfile: requirements.txt
	test -d venv || virtualenv venv --python=python3
	. venv/bin/activate && python -m pip install -Ur requirements.txt
	touch venv/touchfile

clean: ## clean
	rm -rf venv

# TODO: make dynamic
theme = edx-platform/nau-basic
COMPOSE_PROJECT_NAME= nau-juniper-devstack

pull_translations: _venv
	. venv/bin/activate && cd $(theme) && i18n_tool transifex pull

update_translations: _venv ## update strings to be translated, compile and validate them
	. venv/bin/activate && cd $(theme) && i18n_tool extract -v
	. venv/bin/activate && cd $(theme) && i18n_tool dummy
	. venv/bin/activate && cd $(theme) && i18n_tool generate
	. venv/bin/activate && cd $(theme) && i18n_tool validate

publish_lms_devstack: | update_translations ## Publish changes to LMS devstack
	@echo "Running compilejsi18n && collectstatic at lms"
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py lms compilejsi18n --locale pt-pt'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py lms compilejsi18n --locale en'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py lms collectstatic -i *css -i templates -i vendor --noinput -v2 | grep Copying | grep i18n'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).lms bash -c 'kill $$(ps aux | grep "manage.py lms" | egrep -v "while|grep" | awk "{print \$$2}")'

publish_studio_devstack: | update_translations ## Publish changes to STUDIO devstack
	@echo "Running compilejsi18n && collectstatic at studio"
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py cms compilejsi18n --locale pt-pt'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py cms compilejsi18n --locale en'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py cms collectstatic -i *css -i templates -i vendor --noinput -v2 | grep Copying | grep i18n'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).studio bash -c 'kill $$(ps aux | grep "manage.py cms" | egrep -v "while|grep" | awk "{print \$$2}")'

# Generates a help message. Borrowed from https://github.com/pydanny/cookiecutter-djangopackage.
help: ## Display this help message
	@echo "Please use \`make <target>' where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'
