@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "TARGET=%~dp0"
set "APPLY=0"
set "DIRECTORY_PROVIDED=0"

:parse
if "%~1"=="" goto parsed
if /I "%~1"=="--apply" (
    set "APPLY=1"
    shift
    goto parse
)
if /I "%~1"=="--help" goto help
if "%~1:~0,2%"=="--" (
    echo Unknown option: %~1
    goto help_error
)
if "!DIRECTORY_PROVIDED!"=="1" (
    echo Only one directory may be provided.
    goto help_error
)
set "TARGET=%~1"
set "DIRECTORY_PROVIDED=1"
shift
goto parse

:parsed
if not exist "%TARGET%\" (
    echo Directory not found: %TARGET%
    exit /b 1
)
if not "%TARGET:~-1%"=="\" set "TARGET=%TARGET%\"

set /a COUNT=0
for /f "delims=" %%F in ('dir /b /a-d "%TARGET%" 2^>nul') do (
    set "NAME=%%F"
    if /I not "!NAME!"=="organize.bat" if /I not "!NAME!"=="organize.py" if /I not "!NAME!"=="organize.sh" if /I not "!NAME:~0,29!"=="organize-downloads.sh.backup-" (
        call :category "%%~xF"
        set "DESTDIR=%TARGET%!CATEGORY!"
        call :unique_destination "!DESTDIR!" "!NAME!"
        echo %TARGET%!NAME! ^> !DEST!
        set /a COUNT+=1
        if "!APPLY!"=="1" (
            if not exist "!DESTDIR!\" mkdir "!DESTDIR!"
            move /Y "%TARGET%!NAME!" "!DEST!" >nul
        )
    )
)

if "!COUNT!"=="0" (
    echo No files found in %TARGET%
    exit /b 0
)
if "!APPLY!"=="1" (
    echo.
    echo Moved !COUNT! file^(s^).
) else (
    echo.
    echo Dry run only: !COUNT! file^(s^) would be moved. Re-run with --apply to apply these moves.
)
exit /b 0

:category
set "CATEGORY=Other"
set "EXTENSION=%~1"
if /I "!EXTENSION!"==".exe" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".msi" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".msix" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".appx" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".deb" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".rpm" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".appimage" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".run" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".bin" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".sh" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".bat" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".cmd" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".com" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".apk" set "CATEGORY=Programs"
if /I "!EXTENSION!"==".iso" set "CATEGORY=Programs"

for %%E in (.mp4 .mkv .avi .mov .wmv .flv .webm .m4v .3gp .mpg .mpeg .m2ts .ts .vob) do if /I "!EXTENSION!"=="%%E" set "CATEGORY=Video"
for %%E in (.zip .rar .7z .tar .gz .bz2 .xz .lz .lzma .zst .tgz .tbz .tbz2 .txz .cab .arj .cbz .cbr) do if /I "!EXTENSION!"=="%%E" set "CATEGORY=Compressed"
for %%E in (.jpg .jpeg .png .gif .bmp .tif .tiff .webp .svg .ico .heic .avif) do if /I "!EXTENSION!"=="%%E" set "CATEGORY=Images"
for %%E in (.mp3 .wav .flac .m4a .aac .ogg .oga .opus .wma .aiff .alac) do if /I "!EXTENSION!"=="%%E" set "CATEGORY=Audio"
for %%E in (.pdf .doc .docx .odt .rtf .txt .md .tex .xls .xlsx .ods .csv .ppt .pptx .odp .epub .mobi .ipynb .c .h .cpp .java .py .js .ts .html .css .json .xml) do if /I "!EXTENSION!"=="%%E" set "CATEGORY=Documents"
exit /b 0

:unique_destination
set "DESTDIR=%~1"
set "FILENAME=%~2"
set "DEST=%DESTDIR%\%~2"
set "STEM=%~n2"
set "EXT=%~x2"
set /a NUMBER=1
:unique_loop
if exist "!DEST!" (
    set "DEST=!DESTDIR!\!STEM! (!NUMBER!)!EXT!"
    set /a NUMBER+=1
    goto unique_loop
)
exit /b 0

:help
echo Usage: organize.bat [DIRECTORY] [--apply]
echo.
echo By default, files directly inside the folder containing this script are previewed.
echo Use --apply to move the files.
exit /b 0

:help_error
call :help
exit /b 2
