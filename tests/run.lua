-- Run from the repo root: lua tests/run.lua
local H = dofile("tests/harness.lua")
local ns = H.ns

local KNUCKLEBONE, FEATHER, PEARL = 276124, 276126, 276117
local OFI = ns.NPC_ID

-- Row indices, in the order Data.lua lists the combinations.
local CHOLERIC, VIRULENT, VOLATILE, PHLEGMATIC, ODIOUS = 1, 2, 3, 4, 5
local PESTILENT, MELANCHOLIC, FRAGILE, EERIE, BALANCED = 6, 7, 8, 9, 10

local failures = 0
local function check(label, condition)
	if condition then
		print("  ok  " .. label)
	else
		failures = failures + 1
		print("FAIL  " .. label)
	end
end

local function has(text, needle) return tostring(text):find(needle, 1, true) ~= nil end
local function strip(text) return (tostring(text):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", "")) end

local function SetBags(bone, feather, pearl)
	H.bags[KNUCKLEBONE], H.bags[FEATHER], H.bags[PEARL] = bone, feather, pearl
	H.Fire("BAG_UPDATE_DELAYED")
end

-- A cell holds either a number or a faint placeholder; only the number matters.
local function Cell(text) return (strip(text):match("%d+")) or "" end

local function Render()
	local out = {}
	for index, row in ipairs(H.Rows()) do
		out[index] = {
			name = row.name,
			counts = { Cell(row.counts[1]), Cell(row.counts[2]), Cell(row.counts[3]) },
			-- A cell the player cannot cover is coloured; a plain one is not.
			short = {
				row.counts[1]:find("|cff") ~= nil,
				row.counts[2]:find("|cff") ~= nil,
				row.counts[3]:find("|cff") ~= nil,
			},
			done = row.check,
			suggested = row.highlight,
			accent = row.accent,
			icon = row.icon,
		}
	end
	return out
end

--------------------------------------------------------------------------------

print("=== the data itself ===")
check("ten combinations", #ns.combinations == 10)

do
	-- Every multiset of three drawn from three ingredients, once each. If a row is
	-- ever mistyped this catches it before the window ever renders.
	local seen, distinct = {}, 0
	for _, combination in ipairs(ns.combinations) do
		local total, key = 0, {}
		for _, ingredient in ipairs(ns.ingredients) do
			local need = combination.counts[ingredient.id] or 0
			total = total + need
			table.insert(key, need)
		end
		check(combination.name .. " uses exactly three ingredients", total == ns.INGREDIENTS_PER_MIX)
		local signature = table.concat(key, ",")
		if not seen[signature] then
			seen[signature] = true
			distinct = distinct + 1
		end
	end
	check("no two combinations are the same mix", distinct == 10)
end

do
	local ids = {}
	for _, combination in ipairs(ns.combinations) do
		check("offering item " .. combination.itemID .. " is unique", not ids[combination.itemID])
		ids[combination.itemID] = true
	end
end

print("=== visibility ===")
check("hidden on login", not H.window:IsShown())
H.SetQuest(true)
H.SetTarget(12345)
check("some other creature does not open it", not H.window:IsShown())
H.SetTarget(OFI)
check("Ofi plus the quest opens it", H.window:IsShown())
H.SetTarget(nil)
check("losing the target closes it", not H.window:IsShown())

-- A character that has finished the chain but not picked the daily up has
-- nothing to be told, so the window stays out of the way.
H.SetQuest(false)
H.Unlock()
H.SetTarget(nil)
H.SetTarget(OFI)
check("no quest and nothing to explain, no window", not H.window:IsShown())

-- One that has not unlocked it does, which is the whole point of the chain.
H.Relock()
H.SetTarget(nil)
H.SetTarget(OFI)
check("but it opens for a character still working up to it", H.window:IsShown())

H.Unlock()
H.SetTarget(nil)
H.SetTarget(OFI)
ns.db.requireQuest = false
H.SetTarget(nil)
H.SetTarget(OFI)
check("and always, once the option is off", H.window:IsShown())
ns.db.requireQuest = true
H.Relock()
H.SetQuest(true)
H.SetTarget(nil)
H.SetTarget(OFI)

print("=== a secret target guid ===")
H.SetGUID("<SECRET>")
local ok = pcall(ns.IsTargetingOfi)
check("comparing it is never attempted", ok and ns.IsTargetingOfi() == false)
H.SetTarget(OFI)

print("=== the requirement grid ===")
SetBags(3, 3, 3)
local rows = Render()
check("Choleric is three pearls", rows[CHOLERIC].counts[1] == "" and rows[CHOLERIC].counts[2] == "" and rows[CHOLERIC].counts[3] == "3")
check("Balanced is one of each", table.concat(rows[BALANCED].counts, "/") == "1/1/1")
check("Eerie is two bones and a feather", table.concat(rows[EERIE].counts, "/") == "2/1/")
check("Melancholic is three bones", table.concat(rows[MELANCHOLIC].counts, "/") == "3//")

print("=== offering icons ===")
check("each row wears its own offering's icon",
	rows[CHOLERIC].icon == 100000 + ns.combinations[CHOLERIC].itemID
		and rows[BALANCED].icon == 100000 + ns.combinations[BALANCED].itemID)
do
	local distinct = {}
	for _, row in ipairs(rows) do distinct[row.icon] = true end
	local count = 0
	for _ in pairs(distinct) do count = count + 1 end
	check("ten different icons", count == 10)
end

print("=== what you can afford ===")
SetBags(0, 0, 3)
rows = Render()
check("three pearls buys Choleric", not rows[CHOLERIC].short[3])
check("and nothing else", rows[BALANCED].short[1])
check("an affordable row is flagged", rows[CHOLERIC].accent)
check("an unaffordable one is not", not rows[BALANCED].accent)
local state = ns.BuildState()
check("one affordable", state.affordable == 1)
check("Volatile is short a bone", state.rows[VOLATILE].missing[KNUCKLEBONE] == 1)
check("Phlegmatic is short three feathers", state.rows[PHLEGMATIC].missing[FEATHER] == 3)

print("=== a bank is not a bag ===")
-- Only what you carry can be handed over, so stored stock must not make a mix
-- look available.
H.stored[FEATHER] = 20
state = ns.BuildState()
check("stored feathers are reported apart", state.stored[FEATHER] == 20)
check("but do not unlock Phlegmatic", state.rows[PHLEGMATIC].affordable == false)
check("and do count against the long-run shortfall", state.shortfall[FEATHER] == 0)
H.stored[FEATHER] = 0

print("=== the total still to gather ===")
SetBags(0, 0, 0)
state = ns.BuildState()
check("ten of each, all ten mixes outstanding",
	state.stillNeed[KNUCKLEBONE] == 10 and state.stillNeed[FEATHER] == 10 and state.stillNeed[PEARL] == 10)
check("all ten short", state.shortfall[PEARL] == 10)
check("footer names the shortfall", has(H.footer.Need:GetText(), ns.L.STILL_NEED))

print("=== achievement criteria ===")
H.SetCriteria({ "Choleric Offering", "Balanced Offering" })
H.Fire("CRITERIA_UPDATE")
rows = Render()
check("Choleric ticked", rows[CHOLERIC].done)
check("Balanced ticked", rows[BALANCED].done)
check("Eerie not ticked", not rows[EERIE].done)
state = ns.BuildState()
check("two collected", state.completed == 2)
check("eight left", state.remaining == 8)
check("progress line counts them", has(H.footer.Progress:GetText(), "2 of 10"))
-- Ten pearls across all ten mixes, less the three Choleric and one Balanced took.
check("the eight left want 6 pearls", state.stillNeed[PEARL] == 6)

-- The client hands criteria out in its own order, and the number that identifies
-- one is the offering item it asks you to loot, not the criterion's own id. Both
-- are wrong in the harness on purpose, so this only passes on the asset.
check("matched by asset, not by position", ns.BuildState().rows[CHOLERIC].done == true)

print("=== telling the three row states apart ===")
-- With nothing in the bags, every unfinished row is "cannot afford". If that
-- treatment sits too close to the collected one the whole list reads as one
-- grey block, which is exactly what the first pass got wrong.
SetBags(0, 0, 0)
do
	local drawn = H.Rows()
	local done, todo = drawn[CHOLERIC], drawn[EERIE]
	check("the collected row is ticked", done.check and not todo.check)
	check("and washed", done.wash and not todo.wash)
	check("and carries an edge bar", done.accent and not todo.accent)
	check("and its icon is greyed", done.dimmed and not todo.dimmed)

	local distance = math.abs(done.color[1] - todo.color[1])
		+ math.abs(done.color[2] - todo.color[2])
		+ math.abs(done.color[3] - todo.color[3])
	check("and the two text colours are far apart, not " .. string.format("%.2f", distance),
		distance > 0.6)
end

print("=== the shopping list carries tooltips ===")
do
	local chips = H.footer.Chips
	check("one chip per ingredient still wanted", chips[1]:IsShown() and chips[3]:IsShown())

	for index = 1, #ns.ingredients do
		-- A chip with no width would stack on its neighbours at the same spot.
		check("chip " .. index .. " is wider than its icon", chips[index]:GetWidth() > 14)
	end

	local chip = chips[2]
	chip:GetScript("OnEnter")(chip)
	local text = strip(table.concat(H.tooltip.lines, "\n"))
	check("names the ingredient item", has(text, "item:" .. ns.ingredients[2].id))
	check("reports what is in your bags", has(text, ns.L.TT_IN_BAGS))
	check("and how much the remaining mixes want", has(text, ns.L.TT_NEEDED))
	check("and the shortfall", has(text, ns.L.TT_SHORT_BY))
end

print("=== unlocking the daily on a fresh character ===")
H.Relock()
H.Fire("QUEST_LOG_UPDATE")
do
	local unlock = ns.BuildState().unlock
	check("nothing done yet", unlock.completed == 0 and not unlock.ready)
	check("the first step is the one named", unlock.nextIndex == 1)
	check("the bottom line names it",
		has(H.footer.Note:GetText(), unlock.nextStep.title))
	check("and says which step it is", has(H.footer.Note:GetText(), "1"))
	check("the line becomes hoverable", H.footer.NoteHit:IsShown())

	local hit = H.footer.NoteHit
	hit:GetScript("OnEnter")(hit)
	local text = strip(table.concat(H.tooltip.lines, "\n"))
	check("the tooltip lays out the whole route", has(text, ns.L.UNLOCK_TITLE))
	for _, step in ipairs(ns.unlockChain) do
		check("listing " .. step.name, has(text, step.name))
	end
	check("with what to do next", has(text, ns.L.UNLOCK_ISLE))
	check("and warns the campaign is per character", has(text, ns.L.UNLOCK_CAVEAT))
	check("uncached quest titles are asked for",
		H.questsRequested[ns.unlockChain[1].questID] == true)
end

print("=== part-way through the chain ===")
H.questDone[ns.unlockChain[1].questID] = true
H.Fire("QUEST_LOG_UPDATE")
do
	local unlock = ns.BuildState().unlock
	check("one down", unlock.completed == 1 and not unlock.ready)
	check("now pointing at step 2", unlock.nextIndex == 2)
	check("the bottom line moved on",
		has(H.footer.Note:GetText(), ns.unlockChain[2].name))

	-- The client's own title wins over the enUS one shipped in Data.lua.
	H.questTitles[ns.unlockChain[2].questID] = "Ingrédients ésotériques"
	H.Fire("QUEST_LOG_UPDATE")
	check("a cached title is used", has(H.footer.Note:GetText(), "Ingrédients ésotériques"))
	H.questTitles[ns.unlockChain[2].questID] = nil
end

print("=== chain done, daily not in the log ===")
H.Unlock()
H.SetQuest(false)
H.Fire("QUEST_LOG_UPDATE")
do
	check("no more unlock line", ns.BuildState().unlock.ready)
	check("it asks you to pick the quest up", has(H.footer.Note:GetText(), ns.L.NO_QUEST))
	check("and stops being hoverable", not H.footer.NoteHit:IsShown())

	H.questDone[ns.QUEST_ID] = true
	H.Fire("QUEST_LOG_UPDATE")
	check("today's mix already spent is said so", has(H.footer.Note:GetText(), ns.L.DAILY_DONE))
	H.questDone[ns.QUEST_ID] = nil

	-- The confusing one: this character never mixed, but the warband did.
	H.questDoneAccount[ns.QUEST_ID] = true
	H.Fire("QUEST_LOG_UPDATE")
	check("another character having mixed is called out",
		has(H.footer.Note:GetText(), ns.L.DAILY_DONE_ALT))
	H.questDoneAccount[ns.QUEST_ID] = nil
end

H.SetQuest(true)
H.Fire("QUEST_LOG_UPDATE")
check("back to the daily note when on the quest", has(H.footer.Note:GetText(), ns.L.DAILY_NOTE))

print("=== the simmering cauldron ===")
do
	check("there are bubbles", #ns.bubbles == ns.BUBBLE_COUNT and ns.BUBBLE_COUNT > 0)
	-- Getting this pairing wrong has cost two rounds: an arc texture drew
	-- crescents, and a mask over a colour fill drew squares. It has to be a
	-- real texture file with the mask set first.
	do
		local texture = ns.bubbles[1].textures[1]
		check("each is a real texture file, not a colour fill",
			type(texture:GetTexture()) == "string")
		check("rounded off by a mask", texture.mask ~= nil)
		check("with the mask set first", texture.maskedBeforeTexture == true)
		check("and blended additively", texture.blend == "ADD")
	end

	-- A single masked disc is flat. The glow comes from concentric discs summing
	-- additively, so the layers have to shrink inwards and no one of them may
	-- carry the whole opacity.
	do
		local bubble = ns.bubbles[1]
		check("a bubble is several layers", #bubble.textures == #ns.BUBBLE_LAYERS
			and #ns.BUBBLE_LAYERS > 1)

		local shrinking, total = true, 0
		for index, layer in ipairs(ns.BUBBLE_LAYERS) do
			if index > 1 and layer[1] >= ns.BUBBLE_LAYERS[index - 1][1] then
				shrinking = false
			end
			total = total + layer[2]
		end
		check("each layer is smaller than the last", shrinking)
		check("the outermost spans the full size", ns.BUBBLE_LAYERS[1][1] == 1)
		check("and together they reach full opacity, not more",
			math.abs(total - 1) < 0.02)
	end
	check("they are scattered on the first fill, not all at the bottom",
		ns.bubbles[1].y ~= ns.bubbles[2].y or ns.bubbles[2].y ~= ns.bubbles[3].y)

	local before = ns.bubbles[1].y
	H.Tick(0.05)
	check("a tick moves them up", ns.bubbles[1].y > before)

	-- Run long enough that every bubble must have topped out and come back.
	H.Tick(0.05, 600)
	local lowest, highest, faded = math.huge, -math.huge, true
	for _, bubble in ipairs(ns.bubbles) do
		lowest = math.min(lowest, bubble.y)
		highest = math.max(highest, bubble.y)
		for _, texture in ipairs(bubble.textures) do
			if texture:GetAlpha() > ns.BUBBLE_ALPHA[2] then faded = false end
		end
	end
	check("none has escaped the bottom", lowest >= 0)
	check("none has climbed past the top", highest < ns.BUBBLE_TRAVEL)
	check("and none is ever more than faint", faded)

	-- Checked once the animation has actually assigned alphas: no single disc
	-- may carry the bubble, or the glow collapses back to a flat sticker.
	do
		local bubble = ns.bubbles[1]
		local strongest = 0
		for _, texture in ipairs(bubble.textures) do
			strongest = math.max(strongest, texture:GetAlpha())
		end
		check("no single layer carries the whole bubble", strongest < bubble.peak)
	end

	-- Position is set through the widget, which the harness does not model, so
	-- the sway is checked on the state the maths actually runs on.
	local swayed = false
	for _, bubble in ipairs(ns.bubbles) do
		if bubble.sway > 0 and bubble.phase > 0 then swayed = true end
	end
	check("they sway as they rise", swayed)

	-- A large disc at full strength reads as a blob, so opacity has to come off
	-- with size. Compared at the extremes, where the rule has to hold whatever
	-- the random draw was.
	do
		local smallest, largest
		for _, bubble in ipairs(ns.bubbles) do
			if not smallest or bubble.size < smallest.size then smallest = bubble end
			if not largest or bubble.size > largest.size then largest = bubble end
		end
		local ceiling = function(size)
			local grown = (size - ns.BUBBLE_SIZE[1]) / (ns.BUBBLE_SIZE[2] - ns.BUBBLE_SIZE[1])
			return ns.BUBBLE_ALPHA[2] * (1 - ns.BUBBLE_SIZE_FADE * grown)
		end
		check("a big bubble is capped below a small one's ceiling",
			largest.size == smallest.size or ceiling(largest.size) < ceiling(smallest.size))
		check("and stays under its own cap", largest.peak <= ceiling(largest.size) + 1e-9)
	end

	SlashCmdList.MYSTERIOUSMIXHELPER("bubbles")
	local hidden = true
	for _, bubble in ipairs(ns.bubbles) do
		for _, texture in ipairs(bubble.textures) do
			if texture:IsShown() then hidden = false end
		end
	end
	check("the option puts them out", hidden)
	local still = ns.bubbles[1].y
	H.Tick(0.05, 10)
	check("and stops the animation", ns.bubbles[1].y == still)
	SlashCmdList.MYSTERIOUSMIXHELPER("bubbles")
	check("and lights them again", ns.bubbles[1].textures[1]:IsShown())

	-- 1.6 briefly made this a three-way choice. A saved setting from that build
	-- has to survive the way back.
	ns.db.brew, ns.db.fx = "off", { alpha = 1 }
	ns.db.bubbles = nil
	H.Fire("ADDON_LOADED", "MysteriousMixHelper")
	check("an old brew setting is carried over", ns.db.bubbles == false)
	check("and the effect's settings dropped", ns.db.brew == nil and ns.db.fx == nil)
	ns.db.bubbles = true
	ns.OnOptionChanged("bubbles")
end

print("=== credits ===")
do
	local badge = ns.window.Badge
	badge:GetScript("OnEnter")(badge)
	local text = strip(table.concat(H.tooltip.lines, "\n"))
	check("the cauldron thanks Lazey", has(text, "Lazey"))
	check("and points at where the table came from", has(text, "Wowhead"))
	check("and carries the version", has(text, ns.version))
end

-- The column headers use the same tooltip, so the two never disagree.
do
	local cell = ns.headers[1]
	cell:GetScript("OnEnter")(cell)
	check("the column header agrees",
		has(strip(table.concat(H.tooltip.lines, "\n")), ns.L.TT_NEEDED))
end

SetBags(0, 0, 3)

print("=== when the criteria carry no asset ===")
H.SetCriteria({ "Choleric Offering" }, { noAsset = true })
H.Fire("CRITERIA_UPDATE")
state = ns.BuildState()
check("it falls back to the criteria text", state.known == true and state.rows[CHOLERIC].done == true)
H.SetCriteria({ "Choleric Offering", "Balanced Offering" })
H.Fire("CRITERIA_UPDATE")

print("=== the criteria text supplies the localised name ===")
do
	-- The criteria string is the offering's name in the player's own language, so
	-- the window shows that rather than the enUS name shipped in Data.lua.
	H.SetCriteria({})
	H.Fire("CRITERIA_UPDATE")
	check("row uses the client's own criteria text", Render()[CHOLERIC].name == "Choleric Offering")

	H.ClearCriteria()
	H.Fire("CRITERIA_UPDATE")
	check("and the enUS name only when there is none", Render()[CHOLERIC].name == "Choleric Offering")
end

print("=== no criteria data at all ===")
H.ClearCriteria()
H.Fire("CRITERIA_UPDATE")
state = ns.BuildState()
check("progress reported as unknown", state.known == false)
check("the window says so instead of guessing", has(H.footer.Progress:GetText(), ns.L.CRITERIA_UNKNOWN))
H.SetCriteria({})
H.Fire("CRITERIA_UPDATE")

print("=== all ten collected ===")
do
	local every = {}
	for _, combination in ipairs(ns.combinations) do table.insert(every, combination.name) end
	H.SetCriteria(every)
	H.Fire("CRITERIA_UPDATE")
	state = ns.BuildState()
	check("nothing remaining", state.remaining == 0)
	check("footer congratulates", has(H.footer.Progress:GetText(), ns.L.ALL_DONE))
	check("no shopping list left", H.footer.Need:GetText() == "")
	H.SetCriteria({})
	H.Fire("CRITERIA_UPDATE")
end

print("=== the suggestion ===")
SetBags(3, 3, 3)
state = ns.BuildState()
check("everything is affordable", state.affordable == 10)
check("it picks the mix that spares the others", state.suggested == state.rows[BALANCED])
check("the row is highlighted", Render()[BALANCED].suggested)

SetBags(0, 0, 3)
state = ns.BuildState()
check("with one option it picks that one", state.suggested == state.rows[CHOLERIC])

SetBags(0, 0, 0)
state = ns.BuildState()
check("nothing affordable, nothing suggested", state.suggested == nil)

ns.db.suggest = false
check("and none at all when the option is off", ns.BuildState().suggested == nil)
ns.db.suggest = true

print("=== dismissing the window ===")
SetBags(3, 3, 3)
H.SetTarget(OFI)
check("open at Ofi", H.window:IsShown())
H.window:Hide()                      -- as the close button or Escape would
check("closed", not H.window:IsShown())
H.Fire("BAG_UPDATE_DELAYED")
check("it stays closed while you are still stood there", not H.window:IsShown())
H.SetTarget(nil)
H.SetTarget(OFI)
check("but comes back next time you target him", H.window:IsShown())

print("=== keeping it open away from Ofi ===")
H.SetTarget(nil)
check("closed again", not H.window:IsShown())
SlashCmdList.MYSTERIOUSMIXHELPER("")
check("/mmh opens it anywhere", H.window:IsShown())
H.SetTarget(12345)
check("targeting something else leaves it alone", H.window:IsShown())
SlashCmdList.MYSTERIOUSMIXHELPER("")
check("/mmh closes it again", not H.window:IsShown())

print("=== row tooltip ===")
H.SetQuest(true)
H.SetTarget(OFI)
SetBags(0, 0, 3)
do
	local row = H.Rows()[PHLEGMATIC].frame
	row:GetScript("OnEnter")(row)
	local text = strip(table.concat(H.tooltip.lines, "\n"))
	-- The offering's own item tooltip leads, so the name, quality and flavour
	-- text come from the game rather than being reprinted here.
	check("leads with the offering item", has(text, "item:" .. ns.combinations[PHLEGMATIC].itemID))
	check("lists the requirement", has(text, "Serpent's Feather | 3x"))
	check("says what is missing", has(text, ns.L.TT_SHORT))

	row = H.Rows()[CHOLERIC].frame
	row:GetScript("OnEnter")(row)
	check("an affordable one says so", has(strip(table.concat(H.tooltip.lines, "\n")), ns.L.TT_READY))
end

print("=== item names ===")
H.names[PEARL] = "Perle de sang voilée"
H.Fire("GET_ITEM_INFO_RECEIVED")
do
	local row = H.Rows()[CHOLERIC].frame
	row:GetScript("OnEnter")(row)
	check("a cached name is used", has(strip(table.concat(H.tooltip.lines, "\n")), "Perle de sang voilée"))

	row = H.Rows()[MELANCHOLIC].frame
	row:GetScript("OnEnter")(row)
	check("an uncached one falls back to enUS", has(strip(table.concat(H.tooltip.lines, "\n")), "Ancient Knucklebone"))
	check("and is asked for", H.requested[KNUCKLEBONE] == true)
end

print("=== slash command ===")
SlashCmdList.MYSTERIOUSMIXHELPER("dimdone")
check("toggles case-insensitively", ns.db.dimDone == false)
SlashCmdList.MYSTERIOUSMIXHELPER("dimDone")
check("toggles back", ns.db.dimDone == true)
SlashCmdList.MYSTERIOUSMIXHELPER("nope")
check("reports an unknown option", has(H.chat[#H.chat], "nope"))
SlashCmdList.MYSTERIOUSMIXHELPER("help")
check("lists every option", #H.chat > #ns.optionOrder)
SlashCmdList.MYSTERIOUSMIXHELPER("reset")
check("reset clears the saved position", ns.db.point == nil and has(H.chat[#H.chat], ns.L.SLASH_RESET_DONE))

print("=== version ===")
-- Guards against the TOC losing its literal version and falling back to "?",
-- which is what stops the in-game addon list from showing one.
check("the TOC carries a literal semver, read back as " .. tostring(ns.version),
	type(ns.version) == "string" and ns.version:match("^%d+%.%d+%.%d+$") ~= nil)

print("")
if failures > 0 then
	print(failures .. " check(s) FAILED")
	os.exit(1)
end
print("all checks passed")
