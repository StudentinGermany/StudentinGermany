import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd


ALG_DIR = Path(__file__).resolve().parent
SRC_DIR = ALG_DIR / "src"
IMAGE_DIR = SRC_DIR / "sample_source_files"
FINDPOTATOS_SCRIPT = SRC_DIR / "findPOTATOs.py"
PARAMETERS_FILE = SRC_DIR / "parameters.py"

ALGORITHM = "findPOTATOs"
SURVEY = "BENCH"
DEFAULT_OBSCODE = "I11"
DEFAULT_BAND = "r"
DEFAULT_MAG_ERR = 0.1
DEFAULT_RA_ERR = 0.2
DEFAULT_DEC_ERR = 0.2
NIGHT_GAP_DAYS = 0.5
GROUP_SIZE = 3
MIN_IMAGE_SEP_DAYS = 0.005  # ~7 min — keeps motion above stationary-source removal threshold

_PRECISION = 4  # decimal places for position matching
_obj_lookup: dict[tuple[float, float], str] = {}


def require_file(path: Path, description: str) -> None:
    if not path.exists():
        raise FileNotFoundError(f"Missing {description}: {path}")


def relative_path(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(Path.cwd().resolve()))
    except ValueError:
        return str(path)


def _mpc_to_deg(h_or_d: str, m: str, s: str) -> float:
    sign = -1 if h_or_d.startswith("-") else 1
    return sign * (abs(float(h_or_d)) + float(m) / 60 + float(s) / 3600)


# ── Ingest ────────────────────────────────────────────────────────────────────

def ingest(det_file: Path) -> None:
    global _obj_lookup
    df = pd.read_csv(det_file)

    _obj_lookup = {
        (round(float(r.ra), _PRECISION), round(float(r.dec), _PRECISION)): str(r.ObjID)
        for r in df.itertuples()
    }

    df["observatory_code"] = DEFAULT_OBSCODE
    df["band"] = DEFAULT_BAND
    df["mag_err"] = DEFAULT_MAG_ERR
    df["RA_err"] = DEFAULT_RA_ERR
    df["Dec_err"] = DEFAULT_DEC_ERR
    df = df.rename(columns={"ra": "RA", "dec": "Dec", "mag": "magnitude"})

    IMAGE_DIR.mkdir(exist_ok=True)
    for old in IMAGE_DIR.glob("bench_*.csv"):
        old.unlink()

    sorted_mjds = sorted(df["mjd"].unique())
    image_files: list[str] = []
    for i, mjd in enumerate(sorted_mjds):
        fname = f"bench_{i}.csv"
        df[df["mjd"] == mjd][
            ["RA", "Dec", "mjd", "magnitude", "observatory_code", "band", "mag_err", "RA_err", "Dec_err"]
        ].reset_index(drop=True).to_csv(IMAGE_DIR / fname, index=False)
        image_files.append(fname)

    nights: list[list[tuple[float, str]]] = []
    current: list[tuple[float, str]] = [(sorted_mjds[0], image_files[0])]
    for idx in range(1, len(sorted_mjds)):
        if sorted_mjds[idx] - sorted_mjds[idx - 1] >= NIGHT_GAP_DAYS:
            nights.append(current)
            current = []
        current.append((sorted_mjds[idx], image_files[idx]))
    nights.append(current)

    groups: list[list[str]] = []
    for night in nights:
        i = 0
        while i < len(night):
            group_mjds = [night[i][0]]
            group_files = [night[i][1]]
            j = i + 1
            while len(group_files) < GROUP_SIZE and j < len(night):
                if night[j][0] - group_mjds[-1] >= MIN_IMAGE_SEP_DAYS:
                    group_mjds.append(night[j][0])
                    group_files.append(night[j][1])
                j += 1
            if len(group_files) == GROUP_SIZE:
                groups.append(group_files)
            i = j

    cols = [f"file{chr(ord('a') + i)}" for i in range(GROUP_SIZE)]
    with (SRC_DIR / f"image_groups_{SURVEY}.csv").open("w") as f:
        f.write(",".join(cols) + "\n")
        for group in groups:
            f.write(",".join(group) + "\n")


# ── Operate ───────────────────────────────────────────────────────────────────

def operate() -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(FINDPOTATOS_SCRIPT), SURVEY],
        cwd=str(SRC_DIR),
        capture_output=True,
        text=True,
        input="\n\n",
    )


# ── Output ────────────────────────────────────────────────────────────────────

def parse_results() -> list[str]:
    output_dir = SRC_DIR / "output"
    if not output_dir.exists():
        return []
    seen: set[str] = set()
    found: list[str] = []
    for tracklet_file in output_dir.rglob("tracklets_*.txt"):
        with tracklet_file.open() as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                # MPC format: id C<year> MM DD.ddddd RA_h RA_m RA_s Dec_d Dec_m Dec_s ...
                parts = line.split()
                if len(parts) < 10:
                    continue
                ra = round(_mpc_to_deg(parts[4], parts[5], parts[6]) * 15, _PRECISION)
                dec = round(_mpc_to_deg(parts[7], parts[8], parts[9]), _PRECISION)
                obj_id = _obj_lookup.get((ra, dec))
                if obj_id and obj_id not in seen:
                    seen.add(obj_id)
                    found.append(obj_id)
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


def _cleanup() -> None:
    for f in IMAGE_DIR.glob("bench_*.csv"):
        f.unlink(missing_ok=True)
    (SRC_DIR / f"image_groups_{SURVEY}.csv").unlink(missing_ok=True)


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

    require_file(FINDPOTATOS_SCRIPT, "findPOTATOs.py script")
    require_file(PARAMETERS_FILE, "parameters.py config file")

    output_dir = det_file.parent / "results" / ALGORITHM / det_file.stem
    output_dir.mkdir(parents=True, exist_ok=True)
    output_file = output_dir / f"{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}.json"

    ingest(det_file)
    result = operate()

    # findPOTATOs crashes at ADES export when no tracklets are found (ades_result undefined in source)
    if result.returncode != 0:
        ades_crash = result.stderr and "ades_result" in result.stderr and "NameError" in result.stderr
        if not ades_crash:
            _cleanup()
            raise subprocess.CalledProcessError(result.returncode, FINDPOTATOS_SCRIPT)

    found = parse_results()
    write_result(output_file, det_file=det_file, found=found)
    _cleanup()


if __name__ == "__main__":
    main()
