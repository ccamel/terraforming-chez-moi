import tempfile
import unittest
from pathlib import Path

from check_sops_env import check


class CheckSopsEnvTest(unittest.TestCase):
    def test_encrypted_file_and_rejected_changes(self):
        encrypted = "ENC[AES256_GCM,data:YWJj,iv:YWJj,tag:YWJj,type:str]"
        content = (
            f"SECRET={encrypted}\n"
            "sops_age__list_0__map_enc=-----BEGIN AGE ENCRYPTED FILE-----\\nYWJj\\n-----END AGE ENCRYPTED FILE-----\\n\n"
            "sops_age__list_0__map_recipient=age1abc\n"
            "sops_lastmodified=2026-01-01T00:00:00Z\n"
            f"sops_mac={encrypted}\n"
            "sops_unencrypted_suffix=_unencrypted\n"
            "sops_version=3.12.1\n"
        )
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / ".env.sops"
            path.write_text(content)
            check(path)
            for invalid in (
                content.replace(f"SECRET={encrypted}", "SECRET=plaintext"),
                content + "OTHER=plaintext\n",
                content + "SECRET=plaintext\n",
                content.replace(
                    "sops_age__list_0__map_recipient", "sops_age__list_1__map_recipient"
                ),
                content.replace(f"sops_mac={encrypted}\n", ""),
            ):
                with self.subTest(invalid=invalid), self.assertRaises(ValueError):
                    path.write_text(invalid)
                    check(path)


if __name__ == "__main__":
    unittest.main()
