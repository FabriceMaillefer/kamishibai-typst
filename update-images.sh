#!/usr/bin/env bash
# Régénère images.typ à partir du contenu du dossier Images/
set -euo pipefail
cd "$(dirname "$0")"

{
  echo "// Généré automatiquement par update-images.sh — ne pas éditer à la main."
  echo "#let images = ("
  find Images -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
    | sort -V \
    | while IFS= read -r f; do
        base="${f##*/}"
        label="${base%.*}"
        printf '  (path: "%s", label: "%s"),\n' "$f" "$label"
      done
  echo ")"
} > images.typ

count=$(grep -c '^  (path:' images.typ || true)
echo "images.typ mis à jour : $count image(s) trouvée(s) dans Images/."
