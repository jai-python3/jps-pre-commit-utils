"""Git diff handling."""

import subprocess


def get_staged_diff() -> str:
    """Return the staged diff (added lines only)."""
    result = subprocess.run(
        ["git", "diff", "--cached", "--unified=0"],
        capture_output=True,
        text=True,
        check=False,
    )
    return result.stdout or ""
