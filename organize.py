#!/usr/bin/env python3
"""Sort files in a folder into type-based category folders."""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path


CATEGORIES = {
    "Programs": {
        "exe", "msi", "msix", "appx", "deb", "rpm", "appimage", "run",
        "bin", "sh", "bat", "cmd", "com", "apk", "iso",
    },
    "Video": {
        "mp4", "mkv", "avi", "mov", "wmv", "flv", "webm", "m4v", "3gp",
        "mpg", "mpeg", "m2ts", "ts", "vob",
    },
    "Compressed": {
        "zip", "rar", "7z", "tar", "gz", "bz2", "xz", "lz", "lzma", "zst",
        "tgz", "tbz", "tbz2", "txz", "cab", "arj", "cbz", "cbr",
    },
    "Images": {
        "jpg", "jpeg", "png", "gif", "bmp", "tif", "tiff", "webp", "svg",
        "ico", "heic", "avif",
    },
    "Audio": {
        "mp3", "wav", "flac", "m4a", "aac", "ogg", "oga", "opus", "wma",
        "aiff", "alac",
    },
    "Documents": {
        "pdf", "doc", "docx", "odt", "rtf", "txt", "md", "tex", "xls",
        "xlsx", "ods", "csv", "ppt", "pptx", "odp", "epub", "mobi",
        "ipynb", "c", "h", "cpp", "java", "py", "js", "ts", "html", "css",
        "json", "xml",
    },
}


def category_for(path: Path) -> str:
    extension = path.suffix.removeprefix(".").lower()
    for category, extensions in CATEGORIES.items():
        if extension in extensions:
            return category
    return "Other"


def available_destination(directory: Path, filename: str) -> Path:
    candidate = directory / filename
    path = Path(filename)
    stem = path.stem
    suffix = path.suffix
    counter = 1
    while candidate.exists():
        candidate = directory / f"{stem} ({counter}){suffix}"
        counter += 1
    return candidate


def parse_args() -> argparse.Namespace:
    script_directory = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(
        description="Sort files directly inside a folder by file type."
    )
    parser.add_argument(
        "directory",
        nargs="?",
        type=Path,
        default=script_directory,
        help="folder to organize (default: the folder containing this script)",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="perform the moves; without this option, only show the plan",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    directory = args.directory.expanduser().resolve()
    script_path = Path(__file__).resolve()

    if not directory.is_dir():
        print(f"Directory not found: {directory}", file=sys.stderr)
        return 1

    files = [
        path for path in directory.iterdir()
        if path.is_file()
        and path.resolve() != script_path
        and path.name != "organize.sh"
        and path.name != "organize.bat"
        and not path.name.startswith("organize-downloads.sh.backup-")
    ]

    if not files:
        print(f"No files found in {directory}")
        return 0

    planned = 0
    for source in files:
        destination_directory = directory / category_for(source)
        destination = available_destination(destination_directory, source.name)
        print(f"{source} -> {destination}")
        planned += 1
        if args.apply:
            destination_directory.mkdir(exist_ok=True)
            shutil.move(str(source), str(destination))

    if args.apply:
        print(f"\nMoved {planned} file(s).")
    else:
        print(
            f"\nDry run only: {planned} file(s) would be moved. "
            "Re-run with --apply to apply these moves."
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
