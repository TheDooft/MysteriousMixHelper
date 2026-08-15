local addonName, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Look
--------------------------------------------------------------------------------

-- A flat dark panel drawn out of plain colour textures rather than one of the
-- carved Blizzard frame templates: nothing to tile or scale wrong, and it sits
-- better next to the current UI.
local PANEL_BG    = { 0.043, 0.047, 0.059, 0.95 }
local PANEL_EDGE  = { 1, 1, 1, 0.10 }
local TITLE_BG    = { 0.078, 0.086, 0.106, 1 }
local ACCENT      = { 1.00, 0.72, 0.20 }
local ZEBRA       = { 1, 1, 1, 0.022 }
local HOVER       = { 1, 1, 1, 0.055 }
local SUGGEST_BG  = { 1.00, 0.72, 0.20, 0.09 }

local TEXT_BRIGHT = { 0.96, 0.96, 0.97 }
local TEXT_DIM    = { 0.44, 0.45, 0.50 }
local TEXT_LABEL  = { 0.55, 0.57, 0.64 }
local SHORT       = { 0.93, 0.34, 0.34 }

-- The three row states have to be told apart at a glance, so each gets its own
-- text colour, its own edge bar and — for collected — a wash and a tick. Keep
-- these far apart: an earlier pass had "collected" and "cannot afford" a couple
-- of hundredths from each other and the whole list read as one grey block.
local READY       = { 0.42, 0.90, 0.48 }  -- not collected, and you can make it
local TODO        = { 0.84, 0.85, 0.88 }  -- not collected, ingredients missing
local DONE        = { 0.36, 0.47, 0.39 }  -- collected: dim, and green about it
local DONE_WASH   = { 0.28, 0.85, 0.42, 0.055 }
local DONE_BAR    = { 0.30, 0.78, 0.42, 0.55 }

local MISSING_HEX = "|cffee5555"

-- Icons carry a baked-in border; trimming the outer few percent leaves a clean
-- square that suits a flat panel.
local ICON_TRIM = { 0.07, 0.93, 0.07, 0.93 }

-- Ofi's cauldron, simmering behind the table: soft discs of light rising and
-- swaying, tinted green and blended additively. Faint on purpose — this sits
-- under ten rows of text it must never compete with.
--
-- A bubble is a plain white texture tinted green and rounded off by the mask
-- Blizzard uses on portraits.
--
-- Both halves matter, and getting either wrong has already cost a round:
--   * The loading spinner's StreamCircle is an *arc*, not a circle. Invisible
--     at 13px, but every bubble read as a crescent once they reached 38px.
--   * SetMask does not apply to a SetColorTexture fill — that combination is
--     not one the game ships anywhere, and it drew squares.
-- So this follows the pairing Blizzard actually uses to round an arbitrary
-- icon (Blizzard_ArtifactPerks, Blizzard_EncounterJournal): set the mask, then
-- set a real texture file under it. ChatFrameBackground is that file — flat
-- white, so a vertex colour is the only tint in play.
local BUBBLE_MASK    = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local BUBBLE_TEXTURE = "Interface\\ChatFrame\\ChatFrameBackground"
local BUBBLE_COLOR   = { 0.46, 1.00, 0.62 }
local BUBBLE_COUNT   = 16
local BUBBLE_ALPHA   = { 0.12, 0.30 }
local BUBBLE_SIZE    = { 10, 34 }
local BUBBLE_SPEED   = { 10, 34 }   -- pixels a second
local BUBBLE_SWAY    = { 3, 11 }    -- pixels either side of the rise
local BUBBLE_INSET   = 4            -- above the bottom edge

-- How much of its opacity the largest bubble gives up. A big disc at full
-- strength is a blob; thinning it with size keeps the large ones reading as
-- haze and lets the small ones stay crisp.
local BUBBLE_SIZE_FADE = 0.55

