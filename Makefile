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

.PHONY: help clean version install-build-tools build publish install uninstall test lint format release bump_version changelog build-test

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
  --cov-config=.coveragerc \
  --cov-branch \
  --cov-fail-under=0 \
  --cov-append \
  --cov-context=test \
  --cov-report=xml \
  --cov-report=term-missing \
  --cov-branch \
  --cov-fail-under=0 \
  --cov-context=test \
  --cov-append \
  --cov-append \
  --cov-context=test \
  --cov-report=term-missing \
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
	@if [ -z "$(PART)" ]; then \
		echo "❌ Missing version part argument."; \
		echo "Usage: make release PART=[PATCH|MINOR|MAJOR] [DRYRUN=1]"; \
		exit 1; \
	fi; \

	@# Ensure working directory is completely clean (no modified or untracked files)
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo ""; \
		echo "❌ Working directory not clean. Commit or stash changes before releasing."; \
		exit 1; \
	fi; \
	$(MAKE) bump_version PART=$(PART) DRYRUN=$(DRYRUN); \
	if [ "$(DRYRUN)" = "1" ]; then \
		echo ""; \
		echo "🧪 [DRY RUN] Skipping commit, tag, push, changelog, and PyPI upload."; \
		exit 0; \
	fi; \
	VERSION=$$(cat .version); \
	echo ""; \
	echo "🔖 Releasing version $$VERSION"; \
	$(MAKE) changelog VERSION=$$VERSION; \
	git add pyproject.toml .version docs/CHANGELOG.md; \
	git commit -m "Release v$$VERSION"; \
	git tag -a "v$$VERSION" -m "Release v$$VERSION\n\nReleased on $(DATE)"; \
	git push origin main; \
	git push origin "v$$VERSION"; \
	$(MAKE) clean build; \
	echo ""; \
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
	@VERSION=$(VERSION); \
	if [ -z "$$VERSION" ]; then VERSION=$(CURRENT_VERSION); fi; \
	echo ""; \
	echo "🗒️  Updating docs/CHANGELOG.md for version $$VERSION"; \
	mkdir -p docs; \
	if [ ! -f docs/CHANGELOG.md ]; then \
		echo "# Changelog" > docs/CHANGELOG.md; \
		echo "" >> docs/CHANGELOG.md; \
	fi; \
	echo "## [$$VERSION] - $(DATE)" > docs/.CHANGELOG.tmp; \
	echo "- Released via automated Makefile workflow." >> docs/.CHANGELOG.tmp; \
	echo "" >> docs/.CHANGELOG.tmp; \
	prev_tag=$$(git describe --tags --abbrev=0 --match "v*" --exclude "v$$VERSION" 2>/dev/null || echo ""); \
	if [ -n "$$prev_tag" ]; then \
		echo "🧾 Including commits since $$prev_tag"; \
		git --no-pager log "$$prev_tag"..HEAD --pretty=format:"- [%ad] %an: %s" --date=short --no-color | tail -r >> docs/.CHANGELOG.tmp; \
	else \
		echo "🧾 No previous tag found — including all commits."; \
		git --no-pager log --pretty=format:"- [%ad] %an: %s" --date=short --no-color | tail -r >> docs/.CHANGELOG.tmp; \
	fi; \
	echo "" >> docs/.CHANGELOG.tmp; \
	# Prepend new changelog section (newest first)
	(cat docs/.CHANGELOG.tmp; echo ""; cat docs/CHANGELOG.md) > docs/.CHANGELOG.new; \
	mv docs/.CHANGELOG.new docs/CHANGELOG.md; \
	rm -f docs/.CHANGELOG.tmp; \
	echo "✅ Changelog updated at docs/CHANGELOG.md"



# Allow "make release PATCH" to behave like "make release PART=PATCH"
# PATCH MINOR MAJOR:
# 	@$(MAKE) release PART=$@ DRYRUN=$(DRYRUN)

changelog-preview:
	@printf "\n🧾 \\033[1;36mPreviewing changelog entries since last tag...\\033[0m\n"
	@latest_tag=$$(git describe --tags --abbrev=0 2>/dev/null || echo ""); \
	if [ -n "$$latest_tag" ]; then \
		printf "📌 \\033[1;34mComparing commits since %s\\033[0m\n\n" "$$latest_tag"; \
		git log "$$latest_tag"..HEAD --date=short \
			--pretty=format:"\\033[1;33m- [%ad]\\033[0m \\033[1;32m%an\\033[0m: %s" \
		| awk '{gsub(/\\033/, "\033"); print}' | sort -r; \
	else \
		printf "⚠️  \\033[1;31mNo tags found — showing all commits.\\033[0m\n"; \
		git log --date=short \
			--pretty=format:"\\033[1;33m- [%ad]\\033[0m \\033[1;32m%an\\033[0m: %s" \
		| awk '{gsub(/\\033/, "\033"); print}' | sort -r; \
	fi; \
	printf "\n✅ \\033[1;32mAbove entries would be added to the next changelog section.\\033[0m\n"



build-test:
	@$(MAKE) clean
	@$(MAKE) build
	@$(MAKE) test

