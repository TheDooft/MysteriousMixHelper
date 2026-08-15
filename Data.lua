local _, ns = ...

-- Everything the addon knows about the Mixing Mysteries daily.
--
-- Ofi the Sly takes three ingredients, one dialogue choice at a time, drawn from
-- three kinds. That is ten distinct multisets, and each one yields a different
-- Mysterious Offering. Collecting all ten earns Mysterious Mix Master.
--
-- Sources:
--   quest       https://www.wowhead.com/quest=97016/mixing-mysteries
--   npc         https://www.wowhead.com/npc=254599/ofi-the-sly
--   achievement https://www.wowhead.com/achievement=63432/mysterious-mix-master
--   the mapping from combination to offering is Lazey's comment on the
--   achievement page (#comments:id=6389799), cross-checked against the criteria
--   ids in Wowhead's achievement data.

ns.QUEST_ID       = 97016   -- Mixing Mysteries, a daily
ns.NPC_ID         = 254599  -- Ofi the Sly, Tokka's Landing, The Coiled Isle
ns.ACHIEVEMENT_ID = 63432   -- Mysterious Mix Master

local KNUCKLEBONE = 276124
local FEATHER     = 276126
local PEARL       = 276117

-- Display order of the three ingredient columns. `name` is the enUS name, used
-- only until the client has the item cached and can hand back a localised one.
ns.ingredients = {
	{ id = KNUCKLEBONE, name = "Ancient Knucklebone" },
	{ id = FEATHER,     name = "Serpent's Feather" },
	{ id = PEARL,       name = "Clouded Blood-Pearl" },
}

-- What a character has to have done before Ofi will offer the daily, in order.
-- `name` is the enUS title, shown only until the client can supply a localised
-- one through C_QuestLog.GetTitleForQuestID.
--
-- Campaign progress is per character, which is the whole reason this is worth
-- tracking: the isle itself is a warband unlock, so an alt can stand in front
-- of Ofi with no way to see what it is still missing.
--
-- Wowhead does not publish a prerequisite link for the daily, so this chain is
-- read off the quests themselves: 92924 is what carries you to Tokka's Landing,
-- and 97026 is the item-started quest that hands you in to Ofi. If a step turns
-- out to be wrong the window simply names one quest too many, which is why the
-- wording says "step N of M" rather than claiming these are the only gates.
ns.unlockChain = {
	{ questID = 92924, name = "What Lies Beyond the Fog", hint = "UNLOCK_ISLE" },
	{ questID = 97026, name = "Esoteric Ingredients",     hint = "UNLOCK_ESOTERIC" },
}

-- The ten combinations, in the order Lazey's comment lists them, so the window
-- reads the same way as the guide most players will have come from.
--
-- `itemID` is the offering item the mix produces. Each achievement criterion is
-- "loot this item", so the item id is what the criterion carries as its asset —
-- which is how Core.lua ties a row to the player's progress, and where the row
-- icon comes from. Stable across locales, unlike the criteria text.
ns.combinations = {
	{ itemID = 277946, name = "Choleric Offering",    counts = { [PEARL] = 3 } },
	{ itemID = 277938, name = "Virulent Offering",    counts = { [FEATHER] = 1, [PEARL] = 2 } },
	{ itemID = 277939, name = "Volatile Offering",    counts = { [KNUCKLEBONE] = 1, [PEARL] = 2 } },
	{ itemID = 277944, name = "Phlegmatic Offering",  counts = { [FEATHER] = 3 } },
	{ itemID = 277942, name = "Odious Offering",      counts = { [FEATHER] = 2, [PEARL] = 1 } },
	{ itemID = 277943, name = "Pestilent Offering",   counts = { [KNUCKLEBONE] = 1, [FEATHER] = 2 } },
	{ itemID = 277945, name = "Melancholic Offering", counts = { [KNUCKLEBONE] = 3 } },
	{ itemID = 277940, name = "Fragile Offering",     counts = { [KNUCKLEBONE] = 2, [PEARL] = 1 } },
	{ itemID = 277941, name = "Eerie Offering",       counts = { [KNUCKLEBONE] = 2, [FEATHER] = 1 } },
	{ itemID = 277937, name = "Balanced Offering",    counts = { [KNUCKLEBONE] = 1, [FEATHER] = 1, [PEARL] = 1 } },
}

ns.ACHIEVEMENT_ICON = "Interface\\Icons\\inv_misc_cauldron_arcane"

-- An in-game effect model, offered as an alternative to the drawn bubbles for
-- what simmers behind the table. A looping venom cast: green, roiling, and
-- already the right sort of thing for Ofi's cauldron.
ns.FX_MODEL = 5749206
ns.FX_NAME  = "11fx_arakaracityofechoes_kikataltheharvester_venomvolley_precast"

ns.INGREDIENTS_PER_MIX = 3