-- A masked texture gives a flat disc with one hard edge, which reads as a
-- sticker rather than something glowing in a liquid. There is no radial
-- gradient to be had from a texture and a mask, so each bubble is instead
-- built from several concentric discs; blended additively they sum to a bright
-- core falling away to nothing. Each entry is {share of the full size, share
-- of the bubble's opacity}, largest first.
local BUBBLE_LAYERS = {
	{ 1.00, 0.24 },
	{ 0.76, 0.24 },
	{ 0.52, 0.26 },
	{ 0.28, 0.26 },
}

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

local WIDTH    = 460
local PAD      = 14
local ROW_W    = WIDTH - PAD * 2
local ROW_H    = 24
local COL_W    = 62
local ICON     = 18
local TICK_W   = 18
local COUNT    = #ns.ingredients

-- Centre of each ingredient column, measured from the left edge of a row. The
-- columns are pinned right so the offering names get whatever is left.
local COL_X = {}
for index = 1, COUNT do
	COL_X[index] = ROW_W - (COUNT - index + 1) * COL_W + COL_W / 2
end
local ICON_X = TICK_W
local NAME_X = ICON_X + ICON + 8
local NAME_W = COL_X[1] - COL_W / 2 - NAME_X - 8

local TITLE_H  = 32
local LABEL_Y  = TITLE_H + 12
local CHIP_Y   = LABEL_Y + 16
local STORED_Y = CHIP_Y + 26
local RULE_Y   = STORED_Y + 16
local ROWS_TOP = RULE_Y + 6
local RULE2_Y  = ROWS_TOP + #ns.combinations * ROW_H + 6
local PROG_Y   = RULE2_Y + 10
local NEED_Y   = PROG_Y + 20
local NOTE_Y   = NEED_Y + 20
local HEIGHT   = NOTE_Y + 22

local frame, rows, headers, footer, bubbles
local programmaticHide, manualOpen, suppressed = false, false, false

-- How far a bubble climbs. Stops short of the title bar by its own largest
-- size, so one can never poke out over the header.
local BUBBLE_TRAVEL = HEIGHT - TITLE_H - BUBBLE_SIZE[2] - BUBBLE_INSET * 2
ns.BUBBLE_TRAVEL = BUBBLE_TRAVEL
ns.BUBBLE_COUNT, ns.BUBBLE_ALPHA = BUBBLE_COUNT, BUBBLE_ALPHA
ns.BUBBLE_SIZE, ns.BUBBLE_SIZE_FADE = BUBBLE_SIZE, BUBBLE_SIZE_FADE
ns.BUBBLE_LAYERS = BUBBLE_LAYERS

-- The last state drawn, so a tooltip opening later can quote the same numbers
-- the window is showing rather than recomputing them.
local shown

--------------------------------------------------------------------------------
-- Small builders
--------------------------------------------------------------------------------

local function Fill(parent, layer, color)
	local texture = parent:CreateTexture(nil, layer or "BACKGROUND")
	texture:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
	return texture
end

local function Rule(parent, offsetY, color)
	local rule = Fill(parent, "ARTWORK", color or PANEL_EDGE)
	rule:SetHeight(1)
	rule:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -offsetY)
	rule:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -PAD, -offsetY)
	return rule
end

local function Text(parent, template, x, y, width, justify, color)
	local text = parent:CreateFontString(nil, "OVERLAY", template)
	text:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
	if width then
		text:SetWidth(width)
	end
	text:SetJustifyH(justify or "LEFT")
	if color then
		text:SetTextColor(color[1], color[2], color[3])
	end
	return text
end

local function ItemIcon(parent, size, layer)
	local icon = parent:CreateTexture(nil, layer or "ARTWORK")
	icon:SetSize(size, size)
	icon:SetTexCoord(unpack(ICON_TRIM))
	return icon
end

-- A 1px outline, drawn as four thin strips so it stays crisp at any UI scale.
-- `spread` is how far outside the anchor the strips sit: 1 hugs an icon from the
-- outside, 0 keeps them flush, which is what the panel edge wants so the border
-- does not hang off the frame.
local function Outline(parent, anchor, color, layer, spread)
	spread = spread or 1
	local strips = {}
	for index, edge in ipairs({
		{ "TOPLEFT", "TOPRIGHT", 0, 1, true },
		{ "BOTTOMLEFT", "BOTTOMRIGHT", 0, -1, true },
		{ "TOPLEFT", "BOTTOMLEFT", -1, 0, false },
		{ "TOPRIGHT", "BOTTOMRIGHT", 1, 0, false },
	}) do
		local strip = Fill(parent, layer or "BORDER", color)
		strip:SetPoint(edge[1], anchor, edge[1], edge[3] * spread, edge[4] * spread)
		strip:SetPoint(edge[2], anchor, edge[2], edge[3] * spread, edge[4] * spread)
		if edge[5] then strip:SetHeight(1) else strip:SetWidth(1) end
		strips[index] = strip
	end
	return strips
