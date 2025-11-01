"""Reporting utilities using Rich."""

from rich.console import Console


def print_report(findings):
    console = Console()
    console.print("\n[bold cyan]🔍 Pre-commit inserted-line scan results[/bold cyan]")
    if not findings:
        console.print("[green]✅ No issues detected.[/green]")
        return
    for f in findings:
        console.print(
            f"[yellow]Added line contains pattern:[/yellow] '{f['pattern']}' → {f['line']}"
        )
    console.print(f"\n[red]⚠️ Total findings: {len(findings)}[/red]")
