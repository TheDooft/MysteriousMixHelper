-- Stubs the slice of the WoW API that Mysterious Mix Helper touches, loads the
-- addon, and hands back the handles a test needs to drive it. Run from the repo
-- root:
--
--   lua tests/run.lua
--
-- The window is built out of frames rather than tooltip lines, so the widget
-- mocks below record what was set on them; a test reads the rendered row text
-- back out of `H.Rows()`.

local ADDON_DIR = os.getenv("MMH_ADDON_DIR") or "./"

local bags = {}      -- itemID -> amount in bags
local stored = {}    -- itemID -> amount in banks, on top of bags
local names = {}     -- itemID -> localised name; absent means "not cached yet"
local requested = {}
local chat = {}

local criteria = {}  -- list of { asset = itemID, id = criteriaID, name, completed }
local questLog = {}  -- questID -> true
local targetGUID = nil

_G.GetLocale = function() return "enUS" end
_G.issecretvalue = function(value) return value == "<SECRET>" end

-- The client has both of these as globals; standalone Lua 5.4 has neither.
_G.unpack = table.unpack

_G.strsplit = function(separator, text)
	local parts, start = {}, 1
	text = tostring(text)
	while true do
		local position = text:find(separator, start, true)
		if not position then
			table.insert(parts, text:sub(start))
			break
		end
		table.insert(parts, text:sub(start, position - 1))
		start = position + 1
	end
	return table.unpack(parts)
end

_G.C_Item = {
	GetItemNameByID = function(id) return names[id] end,
	RequestLoadItemDataByID = function(id) requested[id] = true end,
	GetItemIconByID = function(id) return 100000 + id end,
	-- GetItemCount(itemInfo, includeBank, includeUses, includeReagentBank, includeAccountBank)
	GetItemCount = function(id, includeBank)
		return (bags[id] or 0) + (includeBank and (stored[id] or 0) or 0)
	end,
}

local questDone = {}        -- questID -> completed by this character
local questDoneAccount = {} -- questID -> completed by someone in the warband
local questTitles = {}      -- questID -> localised title; absent means uncached
local questsRequested = {}

_G.C_QuestLog = {
	IsOnQuest = function(questID) return questLog[questID] == true end,
	IsQuestFlaggedCompleted = function(questID) return questDone[questID] == true end,
	IsQuestFlaggedCompletedOnAccount = function(questID)
		return questDone[questID] == true or questDoneAccount[questID] == true
	end,
	GetTitleForQuestID = function(questID) return questTitles[questID] end,
	RequestLoadQuestByID = function(questID) questsRequested[questID] = true end,
}

_G.UnitGUID = function(unit) return unit == "target" and targetGUID or nil end

_G.GetAchievementNumCriteria = function() return #criteria end
_G.GetAchievementCriteriaInfo = function(_, index)
	local entry = criteria[index]
	if not entry then return nil end
	-- criteriaString, criteriaType, completed, quantity, reqQuantity, charName,
	-- flags, assetID, quantityString, criteriaID
	return entry.name, 0, entry.completed, 0, 1, nil, 0, entry.asset, nil, entry.id
end

-- Read the real TOC, so a test can catch the version going missing from it.
local tocVersion
do
	local toc = io.open(ADDON_DIR .. "MysteriousMixHelper.toc", "r")
	if toc then
		tocVersion = toc:read("a"):match("##%s*Version:%s*([^\r\n]+)")
		toc:close()
	end
end

_G.C_AddOns = {
	GetAddOnMetadata = function(_, field) return field == "Version" and tocVersion or nil end,
}

_G.DEFAULT_CHAT_FRAME = { AddMessage = function(_, message) table.insert(chat, message) end }
_G.SlashCmdList = {}
_G.Settings = nil -- exercises the guard in RegisterSettings
_G.UISpecialFrames = {}

--------------------------------------------------------------------------------
-- Widget mocks
--------------------------------------------------------------------------------

local function Region()
	local region = { shown = true, r = 1, g = 1, b = 1 }
	function region:SetPoint() end
	function region:ClearAllPoints() end
	function region:SetAllPoints() end
	function region:SetSize() end
	function region:SetWidth() end
	function region:SetHeight() end
	function region:SetJustifyH() end
	function region:SetShown(value) self.shown = value and true or false end
	-- Enough of a measurement for the footer's chip layout to be exercised.
	function region:GetStringWidth() return #(self.text or "") * 6 end
	function region:SetTexture(value) self.texture = value end
	function region:GetTexture() return self.texture end
	function region:SetTexCoord() end
	function region:SetColorTexture() end
	function region:SetDesaturated(value) self.desaturated = value and true or false end
	function region:SetBlendMode(mode) self.blend = mode end
	function region:SetMask(path) self.mask = path end
	function region:SetVertexColor() end
	function region:SetAlpha(value) self.alpha = value end
	function region:GetAlpha() return self.alpha or 1 end
	function region:SetText(text) self.text = tostring(text or "") end
	function region:GetText() return self.text or "" end
	function region:SetTextColor(r, g, b) self.r, self.g, self.b = r, g, b end
	function region:Show() self.shown = true end
	function region:Hide() self.shown = false end
	function region:IsShown() return self.shown end
	return region
end

local frames = {}

