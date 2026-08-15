local addonName, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

local WIDTH   = 420
local PAD     = 16
local ROW_W   = WIDTH - PAD * 2
local ROW_H   = 20
local COL_W   = 60
local COUNT   = #ns.ingredients

-- Centre of each ingredient column, measured from the left edge of a row. The
-- columns are pinned to the right so the offering names get whatever is left.
local COL_X = {}
for index = 1, COUNT do
	COL_X[index] = ROW_W - (COUNT - index + 1) * COL_W + COL_W / 2
end
local NAME_W = COL_X[1] - COL_W / 2 - 24

local HEADER_Y   = 36
local STORED_Y   = 52
local RULE_Y     = 64
local ROWS_TOP   = 72
local RULE2_Y    = ROWS_TOP + #ns.combinations * ROW_H + 6
local PROGRESS_Y = RULE2_Y + 10
local NEED_Y     = PROGRESS_Y + 18
local NOTE_Y     = NEED_Y + 18
local HEIGHT     = NOTE_Y + 22

local DONE_COLOR   = { 0.50, 0.50, 0.50 }
local READY_COLOR  = { 0.30, 0.95, 0.35 }
local SHORT_COLOR  = { 0.85, 0.85, 0.85 }
local MISSING_HEX  = "|cffff4040"
local STORED_HEX   = "|cff8a8a8a"

local frame, rows, headers, footer
local programmaticHide, manualOpen, suppressed = false, false, false

--------------------------------------------------------------------------------
-- Small builders
--------------------------------------------------------------------------------

local function Rule(parent, offsetY)
	local rule = parent:CreateTexture(nil, "ARTWORK")
	rule:SetColorTexture(1, 1, 1, 0.12)
	rule:SetHeight(1)
	rule:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -offsetY)
	rule:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -PAD, -offsetY)
	return rule
end

local function Label(parent, template, point, x, y, width, justify)
	local text = parent:CreateFontString(nil, "ARTWORK", template)
	text:SetPoint(point, parent, "TOPLEFT", x, -y)
	if width then
		text:SetWidth(width)
	end
	text:SetJustifyH(justify or "LEFT")
	return text
end

-- One ingredient's stock, sitting above the column of requirements that uses it.
local function CreateHeaderCell(parent, index)
	local ingredient = ns.ingredients[index]

	local cell = CreateFrame("Frame", nil, parent)
	cell:SetSize(COL_W, 30)
	cell:SetPoint("TOP", parent, "TOPLEFT", PAD + COL_X[index], -(HEADER_Y - 4))

	cell.Count = cell:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	cell.Count:SetPoint("TOP")
	cell.Count:SetWidth(COL_W)
	cell.Count:SetJustifyH("CENTER")

	cell.Stored = parent:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	cell.Stored:SetPoint("TOP", parent, "TOPLEFT", PAD + COL_X[index], -STORED_Y)
	cell.Stored:SetWidth(COL_W)
	cell.Stored:SetJustifyH("CENTER")

	cell:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetItemByID(ingredient.id)
		GameTooltip:Show()
	end)
	cell:SetScript("OnLeave", GameTooltip_Hide)

	return cell
end

local function ShowRowTooltip(self)
	local row = self.state
	if not row then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(row.displayName, 1, 1, 1)
	GameTooltip:AddLine(L.TT_REQUIRES, 0.7, 0.7, 0.7)
	for _, ingredient in ipairs(ns.ingredients) do
		local need = row.combination.counts[ingredient.id]
		if need then
			GameTooltip:AddDoubleLine(
				ns.GetItemIcon(ingredient.id) .. ns.GetItemName(ingredient.id, ingredient.name),
				need .. "x", 1, 1, 1, 1, 1, 1)
		end
	end

	if row.done then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.TT_DONE, unpack(DONE_COLOR))
	elseif row.affordable then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.TT_READY, unpack(READY_COLOR))
		if self.suggested then
			GameTooltip:AddLine(L.TT_SUGGESTED, 1, 0.82, 0, true)
		end
	else
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.TT_SHORT, 1, 0.3, 0.3)
		for _, ingredient in ipairs(ns.ingredients) do
			local short = row.missing[ingredient.id]
			if short then
				GameTooltip:AddDoubleLine(
					ns.GetItemIcon(ingredient.id) .. ns.GetItemName(ingredient.id, ingredient.name),
					short .. "x", 1, 0.3, 0.3, 1, 0.3, 0.3)
			end
		end
	end

	GameTooltip:Show()
end