end

--------------------------------------------------------------------------------
-- The cauldron
--------------------------------------------------------------------------------

local function Between(range)
	return range[1] + math.random() * (range[2] - range[1])
end

-- Send a bubble back to the bottom with a fresh set of numbers, so the pattern
-- never settles into a loop the eye can pick out.
local function ResetBubble(bubble, atBottom)
	bubble.size  = Between(BUBBLE_SIZE)
	bubble.x     = math.random() * (WIDTH - BUBBLE_SWAY[2] * 2 - bubble.size) + BUBBLE_SWAY[2]
	bubble.speed = Between(BUBBLE_SPEED)
	bubble.sway  = Between(BUBBLE_SWAY)
	bubble.rate  = 0.5 + math.random() * 1.8
	bubble.phase = math.random() * math.pi * 2

	local grown = (bubble.size - BUBBLE_SIZE[1]) / (BUBBLE_SIZE[2] - BUBBLE_SIZE[1])
	bubble.peak = Between(BUBBLE_ALPHA) * (1 - BUBBLE_SIZE_FADE * grown)
	-- On the first fill they are scattered up the window, so it is already
	-- simmering when it opens rather than starting empty.
	bubble.y     = atBottom and 0 or math.random() * BUBBLE_TRAVEL

	for index, layer in ipairs(BUBBLE_LAYERS) do
		local size = bubble.size * layer[1]
		bubble.textures[index]:SetSize(size, size)
	end
end

local function StepBubbles(elapsed)
	for _, bubble in ipairs(bubbles) do
		bubble.y = bubble.y + bubble.speed * elapsed
		bubble.phase = bubble.phase + bubble.rate * elapsed
		if bubble.y >= BUBBLE_TRAVEL then
			ResetBubble(bubble, true)
		end

		local progress = bubble.y / BUBBLE_TRAVEL
		-- Swell in off the bottom, thin out before the top: no bubble should
		-- ever appear or vanish mid-window.
		local fade = math.min(1, progress * 8) * math.min(1, (1 - progress) * 5)
		local centreX = bubble.x + math.sin(bubble.phase) * bubble.sway + bubble.size / 2
		local centreY = BUBBLE_INSET + bubble.y + bubble.size / 2

		-- Every layer shares one centre, so the discs stay concentric whatever
		-- their sizes.
		for index, layer in ipairs(BUBBLE_LAYERS) do
			local texture = bubble.textures[index]
			texture:SetAlpha(bubble.peak * layer[2] * fade)
			texture:ClearAllPoints()
			texture:SetPoint("CENTER", frame, "BOTTOMLEFT", centreX, centreY)
		end
	end
end

local function CreateBubbles(parent)
	local list = {}
	for index = 1, BUBBLE_COUNT do
		local bubble = { textures = {} }
		for layer = 1, #BUBBLE_LAYERS do
			-- Sub-level 2 puts them over the panel background; the rows are
			-- child frames, so text and icons stay in front without any
			-- further ordering.
			local texture = parent:CreateTexture(nil, "BACKGROUND", nil, 2)
			-- Mask before texture: a mask rewrites the texture coordinates, so
			-- Blizzard's own code always sets it first.
			texture:SetMask(BUBBLE_MASK)
			texture:SetTexture(BUBBLE_TEXTURE)
			texture:SetVertexColor(unpack(BUBBLE_COLOR))
			texture:SetBlendMode("ADD")
			bubble.textures[layer] = texture
		end
		list[index] = bubble
	end
	return list
end

