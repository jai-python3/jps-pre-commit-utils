# Changelog

## [v1.3.0] - 2025-11-14

- Changes since v1.2.0

- [2025-11-14] Jaideep Sundaram [(3881f33)](https://github.com/jai-python3/jps-pre-commit-utils/commit/3881f33): Release v1.3.0
- [2025-11-14] Jaideep Sundaram [(216fbf6)](https://github.com/jai-python3/jps-pre-commit-utils/commit/216fbf6): chore: autofix
- [2025-11-14] Jaideep Sundaram [(d7fdb0f)](https://github.com/jai-python3/jps-pre-commit-utils/commit/d7fdb0f): chore: fix lint issues
- [2025-11-14] Jaideep Sundaram [(e8695d0)](https://github.com/jai-python3/jps-pre-commit-utils/commit/e8695d0): removes instructions for build rule.
  updates instructions for fix, format, lint, test. adds help.py.
- [2025-11-14] Jaideep Sundaram [(bc0405d)](https://github.com/jai-python3/jps-pre-commit-utils/commit/bc0405d): chore: removes publish rule from
  Makefile and adds maintainer to pyproject.toml
- [2025-11-13] Jaideep Sundaram [(4a337db)](https://github.com/jai-python3/jps-pre-commit-utils/commit/4a337db): chore: fixes all lint issues
- [2025-11-13] Jaideep Sundaram [(cd169fe)](https://github.com/jai-python3/jps-pre-commit-utils/commit/cd169fe): chore: cleanup of Makefile and
  pyproject.toml
- [2025-11-09] Jaideep Sundaram [(0cd75b0)](https://github.com/jai-python3/jps-pre-commit-utils/commit/0cd75b0): chore: adds static code analysis
  tools
- [2025-11-02] Jaideep Sundaram [(6c99901)](https://github.com/jai-python3/jps-pre-commit-utils/commit/6c99901): moves support for deriving changelog
  into standalone Python program
- [2025-11-01] Jaideep Sundaram [(a559cd5)](https://github.com/jai-python3/jps-pre-commit-utils/commit/a559cd5): fix: removes trailing backslash
- [2025-11-01] Jaideep Sundaram [(4915302)](https://github.com/jai-python3/jps-pre-commit-utils/commit/4915302): fix for changelog indentations and
  line breaks.
- [2025-11-01] Jaideep Sundaram [(120b9a8)](https://github.com/jai-python3/jps-pre-commit-utils/commit/120b9a8): fix: release target trailing
  backslashes were missing
- [2025-11-01] Jaideep Sundaram [(86fe36e)](https://github.com/jai-python3/jps-pre-commit-utils/commit/86fe36e): adds @ prefix to quiet echoed command
  cat .version.
- [2025-11-01] Jaideep Sundaram [(5a2f073)](https://github.com/jai-python3/jps-pre-commit-utils/commit/5a2f073): adds @ prefix to quiet echoed
  commands
- [2025-11-01] Jaideep Sundaram [(1f64aa4)](https://github.com/jai-python3/jps-pre-commit-utils/commit/1f64aa4): chore: fixes all markdown issues
- [2025-11-01] Jaideep Sundaram [(247d2fe)](https://github.com/jai-python3/jps-pre-commit-utils/commit/247d2fe): adds support for set -euo pipefail at
  the start (to stop on any failure — lint, test, or markdownlint). adds support for dDuplicate-tag detection and abort.
- [2025-11-01] Jaideep Sundaram [(2531af9)](https://github.com/jai-python3/jps-pre-commit-utils/commit/2531af9): adds support to add short commit in
  changelog
- [2025-11-01] Jaideep Sundaram [(1448913)](https://github.com/jai-python3/jps-pre-commit-utils/commit/1448913): fixes changelog-preview. adds short
  commit hash and URL.
- [2025-11-01] Jaideep Sundaram [(2cb1804)](https://github.com/jai-python3/jps-pre-commit-utils/commit/2cb1804): changes changelog-preview to include
  entire commit message: subject and body. changes changelog-preview to indent lines.
- [2025-11-01] Jaideep Sundaram [(f2349a8)](https://github.com/jai-python3/jps-pre-commit-utils/commit/f2349a8): autoformatting using makrdownlint-
  cli2
- [2025-11-01] Jaideep Sundaram [(8e465e0)](https://github.com/jai-python3/jps-pre-commit-utils/commit/8e465e0): changes https to ssh-keys removes
  pytest updates hooks
- [2025-11-01] Jaideep Sundaram [(aab4012)](https://github.com/jai-python3/jps-pre-commit-utils/commit/aab4012): chore: updates pre-commit hooks,
  reorders
- [2025-11-01] Jaideep Sundaram [(b377e30)](https://github.com/jai-python3/jps-pre-commit-utils/commit/b377e30): initial check-in for
  .markdownlint.yaml
- [2025-11-01] Jaideep Sundaram [(0c93a8f)](https://github.com/jai-python3/jps-pre-commit-utils/commit/0c93a8f): improvements to CI/CD pipelines
- [2025-11-01] Jaideep Sundaram [(35a063e)](https://github.com/jai-python3/jps-pre-commit-utils/commit/35a063e): adjustments to changelog-preview
  target
- [2025-11-01] Jaideep Sundaram [(fff7b8b)](https://github.com/jai-python3/jps-pre-commit-utils/commit/fff7b8b): replaces tail -r with tac
- [2025-11-01] Jaideep Sundaram [(38b74ec)](https://github.com/jai-python3/jps-pre-commit-utils/commit/38b74ec): fixes changelog target so that will
  disable git log pager
- [2025-11-01] Jaideep Sundaram [(3006788)](https://github.com/jai-python3/jps-pre-commit-utils/commit/3006788): updates version to 1.2.0
- [2025-11-01] Jaideep Sundaram [(b6f7dc1)](https://github.com/jai-python3/jps-pre-commit-utils/commit/b6f7dc1): adds changelog-preview target. fixes
  release target so that the updated CHANGELOG.md gets tagged also.
- [2025-11-01] Jaideep Sundaram [(5d1f1bf)](https://github.com/jai-python3/jps-pre-commit-utils/commit/5d1f1bf): resorts CHANGELOG entires
- [2025-11-01] Jaideep Sundaram [(7ce4298)](https://github.com/jai-python3/jps-pre-commit-utils/commit/7ce4298): adds tests for cli and
  check_inserted_lines. formats with black. fixes with autoflake.
- [2025-11-01] Jaideep Sundaram [(aa52cdc)](https://github.com/jai-python3/jps-pre-commit-utils/commit/aa52cdc): adds tests. fixes implementation- now
  more complete.
- [2025-11-01] Jaideep Sundaram [(88ad2a4)](https://github.com/jai-python3/jps-pre-commit-utils/commit/88ad2a4): initial check-in for .pre-commit-
  config.yaml
- [2025-11-01] Jaideep Sundaram [(22533e7)](https://github.com/jai-python3/jps-pre-commit-utils/commit/22533e7): adds autoflake pre-commit. adds new
  targets `make fix` and `make precommit`. adds lint and test as dependencies to `make build` and `make release` targets.
- [2025-11-01] Jaideep Sundaram [(777b946)](https://github.com/jai-python3/jps-pre-commit-utils/commit/777b946): refactors the code and adds more
  tests to increase test coverage
- [2025-11-01] Jaideep Sundaram [(7893ace)](https://github.com/jai-python3/jps-pre-commit-utils/commit/7893ace): adds pythonpath = ["src"] to
  [tool.pytest.ini_options]
- [2025-11-01] Jaideep Sundaram [(4441a6b)](https://github.com/jai-python3/jps-pre-commit-utils/commit/4441a6b): fixes clean
- [2025-11-01] Jaideep Sundaram [(ed8976b)](https://github.com/jai-python3/jps-pre-commit-utils/commit/ed8976b): updates version in pyproject.toml to
  v1.2.0
- [2025-11-01] Jaideep Sundaram [(e843d52)](https://github.com/jai-python3/jps-pre-commit-utils/commit/e843d52): updates CHANGELOG for release v1.2.0

## [1.2.0] - 2025-11-01

- Released via automated Makefile workflow.

- [2025-11-01] Jaideep Sundaram: Release v1.2.0
- [2025-11-01] Jaideep Sundaram: adds project urls.
- [2025-11-01] Jaideep Sundaram: updates checks. removes pip cache.
- [2025-11-01] Jaideep Sundaram: splits pytest command-line parameters onto separate lines.
- [2025-11-01] Jaideep Sundaram: updates CHANGELOG for release

## [1.1.0] - 2025-10-31

- Released via automated Makefile workflow.

- [2025-10-31] Jaideep Sundaram: Release v1.1.0
- [2025-10-31] Jaideep Sundaram: format with black
- [2025-10-31] Jaideep Sundaram: fixes codecov upload support
- [2025-10-31] Jaideep Sundaram: adds test coverage
- [2025-10-31] Jaideep Sundaram: adds flake8 config
- [2025-10-31] Jaideep Sundaram: adds tests
- [2025-10-31] Jaideep Sundaram: format with black
- [2025-10-31] Jaideep Sundaram: adds CI/CD pipeline definitions
- [2025-10-31] Jaideep Sundaram: adds build-test and bump_version MAJOR check
- [2025-10-31] Jaideep Sundaram: Initial commit - project scaffold for jps-pre-commit-utils
- [2025-10-31] Jaideep Sundaram: Initial commit - bootstrap jps-pre-commit-utils

## [1.0.0] - 2025-10-31

- Initial release of `jps-pre-commit-utils`
- Added CLI utility to scan staged diffs for debug/test patterns and hardcoded paths
