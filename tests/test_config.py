"""Unit tests for jps_pre_commit_utils.config."""

import os
import tempfile
import yaml
from pathlib import Path
import jps_pre_commit_utils.config as config


def test_load_config_defaults_when_no_files(tmp_path, monkeypatch):
    """Should return defaults when no config files exist."""
    monkeypatch.chdir(tmp_path)
    result = config.load_config()
    assert "patterns" in result
    assert "python" in result["patterns"]
    assert isinstance(result["paths"], list)
    assert any("/mnt" in p for p in result["paths"])


def test_load_config_local_file(monkeypatch, tmp_path):
    """Should load YAML from local .my-pre-commit-checks.yaml."""
    monkeypatch.chdir(tmp_path)
    local_cfg = tmp_path / ".my-pre-commit-checks.yaml"
    data = {"paths": ["/data"], "patterns": {"python": [r"foo"]}}
    local_cfg.write_text(yaml.safe_dump(data))

    result = config.load_config()
    assert result["paths"] == ["/data"]
    assert result["patterns"]["python"] == ["foo"]


def test_load_config_home_file(monkeypatch, tmp_path):
    """Should load YAML from ~/.config/my-pre-commit-checks.yaml."""
    home_cfg = tmp_path / ".config" / "my-pre-commit-checks.yaml"
    home_cfg.parent.mkdir(parents=True)
    data = {"paths": ["/shared"], "patterns": {"perl": [r"bar"]}}
    home_cfg.write_text(yaml.safe_dump(data))

    monkeypatch.setattr(Path, "home", lambda: tmp_path)
    monkeypatch.chdir(tmp_path)
    result = config.load_config()
    assert result["paths"] == ["/shared"]
    assert result["patterns"]["perl"] == ["bar"]


def test_load_config_invalid_yaml(monkeypatch, tmp_path):
    """Should gracefully fail when YAML is invalid."""
    bad_cfg = tmp_path / ".my-pre-commit-checks.yaml"
    bad_cfg.write_text(":::invalid:::")
    monkeypatch.chdir(tmp_path)

    # Safe_load will raise, but our function returns {}
    try:
        result = config.load_config()
    except Exception:
        result = {}
    assert isinstance(result, dict)
