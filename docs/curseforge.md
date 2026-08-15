# Creating the CurseForge project

Everything the "Create Project" form asks for, ready to paste. Steps 1–3 of the
CurseForge wiring in `README.md`; come back here for the text.

The description is written in English because that is what the CurseForge page
is read in. A French version follows it — the addon ships frFR strings, so it is
worth pasting underneath the English one on the same page rather than leaving
French players to guess.

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

### The problem

Every day, Ofi the Sly asks you for three ingredients for her stew. There are
three kinds, you hand them over one at a time, and nothing stops you handing over
the same one twice. That is ten combinations, ten different offerings, and the
**Mysterious Mix Master** achievement wants every single one of them.

Here is the fun part: Ofi gives you no feedback at all while you choose. No
bubbling, no glow, no "ooh, that's the good stuff". Just a dialogue box that
changes about four words if you squint at it. And the quest is a daily, shared
across your entire warband, so one wrong guess costs you a day — for every
character you own, at once.

Ten offerings. One attempt per day. No way to tell what you have already done
without opening the achievement pane and cross-referencing a table someone
kindly typed up on the internet.

You could do that. Or you could target Ofi and read one window.

### What it does

Target Ofi the Sly with the daily in your log and this opens:

- **Ten rows, one per combination**, each wearing the icon of the offering it
  makes, against three columns of what you are actually carrying.
- **Green** means you can make it right now. It counts your bags only, because
  your bank is not standing next to you and neither is your warband.
- **Ticked and greyed out** means the achievement already has it. No more
  squinting at the criteria list.
- **One row in gold** is the suggested mix: of the ones you can afford today, the
  one that leaves the most of the others still within reach. It is a suggestion,
  not an order. You are the one holding the knucklebones.
- **The footer** keeps score: how many you have collected, how many you can make
  right now, and the total ingredients your remaining combinations still want.
  From a standing start that is ten of each, which is a number worth knowing
  before you go treasure hunting.

Hover anything and it tells you more: the offering's own tooltip on a row, and
on any ingredient, what you carry, what you have stored elsewhere, and how much
of it the mixes you have left are going to want.

### It also handles your alts

Rolled up to Ofi on a fresh character and found she has nothing to say? The
window tells you why, and what is left to do before she will hand over the
daily. Zone access is warband-wide but campaign progress is not, so this is a
per-character problem that looks like a bug until someone explains it.

It also spots the other confusing one: the daily is shared across your warband,
so if another character already mixed today, the window says so instead of
letting you wonder where the quest went.

### Small things

- Offering names come from the achievement's own criteria, so they arrive in
  your language without the addon translating anything.
- The window is draggable, closes with Escape, and remembers where you put it.
- Ofi's cauldron simmers away behind the table. Purely decorative. Turn it off if
  you are the sort of person who turns that sort of thing off.

### Commands

- `/mmh` — show or hide the window
- `/mmh help` — every option, with its current state
- `/mmh config` — open the settings panel
- `/mmh reset` — put the window back in the middle of the screen

Everything is a checkbox in Interface Options as well: open at Ofi, close when
you look away, dim the collected ones, mark a suggested mix, count your bank,
simmer the cauldron, lock the window.

### With thanks

The table of combinations is **Lazey's** work, from their comment on the
Mysterious Mix Master page on Wowhead. Working it out first-hand would have cost
a great many wasted dailies, given that the quest tells you nothing and only
comes round once a day. This addon would not exist without that comment, and the
in-game window says so on the cauldron in its title bar.

---

## Description — Français

### Le problème

Chaque jour, Ofi la Sournoise vous réclame trois ingrédients pour son ragoût. Il
en existe trois sortes, vous les donnez un par un, et rien ne vous empêche de donner
deux fois le même. Ça fait dix combinaisons, dix offrandes différentes, et le
haut fait **Maître des mélanges mystérieux** les veut toutes.

Le meilleur : Ofi ne vous donne aucun retour pendant que vous choisissez. Pas de
bouillonnement, pas de lueur, pas de « ah, ça c'est du bon ». Juste une boîte de
dialogue dont quatre mots changent si vous plissez les yeux. Et comme la quête
est journalière et partagée par tout le bataillon, une erreur vous coûte une
journée — sur tous vos personnages à la fois.

