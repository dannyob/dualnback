module Instructions exposing (instructionsHtml)

import Markdown
import Html
instructions = """
Welcome to Dual N Back, the mind game that ACTUAL scientists 
believe might improve your IQ. 

(WARNING: see giant footnote in tiny font.)

How to Play

See this grid?

Every two seconds, a new spot will light up on it, and 
a voice will say a letter.

Your job is to notice when the latest spot is in same place as the spot TWO steps 
back, OR when the voice says the same letter as two steps back.

If the spots match, hit the 'S' key. If the letters match, hit the 'L' key.

If they both match, hit both keys (in any order).

Every time you make a match, you'll get a point.

Every time you miss a match, you'll lose a point.

If you do well enough, we'll start matching spots and letters THREE steps back.

Ready to play?

"""
instructionsHtml = Markdown.toHtml [] instructions

