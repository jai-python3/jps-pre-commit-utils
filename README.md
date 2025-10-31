# jps-pre-commit-utils

Pre-commit utilities for detecting debug/test leftovers, hardcoded paths, and other configurable issues
before code is committed. Provides a customizable YAML-based configuration and supports Python, Perl, and YAML files.

## 🧩 Installation
```bash
pip install jps-pre-commit-utils
```

## 🧩 Usage
```bash
jj-pre-commit-checks
```

Optionally configure behavior via `.my-pre-commit-checks.yaml` in your repository root
or `~/.config/my-pre-commit-checks.yaml`.

## 🧾 Example Configuration
```yaml
base_paths:
  - /mnt/pure3
  - /Users
ignore_patterns:
  - /mnt/pure3/bioinfo/shared/
extra_regexes:
  - "jira/[A-Z]+-[0-9]+"
```

## 🧪 Example Run
```bash
git add .
jj-pre-commit-checks
```

Output:
```
🔧 Performing the following checks:
• 🐍 Python debug/test statements
• 🐪 Perl debug/test statements
• 📁 Hardcoded absolute paths
• 🧪 Comments containing 'test' or 'testing'
```

## 🧱 Development
```bash
pip install -e '.[dev]'
make lint
make test
```

## 🧾 License
MIT License © 2025 Jaideep Sundaram
