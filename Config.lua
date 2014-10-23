local addonName, L = ...

local objects = {}
local temporary = {}

local defaults = {
	toggle = true,
	items = true,
	faireport = true,
	gossip = true,
	gossipraid = true,
	modifier = 'SHIFT',
	reverse = false,
	delay = false,
	itemBlacklist = {
		-- Inscription weapons
		[31690] = 79343, -- Inscribed Tiger Staff
		[31691] = 79340, -- Inscribed Crane Staff
		[31692] = 79341, -- Inscribed Serpent Staff

		-- Darkmoon Faire artifacts
		[29443] = 71635, -- Imbued Crystal
		[29444] = 71636, -- Monstrous Egg
		[29445] = 71637, -- Mysterious Grimoire
		[29446] = 71638, -- Ornate Weapon
		[29451] = 71715, -- A Treatise on Strategy
		[29456] = 71951, -- Banner of the Fallen
		[29457] = 71952, -- Captured Insignia
		[29458] = 71953, -- Fallen Adventurer's Journal
		[29464] = 71716, -- Soothsayer's Runes

		-- Tiller Gifts
		['progress_79264'] = 79264, -- Ruby Shard
		['progress_79265'] = 79265, -- Blue Feather
		['progress_79266'] = 79266, -- Jade Cat
		['progress_79267'] = 79267, -- Lovely Apple
		['progress_79268'] = 79268, -- Marsh Lily

		-- Misc
		[31664] = 88604, -- Nat's Fishing Journal
	}
}

local Panel = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
Panel.name = addonName
Panel:Hide()

Panel:RegisterEvent('PLAYER_LOGIN')
Panel:SetScript('OnEvent', function()
	local oldName = 'Monomyth'
	if(IsAddOnLoaded(oldName)) then
		DisableAddOn(oldName)
		print('|cffff8080QuickQuest:|r', string.format(L['You\'re running a conflicting addon (%s), type /reload to resolve'], oldName))
	end

	QuickQuestDB = QuickQuestDB or defaults

	-- TEMP: import from old DB
	if(QuickQuestDB.ignoredQuests) then
		QuickQuestDB.itemBlacklist = QuickQuestDB.ignoredQuests
		QuickQuestDB.ignoredQuests = nil
	end

	for key, value in next, defaults do
		if(QuickQuestDB[key] == nil) then
			QuickQuestDB[key] = value
		end
	end
end)

function Panel:okay()
	for key, value in next, temporary do
		QuickQuestDB[key] = value
	end
end

function Panel:cancel()
	table.wipe(temporary)
end

function Panel:default()
	for key, value in next, defaults do
		if(key ~= 'itemBlacklist') then
			QuickQuestDB[key] = value
		end
	end

	table.wipe(temporary)
end

function Panel:refresh()
	for key, object in next, objects do
		if(object:IsObjectType('CheckButton')) then
			object:SetChecked(QuickQuestDB[key])
		elseif(object:IsObjectType('Frame')) then
			object.Label:SetText(object.keys[QuickQuestDB[key]])
		end
	end
end

local function ToggleAll(self)
	local enabled = self:GetChecked()

	for _, object in next, objects do
		if(object:IsObjectType('CheckButton')) then
			if(enabled) then
				local parent = object.realParent
				if(not parent or parent:GetChecked()) then
					object:Enable()
					object.Text:SetTextColor(1, 1, 1)
				end
			else
				if(object ~= self) then
					object:Disable()
				end

				object.Text:SetTextColor(1/3, 1/3, 1/3)
			end
		elseif(object:IsObjectType('Frame')) then
			if(enabled) then
				object.Button:Enable()
				object.Label:SetTextColor(1, 1, 1)
				object.Text:SetTextColor(1, 1, 1)
			else
				object.Button:Disable()
				object.Label:SetTextColor(1/3, 1/3, 1/3)
				object.Text:SetTextColor(1/3, 1/3, 1/3)
			end
		end
	end
end

local CreateCheckButton
do
	local function ClickCheckButton(self)
		if(self:GetChecked()) then
			temporary[self.key] = true
		else
			temporary[self.key] = false
		end
	end

	function CreateCheckButton(parent, key, realParent)
		local CheckButton = CreateFrame('CheckButton', nil, parent, 'InterfaceOptionsCheckButtonTemplate')
		CheckButton:SetHitRectInsets(0, 0, 0, 0)
		CheckButton:SetScript('OnClick', ClickCheckButton)
		CheckButton.realParent = realParent
		CheckButton.key = key

		objects[key] = CheckButton

		return CheckButton
	end
end

