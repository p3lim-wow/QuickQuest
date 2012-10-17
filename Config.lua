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
	Modifier.Text:SetText('Modifier to temporarly disable automation')

	Reverse:HookScript('OnClick', function(self)
		if(self:GetChecked()) then
			Modifier.Text:SetText('Modifier to temporarly enable automation')
		else
			Modifier.Text:SetText('Modifier to temporarly disable automation')
		end
	end)

	self:SetScript('OnShow', nil)
end)

InterfaceOptions_AddCategory(Panel)

SLASH_Monomyth1 = '/monomyth'
SlashCmdList[addonName] = function()
	InterfaceOptionsFrame_OpenToCategory(addonName)
end
