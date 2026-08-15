local addonName, ns = ...
local L = ns.L

local defaults = {
	autoShow     = true,
	autoHide     = true,
	requireQuest = true,
	dimDone      = true,
	suggest      = true,
	showTotals   = true,
	locked       = false,
	-- Window placement, filled in when the player drags it.
	point        = nil,
	x            = 0,
	y            = 0,
}

-- Order used by both the options panel and the slash command listing.
local optionOrder = {
	"autoShow", "autoHide", "requireQuest", "dimDone", "suggest", "showTotals", "locked",
}

local optionLabels = {
	autoShow     = { L.OPT_AUTO_SHOW,     L.OPT_AUTO_SHOW_TT },
	autoHide     = { L.OPT_AUTO_HIDE,     L.OPT_AUTO_HIDE_TT },
	requireQuest = { L.OPT_REQUIRE_QUEST, L.OPT_REQUIRE_QUEST_TT },
	dimDone      = { L.OPT_HIDE_DONE,     L.OPT_HIDE_DONE_TT },
	suggest      = { L.OPT_SUGGEST,       L.OPT_SUGGEST_TT },
	showTotals   = { L.OPT_SHOW_TOTALS,   L.OPT_SHOW_TOTALS_TT },
	locked       = { L.OPT_LOCKED,        L.OPT_LOCKED_TT },
}

ns.optionOrder = optionOrder
ns.optionLabels = optionLabels

local db
local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "?"
ns.version = version

--------------------------------------------------------------------------------
-- Item helpers
--------------------------------------------------------------------------------

-- The client only knows an item's localised name once it has been cached. Ask
-- for it, and fall back to the enUS name in Data.lua until it arrives.
function ns.GetItemName(itemID, fallback)
	local name = C_Item.GetItemNameByID(itemID)
	if name then
		return name
	end
	C_Item.RequestLoadItemDataByID(itemID)
	return fallback or tostring(itemID)
end

-- The item's icon as a file id, asking the client for it when it has none yet.
-- Several places in the window are icon and nothing else, so it is worth the
-- request rather than waiting for something else to happen to want the item.
function ns.GetItemIconFile(itemID)
	local icon = C_Item.GetItemIconByID(itemID)
	if not icon then
		C_Item.RequestLoadItemDataByID(itemID)
		return nil
	end
	return icon
end

-- The same icon as a texture escape, for use inside a line of text.
function ns.GetItemIcon(itemID, size)
	local icon = ns.GetItemIconFile(itemID)
	if not icon then
		return ""
	end
	return string.format("|T%d:%d:%d:0:0|t ", icon, size or 14, size or 14)
end

--------------------------------------------------------------------------------
-- What the game currently says
--------------------------------------------------------------------------------

-- Only what is in your bags can be handed to Ofi, so that is the number the
-- window judges a combination against. What sits in a bank is reported apart.
local function BagCount(itemID)
	return C_Item.GetItemCount(itemID) or 0
end

-- Bags, bank, reagent bank and warband bank together.
local function StoredCount(itemID)
	return C_Item.GetItemCount(itemID, true, false, true, true) or 0
end

-- Achievement progress keyed by offering item id:
-- { completed = bool, name = <localised> }.
--
-- The criteria text is the offering's own name in the player's language, so it
-- doubles as the translation the addon would otherwise have to ship.
--
-- Each criterion is "loot this offering", so the number it carries as its asset
-- is the offering's item id — the one Data.lua lists. That is the match that
-- should work, and it holds in every locale. Criteria ids and then the enUS
-- criteria text are tried after it, so a reworked achievement degrades to
-- something partly useful instead of reporting all ten as unfinished. When no
-- strategy accounts for all ten the result is nil, and the window says so
-- rather than guessing.
function ns.GetCriteriaState()
	local total = GetAchievementNumCriteria(ns.ACHIEVEMENT_ID)
	if not total or total == 0 then
		return nil
	end

	local byAsset, byCriteria, byName = {}, {}, {}
	for index = 1, total do
		local criteriaString, _, completed, _, _, _, _, assetID, _, criteriaID =
			GetAchievementCriteriaInfo(ns.ACHIEVEMENT_ID, index)
		local entry = { completed = completed and true or false, name = criteriaString }
		if assetID and assetID ~= 0 then
			byAsset[assetID] = entry
		end
		if criteriaID then
			byCriteria[criteriaID] = entry
		end
		if criteriaString then
			byName[criteriaString] = entry
		end
	end

	for _, lookup in ipairs({ byAsset, byCriteria, byName }) do
		local state, complete = {}, true
		for _, combination in ipairs(ns.combinations) do
			-- Only one of these keys can hit: the first two tables are numeric,
			-- the last one is keyed by text.
			local entry = lookup[combination.itemID] or lookup[combination.name]
			if not entry then
				complete = false
				break
			end
			state[combination.itemID] = entry
		end
		if complete then
			return state
		end
	end

	return nil
