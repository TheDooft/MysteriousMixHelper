local _, ns = ...

-- enUS is the fallback: any key missing from a translation falls back to this table.
local L = {
	TITLE            = "Mysterious Mix Helper",

	-- Window
	IN_YOUR_BAGS     = "In your bags",
	COMBINATIONS     = "Combinations",
	SUGGESTED        = "Suggested",
	-- %d done, %d total
	PROGRESS         = "%d of %d offerings collected",
	-- %d combinations you can hand in right now
	CAN_MAKE_NOW     = "%d you can make now",
	CAN_MAKE_NONE    = "none you can make now",
	ALL_DONE         = "All ten offerings collected — the achievement is yours.",
	STILL_NEED       = "Still need in total:",
	NOTHING_MISSING  = "You hold enough for every combination you have left.",
	DAILY_NOTE       = "One mix per day, shared across your warband.",
	NO_QUEST         = "Pick up Mixing Mysteries from Ofi to hand in a mix.",
	CRITERIA_UNKNOWN = "Achievement progress unavailable — open the achievement once to load it.",

	-- Unlocking the daily
	UNLOCK_STEP      = "To unlock, step %d of %d:",
	UNLOCK_TITLE     = "Unlocking Mixing Mysteries",
	UNLOCK_ISLE      = "Follow the Curse of Ula'tek campaign until it takes you across to Tokka's Landing on The Coiled Isle.",
	UNLOCK_ESOTERIC  = "Loot a Handful of Esoteric Ingredients on the isle, use it, and take the quest it starts to Ofi the Sly.",
	UNLOCK_CAVEAT    = "Campaign progress is per character, so an alt has to walk this itself.",
	DAILY_DONE       = "Today's mix is already spent — the quest returns tomorrow.",
	DAILY_DONE_ALT   = "Another character has already mixed today. The daily is shared across your warband.",

	-- Ingredient tooltips
	TT_IN_BAGS       = "In your bags",
	TT_STORED        = "Stored elsewhere",
	TT_NEEDED        = "Wanted by the mixes you have left",
	TT_SHORT_BY      = "Short by",

	-- Row tooltips
	TT_REQUIRES      = "Requires:",
	TT_DONE          = "Already collected.",
	TT_READY         = "You can make this one right now.",
	TT_SHORT         = "You are short:",
	TT_SUGGESTED     = "Suggested today: of the mixes you can make, this one leaves the most of the others still within reach.",

	-- Credits, shown on the title bar's cauldron and printed by /mmh help
	ABOUT_VERSION    = "version %s",
	ABOUT_HINT       = "Drag to move.  /mmh for options.",
	THANKS_TITLE     = "With thanks",
	THANKS_BODY      = "The table of combinations is Lazey's work, from their comment on the Mysterious Mix Master page on Wowhead. This addon would have taken a great many wasted dailies to work out without it.",

	-- Options
	OPT_AUTO_SHOW    = "Open at Ofi the Sly",
	OPT_AUTO_SHOW_TT = "Open the window automatically while you are on Mixing Mysteries and have Ofi the Sly targeted.",
	OPT_AUTO_HIDE    = "Close when you look away",
	OPT_AUTO_HIDE_TT = "Close the window again once Ofi is no longer your target. Turn this off to keep it open while you shop for ingredients.",
	OPT_REQUIRE_QUEST = "Only when there is something to say",
	OPT_REQUIRE_QUEST_TT = "Open only when Mixing Mysteries is in your quest log, or when this character has not unlocked it yet and the window can explain what is left. Turn this off to see the list whenever you target Ofi.",
	OPT_HIDE_DONE    = "Dim collected offerings",
	OPT_HIDE_DONE_TT = "Grey out the combinations you have already turned in.",
	OPT_SUGGEST      = "Mark a suggested mix",
	OPT_SUGGEST_TT   = "Point out which of the mixes you can afford leaves you best placed for the ones you still need.",
	OPT_SHOW_TOTALS  = "Count bank and warband bank",
	OPT_SHOW_TOTALS_TT = "Also show what you have stored away. Only what is in your bags can actually be handed to Ofi, so stored items are shown separately.",
	OPT_BREW         = "Behind the table",
	OPT_BREW_TT      = "What simmers behind the list. Purely decorative.",
	BREW_OFF         = "Nothing",
	BREW_OFF_TT      = "A plain background.",
	BREW_BUBBLES     = "Rising bubbles",
	BREW_BUBBLES_TT  = "Bubbles drawn by the addon, drifting up and swaying as they go.",
	BREW_FX          = "Ofi's brew",
	BREW_FX_TT       = "An effect model from the game itself. Heavier than the bubbles, and its framing can be dialled in with /mmh fx.",
	BREW_SET         = "Behind the table: %s",
	BREW_UNKNOWN     = "Unknown style '%s'. Use off, bubbles or fx.",

	FX_CURRENT       = "Framing for Ofi's brew:",
	FX_SET           = "fx %s = %g",
	FX_UNKNOWN       = "Unknown setting '%s'. Type /mmh fx for the list.",
	FX_RANGE         = "fx %s takes a number between %g and %g.",
	FX_RESET_HINT    = "|cffffd100/mmh fx reset|r — back to the shipped framing",
	FX_RESET_DONE    = "Framing reset.",

	OPT_LOCKED       = "Lock the window",
	OPT_LOCKED_TT    = "Stop the window being dragged around.",

	-- Slash command
	SLASH_HEADER     = "v%s — /mmh <option> to toggle:",
	SLASH_TOGGLE     = "|cffffd100/mmh|r — show or hide the window",
	SLASH_CONFIG     = "|cffffd100/mmh config|r — open the settings panel",
	SLASH_RESET      = "|cffffd100/mmh reset|r — put the window back in the middle of the screen",
	SLASH_UNKNOWN    = "Unknown option '%s'. Type /mmh for the list.",
	SLASH_ON         = "|cff20ff20on|r",
	SLASH_OFF        = "|cffff2020off|r",
	SLASH_RESET_DONE = "Window position reset.",

	-- %s is an item name, %d the amount stored outside your bags
	STORED_AWAY      = "+%d stored",
}

