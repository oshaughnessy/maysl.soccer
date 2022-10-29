install:
	bundle install

edit:
	vim _pages/*.md

build:
	bundle exec jekyll build

local-config: 
	@echo "Generating local config from _config.yml"
	@sed '/^remote_theme:/d' _config.yml > local.yml
	@echo "theme: minimal-mistakes-jekyll" >> local.yml

serve: local-config
	bundle exec jekyll serve --livereload --config local.yml

theme: THEME := $(shell awk -F': ' '$$1=="theme" || $$1=="remote_theme" { print $$2 }' _config.yml |sed 's,^.*jekyll-theme-,,')
theme: #THEME_PATH := $(shell bundle info --path $(THEME))
theme:
	@echo "$(THEME): $(THEME_PATH)"

lint:
	yamllint _config.yml

c commit:
	git commit -av

p push:
	git push