end

-- The npc id behind a unit, or nil for anything that is not a creature. Unit
-- guids come back secret in identity-restricted content, and a secret value
-- cannot even be compared, so that has to be the very first test.
function ns.GetUnitNpcID(unit)
	local guid = UnitGUID(unit)
	if not guid or issecretvalue(guid) then
		return nil
	end
	local unitType, _, _, _, _, npcID = strsplit("-", guid)
	if unitType ~= "Creature" and unitType ~= "Vehicle" then
		return nil
	end
	return tonumber(npcID)
end

function ns.IsTargetingOfi()
	return ns.GetUnitNpcID("target") == ns.NPC_ID
end

function ns.HasQuest()
	return C_QuestLog.IsOnQuest(ns.QUEST_ID) and true or false
end

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

-- Of the mixes you can afford, which one leaves you best placed for the rest?
--
-- Score a candidate by how many of the other unfinished combinations you could
-- still afford after paying for it. Ties go to the mix that leaves the largest
-- smallest-stack behind, which keeps a single scarce ingredient from being
-- drained. Only a heuristic — you can always buy more — so the window labels it
-- a suggestion rather than an instruction.
local function Suggest(state)
	local best, bestScore, bestFloor

	for _, row in ipairs(state.rows) do
		if not row.done and row.affordable then
			local left = {}
			for _, ingredient in ipairs(ns.ingredients) do
				left[ingredient.id] = state.bags[ingredient.id] - (row.combination.counts[ingredient.id] or 0)
			end

			local score, floor = 0, math.huge
			for _, other in ipairs(state.rows) do
				if other ~= row and not other.done then
					local affordable = true
					for _, ingredient in ipairs(ns.ingredients) do
						if (other.combination.counts[ingredient.id] or 0) > left[ingredient.id] then
							affordable = false
							break
						end
					end
					if affordable then
						score = score + 1
					end
				end
			end
			for _, ingredient in ipairs(ns.ingredients) do
				floor = math.min(floor, left[ingredient.id])
			end

			if not best or score > bestScore or (score == bestScore and floor > bestFloor) then
				best, bestScore, bestFloor = row, score, floor
			end
		end
	end

	return best
end

-- Everything the window draws, in one plain table. Kept free of any frame work
-- so it can be exercised without the game running.
function ns.BuildState()
	local criteria = ns.GetCriteriaState()

	local state = {
		bags        = {},
		stored      = {},   -- ingredient id -> amount outside your bags
		rows        = {},
		completed   = 0,
		remaining   = 0,
		affordable  = 0,
		stillNeed   = {},   -- ingredient id -> amount the unfinished mixes want
		shortfall   = {},   -- ingredient id -> how much of that you do not have
		known       = criteria ~= nil,
		onQuest     = ns.HasQuest(),
	}

	for _, ingredient in ipairs(ns.ingredients) do
		local bags = BagCount(ingredient.id)
		state.bags[ingredient.id] = bags
		state.stored[ingredient.id] = math.max(0, StoredCount(ingredient.id) - bags)
		state.stillNeed[ingredient.id] = 0
	end

	for index, combination in ipairs(ns.combinations) do
		local entry = criteria and criteria[combination.itemID]
		local row = {
			index       = index,
			combination = combination,
			-- The criteria text is already localised; the enUS name only stands in
			-- while the achievement data is unavailable.
			displayName = entry and entry.name or combination.name,
			done        = entry and entry.completed or false,
			affordable  = true,
			missing     = {},
		}

		for _, ingredient in ipairs(ns.ingredients) do
			local need = combination.counts[ingredient.id] or 0
			local short = need - state.bags[ingredient.id]
			if short > 0 then
				row.affordable = false
				row.missing[ingredient.id] = short
			end
		end

		if row.done then
			state.completed = state.completed + 1
		else
			state.remaining = state.remaining + 1
			if row.affordable then
				state.affordable = state.affordable + 1
			end
			for _, ingredient in ipairs(ns.ingredients) do
				state.stillNeed[ingredient.id] = state.stillNeed[ingredient.id]
					+ (combination.counts[ingredient.id] or 0)
			end
		end

		state.rows[index] = row
	end

	for _, ingredient in ipairs(ns.ingredients) do
		local have = state.bags[ingredient.id] + state.stored[ingredient.id]
		state.shortfall[ingredient.id] = math.max(0, state.stillNeed[ingredient.id] - have)
	end

	if db and db.suggest then
		state.suggested = Suggest(state)
	end

	return state