local function CreateRow(parent, index)
	local row = CreateFrame("Frame", nil, parent)
	row:SetSize(ROW_W, ROW_H)
	row:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -(ROWS_TOP + (index - 1) * ROW_H))
	row:EnableMouse(true)

	row.Highlight = row:CreateTexture(nil, "BACKGROUND")
	row.Highlight:SetAllPoints()
	row.Highlight:SetColorTexture(1, 0.82, 0, 0.10)
	row.Highlight:Hide()

	row.Check = row:CreateTexture(nil, "ARTWORK")
	row.Check:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Criteria-Check")
	row.Check:SetTexCoord(0, 0.65625, 0, 1)
	row.Check:SetSize(16, 13)
	row.Check:SetPoint("LEFT", row, "LEFT", 0, 0)
	row.Check:Hide()

	row.Name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	row.Name:SetPoint("LEFT", row, "LEFT", 22, 0)
	row.Name:SetWidth(NAME_W)
	row.Name:SetJustifyH("LEFT")

	row.Counts = {}
	for column = 1, COUNT do
		local text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		text:SetPoint("CENTER", row, "LEFT", COL_X[column], 0)
		text:SetWidth(COL_W)
		text:SetJustifyH("CENTER")
		row.Counts[column] = text
	end

	row:SetScript("OnEnter", ShowRowTooltip)
	row:SetScript("OnLeave", GameTooltip_Hide)

	return row
end

--------------------------------------------------------------------------------
-- Drawing
--------------------------------------------------------------------------------

local function DrawHeader(state)
	for index, ingredient in ipairs(ns.ingredients) do
		local cell = headers[index]
		local bags = state.bags[ingredient.id]
		cell.Count:SetText(ns.GetItemIcon(ingredient.id, 18) .. bags)
		if bags == 0 then
			cell.Count:SetTextColor(1, 0.25, 0.25)
		else
			cell.Count:SetTextColor(1, 0.82, 0)
		end

		local stored = state.stored[ingredient.id]
		if ns.db.showTotals and stored > 0 then
			cell.Stored:SetText(string.format(L.STORED_AWAY, stored))
		else
			cell.Stored:SetText("")
		end
	end
end

local function DrawRow(row, state, entry)
	row.state = entry
	row.suggested = ns.db.suggest and state.suggested == entry

	row.Name:SetText(entry.displayName)

	local red, green, blue
	if entry.done then
		red, green, blue = unpack(ns.db.dimDone and DONE_COLOR or SHORT_COLOR)
		row.Check:Show()
	else
		row.Check:Hide()
		if entry.affordable then
			red, green, blue = unpack(READY_COLOR)
		else
			red, green, blue = unpack(SHORT_COLOR)
		end
	end
	row.Name:SetTextColor(red, green, blue)

	if row.suggested and not entry.done then
		row.Highlight:Show()
	else
		row.Highlight:Hide()
	end

	for column, ingredient in ipairs(ns.ingredients) do
		local need = entry.combination.counts[ingredient.id]
		local text = row.Counts[column]
		if not need then
			text:SetText("")
		elseif entry.missing[ingredient.id] then
			text:SetText(MISSING_HEX .. need .. "|r")
		else
			text:SetText(tostring(need))
			text:SetTextColor(red, green, blue)
		end
	end
end

local function DrawFooter(state)
	local total = #ns.combinations

	if not state.known then
		footer.Progress:SetText(L.CRITERIA_UNKNOWN)
		footer.Progress:SetTextColor(1, 0.5, 0.2)
	elseif state.remaining == 0 then
		footer.Progress:SetText(L.ALL_DONE)
		footer.Progress:SetTextColor(unpack(READY_COLOR))
	else
		local made = state.affordable > 0
			and string.format(L.CAN_MAKE_NOW, state.affordable)
			or L.CAN_MAKE_NONE
		footer.Progress:SetText(string.format(L.PROGRESS, state.completed, total) .. " · " .. made)
		footer.Progress:SetTextColor(1, 1, 1)
	end

	if state.remaining == 0 then
		footer.Need:SetText("")
	else
		local parts, anyShort = {}, false
		for _, ingredient in ipairs(ns.ingredients) do
			local need = state.stillNeed[ingredient.id]
			if need > 0 then
				local short = state.shortfall[ingredient.id]
				if short > 0 then
					anyShort = true
					table.insert(parts, ns.GetItemIcon(ingredient.id) .. MISSING_HEX .. need .. "|r")
				else
					table.insert(parts, ns.GetItemIcon(ingredient.id) .. need)
				end
			end
		end
		if anyShort then
			footer.Need:SetText(L.STILL_NEED .. " " .. table.concat(parts, "   "))
		else
			footer.Need:SetText(L.NOTHING_MISSING)
		end
	end

	if not state.onQuest then
		footer.Note:SetText(L.NO_QUEST)
		footer.Note:SetTextColor(1, 0.82, 0)
	else
		footer.Note:SetText(L.DAILY_NOTE)
		footer.Note:SetTextColor(0.55, 0.55, 0.55)
	end
