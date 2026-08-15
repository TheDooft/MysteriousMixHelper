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

	-- Where ingredients come from
	TT_WHERE         = "Where to find it",
	-- %s is the container's item name
	TT_FROM          = "Opens out of %s, found as treasure around The Coiled Isle.",
	-- %d is the share of containers holding at least one
	TT_FROM_CHANCE   = "About %d%% of them hold at least one.",
	TT_TRADABLE      = "Tradable, so the auction house is an option too.",

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
	OPT_REQUIRE_QUEST = "Only with the quest in your log",
	OPT_REQUIRE_QUEST_TT = "Open only when Mixing Mysteries is actually in your quest log. Turn this off to see the list whenever you target Ofi.",
	OPT_HIDE_DONE    = "Dim collected offerings",
	OPT_HIDE_DONE_TT = "Grey out the combinations you have already turned in.",
	OPT_SUGGEST      = "Mark a suggested mix",
	OPT_SUGGEST_TT   = "Point out which of the mixes you can afford leaves you best placed for the ones you still need.",
	OPT_SHOW_TOTALS  = "Count bank and warband bank",
	OPT_SHOW_TOTALS_TT = "Also show what you have stored away. Only what is in your bags can actually be handed to Ofi, so stored items are shown separately.",
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

		TT_WHERE         = "Où en trouver",
		TT_FROM          = "S'ouvre depuis %s, un trésor à ramasser sur l'Île Lovée.",
		TT_FROM_CHANCE   = "Environ %d%% d'entre eux en contiennent au moins un.",
		TT_TRADABLE      = "Échangeable : l'hôtel des ventes est une option.",

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
		OPT_REQUIRE_QUEST = "Seulement avec la quête dans le journal",
		OPT_REQUIRE_QUEST_TT = "N'ouvre que si « Mélanges mystérieux » est réellement dans votre journal. Désactivez pour voir la liste dès que vous ciblez Ofi.",
		OPT_HIDE_DONE    = "Griser les offrandes obtenues",
		OPT_HIDE_DONE_TT = "Estompe les combinaisons que vous avez déjà rendues.",
		OPT_SUGGEST      = "Signaler un mélange conseillé",
		OPT_SUGGEST_TT   = "Indique lequel des mélanges à votre portée vous laisse le mieux placé pour ceux qu'il vous reste.",
		OPT_SHOW_TOTALS  = "Compter banque et banque de bataillon",
		OPT_SHOW_TOTALS_TT = "Affiche aussi ce que vous avez rangé. Seul le contenu des sacs peut être donné à Ofi, le reste est donc indiqué à part.",
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
