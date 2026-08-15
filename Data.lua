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

-- All three ingredients come out of the same container, found as treasure around
-- The Coiled Isle. One bag can hold more than one kind, so there is no such
-- thing as "the place knucklebones come from" — `chance` is how often a bag
-- holds at least one of that ingredient, per Wowhead's loot sample.
--
-- (A widely-repeated tip has each ingredient near a different sort of mob. The
-- loot data does not support it: one bag, three ingredients.)
ns.CONTAINER_ID   = 278084
ns.CONTAINER_NAME = "Handful of Esoteric Ingredients"

-- Display order of the three ingredient columns. `name` is the enUS name, used
-- only until the client has the item cached and can hand back a localised one.
ns.ingredients = {
	{ id = KNUCKLEBONE, name = "Ancient Knucklebone", chance = 85 },
	{ id = FEATHER,     name = "Serpent's Feather",   chance = 74 },
	{ id = PEARL,       name = "Clouded Blood-Pearl", chance = 84 },
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

ns.INGREDIENTS_PER_MIX = 3
