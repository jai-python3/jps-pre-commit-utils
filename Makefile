# ===========================================================
# Makefile for jps-pre-commit-utils
# ===========================================================
SHELL := /bin/bash

PACKAGE_NAME := jps-pre-commit-utils
PYTHON := python3
PIP := pip
CURRENT_VERSION := $(shell grep -m1 '^version =' pyproject.toml | sed 's/.*"\(.*\)".*/\1/')
PART := $(word 2, $(MAKECMDGOALS))
DRYRUN ?= 0
DATE := $(shell date +'%Y-%m-%d')

.PHONY: help clean version install-build-tools build install uninstall test lint format build-test precommit vulture

# -----------------------------------------------------------
# Help
# -----------------------------------------------------------
help:
	@echo ""
	@echo "Available make targets:"
	@echo "  make help                  - Show this help message"
	@echo "  make clean                 - Remove build artifacts and caches"
	@echo "  make version               - Show current version"
	@echo "  make install-build-tools   - Install build dependencies"
	@echo "  make build                 - Build the package"
	@echo "  make install               - Install package locally (editable mode)"
	@echo "  make uninstall             - Uninstall package"
	@echo "  make test                  - Run tests with pytest"
	@echo "  make lint                  - Run flake8 lint checks"
	@echo "  make format                - Format code with black"
	@echo "  make fix                   - Auto-fix code style and imports"
	@echo "  make build-test            - Clean, build, and test the package"
	@echo "  make precommit             - Run pre-commit hooks on all files"
	@echo "  make vulture               - Run vulture to find unused code"

# -----------------------------------------------------------
# Clean and Utility
# -----------------------------------------------------------
clean:
	@echo ""
	@echo "🧹 Cleaning build and cache artifacts..."
	rm -rf build dist .pytest_cache .coverage
	find . -type d -name '__pycache__' -exec rm -rf {} +
	find . -type d -name '*.egg-info' -exec rm -rf {} +

version:
	@echo ""
	@echo "📦 Current version: $(CURRENT_VERSION)"

# -----------------------------------------------------------
# Build, Publish, Install, Uninstall
# -----------------------------------------------------------
install-build-tools:
	@echo ""
	@echo "🛠️  Installing build tools..."
	$(PIP) install -e '.[dev]'

build: lint test
	@echo ""
	@echo "🔧 Building the package..."
	$(PYTHON) -m build

build-test:
	@$(MAKE) clean
	@$(MAKE) build
	@$(MAKE) test

publish:
	@echo ""
	@echo "🚀 Publishing distribution to PyPI..."
	twine upload dist/*

install:
	@echo ""
	@echo "📦 Installing package in editable mode..."
	$(PIP) install -e .

uninstall:
	@echo ""
	@echo "🗑️  Uninstalling package..."
	$(PIP) uninstall -y $(PACKAGE_NAME)

# -----------------------------------------------------------
# QA / Developer Convenience
# -----------------------------------------------------------
test:
	@echo ""
	@echo "🧪 Running pytest with coverage..."
	pytest -v --disable-warnings \
	  --cov=src/jps_pre_commit_utils \
	  --cov-report=term-missing \
	  --cov-report=xml \
	  --cov-config=.coveragerc \
	  --cov-branch \
	  --cov-fail-under=0 \
	  --cov-append \
	  --cov-context=test

lint:
	@echo ""
	@echo "🔍 Running flake8 lint checks..."
	flake8 src tests

format:
	@echo ""
	@echo "🎨 Formatting code with black..."
	black src tests

fix:
	@echo ""
	@echo "🧹 Auto-removing unused imports, sorting, and formatting code..."
	autoflake --in-place --recursive --remove-all-unused-imports --remove-unused-variables --ignore-init-module-imports src tests
	isort src tests
	black src tests
	flake8 src tests

precommit:
	@echo "✅ Running pre-commit hooks on all files..."
	pre-commit run --all-files

vulture:
	@echo "🪶 Running Vulture dead code analysis..."
	vulture src --min-confidence 80 --exclude tests,venv,build,dist
