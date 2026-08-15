## v1.7.0

- Bigger bubbles: up to 38px across rather than 22, and swaying wider. Eighteen
  of them, so the window does not get crowded at that size.
- Dropped the effect-model alternative introduced in 1.6 — it did not look good
  in the client. Back to a plain on/off switch, and a setting saved by 1.6
  carries over. `/mmh bubbles`.

## v1.6.0

- Tried an in-game effect model behind the table as an alternative to the drawn
  bubbles, with live framing controls. Removed again in 1.7; see that entry.
- The bubbles are less shy — more of them, larger, and up to 32% opacity rather
  than 13%.
- Fixed the saved settings sharing the defaults table, which would have let a
  changed value quietly rewrite the default it is meant to be restorable to.

## v1.5.0

- Ofi's cauldron now simmers behind the table: faint bubbles rise, sway and
  thin out before the top. Purely decorative, and off with `/mmh bubbles` or
  the "Keep the cauldron simmering" option.

## v1.4.0

- On a character that cannot take the daily yet, the bottom line now names the
  next step towards unlocking it, and hovering that line lays out the whole
  route with what is already done ticked off. Quest titles come from the
  client, so they arrive in your language.
- The window now also opens at Ofi for a character still working up to the
  daily — previously "only with the quest in your log" hid it from exactly the
  character that most needed telling. The option is renamed to match.
- Says when today's mix has already been spent, including the case where
  another character in the warband spent it.
- Removed the "where to find it" note from ingredient tooltips. All three list
  the same container on Wowhead, so it said the same thing three times; whether
  separate treasures favour separate ingredients is disputed between players
  and not something this addon should assert.

## v1.3.0

- Ingredient tooltips now say where to find more: the container they open out
  of, how often a container holds that particular one, and that they can be
  bought rather than farmed.
- Hovering the cauldron on the title bar shows the version and a thank-you to
  Lazey, whose Wowhead comment is where the table of combinations comes from.
  `/mmh help` prints the same credit.

## v1.2.0

- Collected offerings are far easier to pick out: the tick has a column of its
  own instead of riding on the icon's corner, and the row gets a green wash and
  a green edge bar. The three row states now use text colours that are actually
  far apart — previously "collected" and "cannot afford" were within a few
  hundredths of each other and the list read as one grey block.
- The icons in the "still need in total" line are real controls now, so hovering
  one shows the ingredient, what you carry, what you have stored, how much the
  combinations you have left still want, and the shortfall. The column headers
  show the same tooltip.

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
