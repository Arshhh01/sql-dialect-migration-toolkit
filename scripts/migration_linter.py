#!/usr/bin/env python3
"""
migration_linter.py

Scans a directory of .sql files for Teradata-specific syntax that does not have a
direct Redshift equivalent, and prints a report of file, line number, pattern
matched, and the suggested fix.

This is a static pass, not an auto-fixer: some patterns (collation, timezone
semantics) need a human decision about the *correct* target behavior, not just a
syntax swap. The goal is to surface every instance so none get missed in a large
codebase, not to blindly rewrite them.

Usage:
    python migration_linter.py path/to/sql/directory
    python migration_linter.py path/to/single_file.sql
"""

import re
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass
class Rule:
    name: str
    pattern: re.Pattern
    message: str


RULES = [
    Rule(
        name="ZEROIFNULL",
        pattern=re.compile(r"\bZEROIFNULL\s*\(", re.IGNORECASE),
        message="No Redshift equivalent — replace with COALESCE(col, 0)",
    ),
    Rule(
        name="QUALIFY",
        pattern=re.compile(r"\bQUALIFY\b", re.IGNORECASE),
        message="Redshift has no QUALIFY clause — wrap the windowed query in a "
        "subquery and filter in the outer WHERE",
    ),
    Rule(
        name="SUBSTR",
        pattern=re.compile(r"\bSUBSTR\s*\(", re.IGNORECASE),
        message="Works on Redshift but prefer SUBSTRING(col FROM start FOR len) "
        "to avoid start/length transcription errors",
    ),
    Rule(
        name="CAST_AS_TIMESTAMP",
        pattern=re.compile(r"CAST\s*\([^)]*\bAS\s+TIMESTAMP\b(?!TZ)", re.IGNORECASE),
        message="Check whether the source column carries a timezone offset — if so, "
        "cast to TIMESTAMPTZ instead, or the offset is silently dropped",
    ),
    Rule(
        name="UNQUALIFIED_TABLE_HINT",
        pattern=re.compile(r"\bFROM\s+(?!mkt\.)([a-zA-Z_][a-zA-Z0-9_]*)\s*(WHERE|JOIN|;|\n|$)", re.IGNORECASE),
        message="Table reference may be unqualified — Redshift has no default-database "
        "resolution; confirm this is schema.table",
    ),
]


def scan_file(path: Path):
    findings = []
    text = path.read_text(errors="ignore")
    for lineno, line in enumerate(text.splitlines(), start=1):
        for rule in RULES:
            if rule.pattern.search(line):
                findings.append((lineno, rule.name, rule.message))
    return findings


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(1)

    target = Path(sys.argv[1])
    if target.is_file():
        sql_files = [target]
    else:
        sql_files = sorted(target.rglob("*.sql"))

    if not sql_files:
        print(f"No .sql files found under {target}")
        sys.exit(0)

    total_findings = 0
    for path in sql_files:
        findings = scan_file(path)
        for lineno, name, message in findings:
            print(f"{path}:{lineno}  [{name}]  {message}")
        total_findings += len(findings)

    print(f"\n{len(sql_files)} file(s) scanned, {total_findings} finding(s).")


if __name__ == "__main__":
    main()
