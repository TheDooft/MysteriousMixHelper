# Mysterious Mix Helper

A small World of Warcraft addon for the **Mixing Mysteries** daily on The Coiled
Isle, and the **Mysterious Mix Master** achievement it feeds.

Ofi the Sly takes three ingredients, one dialogue choice at a time, drawn from
three kinds. That is ten distinct combinations, each yielding a different
Mysterious Offering — and the achievement wants all ten. The quest is a daily and
is shared across your warband, so you get one attempt a day and there is no
in-game feedback while you pick.

Target Ofi with the quest in your log and this window opens:

| | | Bone | Feather | Pearl |
|---|---|---|---|---|
| | **In your bags** | **3** | **1** | **5** |
| ✓ | Choleric Offering | | | 3 |
| | Virulent Offering | | 1 | 2 |
| | Volatile Offering | 1 | | 2 |
| | Phlegmatic Offering | | <span style="color:red">3</span> | |
| … | | | | |

- **Ticked** rows are already credited towards the achievement.
- **Green** rows you can hand in right now.
- **Red numbers** are what you are short of, counting only your bags — a bank is
  no use standing in front of Ofi.
- One row is marked **suggested**: of the mixes you can afford today, the one
  that leaves the most of the remaining ones still within reach. It is a
  heuristic, not an instruction — you can always buy more ingredients.
- The footer totals what your remaining combinations still need altogether.
  From scratch that is ten of each.

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

The mapping is from [Lazey's comment][comment] on the achievement page, with the
criteria ids cross-checked against Wowhead's achievement data.

[comment]: https://www.wowhead.com/achievement=63432/mysterious-mix-master#comments:id=6389799

Ingredients drop from treasures around The Coiled Isle and are tradable, so the
auction house is an option: knucklebones near undead and graveyards, feathers
near serpents and poisonous ground, blood-pearls along the shore.

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
| `locked` | off | Stop the window being dragged. |

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
