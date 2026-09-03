#!/usr/bin/env python3
"""
Repository Validation Script for CI
Checks:
1. Every top-level folder (excluding .git, .github, etc.) contains a non-empty README.txt (or readme.txt).
2. Every top-level folder is documented in the root README.md.
3. Every relative link in root README.md resolves to an existing file or directory (no broken links).
"""

import os
import re
import sys
import urllib.parse
from dataclasses import dataclass
from pathlib import Path


@dataclass
class ValidationIssue:
    category: str
    target_location: str
    problem: str
    action: str
    file_path: Path | None = None
    line: int | None = None


def is_ci() -> bool:
    return os.environ.get("GITHUB_ACTIONS") == "true"


def log_live_error(issue: ValidationIssue):
    if is_ci():
        location_parts = []
        if issue.file_path:
            location_parts.append(f"file={issue.file_path.as_posix()}")
        if issue.line:
            location_parts.append(f"line={issue.line}")
        loc_str = f" {','.join(location_parts)}" if location_parts else ""
        print(f"::error{loc_str}::{issue.problem}")
    print(f"[FAIL] {issue.problem}")


def log_live_success(message: str):
    print(f"[PASS] {message}")


def extract_markdown_links(content: str) -> list[tuple[str, str, int]]:
    """
    Extracts markdown links in format: (link_text, link_url, line_number)
    Handles links like [text](url)
    """
    links = []
    link_pattern = re.compile(r'\[([^\]]+)\]\(([^)]+)\)')
    
    for line_idx, line in enumerate(content.splitlines(), start=1):
        for match in link_pattern.finditer(line):
            text = match.group(1).strip()
            url = match.group(2).strip()
            links.append((text, url, line_idx))
            
    return links


def find_explanation_file(folder: Path) -> Path | None:
    """
    Looks for README.txt (or readme.txt, case-insensitive) in the folder.
    """
    for item in folder.iterdir():
        if item.is_file() and item.name.lower() == "readme.txt":
            return item
    return None


def write_github_step_summary(issues: list[ValidationIssue], total_folders: int):
    """
    Writes a Markdown report to $GITHUB_STEP_SUMMARY if available in GitHub Actions.
    """
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if not summary_path:
        return

    try:
        with open(summary_path, "a", encoding="utf-8") as f:
            f.write("\n## 📋 Repository Validation Report\n\n")
            if not issues:
                f.write("### ✅ All Checks Passed Successfully!\n")
                f.write(f"- Checked **{total_folders}** top-level utility folders.\n")
                f.write("- Every folder has a non-empty `README.txt`.\n")
                f.write("- Root `README.md` is fully accurate with no broken links.\n")
            else:
                f.write(f"### ❌ Found {len(issues)} Issue(s)\n\n")
                f.write("| # | Category | File / Location | Problem | Recommended Action |\n")
                f.write("|---|---|---|---|---|\n")
                for idx, issue in enumerate(issues, start=1):
                    loc = issue.target_location.replace("|", "\\|")
                    prob = issue.problem.replace("|", "\\|")
                    act = issue.action.replace("|", "\\|")
                    f.write(f"| {idx} | **{issue.category}** | `{loc}` | {prob} | {act} |\n")
    except Exception as e:
        print(f"Warning: Could not write GitHub step summary: {e}", file=sys.stderr)


def print_terminal_summary(issues: list[ValidationIssue], total_folders: int, repo_root: Path):
    divider = "=" * 65
    sub_divider = "-" * 65

    print(f"\n{divider}")
    if not issues:
        print("                 VALIDATION PASSED")
        print(divider)
        print(f" Checked {total_folders} top-level folder(s).")
        print(" All top-level folders have valid explanation files (README.txt).")
        print(" Root README.md accurately references all directories with no broken links.")
        print(f"{divider}\n")
        return

    print(f"             VALIDATION FAILED ({len(issues)} Issue{'s' if len(issues) > 1 else ''})")
    print(divider)
    print("The following issues must be resolved before this PR can be merged:\n")

    for idx, issue in enumerate(issues, start=1):
        print(f"{idx}. [{issue.category}]")
        print(f"   Target Location : {issue.target_location}")
        print(f"   Problem         : {issue.problem}")
        print(f"   How to Fix      : {issue.action}")
        if idx < len(issues):
            print(f"\n{sub_divider}")

    print(divider)
    print(f"Total Errors: {len(issues)}")
    print(f"{divider}\n")


