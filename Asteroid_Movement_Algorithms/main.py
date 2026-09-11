import argparse
import logging
import subprocess
import sys
from pathlib import Path

from ingest import ingest
from validate import validate


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    parser = argparse.ArgumentParser(
        description="Moving object detection algorithm benchmarker"
    )
    parser.add_argument("data", help="Path to input dataset")
    parser.add_argument(
        "--alg",
        nargs="+",
        help="Specific algorithm(s) to run (default: all)",
    )
    args = parser.parse_args()

    data_path = Path(args.data)
    if not data_path.exists():
        logging.error(f"Dataset not found: {data_path}")
        sys.exit(1)

    # Standardise test data
    ingest(data_path)

    # Discover available algorithms
    existing_algs = {p.name for p in Path("algorithms").iterdir() if p.is_dir()}

    to_run = []
    if args.alg:
        for alg in args.alg:
            if alg in existing_algs:
                to_run.append(alg)
            else:
                logging.warning(f"Unknown algorithm: {alg}")
    else:
        to_run = list(existing_algs)

    # Run each algorithm and validate results
    for algorithm in to_run:
        adapter = Path("algorithms") / algorithm / "adapter.py"
        # Run as subprocess to handle dependency conflicts
        subprocess.run([sys.executable, str(adapter), str(data_path)], check=True)

    validate(data_path)


if __name__ == "__main__":
    main()
