"""Rule set and pattern definitions."""

import re
from typing import Dict, List, Pattern


def compile_patterns(config: Dict[str, List[str]]) -> Dict[str, List[Pattern]]:
    """Compile regex patterns for performance."""
    compiled = {}
    for group, pats in config.items():
        compiled[group] = [re.compile(p) for p in pats]
    return compiled