_G.CreateFrame = function(_, name, _, template)
	local frame = { scripts = {}, events = {}, shown = false, children = {} }

	function frame:SetPoint() end
	function frame:ClearAllPoints() end
	function frame:SetAllPoints() end
	function frame:GetPoint() return "CENTER", nil, "CENTER", 0, 0 end
	function frame:SetSize(width) self.width = width end
	function frame:SetWidth(width) self.width = width end
	function frame:GetWidth() return self.width or 0 end
	function frame:SetHeight() end
	function frame:SetShown(value) if value then self:Show() else self:Hide() end end
	function frame:SetFrameStrata() end
	function frame:SetClampedToScreen() end
	function frame:EnableMouse() end
	function frame:SetMovable(value) self.movable = value end
	function frame:RegisterForDrag() end
	function frame:StartMoving() end
	function frame:StopMovingOrSizing() end
	function frame:Show()
		self.shown = true
		if self.scripts.OnShow then self.scripts.OnShow(self) end
	end
	function frame:Hide()
		local wasShown = self.shown
		self.shown = false
		if wasShown and self.scripts.OnHide then self.scripts.OnHide(self) end
	end
	function frame:IsShown() return self.shown end
	function frame:SetScript(script, fn) self.scripts[script] = fn end
	function frame:GetScript(script) return self.scripts[script] end
	function frame:RegisterEvent(event) self.events[event] = true end
	function frame:UnregisterEvent(event) self.events[event] = nil end
	function frame:CreateTexture() return Region() end
	function frame:CreateFontString() return Region() end
	function frame:GetFrameLevel() return self.level or 1 end
	function frame:SetFrameLevel(value) self.level = value end

	if template and template:find("BasicFrameTemplate", 1, true) then
		frame.TitleText = Region()
		frame.CloseButton = { SetScript = function() end }
	end

	if name then _G[name] = frame end
	table.insert(frames, frame)
	return frame
end

_G.UIParent = CreateFrame("Frame")

-- Records what a row tooltip was told to draw, colour codes and all.
local tooltip = { lines = {} }
function tooltip:SetOwner() self.lines = {} end
function tooltip:AddLine(text) table.insert(self.lines, tostring(text)) end
function tooltip:AddDoubleLine(left, right)
	table.insert(self.lines, tostring(left) .. " | " .. tostring(right))
end
function tooltip:SetItemByID(id) table.insert(self.lines, "item:" .. tostring(id)) end
function tooltip:Show() end
function tooltip:Hide() end
_G.GameTooltip = tooltip
_G.GameTooltip_Hide = function() end

--------------------------------------------------------------------------------
-- Load
--------------------------------------------------------------------------------

local ns = {}
for _, file in ipairs({ "Locales.lua", "Data.lua", "Core.lua", "UI.lua" }) do
	assert(loadfile(ADDON_DIR .. file))("MysteriousMixHelper", ns)
end

-- Replay the load sequence the client would drive.
local function Fire(event, ...)
	for _, frame in ipairs(frames) do
		if frame.scripts.OnEvent and (frame.events[event] or event == "ADDON_LOADED") then
			frame.scripts.OnEvent(frame, event, ...)
		end
	end
end

Fire("ADDON_LOADED", "MysteriousMixHelper")
Fire("PLAYER_LOGIN")

local window = _G.MysteriousMixHelperFrame

local function SetTarget(npcID)
	targetGUID = npcID and ("Creature-0-1234-2512-5678-" .. npcID .. "-000012AB") or nil
	Fire("PLAYER_TARGET_CHANGED")
end

-- Criteria in the order the client hands them out, which is not the addon's.
--
-- The asset is the offering's item id and the criteria id is something else
-- entirely, exactly as the real achievement is built. `options.noAsset` drops
-- the asset so the fallback path gets exercised too.
local function SetCriteria(completedNames, options)
	options = options or {}
	local done = {}
	for _, name in ipairs(completedNames or {}) do done[name] = true end
	criteria = {}
	for index = #ns.combinations, 1, -1 do
		local combination = ns.combinations[index]
		table.insert(criteria, {
			asset = not options.noAsset and combination.itemID or 0,
			id = 900000 + index,
			name = combination.name,
			completed = done[combination.name] == true,
		})
	end
end

local function ClearCriteria() criteria = {} end

-- The visible text of each row, in display order.
local function Rows()
	local out = {}
	for index, row in ipairs(ns.rows) do
		local counts = {}
		for column = 1, #ns.ingredients do
			counts[column] = row.Counts[column]:GetText()
		end
		out[index] = {
			name = row.Name:GetText(),
			counts = counts,
			check = row.Check:IsShown(),
			highlight = row.Highlight:IsShown(),
			accent = row.Accent:IsShown(),
			wash = row.Wash:IsShown(),
			icon = row.Icon:GetTexture(),
			dimmed = row.Icon.desaturated == true,
			color = { row.Name.r, row.Name.g, row.Name.b },
			frame = row,
		}
	end
	return out
end

SetCriteria({})

return {
	ns = ns,
	window = window,
	Fire = Fire,
	Rows = Rows,
	SetTarget = SetTarget,
	SetCriteria = SetCriteria,
	ClearCriteria = ClearCriteria,
	SetQuest = function(has) questLog[ns.QUEST_ID] = has or nil end,
	questDone = questDone,
	questDoneAccount = questDoneAccount,
	questTitles = questTitles,
	questsRequested = questsRequested,
	-- Walk the whole unlock chain, as a character who has done the campaign.
	Unlock = function()
		for _, step in ipairs(ns.unlockChain) do questDone[step.questID] = true end
	end,
	Relock = function()
		for _, step in ipairs(ns.unlockChain) do questDone[step.questID] = nil end
	end,
	-- Drive the window's OnUpdate, which is what animates the cauldron.
	Tick = function(seconds, steps)
		local handler = window.scripts.OnUpdate
		if not handler then return end
		for _ = 1, steps or 1 do
			handler(window, seconds)
		end
	end,
	SetGUID = function(guid) targetGUID = guid end,
	bags = bags,
	stored = stored,
	names = names,
	requested = requested,
	chat = chat,
	tooltip = tooltip,
	footer = ns.footer,
}
