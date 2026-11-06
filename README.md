# Kamishibai

Génère des planches A3 (42 × 29,7 cm) à partir d'images, imprimées sur 2 pages A4 à découper et recoller.

## Prérequis

- [Typst](https://typst.app) (testé avec 0.15)
  - Windows : `winget install --id Typst.Typst`
  - Arch : `pacman -S typst`
  - Autres : binaire depuis [github.com/typst/typst/releases](https://github.com/typst/typst/releases)
- [Python 3](https://www.python.org/downloads/), sans module supplémentaire
  - Windows : `winget install Python.Python.3.13`

Après une installation sous Windows, fermer et rouvrir le terminal pour que les commandes soient reconnues.

## Specs

- Image finale : 37 × 27,5 cm, centrée sur la page A3
- Découpage : chaque planche = 1 page A4 gauche + 1 page A4 droite, sans perte de dessin au raccord
- Repère de coupe : trait pointillé sur le bord intérieur de chaque page (largeur réglable via `inner-margin` dans `kamishibai.typ`)
- Numérotation : chaque page affiche `<numéro> G` ou `<numéro> D` dans le coin extérieur, pour trier/réordonner les feuilles
- Ordre des planches : tri numérique des noms de fichiers dans `Images/` (`1.jpg`, `2.jpg`, … `31.jpg`)

## Usage

1. Placer les images dans `Images/`
2. Générer le PDF, ce qui met aussi à jour la liste des images :
   - Windows : double-cliquer sur `generer-pdf.bat`, ou lancer `py build.py`
   - Linux/macOS : `./build.py`
3. Imprimer `kamishibai.pdf` en **taille réelle (100 %)**, jamais "ajuster à la page"
4. Découper la bande le long du pointillé sur le bord intérieur de chaque page
5. Recoller les deux pages bord à bord (aligner les pointillés en haut/bas) pour reformer l'A3

Sous Windows, fermer le PDF dans Acrobat avant de relancer la génération : Acrobat verrouille le fichier qu'il affiche.
