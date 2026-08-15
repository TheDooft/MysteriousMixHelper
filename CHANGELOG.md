# Changelog

## v1.1.0

- Each combination now shows the icon of the offering it produces, with the
  collected tick riding on the corner of that icon.
- Reworked the window's look: flat dark panel, accent title bar, zebra rows,
  hover highlight, a status bar down the left edge of each row and a progress
  bar along the bottom.
- Hovering a row now shows the offering's own item tooltip above the ingredient
  breakdown.
- Fixed how achievement progress is matched. Each criterion is keyed by the
  offering's item id, which is what the criterion carries as its asset — the
  previous code treated those numbers as criteria ids, which would have left a
  non-English client reporting progress as unavailable.

## v1.0.0

- First release.
- Window opens at Ofi the Sly while you are on Mixing Mysteries, listing all ten
  ingredient combinations against what you are carrying.
- Ticks off the combinations already credited towards Mysterious Mix Master, and
  takes the offering names from the achievement's own criteria so they arrive in
  your language.
- Marks a suggested mix: of the ones you can afford today, the one that leaves
  the most of the others still within reach.
- Footer totals what the combinations you have left still need in all.
- Options for auto-open, auto-close, dimming collected offerings, counting
  stored items and locking the window. `/mmh` for the command list.