local CreateDropdown
do
	local BACKDROP = {
		bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
		edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], edgeSize = 32,
		insets = {top = 12, bottom = 9, left = 11, right = 12}
	}

	local function OnHide(self)
		self.Menu:Hide()
	end

	local function MenuClick(self)
		local Menu = self:GetParent().Menu
		if(Menu:IsShown()) then
			Menu:Hide()
		else
			for key, Item in next, Menu.items do
				Item.Button:SetChecked(key == (temporary[Menu.key] or QuickQuestDB[Menu.key]))
			end

			Menu:Show()
		end

		PlaySound('igMainMenuOptionCheckBoxOn')
	end

	local function ItemClick(self)
		local Menu = self:GetParent()
		temporary[Menu.key] = self.value

		Menu:Hide()
		Menu:GetParent().Label:SetText(self:GetText())
	end

	function CreateDropdown(parent, key, items)
		local Dropdown = CreateFrame('Frame', nil, parent)
		Dropdown:SetSize(110, 32)
		Dropdown:SetScript('OnHide', OnHide)
		Dropdown.keys = items

		local LeftTexture = Dropdown:CreateTexture()
		LeftTexture:SetPoint('TOPLEFT', -14, 17)
		LeftTexture:SetSize(25, 64)
		LeftTexture:SetTexture([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]])
		LeftTexture:SetTexCoord(0, 0.1953125, 0, 1)

		local RightTexture = Dropdown:CreateTexture()
		RightTexture:SetPoint('TOPRIGHT', 14, 17)
		RightTexture:SetSize(25, 64)
		RightTexture:SetTexture([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]])
		RightTexture:SetTexCoord(0.8046875, 1, 0, 1)

		local MiddleTexture = Dropdown:CreateTexture()
		MiddleTexture:SetPoint('TOPLEFT', LeftTexture, 'TOPRIGHT')
		MiddleTexture:SetPoint('TOPRIGHT', RightTexture, 'TOPLEFT')
		MiddleTexture:SetTexture([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]])
		MiddleTexture:SetTexCoord(0.1953125, 0.8046875, 0, 1)

		local Button = CreateFrame('Button', nil, Dropdown)
		Button:SetPoint('TOPRIGHT', RightTexture, -16, -18)
		Button:SetSize(24, 24)
		Button:SetNormalTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Up]])
		Button:SetPushedTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Down]])
		Button:SetDisabledTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Disabled]])
		Button:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])
		Button:GetHighlightTexture():SetBlendMode('ADD')
		Button:SetScript('OnClick', MenuClick)
		Dropdown.Button = Button

		local Label = Dropdown:CreateFontString(nil, nil, 'GameFontHighlightSmall')
		Label:SetPoint('RIGHT', Button, 'LEFT')
		Label:SetSize(0, 10)
		Dropdown.Label = Label

		local Menu = CreateFrame('Frame', nil, Dropdown)
		Menu:SetPoint('TOPLEFT', Dropdown, 'BOTTOMLEFT', 0, 4)
		Menu:SetBackdrop(BACKDROP)
		Menu:Hide()
		Menu.key = key
		Menu.items = {}
		Dropdown.Menu = Menu

		local index, maxWidth = 0, 0
		for value, name in next, items do
			local Item = CreateFrame('Button', nil, Menu)
			Item:SetPoint('TOPLEFT', 14, -(14 + (18 * index)))
			Item:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
			Item:GetHighlightTexture():SetBlendMode('ADD')
			Item:SetScript('OnClick', ItemClick)
			Item.value = value

			local ItemButton = CreateFrame('CheckButton', nil, Item)
			ItemButton:SetPoint('LEFT')
			ItemButton:SetSize(16, 16)
			ItemButton:SetNormalTexture([[Interface\Common\UI-DropDownRadioChecks]])
			ItemButton:GetNormalTexture():SetTexCoord(0.5, 1, 0.5, 1)
			ItemButton:SetCheckedTexture([[Interface\Common\UI-DropDownRadioChecks]])
			ItemButton:GetCheckedTexture():SetTexCoord(0, 0.5, 0.5, 1)
			ItemButton:EnableMouse(false)
			Item.Button = ItemButton

			local ItemLabel = Item:CreateFontString(nil, nil, 'GameFontHighlightSmall')
			ItemLabel:SetPoint('LEFT', ItemButton, 'RIGHT', 4, -1)
			ItemLabel:SetText(name)
			Item:SetFontString(ItemLabel)

			local width = ItemLabel:GetWidth()
			if(width > maxWidth) then
				maxWidth = width
			end

			Menu.items[value] = Item
			index = index + 1
		end

		for _, Item in next, Menu.items do
			Item:SetSize(32 + maxWidth, 18)
		end

		Menu:SetSize(60 + maxWidth, 28 + 18 * index)

		local Text = Dropdown:CreateFontString(nil, nil, 'GameFontHighlight')
		Text:SetPoint('LEFT', Dropdown, 'RIGHT', 3, 2)
		Dropdown.Text = Text

		objects[key] = Dropdown

		return Dropdown
	end
