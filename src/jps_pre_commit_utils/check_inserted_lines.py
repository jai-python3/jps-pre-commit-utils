#!/usr/bin/env python3
"""
check_inserted_lines.py (v1.1.1)
-----------------------------------------------------------
Custom pre-commit utility to scan staged diffs for newly
added lines that contain debugging, test, or hardcoded
path patterns in Python and Perl source files.
"""

import re
import subprocess
import sys
from pathlib import Path
import yaml
from rich.console import Console
from rich.progress import Progress, BarColumn, TextColumn, TimeRemainingColumn

console = Console()

# -----------------------------------------------------------
# Default regex patterns
# -----------------------------------------------------------

PYTHON_PATTERNS = [
    r"\bsys\.exit\s*\(",
    r"\blogger\.debug\s*\(",
    r"\blogging\.debug\s*\(",
    r"#\s*TODO",
    r"#.*test",  # match any comment containing "test"
]

PERL_PATTERNS = [
    r"\bdie\b",
    r"\bconfess\b",
    r"\bprint\b",
    r"#\s*TODO",
    r"#.*test",  # match any comment containing "test"
]

DEFAULT_PATH_REGEX = r"(/mnt|/home|/Users|C:\\\\Users)[A-Za-z0-9._/\-]+"


# -----------------------------------------------------------
# Helper functions
# -----------------------------------------------------------


def load_config() -> dict:
    """Load configuration from repo or user config file."""
    local_cfg = Path(".my-pre-commit-checks.yaml")
    user_cfg = Path.home() / ".config" / "my-pre-commit-checks.yaml"
    cfg_path = local_cfg if local_cfg.exists() else user_cfg

    if not cfg_path.exists():
        return {"base_paths": [], "ignore_patterns": [], "extra_regexes": []}

    try:
        with open(cfg_path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    except Exception as e:
        console.print(f"[yellow]⚠️  Failed to read config file {cfg_path}: {e}[/yellow]")
        return {"base_paths": [], "ignore_patterns": [], "extra_regexes": []}


def get_staged_diff() -> str:
    """Return the staged diff as text."""
    try:
        diff = subprocess.run(
            ["git", "diff", "--cached", "--unified=0", "--no-color"],
            capture_output=True,
            text=True,
            check=False,
        )
        return diff.stdout
    except Exception as e:
        console.print(f"[red]❌ Error running git diff: {e}[/red]")
        sys.exit(1)


def classify_file(filename: str) -> str:
    """Return 'python', 'perl', or 'other' based on file extension."""
    if filename.endswith(".py"):
        return "python"
    if filename.endswith((".pl", ".pm", ".t")):
        return "perl"
    return "other"


def compile_patterns(config: dict):
    """Compile regex patterns based on config and language defaults."""
    combined = {
        "python": [re.compile(p, re.IGNORECASE) for p in PYTHON_PATTERNS],
        "perl": [re.compile(p, re.IGNORECASE) for p in PERL_PATTERNS],
        "common": [],
    }

    # Add hardcoded path detection
    path_regex = DEFAULT_PATH_REGEX
    for base_path in config.get("base_paths", []):
        path_regex += f"|{re.escape(base_path)}"
    combined["common"].append(re.compile(path_regex, re.IGNORECASE))

    # Add extra regexes
    for rex in config.get("extra_regexes", []):
        combined["common"].append(re.compile(rex, re.IGNORECASE))

    return combined


def should_ignore(line: str, config: dict) -> bool:
    """Return True if line matches any ignore patterns."""
    for pattern in config.get("ignore_patterns", []):
        if re.search(pattern, line):
            return True
    return False


def parse_diff(diff_text: str, config: dict) -> list:
    """
    Parse the diff and return a list of tuples:
    (filename, line_number, added_line)
    """
    findings = []
    current_file = None
    line_number = None
    added_line_pattern = re.compile(r"^\+(?!\+\+)(.*)")
    hunk_header = re.compile(r"@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@")

    for line in diff_text.splitlines():
        if line.startswith("+++ b/"):
            current_file = line[6:]
        elif hunk_header.match(line):
            m = hunk_header.match(line)
            line_number = int(m.group(1))
        elif line.startswith("+") and not line.startswith("+++"):
            if current_file and added_line_pattern.match(line):
                added_line = added_line_pattern.match(line).group(1)
                findings.append((current_file, line_number, added_line))
            if line_number is not None:
                line_number += 1

    return findings


def scan_findings(findings, patterns, config):
    """Scan added lines and return list of violations."""
    violations = []
    total = len(findings)

    with Progress(
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TextColumn("{task.completed}/{task.total}"),
        TimeRemainingColumn(),
        transient=True,
        console=console,
    ) as progress:
        task = progress.add_task("Scanning inserted lines", total=total)

        for filename, lineno, line in findings:
            if should_ignore(line, config):
                progress.advance(task)
                continue

            lang = classify_file(filename)
            applicable_patterns = patterns.get(lang, []) + patterns.get("common", [])

            for pattern in applicable_patterns:
                if pattern.search(line):
                    violations.append(
                        {
                            "file": filename,
                            "line": lineno,
                            "pattern": pattern.pattern,
                            "content": line.strip(),
                        }
                    )
                    break  # only report first matching pattern per line
            progress.advance(task)

    return violations


def print_checks_summary(config):
    """Print the list of checks being performed."""
    console.print("---------------------------------------------------------")
    console.print("[bold]🔧 Performing the following checks:[/bold]")
    console.print("---------------------------------------------------------")
    console.print("• 🐍 Python debug/test statements")
    console.print("• 🐪 Perl debug/test statements")
    console.print("• 📁 Hardcoded absolute paths")
    console.print("• 🧪 Comments containing 'test' or 'testing'")
    if config.get("extra_regexes"):
        console.print("• ⚙️  Additional regex patterns (from config)")
    console.print("---------------------------------------------------------")


def print_report(violations):
    """Print summary report."""
    console.print("---------------------------------------------------------")
    console.print("[bold]🔍 Pre-commit inserted-line scan results[/bold]")
    console.print("---------------------------------------------------------")

    if not violations:
        console.print("[green]✅ No issues detected. (0 findings)[/green]")
        console.print("---------------------------------------------------------")
        return 0

    for v in violations:
        console.print(f"[yellow]⚠️  File:[/yellow] {v['file']}, Line: {v['line']}")
        console.print(f"    Added line contains pattern: \"{v['pattern']}\"")
        console.print(f"    → {v['content']}\n")

    console.print(f"[yellow]⚠️  Total findings: {len(violations)}[/yellow]")
    console.print("---------------------------------------------------------")
    return 1


# -----------------------------------------------------------
# Main entry point
# -----------------------------------------------------------


def main():
    config = load_config()
    print_checks_summary(config)
    diff_text = get_staged_diff()
    findings = parse_diff(diff_text, config)
    patterns = compile_patterns(config)
    violations = scan_findings(findings, patterns, config)
    exit_code = print_report(violations)
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
