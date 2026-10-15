"""只检查本次提交范围内新增或修改的 Dart 文件，不改写源码。"""

import json
import os
from pathlib import Path
import subprocess
import sys


def git(repo, *args):
    return subprocess.check_output(["git", *args], cwd=repo)


def changed_dart_files(repo, event_name, event, head):
    if event_name == "pull_request":
        base = event["pull_request"]["base"]["sha"]
        head = event["pull_request"]["head"]["sha"]
    else:
        base = event.get("before", "")
        if not base or set(base) == {"0"}:
            parent = subprocess.run(
                ["git", "rev-parse", "--verify", f"{head}^"],
                cwd=repo, capture_output=True, text=True,
            )
            base = parent.stdout.strip() if parent.returncode == 0 else None
    if base:
        output = git(repo, "diff", "--name-only", "-z", "--diff-filter=ACMR",
                     base, head, "--", "*.dart")
    else:
        output = git(repo, "ls-tree", "-r", "--name-only", "-z", head)
    return [os.fsdecode(path) for path in output.split(b"\0")
            if path and os.fsdecode(path).endswith(".dart")]


def main():
    repo = Path(__file__).resolve().parents[2]
    event_path = os.environ.get("GITHUB_EVENT_PATH")
    event = json.loads(Path(event_path).read_text()) if event_path else {}
    head = os.environ.get("GITHUB_SHA") or git(repo, "rev-parse", "HEAD").decode().strip()
    files = changed_dart_files(repo, os.environ.get("GITHUB_EVENT_NAME", "push"), event, head)
    if not files:
        print("本次没有需要检查格式的 Dart 文件。")
        return 0
    print(f"检查 {len(files)} 个 Dart 文件的格式。", flush=True)
    return subprocess.run(
        ["dart", "format", "--output=none", "--set-exit-if-changed", *files], cwd=repo,
    ).returncode


if __name__ == "__main__":
    sys.exit(main())