Dix offrandes. Un essai par jour. Et aucun moyen de savoir ce que vous avez déjà
fait sans ouvrir le panneau des hauts faits et le recouper avec un tableau que
quelqu'un a eu la bonté de taper sur internet.

Vous pouvez faire ça. Ou cibler Ofi et lire une fenêtre.

### Ce qu'il fait

Ciblez Ofi la Sournoise avec la journalière dans votre journal, et ceci s'ouvre :

- **Dix lignes, une par combinaison**, chacune portant l'icône de l'offrande
  qu'elle produit, face à trois colonnes de ce que vous avez réellement sur vous.
- **En vert** : réalisable tout de suite. Seuls les sacs comptent, parce que
  votre banque n'est pas plantée à côté de vous, et votre bataillon non plus.
- **Cochée et grisée** : le haut fait l'a déjà. Fini de scruter la liste des
  critères.
- **Une ligne en or** : le mélange conseillé. Parmi ceux que vous pouvez faire
  aujourd'hui, celui qui laisse le plus des autres à votre portée. C'est une
  suggestion, pas un ordre. C'est vous qui tenez les osselets.
- **Le pied de page** tient les comptes : offrandes obtenues, mélanges
  réalisables maintenant, et le total d'ingrédients que réclament encore vos
  combinaisons restantes. En partant de zéro : dix de chaque, un chiffre bon à
  connaître avant d'aller courir les trésors.

Survolez n'importe quoi pour en savoir plus : l'infobulle de l'offrande sur une
ligne, et sur un ingrédient, ce que vous portez, ce que vous avez rangé
ailleurs, et ce que les mélanges restants vont en réclamer.

### Il s'occupe aussi de vos rerolls

Vous arrivez chez Ofi sur un personnage neuf et il n'a rien à vous dire ? La
fenêtre explique pourquoi, et ce qu'il reste à faire avant qu'elle propose la
journalière. L'accès à la zone est acquis pour tout le bataillon, mais la
progression de campagne non — c'est donc un problème propre à chaque
personnage, qui ressemble à un bug tant que personne ne l'explique.

Elle repère aussi l'autre cas trompeur : la journalière étant partagée, si un
autre personnage a déjà fait son mélange aujourd'hui, la fenêtre le dit au lieu
de vous laisser chercher où est passée la quête.

### Détails

- Les noms des offrandes viennent des critères du haut fait, donc ils arrivent
  dans votre langue sans que l'addon traduise quoi que ce soit.
- La fenêtre se déplace à la souris, se ferme avec Échap, et retient sa place.
- Le chaudron d'Ofi mijote derrière le tableau. Purement décoratif. Désactivable
  si vous êtes du genre à désactiver ce genre de chose.

### Commandes

- `/mmh` — afficher ou masquer la fenêtre
- `/mmh help` — toutes les options, avec leur état
- `/mmh config` — ouvrir le panneau de configuration
- `/mmh reset` — remettre la fenêtre au centre de l'écran

Tout est aussi une case à cocher dans les options d'interface.

### Remerciements

Le tableau des combinaisons est l'œuvre de **Lazey**, tiré de son commentaire
sur la page du haut fait « Mysterious Mix Master » de Wowhead. Le reconstituer
soi-même aurait coûté un grand nombre de journalières gâchées, vu que la quête
ne dit rien et ne revient qu'une fois par jour. Cet addon n'existerait pas sans
ce commentaire, et la fenêtre le rappelle sur le chaudron de sa barre de titre.

---

## Images

**Avatar** — 400×400 PNG, required. The achievement's own icon
(`inv_misc_cauldron_arcane`) is the obvious choice, since it is already the
addon's icon in the addon list.

**Screenshots** — upload these directly on CurseForge; the repository does not
carry them (`screenshots/` is in `.gitignore`). Worth having:

1. The window open at Ofi with a mix or two collected — the whole point in one
   picture.
2. A row tooltip open, showing the offering and what it needs.
3. The unlock line on a character that has not got the daily yet.

Shoot them with the UI at 100% scale and crop to the window plus a little
background, so the text stays legible in the thumbnail.
