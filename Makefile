default: help

.PHONY: install
install:
	bundle install

edit:
	vim _pages/*.md

.PHONY: build
build:
	bundle exec jekyll build

local-config: local.yml

local.yml:
	@echo "Generating local config from _config.yml"
	@sed '/^remote_theme:/d' _config.yml > $@
	@echo "theme: minimal-mistakes-jekyll" >> $@

serve: local.yml
	bundle exec jekyll serve --livereload --config local.yml

.PHONY: theme
theme: THEME := $(shell awk -F': ' '$$1=="theme" || $$1=="remote_theme" { print $$2 }' _config.yml |sed 's,^.*jekyll-theme-,,')
theme: #THEME_PATH := $(shell bundle info --path $(THEME))
theme:
	@echo "$(THEME): $(THEME_PATH)"

.PHONY: lint
lint:
	yamllint _config.yml
