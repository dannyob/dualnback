module Instructions exposing (instructionsHtml)

import Markdown
import Html exposing (Html)


instructions : String
instructions =
    """
Welcome to *Dual N Back*, the mind game that **ACTUAL** scientists
believe may improve your IQ.

<small>(WARNING: see </small>giant<small> footnote in <small>tiny</small> font.)</small>

# How to Play

## Behold The Grid!

[INSERT ANIMATED GRID HERE]

Every two seconds, a new spot will light up on this grid, and a voice will tell
you letter.

<div class="bubble">M!</div>

Your job is to notice when the current spot is in same place as the spot TWO
steps back, OR when the voice says the same letter as two steps back.

[ANIMATED GRID SHOWING WHERE THINGS WERE PREVIOUSLY]

## Keys

If the spots match, hit the <span class="keyboard">S</span> key. If the letters match, hit the <span class="keyboard">L</span> key.

If they both match, hit both keys (in any order).

## Scoring

Every time you make a match, you'll get a point.

Every time you miss a match, you'll lose a point.

## Levelling Up

If you do well enough, we'll start matching spots and letters THREE steps back.

Ready to play?

"""


instructionsHtml : Html msg
instructionsHtml =
    Markdown.toHtml [] instructions