end

-- Should the window be open on its own account right now?
function ns.ShouldAutoShow()
	if not db.autoShow then
		return false
	end
	if db.requireQuest and not ns.HasQuest() then
		return false
	end
	return ns.IsTargetingOfi()
end

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

local settingsCategory

local function RegisterSettings()
	if settingsCategory or not Settings then
		return
	end

	local category = Settings.RegisterVerticalLayoutCategory(L.TITLE)
	settingsCategory = category

	for _, key in ipairs(optionOrder) do
		local setting = Settings.RegisterProxySetting(
			category,
			addonName .. "_" .. key,
			Settings.VarType.Boolean,
			optionLabels[key][1],
			defaults[key],
			function() return db[key] end,
			function(value)
				db[key] = value
				if ns.OnOptionChanged then
					ns.OnOptionChanged(key)
				end
			end
		)
		Settings.CreateCheckbox(category, setting, optionLabels[key][2])
	end

	Settings.RegisterAddOnCategory(category)
end

--------------------------------------------------------------------------------
-- Slash command
--------------------------------------------------------------------------------

local function Print(message)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99" .. L.TITLE .. "|r: " .. message)
end
ns.Print = Print

local function PrintOptions()
	Print(string.format(L.SLASH_HEADER, version))
	DEFAULT_CHAT_FRAME:AddMessage("  " .. L.SLASH_TOGGLE)
	for _, key in ipairs(optionOrder) do
		DEFAULT_CHAT_FRAME:AddMessage(string.format(
			"  |cffffd100/mmh %s|r — %s (%s)",
			key, optionLabels[key][1], db[key] and L.SLASH_ON or L.SLASH_OFF
		))
	end
	DEFAULT_CHAT_FRAME:AddMessage("  " .. L.SLASH_CONFIG)
	DEFAULT_CHAT_FRAME:AddMessage("  " .. L.SLASH_RESET)
end

SLASH_MYSTERIOUSMIXHELPER1 = "/mmh"
SLASH_MYSTERIOUSMIXHELPER2 = "/mixhelper"
SlashCmdList.MYSTERIOUSMIXHELPER = function(input)
	local argument = string.lower(string.match(input or "", "^%s*(%S*)") or "")

	if argument == "" then
		if ns.ToggleWindow then
			ns.ToggleWindow()
		end
	elseif argument == "help" or argument == "options" then
		PrintOptions()
	elseif argument == "config" then
		if settingsCategory then
			Settings.OpenToCategory(settingsCategory:GetID())
		end
	elseif argument == "reset" then
		db.point, db.x, db.y = nil, 0, 0
		if ns.ResetWindowPosition then
			ns.ResetWindowPosition()
		end
		Print(L.SLASH_RESET_DONE)
	else
		-- Option keys are camelCase but the argument was lowered, so match case-insensitively.
		for _, key in ipairs(optionOrder) do
			if string.lower(key) == argument then
				db[key] = not db[key]
				Print(optionLabels[key][1] .. ": " .. (db[key] and L.SLASH_ON or L.SLASH_OFF))
				if ns.OnOptionChanged then
					ns.OnOptionChanged(key)
				end
				return
			end
		end
		Print(string.format(L.SLASH_UNKNOWN, argument))
	end
end

--------------------------------------------------------------------------------
-- Loading
--------------------------------------------------------------------------------

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" and ... == addonName then
		MysteriousMixHelperDB = MysteriousMixHelperDB or {}
		db = MysteriousMixHelperDB
		for key, value in pairs(defaults) do
			if db[key] == nil then
				db[key] = value
			end
		end
		ns.db = db
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		RegisterSettings()
		if ns.InitWindow then
			ns.InitWindow()
		end
		self:UnregisterEvent("PLAYER_LOGIN")
	end
end)
