# Screenshots

Captures for the CurseForge project page. Drop the PNGs in here and upload them
from the project's Images tab.

The images themselves are **not tracked** — see `.gitignore`. They are throwaway
captures of a UI that keeps changing, and the CurseForge page is where they
actually live. Only this file is in the repository, so the folder survives a
fresh clone. If you would rather version them, drop the `screenshots/*` line
from `.gitignore`; `.pkgmeta` already keeps the whole folder out of the addon
zip either way.

## Shot list

The page wants three or four that each say something different. In rough order
of how much they earn their place:

| File | What it has to show |
|---|---|
| `01-window.png` | The window open at Ofi, with a couple of combinations collected and a couple affordable — green rows, ticked rows, the gold suggestion, the footer counting. The whole pitch in one picture. |
| `02-row-tooltip.png` | A row hovered: the offering's own tooltip, what it needs, and what you are short of. |
| `03-unlock.png` | The bottom line on a character that cannot take the daily yet, tooltip open on the unlock chain. This is the feature nobody expects and it needs showing. |
| `04-ingredient-tooltip.png` | An ingredient hovered from the "still need in total" line: bags, stored, wanted, shortfall. Optional — only if the first three do not already carry it. |

## Taking them

- UI scale at 100%, or the text goes soft in the thumbnail.
- Crop to the window plus a little background. Ofi and the swamp behind the
  bubbles gives it some context; a full 4K screenshot of your whole UI does not.
- `Alt`+`Z` hides the rest of the interface if something is in the way.
- Screenshots land in `_retail_\Screenshots`. Set `Screenshot Quality` to
  maximum in the graphics options first, or you get JPEG mush.
- Turn the cauldron bubbles on — they photograph well and they are half the
  reason the window looks alive.
