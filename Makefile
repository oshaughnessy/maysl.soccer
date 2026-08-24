default: help

.PHONY: install
install:
	bundle install

edit:
	vim _pages/*.md

.PHONY: build
build:
	bundle exec jekyll build

update:
	@echo "FYI: https://jekyllrb.com/docs/upgrading/"
	bundle update --all

# local.yml is no longer needed: _config.yml uses `theme:` with the bundled gem,
# so local and CI builds read the same config. (Kept as a no-op target so an
# old habit or script doesn't break.)
.PHONY: local-config
local-config:
	@echo "Not needed anymore -- _config.yml uses the bundled theme directly."

.PHONY: serve
serve:
	bundle exec jekyll serve --livereload --port 4000

.PHONY: theme
theme: THEME := $(shell awk -F': ' '$$1=="theme" || $$1=="remote_theme" { print $$2 }' _config.yml |sed 's,^.*jekyll-theme-,,')
theme: #THEME_PATH := $(shell bundle info --path $(THEME))
theme:
	@echo "$(THEME): $(THEME_PATH)"

.PHONY: lint
lint:
	yamllint _config.yml
