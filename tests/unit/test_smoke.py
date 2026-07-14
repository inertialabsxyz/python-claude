"""Smoke test — proves the package imports and the test harness runs.

Replace/extend as real modules land (see .claude/rules/testing.md).
"""

from app import __version__


def test_package_version_is_exposed() -> None:
    assert __version__ == "0.1.0"