def validate_repository(repo_root: Path) -> int:
    print(f"=== Validating Repository at: {repo_root} ===")
    issues: list[ValidationIssue] = []

    root_readme = repo_root / "README.md"
    if not root_readme.exists():
        issue = ValidationIssue(
            category="Missing Root README",
            target_location="README.md",
            problem="Root README.md does not exist in the repository.",
            action="Create a root README.md describing the repository contents.",
            file_path=root_readme
        )
        issues.append(issue)
        log_live_error(issue)
        print_terminal_summary(issues, 0, repo_root)
        write_github_step_summary(issues, 0)
        return 1

    root_readme_content = root_readme.read_text(encoding="utf-8")
    markdown_links = extract_markdown_links(root_readme_content)

    # 1. Resolve all relative links to check for broken links and linked paths
    resolved_links = []
    for text, url, line_num in markdown_links:
        if url.startswith(("http://", "https://", "mailto:", "#")):
            continue

        cleaned_url = url.split("#")[0].split("?")[0]
        if not cleaned_url:
            continue

        decoded_url = urllib.parse.unquote(cleaned_url)
        target_path = (repo_root / decoded_url).resolve()

        if not target_path.exists():
            issue = ValidationIssue(
                category="Broken Link",
                target_location=f"README.md (Line {line_num})",
                problem=f"Link '[{text}]({url})' points to '{decoded_url}', which does not exist.",
                action=f"Update the link in README.md line {line_num} or create the missing file/folder.",
                file_path=root_readme,
                line=line_num
            )
            issues.append(issue)
            log_live_error(issue)
        else:
            resolved_links.append((target_path, text, line_num))

    # 2. Identify top-level directories (ignoring hidden/special folders)
    top_level_folders = [
        item for item in repo_root.iterdir()
        if item.is_dir() and not item.name.startswith(".")
    ]

    print(f"\nDiscovered {len(top_level_folders)} top-level utility folder(s):")
    for folder in sorted(top_level_folders):
        print(f" - {folder.name}")

    print("\n--- Checking Top-Level Folder Explanation Files ---")
    for folder in sorted(top_level_folders):
        readme_file = find_explanation_file(folder)
        if not readme_file:
            issue = ValidationIssue(
                category="Missing Explanation File",
                target_location=f"{folder.name}/",
                problem=f"Folder '{folder.name}' is missing a 'README.txt' explanation file.",
                action=f"Create '{folder.name}/README.txt' explaining the tool's purpose and usage instructions.",
                file_path=folder
            )
            issues.append(issue)
            log_live_error(issue)
        else:
            content = readme_file.read_text(encoding="utf-8", errors="replace").strip()
            if not content:
                issue = ValidationIssue(
                    category="Empty Explanation File",
                    target_location=f"{folder.name}/{readme_file.name}",
                    problem=f"Explanation file '{folder.name}/{readme_file.name}' is empty (0 characters).",
                    action=f"Add helpful usage instructions and details inside '{folder.name}/{readme_file.name}'.",
                    file_path=readme_file
                )
                issues.append(issue)
                log_live_error(issue)
            else:
                log_live_success(f"Folder '{folder.name}' has valid '{readme_file.name}' ({len(content)} characters).")

    print("\n--- Checking Root README.md Directory Coverage ---")
    for folder in sorted(top_level_folders):
        folder_resolved = folder.resolve()
        
        # Check if any link in README.md targets this folder or a file inside this folder
        is_linked = any(
            target == folder_resolved or folder_resolved in target.parents
            for target, _, _ in resolved_links
        )
        is_mentioned = folder.name in root_readme_content

        if is_linked:
            log_live_success(f"Folder '{folder.name}' is referenced and linked in root README.md.")
        elif is_mentioned:
            log_live_success(f"Folder '{folder.name}' is mentioned by name in root README.md.")
        else:
            issue = ValidationIssue(
                category="Unreferenced Directory",
                target_location=f"README.md (Missing: {folder.name}/)",
                problem=f"Folder '{folder.name}' is not documented in root README.md.",
                action=f"Add an entry and link for '{folder.name}' under '## Repository Contents' in README.md.",
                file_path=root_readme
            )
            issues.append(issue)
            log_live_error(issue)

    # Output detailed summary
    print_terminal_summary(issues, len(top_level_folders), repo_root)
    write_github_step_summary(issues, len(top_level_folders))

    return 0 if not issues else 1


if __name__ == "__main__":
    script_path = Path(__file__).resolve()
    default_root = script_path.parent.parent.parent
    root_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else default_root
    sys.exit(validate_repository(root_dir))
