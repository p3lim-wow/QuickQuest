local addonName = ...

local buttons = {}
local temporary = {}

local defaults = {
	toggle = true,
	items = true,
	faireport = true,
	gossip = true,
	gossipraid = true,
	modifier = 'SHIFT',
	reverse = false,
	ignoredQuests = {
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

		-- Misc
		[31664] = 88604, -- Nat's Fishing Journal
	}
}

local Panel = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
Panel.name = addonName
Panel:Hide()

Panel:RegisterEvent('PLAYER_LOGIN')
Panel:SetScript('OnEvent', function()
	MonomythDB = MonomythDB or defaults

	for key, value in pairs(defaults) do
		if(MonomythDB[key] == nil) then
			MonomythDB[key] = value
		end
	end
end)

local UpdateFilterBox

function Panel:okay()
	for key, value in pairs(temporary) do
		MonomythDB[key] = value
	end
end

function Panel:cancel()
	table.wipe(temporary)
end

function Panel:default()
	MonomythDB = defaults
	table.wipe(temporary)
end

function Panel:refresh()
	for key, button in pairs(buttons) do
		if(button:IsObjectType('CheckButton')) then
			button:SetChecked(MonomythDB[key])
		elseif(button:IsObjectType('Button')) then
			UIDropDownMenu_SetSelectedValue(button, MonomythDB[key])

			-- This is for some reason needed, gotta take a look into it later
			UIDropDownMenu_SetText(button, _G[MonomythDB[key] .. '_KEY'])
		end
	end

	UpdateFilterBox()
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

	function CreateCheckButton(parent, key)
		local CheckButton = CreateFrame('CheckButton', nil, parent, 'InterfaceOptionsCheckButtonTemplate')
		CheckButton:SetHitRectInsets(0, 0, 0, 0)
		CheckButton:SetScript('OnClick', ClickCheckButton)
		CheckButton.key = key

		buttons[key] = CheckButton

		return CheckButton
	end
end

local CreateDropdown
do
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(self:GetParent().dropdown, self.value)
		temporary[self:GetParent().dropdown.key] = self.value
	end

	function CreateDropdown(parent, key, func)
		local Dropdown = CreateFrame('Button', 'MonomythDropDown_' .. GetTime(), parent, 'UIDropDownMenuTemplate')
		Dropdown.OnClick = OnClick
		Dropdown.key = key

		UIDropDownMenu_SetWidth(Dropdown, 90)
		UIDropDownMenu_SetSelectedValue(Dropdown, MonomythDB[key])
		UIDropDownMenu_Initialize(Dropdown, func)

		local Text = Dropdown:CreateFontString(nil, nil, 'GameFontHighlight')
		Text:SetPoint('LEFT', Dropdown, 'RIGHT', -1, 2)
		Dropdown.Text = Text

		buttons[key] = Dropdown

		return Dropdown
	end
end

local filterBackdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], tile = true, tileSize = 16,
	edgeFile = [=[Interface\Tooltips\UI-Tooltip-Border]=], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

local function FilterDetailsOnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
	GameTooltip:AddLine('Easily add more items to filter by\ngrabbing one from your inventory\nand dropping it into the box below.\n\nJust as easily you remove an existing\nitem by right-clicking on it.', 1, 1, 1)
	GameTooltip:Show()
end

local function FilterItemOnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
	GameTooltip:SetItemByID(self.itemID)
end

local filterItems = {}

StaticPopupDialogs.MONOMYTH_FILTER = {
	text = 'Are you sure you want to delete |T%s:16|t%s from the filter?',
	button1 = 'Yes',
	button2 = 'No',
	OnAccept = function(self, data)
		MonomythDB.ignoredQuests[data.questID] = nil
		filterItems[data.itemID] = nil
		data.button:Hide()

		UpdateFilterBox()
	end,
	timeout = 0,
	hideOnEscape = true,
	preferredIndex = 3, -- Avoid some taint
}