end

Panel:SetScript('OnShow', function(self)
	local Title = self:CreateFontString(nil, nil, 'GameFontNormalLarge')
	Title:SetPoint('TOPLEFT', 16, -16)
	Title:SetText(addonName)

	local Description = self:CreateFontString(nil, nil, 'GameFontHighlightSmall')
	Description:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -8)
	Description:SetPoint('RIGHT', -32, 0)
	Description:SetJustifyH('LEFT')
	Description:SetText(L['Less clicking, more action!'])
	self.Description = Description

	local Toggle = CreateCheckButton(self, 'toggle')
	Toggle:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', -2, -10)
	Toggle:HookScript('OnClick', ToggleAll)
	Toggle.Text:SetText(L['Enable automating'])

	local Delay = CreateCheckButton(self, 'delay')
	Delay:SetPoint('TOPLEFT', Toggle, 'BOTTOMLEFT', 24, -8)
	Delay.Text:SetText(L['Slow down the automating'])

	local Items = CreateCheckButton(self, 'items')
	Items:SetPoint('TOPLEFT', Delay, 'BOTTOMLEFT', -24, -8)
	Items.Text:SetText(L['Start quests from items'])

	local Gossip = CreateCheckButton(self, 'gossip')
	Gossip:SetPoint('TOPLEFT', Items, 'BOTTOMLEFT', 0, -8)
	Gossip.Text:SetText(L['Select gossip option if there is only one'])

	local GossipRaid = CreateCheckButton(self, 'gossipraid', Gossip)
	GossipRaid:SetPoint('TOPLEFT', Gossip, 'BOTTOMLEFT', 24, -8)
	GossipRaid.Text:SetText(L['Only select gossip option while not in a raid'])

	Gossip:HookScript('OnClick', function(self)
		if(self:GetChecked()) then
			GossipRaid:Enable()
			GossipRaid.Text:SetTextColor(1, 1, 1)
		else
			GossipRaid:Disable()
			GossipRaid.Text:SetTextColor(1/3, 1/3, 1/3)
		end
	end)

	if(QuickQuestDB.gossip) then
		GossipRaid:Enable()
		GossipRaid.Text:SetTextColor(1, 1, 1)
	else
		GossipRaid:Disable()
		GossipRaid.Text:SetTextColor(1/3, 1/3, 1/3)
	end

	local Darkmoon = CreateCheckButton(self, 'faireport')
	Darkmoon:SetPoint('TOPLEFT', GossipRaid, 'BOTTOMLEFT', -24, -8)
	Darkmoon.Text:SetText(L['Darkmoon Faire: Automatically teleport'])

	local Modifier = CreateDropdown(self, 'modifier', {
		ALT = L['ALT key'],
		CTRL = L['CTRL key'],
		SHIFT = L['SHIFT key']
	})
	Modifier:SetPoint('TOPLEFT', Darkmoon, 'BOTTOMLEFT', 0, -14)

	if(QuickQuestDB.reverse) then
		Modifier.Text:SetText(L['Modifier to temporarly enable automation'])
	else
		Modifier.Text:SetText(L['Modifier to temporarly disable automation'])
	end

	local Reverse = CreateCheckButton(self, 'reverse')
	Reverse:SetPoint('TOPLEFT', Modifier, 'BOTTOMLEFT', 24, -8)
	Reverse.Text:SetText(L['Reverse the behaviour of the modifier key'])
	Reverse:HookScript('OnClick', function(self)
		if(self:GetChecked()) then
			Modifier.Text:SetText(L['Modifier to temporarly enable automation'])
		else
			Modifier.Text:SetText(L['Modifier to temporarly disable automation'])
		end
	end)

	Panel:refresh()
	ToggleAll(Toggle)

	self:SetScript('OnShow', nil)
end)

local containerBackdrop = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

local ItemPanel = CreateFrame('Frame', nil, Panel)
ItemPanel.name = 'Item Blacklist'
ItemPanel.parent = addonName
ItemPanel:Hide()

function ItemPanel:default()
	table.wipe(QuickQuestDB.itemBlacklist)

	for quest, item in next, defaults.itemBlacklist do
		QuickQuestDB.itemBlacklist[quest] = item
	end

	self:UpdateList()
end

local items = {}