-- Called when the option is toggled and when the window opens.
local function ApplyBubbles()
	if not bubbles then
		return
	end
	for _, bubble in ipairs(bubbles) do
		if ns.db.bubbles then
			ResetBubble(bubble, false)
		end
		for _, texture in ipairs(bubble.textures) do
			texture:SetShown(ns.db.bubbles)
		end
	end
end

--------------------------------------------------------------------------------
-- Ingredients
--------------------------------------------------------------------------------

-- The item's own tooltip, then the four numbers that matter for this addon.
-- Used by both the column headers and the shopping list in the footer, so the
-- two never drift apart.
local function ShowIngredientTooltip(owner, ingredient)
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
	GameTooltip:SetItemByID(ingredient.id)

	if not shown then
		GameTooltip:Show()
		return
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L.TT_IN_BAGS, shown.bags[ingredient.id],
		unpack(TEXT_LABEL, 1, 3))
	if shown.stored[ingredient.id] > 0 then
		GameTooltip:AddDoubleLine(L.TT_STORED, shown.stored[ingredient.id],
			unpack(TEXT_LABEL, 1, 3))
	end

	local needed = shown.stillNeed[ingredient.id]
	if needed > 0 then
		GameTooltip:AddDoubleLine(L.TT_NEEDED, needed, unpack(TEXT_LABEL, 1, 3))
		local short = shown.shortfall[ingredient.id]
		if short > 0 then
			GameTooltip:AddDoubleLine(L.TT_SHORT_BY, short,
				SHORT[1], SHORT[2], SHORT[3], SHORT[1], SHORT[2], SHORT[3])
		end
	end

	GameTooltip:Show()
end

-- One cell per ingredient, sitting above the column that spends it.
local function CreateHeaderCell(parent, index)
	local ingredient = ns.ingredients[index]

	local cell = CreateFrame("Frame", nil, parent)
	cell:SetSize(COL_W, 24)
	cell:SetPoint("TOP", parent, "TOPLEFT", PAD + COL_X[index], -CHIP_Y)

	-- Icon and count side by side, centred together in the column.
	cell.Icon = ItemIcon(cell, 20)
	cell.Icon:SetPoint("LEFT", cell, "CENTER", -22, 0)
	Outline(cell, cell.Icon, { 1, 1, 1, 0.14 })

	cell.Count = cell:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	cell.Count:SetPoint("LEFT", cell.Icon, "RIGHT", 6, 0)

	cell.Stored = Text(parent, "GameFontDisableSmall",
		PAD + COL_X[index] - COL_W / 2, STORED_Y, COL_W, "CENTER", TEXT_DIM)

	cell:SetScript("OnEnter", function(self) ShowIngredientTooltip(self, ingredient) end)
	cell:SetScript("OnLeave", GameTooltip_Hide)

	return cell
end

-- An icon and an amount, side by side, in the footer's shopping list. A frame
-- rather than a texture escape inside the label, so it can carry a tooltip.
local function CreateNeedChip(parent, index)
	local ingredient = ns.ingredients[index]

	local chip = CreateFrame("Frame", nil, parent)
	chip:SetHeight(16)
	chip:EnableMouse(true)

	chip.Icon = ItemIcon(chip, 14, "OVERLAY")
	chip.Icon:SetPoint("LEFT")

	chip.Count = chip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	chip.Count:SetPoint("LEFT", chip.Icon, "RIGHT", 4, 0)

	chip:SetScript("OnEnter", function(self) ShowIngredientTooltip(self, ingredient) end)
	chip:SetScript("OnLeave", GameTooltip_Hide)
	chip:Hide()

	return chip
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

