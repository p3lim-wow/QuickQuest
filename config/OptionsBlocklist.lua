local addonName, ns = ...
local L = ns.L

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

	local bounds = CreateFrame('Frame', '$parentBounds', panel, BackdropTemplateMixin and 'BackdropTemplate')
	bounds:SetPoint('TOPLEFT', 15, -60)
	bounds:SetPoint('BOTTOMRIGHT', -15, 15)
	bounds:SetBackdrop(BACKDROP)
	bounds:SetBackdropColor(0, 0, 0, 0.5)
	bounds:SetBackdropBorderColor(0.5, 0.5, 0.5)

	local scrollchild = CreateFrame('Frame', '$parentScrollChild', panel)
	scrollchild:SetHeight(1) -- it needs something
	panel.container = scrollchild

	local scrollframe = CreateFrame('ScrollFrame', '$parentContainer', bounds, 'UIPanelScrollFrameTemplate')
	scrollframe:SetPoint('TOPLEFT', 4, -4)
	scrollframe:SetPoint('BOTTOMRIGHT', -4, 4)
	scrollframe:SetScrollChild(scrollchild)

	scrollframe.ScrollBar:ClearAllPoints()
	scrollframe.ScrollBar:SetPoint('TOPRIGHT', bounds, -6, -22)
	scrollframe.ScrollBar:SetPoint('BOTTOMRIGHT', bounds, -6, 22)

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
		for index, itemID in next, ns.db.profile.blocklist.items do
			if itemID == self.itemID then
				ns.db.profile.blocklist.items[index] = nil
			end
		end
	end

	local queryItems = {}
	local function UpdateTexture(button)
		local _, _, _, _, _, _, _, _, _, textureFile = GetItemInfo(button.itemID)
		if textureFile then
			button:SetNormalTexture(textureFile)
		else
			-- wait for cache and retry
			queryItems[button.itemID] = button
			panel.container:RegisterEvent('GET_ITEM_INFO_RECEIVED')
		end
	end

	panel.container:SetScript('OnEvent', function(self, event, itemID)
		local button = queryItems[itemID]
		if button then
			queryItems[itemID] = nil
			UpdateTexture(button)

			if ns.tLength(queryItems) == 0 then
				self:UnregisterEvent(event)
			end
		end
	end)

	local function AddButton(pool, itemID)
		if itemID then
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

			-- check if the item is already blocked
			local exists = false
			for _, existingItemID in next, ns.db.profile.blocklist.items do
				if existingItemID == itemID then
					exists = true
				end
			end

			if not exists then
				-- inject into db
				ns.db.profile.blocklist.items['custom_' .. itemID] = itemID
			end
		else
			print(addonName .. ': Invalid item ID')
		end
	end

	local itemPool = ns.CreateButtonPool(panel.container, 16, 33, 33, 4)
	itemPool:SetSortField('itemID')

	for _, itemID in next, ns.db.profile.blocklist.items do
		AddButton(itemPool, itemID)
	end

	panel.button:SetScript('OnClick', function()
		StaticPopup_Show(addonName .. 'ItemBlocklistPopup', nil, nil, {
			callback = AddButton,
			pool = itemPool,
		})
	end)
end

local function CreateNPCBlocklistOptions()
	local panel = CreateOptionsPanel('NPCBlocklist',
		L['NPC Blocklist'],
		L['Quests and dialogue from NPCs in this list will not be automated.'],
		L['Block NPC'])

	local function OnEnter(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:AddLine('<NYI> (npc name)') -- TODO: can we even get the names?
		GameTooltip:AddDoubleLine('NPC ID', self.npcID)
		GameTooltip:Show()
	end

	local function OnRemove(self)
		ns.db.profile.blocklist.npcs[self.npcID] = nil
	end

	local function UpdateModel(button)
		button.model:ClearModel()
		button.model:SetCreature(button.npcID)

		-- wait for cache and retry
		if not button.model:GetModelFileID() then
			C_Timer.After(1, function()
				UpdateModel(button)
			end)
		end
	end

	local function AddButton(pool, npcID)
		if npcID then
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

			local frame = CreateFrame('Frame', nil, button, BackdropTemplateMixin and 'BackdropTemplate')
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
			ns.db.profile.blocklist.npcs[npcID] = true
		else
			print(addonName .. ': Invalid NPC ID')
		end
	end

	local npcPool = ns.CreateButtonPool(panel.container, 16, 66, 80, 4)
	npcPool:SetSortField('npcID')

	for npcID in next, ns.db.profile.blocklist.npcs do
		AddButton(npcPool, npcID)
	end

	panel.button:SetScript('OnClick', function()
		StaticPopup_Show(addonName .. 'NPCBlocklistPopup', nil, nil, {
			callback = AddButton,
			pool = npcPool,
		})
	end)
end

local function CreateTitleBlocklistOptions()
	local panel = CreateOptionsPanel('TitleBlocklist',
		L['Title Blocklist'],
		L['Quests with titles that partially match or IDs that exactly match entries from this list will not be automated.'],
		L['Block Title'])

	local function OnRemove(self)
		for index, title in next, ns.db.profile.blocklist.title do
			if title == self.title then
				tremove(ns.db.profile.blocklist.title, index)
			end
		end
	end

	local function AddButton(pool, title)
		if title:find("^%s*$") then
			print(addonName .. ': Invalid quest title or ID')
		else
			local button = pool:CreateButton()
			button.title = title
			button.OnRemove = OnRemove

			if not button.text then
				local text = button:CreateFontString('$parentText', 'ARTWORK', 'GameFontNormal')
				text:SetPoint('LEFT', button, 'LEFT', 5, 0)
				button.text = text
				
				local frame = CreateFrame('Frame', nil, button, BackdropTemplateMixin and 'BackdropTemplate')
				frame:SetPoint('TOPLEFT', -2, 2)
				frame:SetPoint('BOTTOMRIGHT', 2, -2)
				frame:SetBackdrop(BACKDROP)
				frame:SetBackdropColor(0, 0, 0, 0)
				frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
				frame:SetFrameLevel(button:GetFrameLevel() + 1)
				button.frame = frame
			
				button.remove:SetFrameLevel(frame:GetFrameLevel() + 1)
			end
			
			button.text:SetText(title)
			
			pool:Reposition()

			-- inject into db
			if not tContains(ns.db.profile.blocklist.title, title) then
				tinsert(ns.db.profile.blocklist.title, title)
			end
		end
	end

	local offset = 16
	local spacing = 4
	local width = 500 -- big enough to only have 1 column
	local height = 18
	local titlePool = ns.CreateButtonPool(panel.container, offset, width, height, spacing)
	titlePool:SetSortField('title')

	for _, title in next, ns.db.profile.blocklist.title do
		AddButton(titlePool, title)
	end

	panel.button:SetScript('OnClick', function()
		StaticPopup_Show(addonName .. 'TitleBlocklistPopup', nil, nil, {
			callback = AddButton,
			pool = titlePool,
		})
	end)
end

function ns.CreateBlocklistOptions()
	ns.CreateBlocklistOptions = nop -- we only want to run this once

	CreateItemBlocklistOptions()
	CreateNPCBlocklistOptions()
	CreateTitleBlocklistOptions()
end
