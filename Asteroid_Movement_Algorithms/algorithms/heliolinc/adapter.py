import argparse
import csv
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd


ALG_DIR = Path(__file__).resolve().parent
SRC_DIR = ALG_DIR / "src" / "src"
TEST_DIR = ALG_DIR / "src" / "tests"
WORK_DIR = ALG_DIR / "work"

MAKE_TRACKLETS = SRC_DIR / "make_tracklets"
HELIOLINC = SRC_DIR / "heliolinc"
LINK_REFINE = SRC_DIR / "link_refine"
EARTH_FILE = TEST_DIR / "Earth1day2020s_02a.txt"
OBSCODE_FILE = TEST_DIR / "ObsCodes.txt"
HELIODIST_FILE = TEST_DIR / "accelmat_mb08a_sp04.txt"

ALGORITHM = "heliolinc"
DEFAULT_OBSCODE = "I11"
DEFAULT_FILTER = "r"


def require_file(path: Path, description: str) -> None:
    if not path.exists():
        raise FileNotFoundError(f"Missing {description}: {path}")


def relative_path(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(Path.cwd().resolve()))
    except ValueError:
        return str(path)


def _run(cmd: list[str]) -> None:
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise subprocess.CalledProcessError(result.returncode, cmd)


def _read_csv(path: Path) -> list[dict]:
    # heliolinc outputs \r mid-record (before index fields); replace to get full rows
    content = path.read_bytes().replace(b"\r,", b",").decode()
    return list(csv.DictReader(content.splitlines()))


# ── Ingest ────────────────────────────────────────────────────────────────────

def ingest(det_file: Path) -> None:
    WORK_DIR.mkdir(exist_ok=True)
    df = pd.read_csv(det_file)
    df["filter"] = DEFAULT_FILTER
    df["obscode"] = DEFAULT_OBSCODE
    df[["ObjID", "mjd", "ra", "dec", "filter", "mag", "obscode"]].to_csv(
        WORK_DIR / "input.csv", index=False
    )
    (WORK_DIR / "colformat.txt").write_text(
        "IDCOL 1\nMJDCOL 2\nRACOL 3\nDECCOL 4\nBANDCOL 5\nMAGCOL 6\nOBSCODECOL 7\n"
    )


# ── Operate ───────────────────────────────────────────────────────────────────

def operate() -> None:
    pairdets = WORK_DIR / "pairdets.csv"
    pairs = WORK_DIR / "pairs.txt"
    linked = WORK_DIR / "linked.csv"
    summary = WORK_DIR / "summary.csv"
    lrlist = WORK_DIR / "lrlist.txt"
    refined_summary = WORK_DIR / "refined_summary.csv"

    _run([
        str(MAKE_TRACKLETS),
        "-dets", str(WORK_DIR / "input.csv"),
        "-pairdets", str(pairdets),
        "-pairs", str(pairs),
        "-earth", str(EARTH_FILE),
        "-obscode", str(OBSCODE_FILE),
        "-colformat", str(WORK_DIR / "colformat.txt"),
    ])

    mjds = [float(r["#MJD"]) for r in _read_csv(pairdets)]
    if not mjds:
        raise ValueError("make_tracklets produced no paired detections")
    ref_mjd = f"{(min(mjds) + max(mjds)) / 2:.2f}"

    _run([
        str(HELIOLINC),
        "-dets", str(pairdets),
        "-pairs", str(pairs),
        "-mjd", ref_mjd,
        "-obspos", str(EARTH_FILE),
        "-heliodist", str(HELIODIST_FILE),
        "-out", str(linked),
        "-outsum", str(summary),
        "-verbose", "-1",
    ])

    lrlist.write_text(f"{linked} {summary}\n")
    _run([
        str(LINK_REFINE),
        "-pairdet", str(pairdets),
        "-lflist", str(lrlist),
        "-outfile", str(WORK_DIR / "refined.csv"),
        "-outsum", str(refined_summary),
    ])

    for f in [pairdets, pairs, linked, summary, lrlist, refined_summary,
              WORK_DIR / "input.csv", WORK_DIR / "colformat.txt"]:
        f.unlink(missing_ok=True)


# ── Output ────────────────────────────────────────────────────────────────────

def parse_results() -> list[str]:
    refined = WORK_DIR / "refined.csv"
    rows = _read_csv(refined)
    refined.unlink(missing_ok=True)
    seen: set[str] = set()
    found: list[str] = []
    for row in rows:
        obj = row["idstring"]
        if obj not in seen:
            seen.add(obj)
            found.append(obj)
    return found


def write_result(output_file: Path, *, det_file: Path, found: list[str]) -> None:
    with output_file.open("w") as f:
        json.dump({
            "algorithm": ALGORITHM,
            "ran_at": datetime.now(timezone.utc).isoformat(),
            "input_csv": relative_path(det_file),
            "found": found,
        }, f, indent=2)
        f.write("\n")


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_csv")
    args = parser.parse_args()

    det_file = Path(args.input_csv).resolve()
    if not det_file.exists():
        raise FileNotFoundError(f"Input dataset not found: {det_file}")
    if det_file.stat().st_size == 0:
        raise ValueError(f"Input dataset is empty: {det_file}")

    for path, description in [
        (MAKE_TRACKLETS, "make_tracklets executable"),
        (HELIOLINC, "heliolinc executable"),
        (LINK_REFINE, "link_refine executable"),
        (EARTH_FILE, "Earth ephemeris file"),
        (OBSCODE_FILE, "observatory code file"),
        (HELIODIST_FILE, "heliocentric hypothesis file"),
    ]:
        require_file(path, description)

    output_dir = det_file.parent / "results" / ALGORITHM / det_file.stem
    output_dir.mkdir(parents=True, exist_ok=True)
    output_file = output_dir / f"{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}.json"

    ingest(det_file)
    operate()
    found = parse_results()
    write_result(output_file, det_file=det_file, found=found)


if __name__ == "__main__":
    main()
