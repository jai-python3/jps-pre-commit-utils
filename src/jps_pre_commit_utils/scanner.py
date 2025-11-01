"""Diff scanning logic."""

from typing import Dict, List

from .rules import compile_patterns


def scan_diff(diff_text: str, config: Dict[str, any]) -> List[Dict[str, str]]:
    """Scan added lines and return list of findings."""
    patterns = compile_patterns(config.get("patterns", {}))
    findings = []
    for line in diff_text.splitlines():
        if not line.startswith("+") or line.startswith("+++ "):
            continue
        for group, regex_list in patterns.items():
            for regex in regex_list:
                if regex.search(line):
                    findings.append({"group": group, "pattern": regex.pattern, "line": line})
    return findings