end

function ns.Refresh()
	if not frame or not frame:IsShown() then
		return
	end

	local state = ns.BuildState()
	DrawHeader(state)
	for index, entry in ipairs(state.rows) do
		DrawRow(rows[index], state, entry)
	end
	DrawFooter(state)
end

--------------------------------------------------------------------------------
-- Visibility
--------------------------------------------------------------------------------

local function HideWindow()
	programmaticHide = true
	frame:Hide()
	programmaticHide = false
end

local function ShowWindow()
	frame:Show()
	ns.Refresh()
end

local function UpdateVisibility()
	if not frame then
		return
	end

	if not ns.ShouldAutoShow() then
		-- Conditions no longer hold, so a window the player dismissed earlier is
		-- free to come back the next time they walk up to Ofi.
		suppressed = false
		if not manualOpen and ns.db.autoHide then
			HideWindow()
		end
		return
	end

	if not suppressed then
		ShowWindow()
	end
end

function ns.ToggleWindow()
	if not frame then
		return
	end
	if frame:IsShown() then
		HideWindow()
		manualOpen = false
		suppressed = ns.ShouldAutoShow()
	else
		manualOpen = true
		suppressed = false
		ShowWindow()
	end
end

function ns.ResetWindowPosition()
	if not frame then
		return
	end
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

function ns.OnOptionChanged(key)
	if key == "locked" and frame then
		frame:SetMovable(not ns.db.locked)
	end
	ns.Refresh()
	UpdateVisibility()
end

--------------------------------------------------------------------------------
-- Construction
--------------------------------------------------------------------------------

function ns.InitWindow()
	if frame then
		return
	end

	frame = CreateFrame("Frame", "MysteriousMixHelperFrame", UIParent, "BasicFrameTemplateWithInset")
	frame:SetSize(WIDTH, HEIGHT)
	frame:SetFrameStrata("HIGH")
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetMovable(not ns.db.locked)
	frame:RegisterForDrag("LeftButton")
	frame:Hide()

	frame.TitleText:SetText(L.TITLE)

	if ns.db.point then
		frame:SetPoint(ns.db.point, UIParent, ns.db.point, ns.db.x, ns.db.y)
	else
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end

	frame:SetScript("OnDragStart", function(self)
		if not ns.db.locked then
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, _, x, y = self:GetPoint()
		ns.db.point, ns.db.x, ns.db.y = point, x, y
	end)

	-- Escape and the close button both land here. Only a dismissal the player
	-- meant should stop the window reopening while they stand at Ofi.
	frame:SetScript("OnHide", function()
		if programmaticHide then
			return
		end
		manualOpen = false
		if ns.ShouldAutoShow() then
			suppressed = true
		end
	end)
	table.insert(UISpecialFrames, "MysteriousMixHelperFrame")

	Label(frame, "GameFontNormalSmall", "TOPLEFT", PAD, HEADER_Y, nil, "LEFT"):SetText(L.IN_YOUR_BAGS)

	headers = {}
	for index = 1, COUNT do
		headers[index] = CreateHeaderCell(frame, index)
	end

	Rule(frame, RULE_Y)

	rows = {}
	for index = 1, #ns.combinations do
		rows[index] = CreateRow(frame, index)
	end

	Rule(frame, RULE2_Y)

	footer = {
		Progress = Label(frame, "GameFontNormalSmall", "TOPLEFT", PAD, PROGRESS_Y, ROW_W, "LEFT"),
		Need     = Label(frame, "GameFontHighlightSmall", "TOPLEFT", PAD, NEED_Y, ROW_W, "LEFT"),
		Note     = Label(frame, "GameFontDisableSmall", "TOPLEFT", PAD, NOTE_Y, ROW_W, "LEFT"),
	}

	-- Handles for the test harness, and convenient at a /dump prompt in game.
	ns.window, ns.rows, ns.headers, ns.footer = frame, rows, headers, footer

	local events = CreateFrame("Frame")
	for _, event in ipairs({
		"PLAYER_TARGET_CHANGED",
		"QUEST_ACCEPTED",
		"QUEST_REMOVED",
		"QUEST_TURNED_IN",
		"QUEST_LOG_UPDATE",
		"BAG_UPDATE_DELAYED",
		"CRITERIA_UPDATE",
		"ACHIEVEMENT_EARNED",
		"GET_ITEM_INFO_RECEIVED",
	}) do
		events:RegisterEvent(event)
	end
	events:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_TARGET_CHANGED" or event == "QUEST_ACCEPTED"
			or event == "QUEST_REMOVED" or event == "QUEST_TURNED_IN" then
			UpdateVisibility()
		end
		ns.Refresh()
	end)

	UpdateVisibility()
end