local function ShowRowTooltip(self)
	local row = self.state
	if not row then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetItemByID(row.combination.itemID)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L.TT_REQUIRES, unpack(TEXT_LABEL))
	for _, ingredient in ipairs(ns.ingredients) do
		local need = row.combination.counts[ingredient.id]
		if need then
			GameTooltip:AddDoubleLine(
				ns.GetItemIcon(ingredient.id) .. ns.GetItemName(ingredient.id, ingredient.name),
				need .. "x", 1, 1, 1, 1, 1, 1)
		end
	end

	GameTooltip:AddLine(" ")
	if row.done then
		GameTooltip:AddLine(L.TT_DONE, unpack(DONE))
	elseif row.affordable then
		GameTooltip:AddLine(L.TT_READY, unpack(READY))
		if self.suggested then
			GameTooltip:AddLine(L.TT_SUGGESTED, ACCENT[1], ACCENT[2], ACCENT[3], true)
		end
	else
		GameTooltip:AddLine(L.TT_SHORT, unpack(SHORT))
		for _, ingredient in ipairs(ns.ingredients) do
			local short = row.missing[ingredient.id]
			if short then
				GameTooltip:AddDoubleLine(
					ns.GetItemIcon(ingredient.id) .. ns.GetItemName(ingredient.id, ingredient.name),
					short .. "x", SHORT[1], SHORT[2], SHORT[3], SHORT[1], SHORT[2], SHORT[3])
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

	-- Every other row gets a whisper of light, so the eye can track across to
	-- the number columns without a heavy grid.
	if index % 2 == 0 then
		local zebra = Fill(row, "BACKGROUND", ZEBRA)
		zebra:SetAllPoints()
	end

	-- A wash across collected rows: the loudest of the three cues that say so.
	row.Wash = Fill(row, "BACKGROUND", DONE_WASH)
	row.Wash:SetAllPoints()
	row.Wash:Hide()

	row.Highlight = Fill(row, "BACKGROUND", SUGGEST_BG)
	row.Highlight:SetAllPoints()
	row.Highlight:Hide()

	row.Hover = Fill(row, "BACKGROUND", HOVER)
	row.Hover:SetAllPoints()
	row.Hover:Hide()

	-- A short bar at the left edge, the row's status at a glance.
	row.Accent = Fill(row, "ARTWORK", ACCENT)
	row.Accent:SetPoint("TOPLEFT", row, "TOPLEFT", -PAD + 4, -3)
	row.Accent:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", -PAD + 4, 3)
	row.Accent:SetWidth(2)
	row.Accent:Hide()

	-- The tick gets a slot of its own rather than riding on the icon's corner,
	-- where it was too small to carry the meaning on its own.
	row.Check = row:CreateTexture(nil, "OVERLAY")
	row.Check:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Criteria-Check")
	row.Check:SetTexCoord(0, 0.65625, 0, 1)
	row.Check:SetSize(16, 13)
	row.Check:SetPoint("LEFT", row, "LEFT", 0, 0)
	row.Check:Hide()

	row.Icon = ItemIcon(row, ICON)
	row.Icon:SetPoint("LEFT", row, "LEFT", ICON_X, 0)
	row.IconEdge = Outline(row, row.Icon, { 1, 1, 1, 0.12 })

	row.Name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.Name:SetPoint("LEFT", row, "LEFT", NAME_X, 0)
	row.Name:SetWidth(NAME_W)
	row.Name:SetJustifyH("LEFT")

	row.Counts = {}
	for column = 1, COUNT do
		local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetPoint("CENTER", row, "LEFT", COL_X[column], 0)
		text:SetWidth(COL_W)
		text:SetJustifyH("CENTER")
		row.Counts[column] = text
	end

	row:SetScript("OnEnter", function(self)
		self.Hover:Show()
		ShowRowTooltip(self)
	end)
	row:SetScript("OnLeave", function(self)
		self.Hover:Hide()
		GameTooltip_Hide()
	end)

	return row
end

--------------------------------------------------------------------------------
-- Drawing
--------------------------------------------------------------------------------

local function DrawHeader(state)
	for index, ingredient in ipairs(ns.ingredients) do
		local cell = headers[index]
		cell.Icon:SetTexture(ns.GetItemIconFile(ingredient.id))

		local bags = state.bags[ingredient.id]
		cell.Count:SetText(bags)
		if bags == 0 then
			cell.Count:SetTextColor(unpack(SHORT))
			cell.Icon:SetDesaturated(true)
			cell.Icon:SetAlpha(0.45)
		else
			cell.Count:SetTextColor(unpack(TEXT_BRIGHT))
			cell.Icon:SetDesaturated(false)
			cell.Icon:SetAlpha(1)
		end

		local stored = state.stored[ingredient.id]
		cell.Stored:SetText(ns.db.showTotals and stored > 0
			and string.format(L.STORED_AWAY, stored) or "")
	end
