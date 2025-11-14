#!/usr/bin/env python3
"""
update_changelog.py

Generates or previews a CHANGELOG.md section for the current version
using git commit history. Captures only the first line (subject)
from each commit message.

Usage:
    python scripts/update_changelog.py <version> [--preview]
"""

import subprocess
import sys
from datetime import date
from pathlib import Path
from typing import List


# -------------------------------------------------------------
# Utility functions
# -------------------------------------------------------------
def run_git_command(args: List[str]) -> str:
    """Execute a git command and return stdout as text.

    Args:
        args: List of git command arguments.

    Returns:
        The standard output from the git command as a string.
    """
    result = subprocess.run(
        ["git", "--no-pager", *args],
        capture_output=True,
        text=True,
        check=False,
    )
    return result.stdout.strip()


def get_latest_tag() -> str | None:
    """Return the latest version tag matching v* (or None).

    Returns:
        The latest tag string or None if not found.
    """
    try:
        tag = run_git_command(["describe", "--tags", "--abbrev=0", "--match", "v*"])
        return tag or None
    except subprocess.CalledProcessError:
        return None


def get_commits(prev_tag: str | None = None) -> List[dict]:
    """Retrieve commits, capturing only the first line (subject).

    Args:
        prev_tag: The previous tag to start from (exclusive). If None, uses all history

    Returns:
        A list of commit dictionaries with keys: hash, date, author, subject.
    """
    fmt = "%h%x1f%ad%x1f%an%x1f%s%x1e"
    args = [
        "log",
        f"{prev_tag}..HEAD" if prev_tag else "HEAD",
        f"--pretty=format:{fmt}",
        "--date=short",
        "--no-color",
    ]
    output = run_git_command(args)
    entries = []
    for raw in output.strip().split("\x1e"):
        if not raw.strip():
            continue
        parts = raw.split("\x1f")
        if len(parts) < 4:
            continue
        short_hash, commit_date, author, subject = parts[:4]
        entries.append(
            {
                "hash": short_hash.strip(),
                "date": commit_date.strip(),
                "author": author.strip(),
                "subject": subject.strip(),
            }
        )
    return entries[::-1]  # newest last for natural order


# -------------------------------------------------------------
# Formatting functions
# -------------------------------------------------------------
def format_changelog_entries(entries: List[dict], repo_url: str, color: bool = False) -> str:
    """Format commit entries into Markdown or colorized terminal output.

    Args:
        entries: List of commit dictionaries with keys: hash, date, author, subject.
        repo_url: Base URL of the repository for commit links.
        color: If True, add ANSI color codes for terminal output.

    Returns:
        Formatted changelog string.
    """
    lines = []
    for e in entries:
        commit_link = f"[({e['hash']})]({repo_url}/commit/{e['hash']})"
        if color:
            # Add ANSI colors for terminal preview only
            YELLOW = "\033[1;33m"
            GREEN = "\033[1;32m"
            CYAN = "\033[1;36m"
            RESET = "\033[0m"
            lines.append(
                f"- {YELLOW}[{e['date']}] {RESET}"
                f"{GREEN}{e['author']}{RESET} "
                f"{CYAN}{commit_link}{RESET}: {e['subject']}"
            )
        else:
            # Plain Markdown (no ANSI escapes)
            lines.append(f"- [{e['date']}] {e['author']} {commit_link}: {e['subject']}")
    return "\n".join(lines) + "\n"


def build_changelog_section(version: str, repo_url: str, preview: bool = False) -> str:
    """Generate the full changelog text for a given version.

    Args:
        version: The new version string (e.g., "v1.2.3").
        repo_url: Base URL of the repository for commit links.
        preview: If True, format with terminal colors for preview.

    Returns:
        The complete changelog section as a string.
    """
    today = date.today().strftime("%Y-%m-%d")
    prev_tag = get_latest_tag()

    if preview:
        print("🧾 Previewing changelog entries since last tag...")
    else:
        print("🧾 Updating CHANGELOG.md...")

    header = f"## [{version}] - {today}\n- Released via automated Makefile workflow.\n\n"
    entries = get_commits(prev_tag)
    body = format_changelog_entries(entries, repo_url, color=preview)
    return header + body


def prepend_to_file(path: Path, text: str) -> None:
    """Prepend text to a file, creating it if necessary.

    Args:
        path: Path to the file to prepend text to.
        text: The text to prepend.
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.write_text("# Changelog\n\n")
    existing = path.read_text()
    path.write_text(text + "\n" + existing)


# -------------------------------------------------------------
# Main
# -------------------------------------------------------------
def main() -> None:
    if len(sys.argv) < 2:
        print("❌ Missing version argument.")
        print("Usage: update_changelog.py <version> [--preview]")
        sys.exit(1)

    version = sys.argv[1]
    preview = "--preview" in sys.argv
    repo_url = "https://github.com/jai-python3/jps-pre-commit-utils"

    changelog_section = build_changelog_section(version, repo_url, preview=preview)

    if preview:
        print(changelog_section)
        print("✅ Above entries would be added to the next changelog section.")
    else:
        changelog_path = Path("docs/CHANGELOG.md")
        prepend_to_file(changelog_path, changelog_section)
        print(f"✅ CHANGELOG updated at {changelog_path}")


if __name__ == "__main__":
    main()
