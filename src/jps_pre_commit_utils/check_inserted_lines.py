#!/usr/bin/env python3
"""Legacy wrapper for jps-pre-commit-utils.

This module exists for backward compatibility with the entry point:
    jj-pre-commit-checks = "jps_pre_commit_utils.check_inserted_lines:main"

All functional logic has been refactored into jps_pre_commit_utils.cli.

It is safe to migrate the entry point to:
    jj-pre-commit-checks = "jps_pre_commit_utils.cli:main"
in a future release.
"""

import warnings

from jps_pre_commit_utils.cli import main as cli_main

# Emit a deprecation warning for developers and maintainers.
warnings.warn(
    "⚠️  The module 'jps_pre_commit_utils.check_inserted_lines' is deprecated. "
    "Please use 'jps_pre_commit_utils.cli' instead.",
    DeprecationWarning,
    stacklevel=2,
)


def main() -> int:
    """Delegate CLI execution to jps_pre_commit_utils.cli.main()."""
    return cli_main()


if __name__ == "__main__":
    raise SystemExit(main())
