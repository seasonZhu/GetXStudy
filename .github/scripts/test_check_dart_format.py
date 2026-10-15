"""使用临时 Git 仓库验证 CI 格式检查范围。"""

from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import check_dart_format as checker


class ChangedFilesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="getx-ci-")
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name)
        self.git("init", "-q")
        self.git("config", "user.name", "测试")
        self.git("config", "user.email", "test@example.invalid")
        self.write("original.dart")
        self.write("delete.dart")
        self.base = self.commit()

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.repo).decode().strip()

    def write(self, name, text="void main() {}\n"):
        (self.repo / name).write_text(text)

    def commit(self):
        self.git("add", "-A")
        self.git("commit", "-qm", "测试提交")
        return self.git("rev-parse", "HEAD")

    def test_push_filters_deleted_and_non_dart_files(self):
        self.write("original.dart", "void other() {}\n")
        self.write("新增 文件.dart")
        self.write("README.md", "说明")
        (self.repo / "delete.dart").unlink()
        head = self.commit()
        self.assertCountEqual(checker.changed_dart_files(
            self.repo, "push", {"before": self.base}, head),
            ["original.dart", "新增 文件.dart"])

    def test_pull_request_uses_event_base_and_head(self):
        self.write("feature.dart")
        head = self.commit()
        self.write("unrelated.dart")
        unrelated = self.commit()
        event = {"pull_request": {"base": {"sha": self.base}, "head": {"sha": head}}}
        self.assertEqual(checker.changed_dart_files(
            self.repo, "pull_request", event, unrelated), ["feature.dart"])

    def test_new_branch_compares_parent(self):
        self.write("new.dart")
        head = self.commit()
        self.assertEqual(checker.changed_dart_files(
            self.repo, "push", {"before": "0" * 40}, head), ["new.dart"])

    def test_first_commit_checks_all_dart_files(self):
        self.assertCountEqual(checker.changed_dart_files(
            self.repo, "push", {"before": "0" * 40}, self.base),
            ["original.dart", "delete.dart"])

    def test_rename_checks_new_path(self):
        self.git("mv", "original.dart", "renamed file.dart")
        head = self.commit()
        self.assertEqual(checker.changed_dart_files(
            self.repo, "push", {"before": self.base}, head), ["renamed file.dart"])

    def test_no_dart_change_skips_formatter(self):
        self.write("README.md", "说明")
        head = self.commit()
        self.assertEqual(checker.changed_dart_files(
            self.repo, "push", {"before": self.base}, head), [])

    def test_formatter_failure_is_propagated(self):
        with patch.object(checker, "changed_dart_files", return_value=["test.dart"]), \
                patch.dict("os.environ", {"GITHUB_SHA": "test", "GITHUB_EVENT_PATH": ""}), \
                patch.object(checker.subprocess, "run") as run:
            run.return_value.returncode = 1
            self.assertEqual(checker.main(), 1)
            self.assertIn("--output=none", run.call_args.args[0])


if __name__ == "__main__":
    unittest.main()