local translations = {
	frFR = {
		TITLE            = "Mysterious Mix Helper",

		IN_YOUR_BAGS     = "Dans vos sacs",
		COMBINATIONS     = "Combinaisons",
		SUGGESTED        = "Conseillé",
		PROGRESS         = "%d offrandes sur %d obtenues",
		CAN_MAKE_NOW     = "%d réalisable(s) maintenant",
		CAN_MAKE_NONE    = "aucune réalisable maintenant",
		ALL_DONE         = "Les dix offrandes sont obtenues — le haut fait est à vous.",
		STILL_NEED       = "Reste à réunir au total :",
		NOTHING_MISSING  = "Vous avez de quoi faire toutes les combinaisons qu'il vous reste.",
		DAILY_NOTE       = "Un mélange par jour, partagé avec tout le bataillon.",
		NO_QUEST         = "Prenez « Mélanges mystérieux » chez Ofi pour rendre un mélange.",
		CRITERIA_UNKNOWN = "Progression du haut fait indisponible — ouvrez-le une fois pour la charger.",

		UNLOCK_STEP      = "Pour débloquer, étape %d sur %d :",
		UNLOCK_TITLE     = "Débloquer « Mélanges mystérieux »",
		UNLOCK_ISLE      = "Suivez la campagne « La malédiction d'Ula'tek » jusqu'à ce qu'elle vous fasse traverser vers le Débarcadère de Tokka, sur l'Île Lovée.",
		UNLOCK_ESOTERIC  = "Ramassez une poignée d'ingrédients ésotériques sur l'île, utilisez-la, et portez la quête qu'elle ouvre à Ofi le Malin.",
		UNLOCK_CAVEAT    = "La progression de campagne est propre à chaque personnage : un reroll doit la refaire lui-même.",
		DAILY_DONE       = "Le mélange du jour est déjà fait — la quête revient demain.",
		DAILY_DONE_ALT   = "Un autre personnage a déjà fait le mélange aujourd'hui. La journalière est partagée par le bataillon.",

		TT_IN_BAGS       = "Dans vos sacs",
		TT_STORED        = "Rangés ailleurs",
		TT_NEEDED        = "Réclamés par les mélanges qu'il vous reste",
		TT_SHORT_BY      = "Il vous en manque",

		TT_REQUIRES      = "Nécessite :",
		TT_DONE          = "Déjà obtenue.",
		TT_READY         = "Vous pouvez faire celle-ci tout de suite.",
		TT_SHORT         = "Il vous manque :",
		TT_SUGGESTED     = "Conseillé aujourd'hui : parmi les mélanges réalisables, c'est celui qui laisse le plus des autres à votre portée.",

		ABOUT_VERSION    = "version %s",
		ABOUT_HINT      = "Glissez pour déplacer.  /mmh pour les options.",
		THANKS_TITLE     = "Remerciements",
		THANKS_BODY      = "Le tableau des combinaisons est l'œuvre de Lazey, tiré de son commentaire sur la page du haut fait « Mysterious Mix Master » de Wowhead. Sans lui, il aurait fallu gâcher un grand nombre de quêtes journalières pour le reconstituer.",

		OPT_AUTO_SHOW    = "Ouvrir chez Ofi le Malin",
		OPT_AUTO_SHOW_TT = "Ouvre la fenêtre automatiquement quand vous avez « Mélanges mystérieux » et Ofi le Malin en cible.",
		OPT_AUTO_HIDE    = "Fermer quand vous détournez le regard",
		OPT_AUTO_HIDE_TT = "Referme la fenêtre dès qu'Ofi n'est plus votre cible. Désactivez pour la garder ouverte pendant vos achats de composants.",
		OPT_REQUIRE_QUEST = "Seulement s'il y a quelque chose à dire",
		OPT_REQUIRE_QUEST_TT = "N'ouvre que si « Mélanges mystérieux » est dans votre journal, ou si ce personnage ne l'a pas encore débloquée et que la fenêtre peut expliquer ce qu'il reste à faire. Désactivez pour voir la liste dès que vous ciblez Ofi.",
		OPT_HIDE_DONE    = "Griser les offrandes obtenues",
		OPT_HIDE_DONE_TT = "Estompe les combinaisons que vous avez déjà rendues.",
		OPT_SUGGEST      = "Signaler un mélange conseillé",
		OPT_SUGGEST_TT   = "Indique lequel des mélanges à votre portée vous laisse le mieux placé pour ceux qu'il vous reste.",
		OPT_SHOW_TOTALS  = "Compter banque et banque de bataillon",
		OPT_SHOW_TOTALS_TT = "Affiche aussi ce que vous avez rangé. Seul le contenu des sacs peut être donné à Ofi, le reste est donc indiqué à part.",
		OPT_BREW         = "Derrière le tableau",
		OPT_BREW_TT      = "Ce qui mijote derrière la liste. Purement décoratif.",
		BREW_OFF         = "Rien",
		BREW_OFF_TT      = "Un fond uni.",
		BREW_BUBBLES     = "Bulles montantes",
		BREW_BUBBLES_TT  = "Des bulles dessinées par l'addon, qui montent en ondulant.",
		BREW_FX          = "Le brouet d'Ofi",
		BREW_FX_TT       = "Un modèle d'effet tiré du jeu. Plus chargé que les bulles ; son cadrage se règle avec /mmh fx.",
		BREW_SET         = "Derrière le tableau : %s",
		BREW_UNKNOWN     = "Style « %s » inconnu. Utilisez off, bubbles ou fx.",

		FX_CURRENT       = "Cadrage du brouet d'Ofi :",
		FX_SET           = "fx %s = %g",
		FX_UNKNOWN       = "Réglage « %s » inconnu. Tapez /mmh fx pour la liste.",
		FX_RANGE         = "fx %s attend un nombre entre %g et %g.",
		FX_RESET_HINT    = "|cffffd100/mmh fx reset|r — revenir au cadrage d'origine",
		FX_RESET_DONE    = "Cadrage réinitialisé.",

		OPT_LOCKED       = "Verrouiller la fenêtre",
		OPT_LOCKED_TT    = "Empêche de déplacer la fenêtre à la souris.",

		SLASH_HEADER     = "v%s — /mmh <option> pour basculer :",
		SLASH_TOGGLE     = "|cffffd100/mmh|r — afficher ou masquer la fenêtre",
		SLASH_CONFIG     = "|cffffd100/mmh config|r — ouvrir le panneau de configuration",
		SLASH_RESET      = "|cffffd100/mmh reset|r — remettre la fenêtre au centre de l'écran",
		SLASH_UNKNOWN    = "Option « %s » inconnue. Tapez /mmh pour la liste.",
		SLASH_ON         = "|cff20ff20activé|r",
		SLASH_OFF        = "|cffff2020désactivé|r",
		SLASH_RESET_DONE = "Position de la fenêtre réinitialisée.",

		STORED_AWAY      = "+%d rangés",
	},
}

local locale = translations[GetLocale()]
if locale then
	for key, value in pairs(locale) do
		L[key] = value
	end
end

ns.L = L