end

local function DrawRow(row, state, entry)
	row.state = entry
	row.suggested = ns.db.suggest and state.suggested == entry

	row.Icon:SetTexture(ns.GetItemIconFile(entry.combination.itemID))
	row.Name:SetText(entry.displayName)

	-- Three states, three treatments. Collected wins over everything: it never
	-- competes with the suggestion, because there is nothing left to suggest.
	local color
	if entry.done then
		color = ns.db.dimDone and DONE or TEXT_BRIGHT
		row.Check:Show()
		row.Wash:SetShown(ns.db.dimDone)
		row.Highlight:Hide()
		row.Accent:SetColorTexture(unpack(DONE_BAR))
		row.Accent:Show()
		row.Icon:SetDesaturated(ns.db.dimDone)
		row.Icon:SetAlpha(ns.db.dimDone and 0.45 or 1)
	else
		color = entry.affordable and READY or TODO
		row.Check:Hide()
		row.Wash:Hide()
		row.Icon:SetDesaturated(false)
		row.Icon:SetAlpha(entry.affordable and 1 or 0.8)

		if row.suggested then
			row.Highlight:Show()
			row.Accent:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
			row.Accent:Show()
		else
			row.Highlight:Hide()
			if entry.affordable then
				row.Accent:SetColorTexture(READY[1], READY[2], READY[3], 0.75)
				row.Accent:Show()
			else
				row.Accent:Hide()
			end
		end
	end
	row.Name:SetTextColor(color[1], color[2], color[3])

	for column, ingredient in ipairs(ns.ingredients) do
		local need = entry.combination.counts[ingredient.id]
		local text = row.Counts[column]
		if not need then
			-- A faint placeholder keeps the columns legible without the noise a
			-- zero would add.
			text:SetText("·")
			text:SetTextColor(0.26, 0.27, 0.30)
		elseif entry.missing[ingredient.id] then
			text:SetText(MISSING_HEX .. need .. "|r")
		else
			text:SetText(tostring(need))
			text:SetTextColor(color[1], color[2], color[3])
		end
	end
end

