// kamishibai.typ
//
// Fabrique des planches de kamishibai au format A3 (42 x 29,7 cm) à partir
// d'images imprimées sur 2 pages A4 à découper puis recoller.
//
// Pour chaque image du dossier Images/, ce fichier génère 2 pages A4 :
//   - la moitié gauche de l'image
//   - la moitié droite de l'image
// Une fois les deux pages imprimées, on découpe la fine bande blanche
// laissée au bord intérieur de chacune (repère en pointillés) puis on
// recolle les deux bords ainsi obtenus pour reformer une page A3 sur
// laquelle l'image mesure environ 37 x 27,5 cm.
//
// Utilisation :
//   1. Placer les images dans le dossier Images/
//   2. Lancer ./update-images.sh pour régénérer images.typ
//   3. Compiler : typst compile kamishibai.typ kamishibai.pdf
//   4. Imprimer en taille réelle (100 %, sans "ajuster à la page")
//   5. Découper la bande le long du repère pointillé sur le bord intérieur
//      de chaque page, puis recoller les deux pages bord à bord en alignant
//      les traits pointillés (haut et bas de la page) pour reformer l'A3.

#import "images.typ": images

// ---- Paramètres ----
#let img-width = 37cm      // largeur finale de l'image sur la page A3
#let img-height = 27.5cm   // hauteur finale de l'image sur la page A3
#let a3-width = 42cm       // largeur d'une page A3 (paysage)
#let a3-height = 29.7cm    // hauteur d'une page A3
#let a4-width = a3-width / 2  // 21cm, largeur réelle d'une page A4 portrait
#let inner-margin = 3mm    // bande réservée à la découpe sur le bord intérieur
                            // (la plupart des imprimantes ne peuvent pas
                            // imprimer jusqu'au bord exact de la feuille :
                            // cette valeur doit être >= à la marge non
                            // imprimable de ton imprimante, sinon le repère
                            // de coupe et le bord de l'image tombent dans
                            // la zone non imprimable et ne s'impriment pas)

#let margin-x = (a3-width - img-width) / 2   // marge blanche extérieure (gauche/droite)
#let margin-y = (a3-height - img-height) / 2 // marge blanche extérieure (haut/bas)

// la bande de découpe est prélevée sur la marge blanche extérieure (qui
// est purement décorative), jamais sur l'image : chaque moitié affiche
// donc bien la totalité de son côté (0 à 18,5cm / 18,5 à 37cm), sans
// aucune perte de dessin ni décalage au raccord
#let outer-margin-x = margin-x - inner-margin

#set page(paper: "a4", margin: 0pt)

#let cut-guide(x) = place(top + left, dx: x, dy: 0pt)[
  #line(start: (0pt, 0pt), end: (0pt, a3-height),
    stroke: (thickness: 0.3pt, dash: "dashed", paint: gray))
]

// numéro de la planche, imprimé dans le coin extérieur (à l'opposé de la
// bande de découpe) pour retrouver et réordonner facilement les feuilles
#let sheet-label(label, side) = {
  let corner = if side == "left" { bottom + left } else { bottom + right }
  let dx = if side == "left" { 8mm } else { -8mm }
  place(corner, dx: dx, dy: -8mm)[
    #text(size: 11pt, fill: gray)[#label #if side == "left" [G] else [D]]
  ]
}

#let half-page(image-path, label, side) = {
  if side == "left" {
    box(width: a4-width - inner-margin, height: a3-height, clip: true, fill: white)[
      #place(top + left, dx: outer-margin-x, dy: margin-y)[
        #image(image-path, width: img-width, height: img-height, fit: "cover")
      ]
    ]
    cut-guide(a4-width - inner-margin)
  } else {
    place(top + right, dx: 0pt, dy: 0pt)[
      #box(width: a4-width - inner-margin, height: a3-height, clip: true, fill: white)[
        #place(top + left, dx: -img-width / 2, dy: margin-y)[
          #image(image-path, width: img-width, height: img-height, fit: "cover")
        ]
      ]
    ]
    cut-guide(inner-margin)
  }
  sheet-label(label, side)
}

#for (i, img) in images.enumerate() [
  #if i > 0 [#pagebreak()]
  #half-page(img.path, img.label, "left")
  #pagebreak()
  #half-page(img.path, img.label, "right")
]
