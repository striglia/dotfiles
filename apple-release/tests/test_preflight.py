import importlib.machinery
import importlib.util
import os
import plistlib
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from datetime import date
from io import StringIO
from pathlib import Path
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / ".local/bin/apple-release-preflight"
LOADER = importlib.machinery.SourceFileLoader("preflight", str(SCRIPT))
PREFLIGHT = importlib.util.module_from_spec(importlib.util.spec_from_loader(LOADER.name, LOADER))
LOADER.exec_module(PREFLIGHT)


class PreflightTests(unittest.TestCase):
    def check(self, *args, sdk="26.2", reason="", today=date(2027, 3, 31)):
        out, err = StringIO(), StringIO()
        with (
            patch.dict(os.environ, {"APPLE_TESTFLIGHT_SDK_OVERRIDE_REASON": reason}),
            patch.object(PREFLIGHT, "toolchain_sdk", return_value=sdk),
            redirect_stdout(out),
            redirect_stderr(err),
        ):
            status = PREFLIGHT.main(list(args), today=today)
        return status, out.getvalue() + err.getvalue()

    def test_default_blocks_old_sdk_even_with_previous_minimum_argument(self):
        for args in ((), ("--minimum-sdk", "26", "--upcoming-sdk", "27", "--effective", "2027-04-01")):
            with self.subTest(args=args):
                status, message = self.check(*args)
                self.assertEqual(status, 1)
                self.assertIn("27", message)

    def test_current_release_sdk_passes(self):
        self.assertEqual(self.check(sdk="27.2")[0], 0)

    def test_one_off_reason_is_logged_before_cutoff(self):
        status, message = self.check("--xcodebuild", "archive", reason="Approved internal test")
        self.assertEqual(status, 0)
        self.assertIn("Approved internal test", message)
        self.assertIn("2027-04-01", message)

    def test_override_cannot_go_below_apple_floor_or_past_cutoff(self):
        self.assertEqual(self.check(sdk="18.4", reason="Test release")[0], 1)
        self.assertEqual(self.check(reason="Test release", today=date(2027, 4, 1))[0], 1)
        self.assertEqual(self.check(reason="   ")[0], 1)

    def test_export_checks_the_archive_independently_of_selected_xcode(self):
        with tempfile.TemporaryDirectory() as directory:
            archive = Path(directory) / "Example Archive.xcarchive"
            app = archive / "Products/Applications/Example.app"
            app.mkdir(parents=True)
            (archive / "Info.plist").write_bytes(plistlib.dumps({
                "ApplicationProperties": {"ApplicationPath": "Applications/Example.app"},
            }))
            metadata = app / "Info.plist"
            metadata.write_bytes(plistlib.dumps({"DTSDKName": "iphoneos26.2"}))
            args = ("--xcodebuild", "-exportArchive", "-archivePath", str(archive))
            self.assertEqual(self.check(*args, sdk="27.2")[0], 1)
            self.assertEqual(self.check(*args, sdk="27.2", reason="Test")[0], 0)
            metadata.write_bytes(plistlib.dumps({"DTSDKName": "iphoneos27.2"}))
            self.assertEqual(self.check(*args, sdk="26.2")[0], 0)

    def test_export_fails_closed_if_archive_path_is_ambiguous(self):
        for args in ((), ("-archivePath",), ("-archivePath", "one", "-archivePath", "two")):
            self.assertEqual(self.check("--xcodebuild", "-exportArchive", *args, sdk="27")[0], 1)


if __name__ == "__main__":
    unittest.main()
