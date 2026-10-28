#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
DOWNLOADS_DIR="$SCRIPT_DIR"
DRY_RUN=1
DIRECTORY_PROVIDED=0

usage() {
    cat <<'EOF'
Usage: organize.sh [DIRECTORY] [--apply]

By default, the script prints the planned moves without changing files.
Pass --apply to perform the moves.
If no directory is provided, files directly inside the script's folder are considered.
EOF
}

for argument in "$@"; do
    case "$argument" in
        --apply) DRY_RUN=0 ;;
        -h|--help) usage; exit 0 ;;
        --*) printf 'Unknown option: %s\n' "$argument" >&2; usage >&2; exit 2 ;;
        *)
            if (( DIRECTORY_PROVIDED == 0 )); then
                DOWNLOADS_DIR="$argument"
                DIRECTORY_PROVIDED=1
            else
                printf 'Only one directory may be provided.\n' >&2
                usage >&2
                exit 2
            fi
            ;;
    esac
done

if [[ ! -d "$DOWNLOADS_DIR" ]]; then
    printf 'Directory not found: %s\n' "$DOWNLOADS_DIR" >&2
    exit 1
fi

category_for() {
    local extension="${1,,}"
    case "$extension" in
        # Installers, packages, scripts, disk images, and executable archives.
        exe|msi|msix|appx|deb|rpm|appimage|run|bin|sh|bat|cmd|com|apk|iso)
            printf 'Programs\n' ;;
        # Common video formats.
        mp4|mkv|avi|mov|wmv|flv|webm|m4v|3gp|mpg|mpeg|m2ts|ts|vob)
            printf 'Video\n' ;;
        # Common compressed/archive formats, including comic-book archives.
        zip|rar|7z|tar|gz|bz2|xz|lz|lzma|zst|tgz|tbz|tbz2|txz|cab|arj|cbz|cbr)
            printf 'Compressed\n' ;;
        # Common image formats.
        jpg|jpeg|png|gif|bmp|tif|tiff|webp|svg|ico|heic|avif)
            printf 'Images\n' ;;
        # Common audio formats.
        mp3|wav|flac|m4a|aac|ogg|oga|opus|wma|aiff|alac)
            printf 'Audio\n' ;;
        # Office, text, ebook, notebook, and source/document formats.
        pdf|doc|docx|odt|rtf|txt|md|tex|xls|xlsx|ods|csv|ppt|pptx|odp|epub|mobi|ipynb|c|h|cpp|java|py|js|ts|html|css|json|xml)
            printf 'Documents\n' ;;
        *)
            printf 'Other\n' ;;
    esac
}

destination_for() {
    local destination="$1"
    local filename="$2"
    local candidate="$destination/$filename"
    local stem="$filename"
    local extension=""
    local counter=1

    if [[ "$filename" == *.* && "$filename" != .* ]]; then
        stem="${filename%.*}"
        extension=".${filename##*.}"
    fi

    while [[ -e "$candidate" ]]; do
        candidate="$destination/${stem} ($counter)${extension}"
        ((counter++))
    done
    printf '%s\n' "$candidate"
}

mapfile -d '' files < <(find "$DOWNLOADS_DIR" -maxdepth 1 -type f -print0)

if (( ${#files[@]} == 0 )); then
    printf 'No files found in %s\n' "$DOWNLOADS_DIR"
    exit 0
fi

planned=0
for source in "${files[@]}"; do
    [[ "$(readlink -f "$source")" == "$SCRIPT_PATH" ]] && continue
    filename="${source##*/}"
    [[ "$filename" == "$(basename "$SCRIPT_PATH").backup-"* ]] && continue
    if [[ "$filename" == .* || "$filename" != *.* ]]; then
        extension=""
    else
        extension="${filename##*.}"
    fi
    category="$(category_for "$extension")"
    directory="$DOWNLOADS_DIR/$category"
    destination="$(destination_for "$directory" "$filename")"
    printf '%s -> %s\n' "$source" "$destination"
    ((planned+=1))

    if (( DRY_RUN == 0 )); then
        mkdir -p "$directory"
        mv -- "$source" "$destination"
    fi
done

if (( DRY_RUN == 1 )); then
    printf '\nDry run only: %d file(s) would be moved. Re-run with --apply to apply these moves.\n' "$planned"
else
    printf '\nMoved %d file(s).\n' "$planned"
fi