local function DrawFooter(state)
	local total = #ns.combinations

	if not state.known then
		footer.Progress:SetText(L.CRITERIA_UNKNOWN)
		footer.Progress:SetTextColor(unpack(ACCENT))
	elseif state.remaining == 0 then
		footer.Progress:SetText(L.ALL_DONE)
		footer.Progress:SetTextColor(unpack(READY))
	else
		local made = state.affordable > 0
			and string.format(L.CAN_MAKE_NOW, state.affordable)
			or L.CAN_MAKE_NONE
		footer.Progress:SetText(string.format(L.PROGRESS, state.completed, total) .. "   ·   " .. made)
		footer.Progress:SetTextColor(unpack(TEXT_BRIGHT))
	end

	footer.Bar:SetWidth(math.max(1, ROW_W * (state.known and state.completed or 0) / total))

	-- The shopping list: a label, then one hoverable chip per ingredient still
	-- wanted. Laid out left to right from wherever the label happens to end,
	-- which is a different place in every language.
	local anyShort = false
	for _, ingredient in ipairs(ns.ingredients) do
		if state.shortfall[ingredient.id] > 0 then
			anyShort = true
			break
		end
	end

	if state.remaining == 0 then
		footer.Need:SetText("")
	elseif not anyShort then
		footer.Need:SetText(L.NOTHING_MISSING)
	else
		footer.Need:SetText(L.STILL_NEED)
	end

	local x = PAD + footer.Need:GetStringWidth() + 10
	for index, ingredient in ipairs(ns.ingredients) do
		local chip = footer.Chips[index]
		local need = state.stillNeed[ingredient.id]
		if state.remaining == 0 or not anyShort or need == 0 then
			chip:Hide()
		else
			chip.Icon:SetTexture(ns.GetItemIconFile(ingredient.id))
			if state.shortfall[ingredient.id] > 0 then
				chip.Count:SetText(need)
				chip.Count:SetTextColor(unpack(SHORT))
			else
				chip.Count:SetText(need)
				chip.Count:SetTextColor(unpack(TEXT_BRIGHT))
			end
			chip:SetWidth(14 + 4 + chip.Count:GetStringWidth())
			chip:ClearAllPoints()
			chip:SetPoint("LEFT", frame, "TOPLEFT", x, -(NEED_Y + 6))
			chip:Show()
			x = x + chip:GetWidth() + 14
		end
	end

	-- The bottom line answers "why can I not hand anything in", in the order the
	-- player runs into the obstacles: chain first, then today's mix, then the
	-- quest simply not being picked up.
	local unlock = state.unlock
	local text, color
	if not unlock.ready then
		text = string.format(L.UNLOCK_STEP, unlock.nextIndex, #unlock.steps)
			.. " " .. unlock.nextStep.title
		color = ACCENT
	elseif state.onQuest then
		text, color = L.DAILY_NOTE, TEXT_DIM
	elseif unlock.doneToday then
		text, color = L.DAILY_DONE, TEXT_DIM
	elseif unlock.doneByOther then
		text, color = L.DAILY_DONE_ALT, TEXT_DIM
	else
		text, color = L.NO_QUEST, ACCENT
	end

	footer.Note:SetText(text)
	footer.Note:SetTextColor(color[1], color[2], color[3])
	footer.NoteHit:SetShown(not unlock.ready)
end

function ns.Refresh()
	if not frame or not frame:IsShown() then
		return
	end

	local state = ns.BuildState()
	shown = state
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
	ApplyBubbles()
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
	elseif key == "bubbles" then
		ApplyBubbles()
	end
	ns.Refresh()
	UpdateVisibility()
end

--------------------------------------------------------------------------------
-- Construction
--------------------------------------------------------------------------------

local function BuildChrome()
	local background = Fill(frame, "BACKGROUND", PANEL_BG)
	background:SetAllPoints()
	Outline(frame, background, PANEL_EDGE, "BORDER", 0)

	local titleBar = Fill(frame, "BACKGROUND", TITLE_BG)
	titleBar:SetPoint("TOPLEFT")
	titleBar:SetPoint("TOPRIGHT")
	titleBar:SetHeight(TITLE_H)

	local accent = Fill(frame, "ARTWORK", { ACCENT[1], ACCENT[2], ACCENT[3], 0.55 })
	accent:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT")
	accent:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT")
	accent:SetHeight(1)

	-- The achievement's cauldron, and where the credits live: a tooltip costs no
	-- room in a window that is already a full-height table.
	local badge = CreateFrame("Frame", nil, frame)
	badge:SetSize(18, 18)
	badge:SetPoint("LEFT", frame, "TOPLEFT", PAD, -TITLE_H / 2)
	badge:EnableMouse(true)
	badge.Icon = badge:CreateTexture(nil, "ARTWORK")
	badge.Icon:SetTexture(ns.ACHIEVEMENT_ICON)
	badge.Icon:SetTexCoord(unpack(ICON_TRIM))
	badge.Icon:SetAllPoints()
	Outline(badge, badge.Icon, { 1, 1, 1, 0.16 })

	badge:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:AddLine(L.TITLE, 1, 1, 1)
		GameTooltip:AddLine(string.format(L.ABOUT_VERSION, ns.version),
			TEXT_LABEL[1], TEXT_LABEL[2], TEXT_LABEL[3])
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.THANKS_TITLE, ACCENT[1], ACCENT[2], ACCENT[3])
		GameTooltip:AddLine(L.THANKS_BODY, 1, 1, 1, true)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.ABOUT_HINT,
			TEXT_DIM[1], TEXT_DIM[2], TEXT_DIM[3], true)
		GameTooltip:Show()
	end)
	badge:SetScript("OnLeave", GameTooltip_Hide)
	frame.Badge = badge

	frame.TitleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.TitleText:SetPoint("LEFT", badge, "RIGHT", 8, 0)
	frame.TitleText:SetText(L.TITLE)
	frame.TitleText:SetTextColor(unpack(TEXT_BRIGHT))

	local close = CreateFrame("Button", nil, frame)
	close:SetSize(TITLE_H, TITLE_H)
	close:SetPoint("TOPRIGHT")
	close.Glyph = close:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	close.Glyph:SetPoint("CENTER")
	close.Glyph:SetText("\195\151") -- multiplication sign, the tidiest × in the game fonts
	close.Glyph:SetTextColor(unpack(TEXT_LABEL))
	close:SetScript("OnEnter", function(self) self.Glyph:SetTextColor(unpack(SHORT)) end)
	close:SetScript("OnLeave", function(self) self.Glyph:SetTextColor(unpack(TEXT_LABEL)) end)
	close:SetScript("OnClick", function() frame:Hide() end)
	frame.CloseButton = close