Panel:SetScript('OnShow', function(self)
	local Title = self:CreateFontString(nil, nil, 'GameFontNormalLarge')
	Title:SetPoint('TOPLEFT', 16, -16)
	Title:SetText(addonName)

	local Description = self:CreateFontString(nil, nil, 'GameFontHighlightSmall')
	Description:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -8)
	Description:SetPoint('RIGHT', -32, 0)
	Description:SetJustifyH('LEFT')
	Description:SetText('Less clicking, more action!')
	self.Description = Description

	local Toggle = CreateCheckButton(self, 'toggle')
	Toggle:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', -2, -10)
	Toggle.Text:SetText('Enable automating')

	local Items = CreateCheckButton(self, 'items')
	Items:SetPoint('TOPLEFT', Toggle, 'BOTTOMLEFT', 0, -8)
	Items.Text:SetText('Automaticly start quests from items')

	local Gossip = CreateCheckButton(self, 'gossip')
	Gossip:SetPoint('TOPLEFT', Items, 'BOTTOMLEFT', 0, -8)
	Gossip.Text:SetText('Automaticly select gossip option if there is only one')

	local GossipRaid = CreateCheckButton(self, 'gossipraid')
	GossipRaid:SetPoint('TOPLEFT', Gossip, 'BOTTOMLEFT', 24, -8)
	GossipRaid.Text:SetText('Only select gossip option while not in a raid')

	Gossip:HookScript('OnClick', function(self)
		if(self:GetChecked()) then
			GossipRaid:Enable()
			GossipRaid.Text:SetTextColor(1, 1, 1)
		else
			GossipRaid:Disable()
			GossipRaid.Text:SetTextColor(1/3, 1/3, 1/3)
		end
	end)

	if(MonomythDB.gossip) then
		GossipRaid:Enable()
		GossipRaid.Text:SetTextColor(1, 1, 1)
	else
		GossipRaid:Disable()
		GossipRaid.Text:SetTextColor(1/3, 1/3, 1/3)
	end

	local Darkmoon = CreateCheckButton(self, 'faireport')
	Darkmoon:SetPoint('TOPLEFT', GossipRaid, 'BOTTOMLEFT', -24, -8)
	Darkmoon.Text:SetText('Darkmoon Faire: Automaticly teleport')

	local Reverse = CreateCheckButton(self, 'reverse')
	Reverse:SetPoint('TOPLEFT', Darkmoon, 'BOTTOMLEFT', 0, -8)
	Reverse.Text:SetText('Reverse the behaviour of the modifier key')

	local Modifier = CreateDropdown(self, 'modifier', function(self)
		local selected = UIDropDownMenu_GetSelectedValue(self)
		local info = UIDropDownMenu_CreateInfo()
		info.text = ALT_KEY
		info.value = 'ALT'
		info.func = self.OnClick
		info.checked = selected == info.value
		UIDropDownMenu_AddButton(info)

		info.text = CTRL_KEY
		info.value = 'CTRL'
		info.func = self.OnClick
		info.checked = selected == info.value
		UIDropDownMenu_AddButton(info)

		info.text = SHIFT_KEY
		info.value = 'SHIFT'
		info.func = self.OnClick
		info.checked = selected == info.value
		UIDropDownMenu_AddButton(info)
	end)
	Modifier:SetPoint('TOPLEFT', Reverse, 'BOTTOMLEFT', -13, -14)

	if(MonomythDB.reverse) then
		Modifier.Text:SetText('Modifier to temporarly enable automation')
	else
		Modifier.Text:SetText('Modifier to temporarly disable automation')
	end

	Reverse:HookScript('OnClick', function(self)
		if(self:GetChecked()) then
			Modifier.Text:SetText('Modifier to temporarly enable automation')
		else
			Modifier.Text:SetText('Modifier to temporarly disable automation')
		end
	end)

	local FilterText = self:CreateFontString(nil, nil, 'GameFontHighlight')
	FilterText:SetPoint('TOPLEFT', Modifier, 'BOTTOMLEFT', 18, -30)
	FilterText:SetText('Items filtered from automization')

	local FilterDetails = CreateFrame('Button', nil, self)
	FilterDetails:SetPoint('LEFT', FilterText, 'RIGHT')
	FilterDetails:SetNormalTexture([=[Interface\GossipFrame\ActiveQuestIcon]=])
	FilterDetails:SetSize(16, 16)

	FilterDetails:SetScript('OnEnter', FilterDetailsOnEnter)
	FilterDetails:SetScript('OnLeave', GameTooltip_Hide)

	local FilterBox = CreateFrame('Frame', nil, self)
	FilterBox:SetPoint('TOPLEFT', FilterText, 'BOTTOMLEFT', -12, -8)
	FilterBox:SetPoint('BOTTOMRIGHT', -8, 8)
	FilterBox:SetBackdrop(filterBackdrop)
	FilterBox:SetBackdropColor(0, 0, 0, 1/2)

	local FilterBounds = CreateFrame('Frame', nil, FilterBox)
	FilterBounds:SetPoint('TOPLEFT', 8, -8)
	FilterBounds:SetPoint('BOTTOMRIGHT', -8, 8)

	local function FilterItemOnClick(self, button)
		if(button == 'RightButton') then
			local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(self.itemID)
			local dialog = StaticPopup_Show('MONOMYTH_FILTER', texture, link)
			dialog.data = {
				itemID = self.itemID,
				questID = self.questID,
				button = self
			}
		end
	end

	function UpdateFilterBox()
		for quest, item in pairs(MonomythDB.ignoredQuests) do
			if(not filterItems[item]) then
				local Button = CreateFrame('Button', nil, FilterBox)
				Button:SetSize(34, 34)
				Button:RegisterForClicks('AnyUp')

				local Texture = Button:CreateTexture(nil, 'ARTWORK')
				Texture:SetAllPoints()
				Texture:SetTexture(select(10, GetItemInfo(item)))

				Button:SetScript('OnClick', FilterItemOnClick)
				Button:SetScript('OnEnter', FilterItemOnEnter)
				Button:SetScript('OnLeave', GameTooltip_Hide)

				Button.questID = quest
				Button.itemID = item

				filterItems[item] = Button
			end
		end

		local index = 1
		local cols = math.floor(FilterBounds:GetWidth() / 36)

		for item, button in pairs(filterItems) do
			button:ClearAllPoints()
			button:SetPoint('TOPLEFT', FilterBounds, (index - 1) % cols * 36, math.floor((index - 1) / cols) * -36)

			index = index + 1
		end
	end

	UpdateFilterBox()

	FilterBox:SetScript('OnMouseUp', function()
		if(CursorHasItem()) then
			local _, itemID, link = GetCursorInfo()

			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					if(GetContainerItemLink(bag, slot) == link) then
						local _, questID = GetContainerItemQuestInfo(bag, slot)
						if(questID) then
							MonomythDB.ignoredQuests[questID] = itemID
							ClearCursor()

							UpdateFilterBox()
							return
						end
					end
				end
			end
		end
	end)

	self:SetScript('OnShow', nil)
end)

InterfaceOptions_AddCategory(Panel)

SLASH_Monomyth1 = '/monomyth'
SlashCmdList[addonName] = function()
	InterfaceOptionsFrame_OpenToCategory(addonName)
end
