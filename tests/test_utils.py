import hashlib
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "app"))

from utils import display_results, hash_password  # noqa: E402


def test_hash_password_is_sha256_hex():
    assert hash_password("secret") == hashlib.sha256(b"secret").hexdigest()
    assert len(hash_password("x")) == 64


def test_hash_password_is_deterministic_and_distinct():
    assert hash_password("abc") == hash_password("abc")
    assert hash_password("abc") != hash_password("abd")


def test_display_results_renders_grid_table(capsys):
    display_results([([(1, "John", "Doe")], ["patientID", "firstName", "lastName"])])
    out = capsys.readouterr().out
    assert "patientID" in out and "John" in out and "+" in out


def test_display_results_handles_empty(capsys):
    display_results([])
    assert "No results found." in capsys.readouterr().out
    display_results([([], ["patientID"])])
    assert "No data found." in capsys.readouterr().out
