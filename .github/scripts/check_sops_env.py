#!/usr/bin/env python3
"""Check the public structure of a SOPS dotenv file, without decrypting it."""

import re
import sys
from pathlib import Path

CIPHERTEXT = r"ENC\[AES256_GCM,data:[A-Za-z0-9+/=]*,iv:[A-Za-z0-9+/=]+,tag:[A-Za-z0-9+/=]+,type:str\]"
METADATA = {
    "sops_lastmodified": r"\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ",
    "sops_mac": CIPHERTEXT,
    "sops_unencrypted_suffix": r"_unencrypted",
    "sops_version": r"\d+\.\d+\.\d+",
}


def check(path):
    seen = set()
    recipients = set()
    encrypted_keys = set()
    variables = 0
    for number, line in enumerate(path.read_text().splitlines(), 1):
        key, separator, value = line.partition("=")
        if (
            not separator
            or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", key)
            or key in seen
        ):
            raise ValueError(f"Invalid or duplicate key on line {number}")
        seen.add(key)
        match = re.fullmatch(r"sops_age__list_(\d+)__map_(enc|recipient)", key)
        if match:
            index, kind = match.groups()
            pattern = (
                r"-----BEGIN AGE ENCRYPTED FILE-----(?:\\n[A-Za-z0-9+/=]+)+\\n-----END AGE ENCRYPTED FILE-----\\n"
                if kind == "enc"
                else r"age1[0-9a-z]+"
            )
            (encrypted_keys if kind == "enc" else recipients).add(index)
        elif key in METADATA:
            pattern = METADATA[key]
        elif key.startswith("sops_"):
            raise ValueError(f"Unexpected SOPS metadata on line {number}")
        else:
            variables += 1
            pattern = CIPHERTEXT
        if not re.fullmatch(pattern, value):
            raise ValueError(f"Invalid or unencrypted value on line {number}")
    if (
        not variables
        or not METADATA.keys() <= seen
        or not recipients
        or recipients != encrypted_keys
    ):
        raise ValueError("Missing variables or SOPS metadata")


if __name__ == "__main__":
    try:
        check(Path(sys.argv[1] if len(sys.argv) > 1 else ".env.sops"))
    except (OSError, ValueError) as error:
        sys.exit(str(error))
