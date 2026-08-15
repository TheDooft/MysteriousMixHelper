# Creating the CurseForge project

The project page's own text, kept here so it can be edited in the repository
rather than only in a web form. `README.md` describes how the repository is
wired to CurseForge; this file is the wording.

The description is in English because that is what the page is read in. A French
version follows it — the addon ships frFR strings, so it is worth pasting
underneath the English one on the same page rather than leaving French players
to guess.

Both are deliberately short. A longer version that walked through every feature
is in the history at commit `cb3864b` if the page ever needs filling out.

---

## Form fields

| Field | Value |
|---|---|
| **Name** | Mysterious Mix Helper |
| **Slug / URL** | `mysterious-mix-helper` |
| **Categories** | Quests & Leveling · Achievements |
| **License** | MIT |
| **Game** | World of Warcraft (Retail) |
| **Game version** | 12.1.0 — deduced by the packager from `## Interface: 120100`, no need to set it by hand on later uploads |

Leave the **Source** tab's packaging on **"No automatic packaging"**. GitHub
Actions builds the zip and pushes it here; letting CurseForge build its own
would duplicate the release and bypass the changelog carving.

---

## Summary

> Ofi the Sly wants three ingredients. She will not tell you what they do. This window will.

---

## Description — English

### Ten combinations. One try a day. No feedback whatsoever.

Ofi the Sly wants three ingredients for her stew. Three kinds, handed over one at
a time, repeats allowed — that is ten combinations, ten different offerings, and
**Mysterious Mix Master** wants every one of them. She gives you no hint while
you choose, and the quest is a daily shared across your whole warband, so a wrong
guess costs every character you own a day.

Target her and this opens:

- **All ten combinations**, against what is actually in your bags
- **Green** — you can make it right now
- **Ticked** — the achievement already has it
- **One in gold** — of the mixes you can afford today, the one that leaves the
  most of the others still within reach
- **The total** your remaining combinations still need, so you know what to farm
- **On an alt** — what is left before she will even offer you the daily

Names come from the achievement's own criteria, so they arrive in your language.

`/mmh` opens it anywhere. `/mmh help` lists the options.

The combination table is **Lazey's** work, from their comment on the Wowhead
achievement page. It would have cost a lot of wasted dailies to work out
otherwise. Thank you.

---

## Description — Français

### Dix combinaisons. Un essai par jour. Aucun retour.

Ofi la Sournoise réclame trois ingrédients pour son ragoût. Trois sortes, données
une par une, répétitions autorisées — soit dix combinaisons, dix offrandes
différentes, et le haut fait **Maître des mélanges mystérieux** les veut toutes.
Elle ne vous souffle rien pendant que vous choisissez, et la quête est
journalière et partagée par tout le bataillon : une erreur coûte une journée à
tous vos personnages.

Ciblez-la et ceci s'ouvre :

- **Les dix combinaisons**, face à ce que vous avez réellement dans vos sacs
- **En vert** : réalisable maintenant
- **Cochée** : le haut fait l'a déjà
- **Une en or** : parmi celles à votre portée aujourd'hui, celle qui laisse le
  plus des autres accessibles
- **Le total** que réclament vos combinaisons restantes, pour savoir quoi farmer
- **Sur un reroll** : ce qu'il reste à faire avant qu'elle propose la journalière

Les noms viennent des critères du haut fait, donc ils arrivent dans votre langue.

`/mmh` l'ouvre n'importe où. `/mmh help` liste les options.

Le tableau des combinaisons est l'œuvre de **Lazey**, tiré de son commentaire sur
la page Wowhead du haut fait. Le reconstituer aurait coûté beaucoup de
journalières gâchées. Merci.

---

## Images

**Avatar** — 400×400 PNG, required. Already made: **`docs/avatar-400.png`**.
Upload it as it is.

It is the achievement's own icon (`inv_misc_cauldron_arcane`, the same one the
addon shows in the addon list) on the window's panel colour, with the title
bar's gold as a frame and a couple of the green bubbles bleeding in from the
edges. The icon takes 83% of the square on purpose: an avatar is looked at at
64px far more often than at 400, and at that size the cauldron is the only part
anyone can actually read.

Regenerate it with `tools/New-Avatar.ps1` if the icon ever changes. It decodes
the client's TGA through `Convert-Tga.ps1` and composes with System.Drawing —
no ImageMagick needed.

**Screenshots** — upload these directly on CurseForge; the repository does not
carry them (`screenshots/` is in `.gitignore`). Worth having:

1. The window open at Ofi with a mix or two collected — the whole point in one
   picture.
2. A row tooltip open, showing the offering and what it needs.
3. The unlock line on a character that has not got the daily yet.

Shoot them with the UI at 100% scale and crop to the window plus a little
background, so the text stays legible in the thumbnail.
