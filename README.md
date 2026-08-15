# Mysterious Mix Helper

A small World of Warcraft addon for the **Mixing Mysteries** daily on The Coiled
Isle, and the **Mysterious Mix Master** achievement it feeds.

Ofi the Sly takes three ingredients, one dialogue choice at a time, drawn from
three kinds. That is ten distinct combinations, each yielding a different
Mysterious Offering — and the achievement wants all ten. The quest is a daily and
is shared across your warband, so you get one attempt a day and there is no
in-game feedback while you pick.

Target Ofi with the quest in your log and a window opens: one row per
combination, wearing the icon of the offering it produces, against three columns
holding what you are carrying of each ingredient.

- A **tick on the offering's icon**, and a greyed row, means it is already
  credited towards the achievement.
- A **green bar** down the left edge marks a mix you can hand in right now.
- **Red numbers** are what you are short of, counting only your bags — a bank is
  no use standing in front of Ofi.
- One row is marked **suggested**, in gold: of the mixes you can afford today,
  the one that leaves the most of the remaining ones still within reach. It is a
  heuristic, not an instruction — you can always buy more ingredients.
- The footer totals what your remaining combinations still need altogether.
  From scratch that is ten of each.

Hovering a row gives you the offering's own item tooltip, then the ingredients
it takes and what you are missing.

Offering names come from the achievement's own criteria, so they show up in your
client's language without the addon shipping a translation.

## The combinations

| Offering | Ancient Knucklebone | Serpent's Feather | Clouded Blood-Pearl |
|---|---|---|---|
| Choleric | | | 3 |
| Virulent | | 1 | 2 |
| Volatile | 1 | | 2 |
| Phlegmatic | | 3 | |
| Odious | | 2 | 1 |
| Pestilent | 1 | 2 | |
| Melancholic | 3 | | |
| Fragile | 2 | | 1 |
| Eerie | 2 | 1 | |
| Balanced | 1 | 1 | 1 |

## Unlocking the daily

On a character that cannot take the quest yet, the bottom line of the window
names the next step and the tooltip lays out the route:

1. [What Lies Beyond the Fog](https://www.wowhead.com/quest=92924) — the Curse
   of Ula'tek campaign quest that carries you across to Tokka's Landing.
2. [Esoteric Ingredients](https://www.wowhead.com/quest=97026) — started by an
   item looted on the isle, handed in to Ofi the Sly.

The isle itself is a warband unlock but campaign progress is per character, so
an alt has to walk this itself. Wowhead publishes no prerequisite link for the
daily, so the chain is read off the quests rather than stated by the game; the
wording says "step N of M" rather than claiming these are the only gates.

The window also says when today's mix has already been spent — including when
another character in the warband spent it, which is the state most likely to
leave you puzzling at Ofi.

## Credits

The table of combinations is [Lazey's work][comment], from their comment on the
Mysterious Mix Master page on Wowhead. Working it out first-hand would have cost
a great many wasted dailies, since the quest gives no feedback while you choose
and can only be done once a day. Hover the cauldron in the window's title bar to
see the credit in game.

The offering item ids were cross-checked against Wowhead's own item pages.

[comment]: https://www.wowhead.com/achievement=63432/mysterious-mix-master#comments:id=6389799

## Commands

```
/mmh
```

Shows or hides the window. `/mmh help` lists every option, `/mmh config` opens
the settings panel, `/mmh reset` puts the window back in the middle of the
screen. Each option can also be toggled by name, e.g. `/mmh autoHide`.

| Option | Default | What it does |
|---|---|---|
| `autoShow` | on | Open automatically at Ofi the Sly. |
| `autoHide` | on | Close again once he is no longer your target. |
| `requireQuest` | on | Only open with Mixing Mysteries actually in your log. |
| `dimDone` | on | Grey out combinations you have already turned in. |
| `suggest` | on | Mark a suggested mix. |
| `showTotals` | on | Also show what you have in bank and warband bank. |
| `bubbles` | on | Simmer the cauldron behind the table. Decoration only. |
| `locked` | off | Stop the window being dragged. |

Each bubble is a flat white texture tinted green, rounded off by Blizzard's
portrait mask and blended additively. The mask has to be set before the texture,
and the texture has to be a real file — a mask over a `SetColorTexture` fill has
no effect and draws squares. Size, count, speed and opacity are the `BUBBLE_*`
constants at the top of `UI.lua`.

An in-game effect model was tried here instead (v1.6, commit `2036755`) and did
not look good in the client; the bubbles stayed.

## Development

The addon files sit at the root of the repository. Install for development with
an NTFS junction:

```bash
cmd //c mklink //J "D:\World of Warcraft\_retail_\Interface\AddOns\MysteriousMixHelper" "C:\dev\MysteriousMixHelper"
```

Tests stub the slice of the WoW API the addon touches — including enough of the
widget system to render the window — and run in standalone Lua:

```bash
lua tests/run.lua
```

Note the harness runs on Lua 5.4 while the client is 5.1; the globals that
differ (`unpack`, `strsplit`) are stubbed in `tests/harness.lua`.

Release: `tools/Set-Version.ps1 <x.y.z> -Tag`, then push the tag. The workflow
refuses to publish if the tag and the TOC version disagree.

## Licence

MIT.
