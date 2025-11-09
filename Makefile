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

.PHONY: help clean version install-build-tools build publish install uninstall test lint format release bump_version changelog build-test precommit vulture

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
	@echo "  make publish               - Upload built package to PyPI"
	@echo "  make install               - Install package locally (editable mode)"
	@echo "  make uninstall             - Uninstall package"
	@echo "  make test                  - Run tests with pytest"
	@echo "  make lint                  - Run flake8 lint checks"
	@echo "  make format                - Format code with black"
	@echo "  make release [PATCH|MINOR|MAJOR] [DRYRUN=1] - Bump version, tag, build, and publish release"
	@echo "  make changelog             - Append latest release entry to docs/CHANGELOG.md"
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

# -----------------------------------------------------------
# Semantic Version Bumping and Release
# -----------------------------------------------------------
bump_version:
	@part=$(PART); \
	if [ "$$part" = "MAJOR" ]; then \
		read -p "⚠️  Confirm MAJOR version bump (y/N): " confirm; \
		[ "$$confirm" = "y" ] || { echo "❌ Aborted."; exit 1; }; \
	fi; \
	current=$(CURRENT_VERSION); \
	IFS=. read -r major minor patch <<< "$$current"; \
	case "$$part" in \
	  PATCH) patch=$$((patch+1));; \
	  MINOR) minor=$$((minor+1)); patch=0;; \
	  MAJOR) major=$$((major+1)); minor=0; patch=0;; \
	  *) echo "Usage: make release [PATCH|MINOR|MAJOR] [DRYRUN=1]" && exit 1;; \
	esac; \
	new_version="$$major.$$minor.$$patch"; \
	echo ""; \
	if [ "$(DRYRUN)" = "1" ]; then \
		echo "🧪 [DRY RUN] Would bump version: $$current → $$new_version"; \
	else \
		sed -i "s/^version = \".*\"/version = \"$$new_version\"/" pyproject.toml; \
		echo "$$new_version" > .version; \
		echo "🔢 Bumped version: $$current → $$new_version"; \
	fi

release: lint test
	@set -euo pipefail; \
	\
	# --- Validate input arguments --- \
	if [ -z "$(PART)" ]; then \
		echo "❌ Missing version part argument."; \
		echo "Usage: make release PART=[PATCH|MINOR|MAJOR] [DRYRUN=1]"; \
		exit 1; \
	fi; \
	\
	# --- Verify working directory cleanliness --- \
	if [ -n "$$(git status --porcelain)" ]; then \
		echo ""; \
		echo "❌ Working directory not clean. Commit or stash changes before releasing."; \
		exit 1; \
	fi; \
	\
	# --- Compute version bump --- \
	$(MAKE) bump_version PART=$(PART) DRYRUN=$(DRYRUN); \
	\
	# --- Handle DRY RUN mode --- \
	if [ "$(DRYRUN)" = "1" ]; then \
		echo ""; \
		echo "🧪 [DRY RUN] Skipping commit, tag, push, changelog, and PyPI upload."; \
		echo "🧩 Dry-run mode ends successfully — no files modified."; \
		exit 0; \
	fi; \
	\
	# --- Read new version and verify tag uniqueness --- \
	VERSION=$$(cat .version); \
	if git rev-parse "v$$VERSION" >/dev/null 2>&1; then \
		echo ""; \
		echo "⚠️  Tag v$$VERSION already exists — aborting release."; \
		exit 1; \
	fi; \
	\
	# --- Proceed with release --- \
	echo ""; \
	echo "🔖 Releasing version $$VERSION"; \
	$(MAKE) changelog VERSION=$$VERSION; \
	git add pyproject.toml .version docs/CHANGELOG.md; \
	git commit -m "Release v$$VERSION"; \
	git tag -a "v$$VERSION" -m "Release v$$VERSION\n\nReleased on $(DATE)"; \
	git push origin main; \
	git push origin "v$$VERSION"; \
	\
	# --- Rebuild for confirmation (safety measure) --- \
	$(MAKE) clean build; \
	echo ""; \
	\
	# --- Post-release summary --- \
	echo "🚀 Skipping local PyPI upload — CI will publish automatically upon tag push."; \
	echo "✅ Successfully created and pushed release tag v$$VERSION to GitHub."; \
	echo "ℹ️  The GitHub Actions workflow 'Publish to PyPI' will now build and upload the package."; \
	echo "ℹ️  If the version already exists on PyPI, CI will detect it and skip the upload safely."; \
	echo ""; \
	echo "📦 Release summary:"; \
	echo "   - Version: v$$VERSION"; \
	echo "   - Date: $(DATE)"; \
	echo "   - CI workflow: https://github.com/jai-python3/jps-pre-commit-utils/actions/workflows/publish-to-pypi.yml"


# 	echo ""; \
# 	echo "🚀 Skipping local PyPI upload — CI will publish automatically upon tag push."; \
# 	echo "✅ Successfully created and pushed release tag v$$VERSION to GitHub."; \
# 	echo "ℹ️  The GitHub Actions workflow 'Publish to PyPI' will now handle the actual upload."

# 	twine upload dist/*; \
# 	echo ""; \
# 	echo "✅ Successfully released v$$VERSION to PyPI and GitHub."

# -----------------------------------------------------------
# Friendly dispatcher: allow "make release PATCH" or "make release PART=PATCH"
# -----------------------------------------------------------
ifeq ($(firstword $(MAKECMDGOALS)),release)
ifneq ($(word 2, $(MAKECMDGOALS)),)
PART := $(word 2, $(MAKECMDGOALS))
$(eval $(word 2, $(MAKECMDGOALS)):;@:)
endif
endif


# -----------------------------------------------------------
# Changelog Update with Commit Summaries (Author + Date)
# -----------------------------------------------------------
changelog:
	@set -euo pipefail; \
	echo "🗒️  Updating CHANGELOG.md..."; \
	python3 scripts/update_changelog.py "$(CURRENT_VERSION)"; \
	echo "✅ CHANGELOG updated successfully."

changelog-preview:
	@set -euo pipefail; \
	echo "🧾 Previewing changelog entries..."; \
	python3 scripts/update_changelog.py "$(CURRENT_VERSION)" --preview

# Allow "make release PATCH" to behave like "make release PART=PATCH"
# PATCH MINOR MAJOR:
# 	@$(MAKE) release PART=$@ DRYRUN=$(DRYRUN)

build-test:
	@$(MAKE) clean
	@$(MAKE) build
	@$(MAKE) test

