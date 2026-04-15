SHELL := /bin/bash
LANGS := python nodejs ruby php bash-curl zsh applescript swift-scripting perl awk

.PHONY: help test capture clean install $(addprefix test-,$(LANGS)) $(addprefix capture-,$(LANGS))

help:
	@echo "apfel-guides-lab"
	@echo ""
	@echo "Targets:"
	@echo "  test                 - run all language tests against live apfel --serve"
	@echo "  test-<lang>          - test single language (python, nodejs, ruby, php, bash-curl, zsh, applescript, swift-scripting, perl, awk)"
	@echo "  capture              - re-run all scripts and write outputs/<lang>/*.txt"
	@echo "  capture-<lang>       - capture single language"
	@echo "  install              - install per-language deps (uv sync, npm install, composer install, bundle install)"
	@echo "  clean                - remove caches and node_modules/vendor"

install:
	@echo "==> python (uv)"
	@cd scripts/python && [ -f pyproject.toml ] && uv sync || true
	@echo "==> nodejs (npm)"
	@cd scripts/nodejs && [ -f package.json ] && npm install --silent || true
	@echo "==> ruby (bundle)"
	@cd scripts/ruby && [ -f Gemfile ] && bundle install --quiet || true
	@echo "==> php (composer)"
	@cd scripts/php && [ -f composer.json ] && composer install --quiet || true

test:
	pytest -v

$(addprefix test-,$(LANGS)):
	pytest -v tests/test_$(subst test-,,$(subst -,_,$@)).py

capture: test
	CAPTURE=1 pytest -v

$(addprefix capture-,$(LANGS)):
	CAPTURE=1 pytest -v tests/test_$(subst capture-,,$(subst -,_,$@)).py

clean:
	rm -rf .pytest_cache __pycache__ **/__pycache__
	rm -rf scripts/nodejs/node_modules scripts/php/vendor
	find . -name "*.pyc" -delete
