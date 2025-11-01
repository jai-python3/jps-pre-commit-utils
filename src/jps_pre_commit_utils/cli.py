"""CLI entrypoint for jps-pre-commit-utils."""

from .config import load_config
from .git_diff import get_staged_diff
from .report import print_report
from .scanner import scan_diff


def main() -> int:
    """Main entrypoint for pre-commit checks."""
    config = load_config()
    added_lines = get_staged_diff()
    findings = scan_diff(added_lines, config)
    print_report(findings)
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
