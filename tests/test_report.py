# tests/test_report.py
from jps_pre_commit_utils import report


def test_print_report_outputs_expected(capsys):
    """Ensure report correctly prints findings with Rich formatting."""
    findings = [
        {"pattern": "TODO", "line": "Added TODO in code"},
        {"pattern": "print", "line": "print('debug')"},
    ]

    report.print_report(findings)
    captured = capsys.readouterr()

    assert "🔍 Pre-commit inserted-line scan results" in captured.out
    assert "⚠️ Total findings: 2" in captured.out


def test_print_report_no_issues(capsys):
    """Should print the success message when no issues are found."""
    report.print_report([])
    captured = capsys.readouterr()
    assert "✅ No issues detected." in captured.out
