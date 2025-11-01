"""Configuration loader for jps-pre-commit-utils.

This module loads pattern and path configuration from YAML files if present,
falling back to reasonable defaults when none exist. It is used by the main
pre-commit checker (`check_inserted_lines.py`) to determine which patterns
and base paths to scan for in added lines.
"""

from __future__ import annotations
import os
import yaml
from pathlib import Path
from typing import Any, Dict


def _deep_merge(base: dict, override: dict) -> dict:
    """Recursively merge two dictionaries."""
    result = dict(base)
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = _deep_merge(result[key], value)
        else:
            result[key] = value
    return result


def load_config() -> Dict[str, Any]:
    """Load configuration for pre-commit checks.

    This function checks for a configuration file in the following order:
      1. The current working directory (`./my-pre-commit-checks.yaml`)
      2. The user's configuration directory (`~/.config/my-pre-commit-checks.yaml`)

    If no configuration file is found, a default configuration is returned.

    Returns:
        dict: A configuration dictionary containing:
            - patterns (list[str]): forbidden or flagged code patterns
            - base_paths (list[str]): common absolute paths to detect hard-coding
            - ignore_patterns (list[str]): paths or regexes to ignore
            - extra_regexes (list[str]): additional regex patterns to include
    """
    default_config: Dict[str, Any] = {
        "patterns": {
            "python": [
                r"sys\.exit",
                r"logger\.debug",
                r"logging\.debug",
                r"test",
                r"TODO",
            ],
            "perl": [
                r"die",
                r"confess",
                r"print",
                r"test",
                r"TODO",
            ],
        },
        "paths": ["/mnt/pure3", "/Users", r"C:\\Users"],
        "ignore_patterns": ["/mnt/pure3/bioinfo/shared/"],
        "extra_regexes": [r"jira/[A-Z]+-[0-9]+"],
    }
    # Support both .my-pre-commit-checks.yaml and my-pre-commit-checks.yaml
    local_candidates = [
        Path.cwd() / ".my-pre-commit-checks.yaml",
        Path.cwd() / "my-pre-commit-checks.yaml",
    ]
    home_dir = Path.home()
    home_candidates = [
        home_dir / ".config" / "my-pre-commit-checks.yaml",
        home_dir / ".config" / ".my-pre-commit-checks.yaml",
    ]

    for path in (*local_candidates, *home_candidates):
        if path.exists():
            try:
                with open(path, "r", encoding="utf-8") as fh:
                    loaded = yaml.safe_load(fh) or {}
                if not isinstance(loaded, dict):
                    raise ValueError("Configuration must be a YAML mapping (dict).")
                merged = _deep_merge(default_config, loaded)
                return merged
            except Exception as exc:
                print(f"⚠️  Failed to load config from {path}: {exc}")
                break

    return default_config


if __name__ == "__main__":
    import pprint

    pprint.pprint(load_config())
