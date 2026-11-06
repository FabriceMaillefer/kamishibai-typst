#!/usr/bin/env python3
"""Génère kamishibai.pdf : met à jour images.typ depuis Images/, puis compile avec Typst.

Fonctionne sous Windows, Linux et macOS. Nécessite seulement Python 3 et Typst.
"""

import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
IMAGES_DIR = ROOT / "Images"
IMAGES_TYP = ROOT / "images.typ"
SOURCE = ROOT / "kamishibai.typ"
PDF = ROOT / "kamishibai.pdf"
EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}


def natural_key(name):
    """Clé de tri numérique : 2.jpg passe avant 10.jpg."""
    parts = re.split(r"(\d+)", name.casefold())
    parts[1::2] = map(int, parts[1::2])
    return parts, name


def typst_string(value):
    """Écrit une chaîne littérale Typst."""
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def update_images():
    """Réécrit images.typ et renvoie le nombre d'images trouvées."""
    IMAGES_DIR.mkdir(exist_ok=True)
    names = sorted(
        (
            p.name
            for p in IMAGES_DIR.iterdir()
            if p.is_file() and p.suffix.lower() in EXTENSIONS
        ),
        key=natural_key,
    )
    if not names:
        return 0

    lines = ["// Généré automatiquement par build.py — ne pas éditer à la main."]
    lines.append("#let images = (")
    for name in names:
        # Typst attend des « / » dans les chemins, y compris sous Windows.
        path = typst_string(f"Images/{name}")
        label = typst_string(Path(name).stem)
        lines.append(f"  (path: {path}, label: {label}),")
    lines.append(")")

    # Typst exige de l'UTF-8, alors que Python utilise souvent cp1252 par
    # défaut sous Windows. Les fins de ligne restent LF sur tous les systèmes.
    with open(IMAGES_TYP, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    return len(names)


def pdf_is_locked():
    """Sous Windows, un lecteur comme Acrobat verrouille le PDF qu'il affiche."""
    try:
        with open(PDF, "r+b"):
            return False
    except FileNotFoundError:
        return False
    except PermissionError:
        return True


def main():
    # Évite un plantage sur un nom de fichier accentué si la sortie est redirigée.
    sys.stdout.reconfigure(errors="replace")
    sys.stderr.reconfigure(errors="replace")

    count = update_images()
    if count == 0:
        print(f"Aucune image trouvée. Placez vos images dans : {IMAGES_DIR}", file=sys.stderr)
        return 1
    print(f"images.typ mis à jour : {count} image(s) trouvée(s) dans Images/.")

    typst = shutil.which("typst")
    if typst is None:
        print(
            "Typst est introuvable.\n"
            "  Windows : winget install --id Typst.Typst\n"
            "            puis fermez et rouvrez le terminal.\n"
            "  Autres  : https://github.com/typst/typst/releases",
            file=sys.stderr,
        )
        return 1

    if pdf_is_locked():
        print(
            f"Impossible d'écrire {PDF.name} : le fichier est verrouillé.\n"
            "Fermez-le dans votre lecteur PDF, puis relancez.",
            file=sys.stderr,
        )
        return 1

    print("Compilation en cours...", flush=True)
    result = subprocess.run([typst, "compile", SOURCE.name, PDF.name], cwd=ROOT)
    if result.returncode != 0:
        print("La compilation a échoué (voir les messages ci-dessus).", file=sys.stderr)
        return result.returncode

    print(f"PDF généré : {PDF}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
