# Run `make` with no arguments for the list.

.DEFAULT_GOAL := help

## help: list these targets
.PHONY: help
help:
	@grep -E '^## [a-z]' $(MAKEFILE_LIST) \
	  | sed 's/^## //' \
	  | awk -F': ' '{printf "  %-12s %s\n", $$1, $$2}'

## install: bundle install
.PHONY: install
install:
	bundle install

## build: jekyll build into _site
.PHONY: build
build:
	bundle exec jekyll build

## serve: jekyll serve with livereload on port 4000
.PHONY: serve
serve:
	bundle exec jekyll serve --livereload --port 4000

## check: build, then run the static site checks
.PHONY: check
check: build
	./bin/check-site.sh

## lint: yamllint _config.yml
.PHONY: lint
lint:
	yamllint _config.yml

## analytics: snapshot GA4 + Search Console into analytics/
.PHONY: analytics
analytics:
	./analytics/pull.sh

## calendar: print dated entries from a district PDF (CAL=path)
.PHONY: calendar
calendar:
	@./bin/read-calendar.sh $(CAL)

## phase: set the season phase (PHASE=signup|preseason|season|wrapup|offseason)
.PHONY: phase
phase:
	@./bin/set-phase.sh $(PHASE)

## update: bundle update --all
.PHONY: update
update:
	@echo "FYI: https://jekyllrb.com/docs/upgrading/"
	bundle update --all

## theme: show which theme _config.yml resolves to
.PHONY: theme
theme:
	@awk -F': ' '$$1=="theme" || $$1=="remote_theme" { print $$2 }' _config.yml

# local.yml is no longer needed: _config.yml uses `theme:` with the bundled gem,
# so local and CI builds read the same config. Kept as a no-op so an old habit
# or script doesn't break.
.PHONY: local-config
local-config:
	@echo "Not needed anymore -- _config.yml uses the bundled theme directly."

.PHONY: edit
edit:
	vim _pages/*.md