end

function ns.InitWindow()
	if frame then
		return
	end

	frame = CreateFrame("Frame", "MysteriousMixHelperFrame", UIParent)
	frame:SetSize(WIDTH, HEIGHT)
	frame:SetFrameStrata("HIGH")
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetMovable(not ns.db.locked)
	frame:RegisterForDrag("LeftButton")
	frame:Hide()

	BuildChrome()

	bubbles = CreateBubbles(frame)
	ns.bubbles = bubbles
	-- OnUpdate only runs while the frame is shown, so a closed window costs
	-- nothing.
	frame:SetScript("OnUpdate", function(_, elapsed)
		if ns.db.bubbles then
			StepBubbles(elapsed)
		end
	end)

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

	Text(frame, "GameFontNormalSmall", PAD, LABEL_Y, nil, "LEFT", TEXT_LABEL)
		:SetText(string.upper(L.IN_YOUR_BAGS))

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
		Progress = Text(frame, "GameFontNormalSmall", PAD, PROG_Y, ROW_W, "LEFT", TEXT_BRIGHT),
		-- No fixed width: GetStringWidth is what the chips are laid out against.
		Need     = Text(frame, "GameFontHighlightSmall", PAD, NEED_Y, nil, "LEFT", TEXT_BRIGHT),
		Note     = Text(frame, "GameFontDisableSmall", PAD, NOTE_Y, ROW_W, "LEFT", TEXT_DIM),
		Chips    = {},
	}
	for index = 1, COUNT do
		footer.Chips[index] = CreateNeedChip(frame, index)
	end

	-- A hit area over the bottom line, shown only while the chain is unfinished:
	-- the line names the next step, the tooltip lays out the whole route.
	local hit = CreateFrame("Frame", nil, frame)
	hit:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -(NOTE_Y - 2))
	hit:SetSize(ROW_W, 16)
	hit:EnableMouse(true)
	hit:SetScript("OnEnter", function(self)
		local unlock = shown and shown.unlock
		if not unlock then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L.UNLOCK_TITLE, 1, 1, 1)
		for _, step in ipairs(unlock.steps) do
			local mark = step.completed and "|cff6be67a+|r" or "|cffffb833>|r"
			local hue = step.completed and DONE or TEXT_BRIGHT
			GameTooltip:AddLine(mark .. " " .. step.title, hue[1], hue[2], hue[3])
			if not step.completed then
				GameTooltip:AddLine("     " .. step.hint,
					TEXT_LABEL[1], TEXT_LABEL[2], TEXT_LABEL[3], true)
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.UNLOCK_CAVEAT,
			TEXT_DIM[1], TEXT_DIM[2], TEXT_DIM[3], true)
		GameTooltip:Show()
	end)
	hit:SetScript("OnLeave", GameTooltip_Hide)
	hit:Hide()
	footer.NoteHit = hit

	-- A thin progress bar along the very bottom edge: ten criteria, one window.
	local track = Fill(frame, "ARTWORK", { 1, 1, 1, 0.05 })
	track:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", PAD, 8)
	track:SetSize(ROW_W, 2)
	footer.Bar = Fill(frame, "OVERLAY", { ACCENT[1], ACCENT[2], ACCENT[3], 0.85 })
	footer.Bar:SetPoint("LEFT", track, "LEFT")
	footer.Bar:SetHeight(2)
	footer.Bar:SetWidth(1)

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