StaticPopupDialogs.QUICKQUEST_ITEM_REMOVE = {
	text = L['Are you sure you want to delete\n|T%s:16|t%s\nfrom the filter?'],
	button1 = 'Yes',
	button2 = 'No',
	OnAccept = function(self, data)
		QuickQuestDB.itemBlacklist[data.questID] = nil
		items[data.itemID] = nil
		data.button:Hide()

		ItemPanel:UpdateList()
	end,
	timeout = 0,
	hideOnEscape = true,
	preferredIndex = 3, -- Avoid some taint
}

ItemPanel:SetScript('OnShow', function(self)
	local Title = self:CreateFontString(nil, nil, 'GameFontHighlight')
	Title:SetPoint('TOPLEFT', 20, -20)
	Title:SetText(L['Items filtered from automation'])

	local Description = CreateFrame('Button', nil, self)
	Description:SetPoint('LEFT', Title, 'RIGHT')
	Description:SetNormalTexture([[Interface\GossipFrame\ActiveQuestIcon]])
	Description:SetSize(16, 16)

	Description:SetScript('OnLeave', GameTooltip_Hide)
	Description:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:AddLine(L.ItemBlacklistTooltip, 1, 1, 1)
		GameTooltip:Show()
	end)

	local Items = CreateFrame('Frame', nil, self)
	Items:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', -12, -8)
	Items:SetPoint('BOTTOMRIGHT', -8, 8)
	Items:SetBackdrop(containerBackdrop)
	Items:SetBackdropColor(0, 0, 0, 1/2)

	local Boundaries = CreateFrame('Frame', nil, Items)
	Boundaries:SetPoint('TOPLEFT', 8, -8)
	Boundaries:SetPoint('BOTTOMRIGHT', -8, 8)

	local function ItemOnClick(self, button)
		if(button == 'RightButton') then
			local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(self.itemID)
			local dialog = StaticPopup_Show('QUICKQUEST_ITEM_REMOVE', texture, link)
			dialog.data = {
				itemID = self.itemID,
				questID = self.questID,
				button = self
			}
		end
	end

	local function ItemOnEnter(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:SetItemByID(self.itemID)
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(L['Right-click to remove from list'], 0, 1, 0)
		GameTooltip:Show()
	end

	self.UpdateList = function()
		local index = 1
		local width = Boundaries:GetWidth()
		local cols = math.floor((width > 0 and width or 591) / 36)

		for quest, item in next, QuickQuestDB.itemBlacklist do
			local Button = items[item]
			if(not Button) then
				Button = CreateFrame('Button', nil, Items)
				Button:SetSize(34, 34)
				Button:RegisterForClicks('AnyUp')

				local Texture = Button:CreateTexture()
				Texture:SetAllPoints()
				Button.Texture = Texture

				Button:SetScript('OnClick', ItemOnClick)
				Button:SetScript('OnEnter', ItemOnEnter)
				Button:SetScript('OnLeave', GameTooltip_Hide)

				items[item] = Button
			end

			local _, _, _, _, _, _, _, _, _, textureFile = GetItemInfo(item)

			if(textureFile) then
				Button.Texture:SetTexture(textureFile)
			elseif(not queryItems) then
				self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
				queryItems = true
			end

			Button:ClearAllPoints()
			Button:SetPoint('TOPLEFT', Boundaries, (index - 1) % cols * 36, math.floor((index - 1) / cols) * -36)

			Button.questID = quest
			Button.itemID = item

			index = index + 1
		end

		if(not queryItems) then
			self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
		end
	end

	self:UpdateList()

	Items:SetScript('OnMouseUp', function()
		if(CursorHasItem()) then
			local _, itemID, link = GetCursorInfo()

			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					if(GetContainerItemLink(bag, slot) == link) then
						local _, questID = GetContainerItemQuestInfo(bag, slot)
						if(not questID) then
							questID = string.format('progress_%s', itemID)
						end

						if(not QuickQuestDB.itemBlacklist[questID]) then
							QuickQuestDB.itemBlacklist[questID] = itemID
							ClearCursor()

							self:UpdateList()
							return
						end
					end
				end
			end
		end
	end)

	self:SetScript('OnShow', nil)
end)

ItemPanel:HookScript('OnEvent', function(self, event)
	if(event == 'GET_ITEM_INFO_RECEIVED') then
		self:UpdateList()
	end
end)

InterfaceOptions_AddCategory(Panel)
InterfaceOptions_AddCategory(ItemPanel)

SLASH_QuickQuest1 = '/qq'
SLASH_QuickQuest2 = '/quickquest'
SlashCmdList[addonName] = function()
	-- On first load IOF doesn't select the right category or panel, this is a dirty fix
	InterfaceOptionsFrame_OpenToCategory(addonName)
	InterfaceOptionsFrame_OpenToCategory(addonName)
end
