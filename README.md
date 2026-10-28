# File-Organizer-Script

The organizer sorts files into folders based on their file types. Use `organize.sh` on Linux/macOS, or `organize.py` on any system with Python installed.


## Categories

- `Programs`
- `Video`
- `Compressed`
- `Documents`
- `Images`
- `Audio`
- `Other`

## Linux and macOS

Make sure the script is executable:

```bash
chmod +x organize.sh
```

Run a dry run first. This only displays the planned moves:

```bash
./organize.sh
```

To actually move the files:

```bash
./organize.sh --apply
```

## Windows

Copy `organize.bat` into the folder you want to organize. It is standalone and does not require Python:

```bat
organize.bat
```

To actually move the files:

```bat
organize.bat --apply
```

Alternatively, you can run the portable Python script directly if Python is installed:

```bat
py -3 organize.py
py -3 organize.py --apply
```

## Custom folders

The same commands accept a folder path:

```bash
./organize.sh /path/to/folder --apply
python organize.py /path/to/folder --apply
```

On Windows:

```bat
organize.bat C:\path\to\folder --apply
```

By default, the script organizes files in the folder where it is located. You can copy the script to another folder and run it there.

To organize a different folder:

```bash
./organize.sh /path/to/folder
```

To preview and then organize a different folder:

```bash
./organize.sh /path/to/folder --apply
```

The script only processes files directly inside the target folder. Existing files are not overwritten; a numbered filename is created instead.
