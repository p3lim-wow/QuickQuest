local addonName, ns = ...
local L = ns.L

-- TODO: scrollframes

local BACKDROP = GameTooltip:GetBackdrop()
local function CreateOptionsPanel(name, localizedName, description, buttonLocalizedText)
	local panel = CreateFrame('Frame', addonName .. name, InterfaceOptionsFramePanelContainer)
	panel.name = localizedName
	panel.parent = addonName

	local title = panel:CreateFontString('$parentTitle', 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', 15, -15)
	title:SetText(panel.name)

	local desc = panel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	desc:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
	desc:SetText(description)

	local container = CreateFrame('Frame', '$parentContainer', panel, BackdropTemplateMixin and 'BackdropTemplate')
	container:SetBackdrop(BACKDROP)
	container:SetBackdropColor(0, 0, 0, 0.5)
	container:SetBackdropBorderColor(0.5, 0.5, 0.5)
	container:SetPoint('TOPLEFT', 15, -60)
	container:SetPoint('BOTTOMRIGHT', -15, 15)
	panel.container = container

	local button = CreateFrame('Button', '$parentButton', panel, 'UIPanelButtonTemplate')
	button:SetPoint('BOTTOMRIGHT', container, 'TOPRIGHT', 0, 5)
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

	local itemPool = ns.CreateButtonPool(panel.container, 15, 33, 33, 5)
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
			button:SetBackdrop(BACKDROP)
			button:SetBackdropColor(0, 0, 0, 0.5)
			button:SetBackdropBorderColor(0.5, 0.5, 0.5)
			button.npcID = npcID
			button.OnEnter = OnEnter
			button.OnLeave = GameTooltip_Hide
			button.OnRemove = OnRemove

			local model = CreateFrame('PlayerModel', nil, button)
			model:SetAllPoints()
			model:SetCamDistanceScale(0.8)
			model:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
			button.model = model

			UpdateModel(button)
			pool:Reposition()

			-- inject into db
			ns.db.profile.blocklist.npcs[npcID] = true
		else
			print(addonName .. ': Invalid NPC ID')
		end
	end

	local npcPool = ns.CreateButtonPool(panel.container, 15, 66, 80, 5)
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

function ns.CreateBlocklistOptions()
	ns.CreateBlocklistOptions = nop -- we only want to run this once

	CreateItemBlocklistOptions()
	CreateNPCBlocklistOptions()
end
