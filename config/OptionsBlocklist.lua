local addonName, addon = ...
local L = addon.L

local BACKDROP = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

local function CreateOptionsPanel(name, localizedName, description, buttonLocalizedText)
	local panel = CreateFrame('Frame', addonName .. name, InterfaceOptionsFramePanelContainer)
	panel.name = localizedName
	panel.parent = addonName

	local title = panel:CreateFontString('$parentTitle', 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', 15, -15)
	title:SetText(panel.name)

	local desc = panel:CreateFontString('$parentDescription', 'ARTWORK', 'GameFontHighlight')
	desc:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
	desc:SetText(description)

	local bounds = CreateFrame('Frame', '$parentBounds', panel, 'BackdropTemplate')
	bounds:SetPoint('TOPLEFT', 15, -60)
	bounds:SetPoint('BOTTOMRIGHT', -15, 15)
	bounds:SetBackdrop(BACKDROP)
	bounds:SetBackdropColor(0, 0, 0, 0.5)
	bounds:SetBackdropBorderColor(0.5, 0.5, 0.5)

	local scrollchild = CreateFrame('Frame', '$parentScrollChild', panel)
	scrollchild:SetHeight(1) -- it needs something
	panel.container = scrollchild

	local scrollframe = CreateFrame('ScrollFrame', '$parentContainer', bounds, 'ScrollFrameTemplate')
	scrollframe:SetPoint('TOPLEFT', 4, -4)
	scrollframe:SetPoint('BOTTOMRIGHT', -4, 4)
	scrollframe:SetScrollChild(scrollchild)

	scrollframe.ScrollBar:ClearAllPoints()
	scrollframe.ScrollBar:SetPoint('TOPRIGHT', bounds, -12, -8)
	scrollframe.ScrollBar:SetPoint('BOTTOMRIGHT', bounds, -12, 8)

	local button = CreateFrame('Button', '$parentButton', panel, 'UIPanelButtonTemplate')
	button:SetPoint('BOTTOMRIGHT', bounds, 'TOPRIGHT', 0, 5)
	button:SetText(buttonLocalizedText)
	button:SetWidth(button:GetTextWidth() * 1.5)
	button:SetHeight(button:GetTextHeight() * 2)
	panel.button = button

	InterfaceOptions_AddCategory(panel)
	return panel
end

local function CreateItemBlocklistOptions()
	local panel = CreateOptionsPanel('ItemBlocklist',
		L['Item Blocklist'],
		L['Quests containing items in this list will not be automated.'],
		L['Block Item'])

	local function OnEnter(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:SetItemByID(self.itemID)
		GameTooltip:Show()
	end

	local function OnRemove(self)
		for itemID in next, addon.db.profile.blocklist.items do
			if itemID == self.itemID then
				addon.db.profile.blocklist.items[itemID] = false
			end
		end
	end

	local function UpdateTexture(button)
		local item = Item:CreateFromItemID(button.itemID)
		local textureFile = item:GetItemIcon()
		if not textureFile then
			item:ContinueOnItemLoad(function()
				UpdateTexture(button)
			end)
			return
		end

		button:SetNormalTexture(textureFile)
	end

	local function AddButton(pool, itemID)
		if not itemID or not tonumber(itemID) then
			print(addonName .. ': Invalid item ID')
			return
		end

		if pool:HasButtonBySortField(itemID) then
			print(addonName .. ': Item', itemID, 'is already blocked')
			return
		end

		local button = pool:CreateButton()
		button.itemID = itemID
		button.OnEnter = OnEnter
		button.OnLeave = GameTooltip_Hide
		button.OnRemove = OnRemove

		local texture = button:CreateTexture(nil, 'OVERLAY')
		texture:SetPoint('CENTER')
		texture:SetSize(54, 54)
		texture:SetTexture([[Interface\Buttons\UI-Quickslot2]])

		UpdateTexture(button)
		pool:Reposition()

		-- inject into db
		addon.db.profile.blocklist.items[itemID] = true
	end

	local itemPool = addon:CreateButtonPool(panel.container, 16, 33, 33, 4)
	itemPool:SetSortField('itemID')

	for itemID, value in next, addon.db.profile.blocklist.items do
		if value then
			AddButton(itemPool, itemID)
		end
	end

	panel.button:SetScript('OnClick', function()
		StaticPopup_Show(addonName .. 'ItemBlocklistPopup', nil, nil, {
			callback = AddButton,
			pool = itemPool,
		})
	end)
end

local function scanNpcName(npcID)
	local tooltipData = C_TooltipInfo.GetHyperlink('unit:Creature-0-0-0-0-' .. npcID .. '-0')
	if tooltipData then
		TooltipUtil.SurfaceArgs(tooltipData) -- TODO: remove this in 10.1

		if tooltipData.lines then
			for _, line in next, tooltipData.lines do
				TooltipUtil.SurfaceArgs(line) -- TODO: remove this in 10.1
			end

			if tooltipData.lines[1] and tooltipData.lines[1].leftText then
				return tooltipData.lines[1].leftText
			end
		end
	end

	return UNKNOWN -- globalstrings
end

local function CreateNPCBlocklistOptions()
	local panel = CreateOptionsPanel('NPCBlocklist',
		L['NPC Blocklist'],
		L['Quests and dialogue from NPCs in this list will not be automated.'],
		L['Block NPC'])

	local function OnEnter(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:AddLine(scanNpcName(self.npcID), 1, 1, 1)
		GameTooltip:AddDoubleLine('NPC ID', self.npcID)
		GameTooltip:Show()
	end

	local function OnRemove(self)
		self.model:ClearModel()
		self.model:Hide()
		addon.db.profile.blocklist.npcs[self.npcID] = false
	end

	local function UpdateModel(button)
		button.model:ClearModel()
		button.model:SetCreature(button.npcID)
		button.model:Show()

		-- wait for cache and retry
		if not button.model:GetModelFileID() then
			C_Timer.After(1, function()
				UpdateModel(button)
			end)
		end
	end

	local function AddButton(pool, npcID)
		if not npcID or not tonumber(npcID) then
			print(addonName .. ': Invalid NPC ID')
			return
		end

		if pool:HasButtonBySortField(npcID) then
			print(addonName .. ': NPC is already blocked')
			return
		end

		local button = pool:CreateButton()
		button.npcID = npcID
		button.OnEnter = OnEnter
		button.OnLeave = GameTooltip_Hide
		button.OnRemove = OnRemove

		local model = CreateFrame('PlayerModel', nil, button)
		model:SetPoint('TOPLEFT', 2, -2)
		model:SetPoint('BOTTOMRIGHT', -2, 2)
		model:SetCamDistanceScale(0.8)
		model:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
		button.model = model

		local frame = CreateFrame('Frame', nil, button, 'BackdropTemplate')
		frame:SetPoint('TOPLEFT', -2, 2)
		frame:SetPoint('BOTTOMRIGHT', 2, -2)
		frame:SetBackdrop(BACKDROP)
		frame:SetBackdropColor(0, 0, 0, 0)
		frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
		frame:SetFrameLevel(model:GetFrameLevel() + 1)

		button.remove:SetFrameLevel(frame:GetFrameLevel() + 1)

		UpdateModel(button)
		pool:Reposition()

		-- inject into db
		addon.db.profile.blocklist.npcs[npcID] = true
	end

	local npcPool = addon:CreateButtonPool(panel.container, 16, 66, 80, 4)
	npcPool:SetSortField('npcID')

	for npcID, value in next, addon.db.profile.blocklist.npcs do
		if value then
			AddButton(npcPool, npcID)
		end
	end

	panel.button:SetScript('OnClick', function()
		StaticPopup_Show(addonName .. 'NPCBlocklistPopup', nil, nil, {
			callback = AddButton,
			pool = npcPool,
		})
	end)
end

local function CreateQuestBlocklistOptions()
	local panel = CreateOptionsPanel('TitleBlocklist',
		L['Quest Blocklist'],
		L['Quests (by partial title or ID) in this list will not be automated.'],
		L['Block Quest'])

	local function OnRemove(self)
		for questID in next, addon.db.profile.blocklist.quests do
			if questID == self.questID then
				addon.db.profile.blocklist.quests[questID] = false
			end
		end
	end

	local function UpdateTitle(button)
		if tonumber(button.questID) then
			local questInfo = QuestCache:Get(button.questID)
			if questInfo.title == "" then
				QuestEventListener:AddCallback(button.questID, function()
					UpdateTitle(button)
				end)
			end

			if questInfo.title ~= "" then
				button.text:SetFormattedText('%d (%s)', button.questID, questInfo.title)
				return
			end
		end

		button.text:SetText(button.questID)
	end

	local function AddButton(pool, questID)
		if tostring(questID):find("^%s*$") then
			print(addonName .. ': Invalid quest title or ID')
			return
		end

		-- try store numbers if we can
		questID = tonumber(questID) or questID

		-- try not to add duplicates
		if pool:HasButtonBySortField(questID) then
			print(addonName .. ': Quest is already blocked')
			return
		end

		local button = pool:CreateButton()
		button.questID = questID
		button.OnRemove = OnRemove

		if not button.text then
			local text = button:CreateFontString('$parentText', 'ARTWORK', 'GameFontNormal')
			text:SetPoint('LEFT', button, 'LEFT', 5, 0)
			button.text = text

			local frame = CreateFrame('Frame', nil, button, 'BackdropTemplate')
			frame:SetPoint('TOPLEFT', -2, 2)
			frame:SetPoint('BOTTOMRIGHT', 2, -2)
			frame:SetBackdrop(BACKDROP)
			frame:SetBackdropColor(0, 0, 0, 0)
			frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
			frame:SetFrameLevel(button:GetFrameLevel() + 1)
			button.frame = frame

			button.remove:SetFrameLevel(frame:GetFrameLevel() + 1)
		end

		UpdateTitle(button)
		pool:Reposition()

		-- inject into db
		addon.db.profile.blocklist.quests[questID] = true
	end

	-- TODO: tweak width
	local questPool = addon:CreateButtonPool(panel.container, 16, 500, 20, 4)
	questPool:SetSortField('questID')

	for questID, value in next, addon.db.profile.blocklist.quests do
		if value then
			AddButton(questPool, questID)
		end
	end

	panel.button:SetScript('OnClick', function()
		StaticPopup_Show(addonName .. 'QuestBlocklistPopup', nil, nil, {
			callback = AddButton,
			pool = questPool,
		})
	end)
end

function addon.CreateBlocklistOptions()
	addon.CreateBlocklistOptions = nop -- we only want to run this once

	CreateItemBlocklistOptions()
	CreateNPCBlocklistOptions()
	CreateQuestBlocklistOptions()
end
