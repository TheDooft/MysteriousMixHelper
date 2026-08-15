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

local function Render()
	local out = {}
	for index, row in ipairs(H.Rows()) do
		out[index] = {
			name = row.name,
			counts = { strip(row.counts[1]), strip(row.counts[2]), strip(row.counts[3]) },
			raw = { row.counts[1], row.counts[2], row.counts[3] },
			done = row.check,
			suggested = row.highlight,
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
		check("criteria id " .. combination.criteriaID .. " is unique", not ids[combination.criteriaID])
		ids[combination.criteriaID] = true
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

H.SetQuest(false)
H.SetTarget(OFI)
check("no quest, no window", not H.window:IsShown())
ns.db.requireQuest = false
H.SetTarget(nil)
H.SetTarget(OFI)
check("unless the quest is not required", H.window:IsShown())
ns.db.requireQuest = true
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

print("=== what you can afford ===")
SetBags(0, 0, 3)
rows = Render()
check("three pearls buys Choleric", not has(H.Rows()[CHOLERIC].counts[3], "|cffff4040"))
check("and nothing else", has(H.Rows()[BALANCED].counts[1], "|cffff4040"))
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

-- The client hands criteria out in its own order; the addon must key on the
-- criteria id rather than trust the index.
check("matched by id, not by position", ns.BuildState().rows[CHOLERIC].done == true)

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
	check("names the offering", has(text, "Phlegmatic Offering"))
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
