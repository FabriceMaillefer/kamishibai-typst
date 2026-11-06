@echo off
rem Double-cliquer ici pour regenerer la liste d'images et compiler le PDF.
cd /d "%~dp0"

py -3 --version >/dev/null 2>nul
if not errorlevel 1 (
    py -3 build.py
    goto :end
)

python --version >/dev/null 2>nul
if not errorlevel 1 (
    python build.py
    goto :end
)

echo Python est introuvable. Pour l'installer :
echo   winget install Python.Python.3.13
echo ou depuis https://www.python.org/downloads/

:end
pause
