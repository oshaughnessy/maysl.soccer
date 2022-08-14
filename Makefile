THEME := $(shell awk -F': ' '$$1=="theme" { print $$2 }' _config.yml |sed 's,^jekyll-theme-,,')
THEME_PATH := $(shell bundle info --path $(THEME))

install:
	bundle install

edit:
	vim *.md

build:
	bundle exec jekyll build

serve:
	bundle exec jekyll serve --livereload

theme:
	@echo "$(THEME): $(THEME_PATH)"
