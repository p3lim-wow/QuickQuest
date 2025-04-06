local addonName, addon = ...
local L = addon.L

addon:RegisterSettings('QuickQuestDB3', {
	{
		key = 'accept',
		type = 'menu',
		title = L['Automate quests'],
		tooltip = L['When "%s" is selected %s will only be automated while tracking them']:format(ACCOUNT_QUEST_LABEL, MINIMAP_TRACKING_ACCOUNT_COMPLETED_QUESTS:lower()),
		default = 3,
		options = {
			{value=1, label=NEVER},
			{value=2, label=ACCOUNT_QUEST_LABEL},
			{value=3, label=ALWAYS},
		},
	},
	{
		key = 'acceptRepeatables',
		type = 'menu',
		title = L['Automate repeatable quests'],
		tooltip = L['When "%s" is selected %s will only be automated while tracking them']:format(ACCOUNT_QUEST_LABEL, MINIMAP_TRACKING_ACCOUNT_COMPLETED_QUESTS:lower()),
		default = 3,
		options = {
			{value=1, label=NEVER},
			{value=2, label=ACCOUNT_QUEST_LABEL},
			{value=3, label=ALWAYS},
		},
	},
	{
		key = 'selectreward',
		type = 'toggle',
		title = L['Highlight valuable reward'],
		default = true,
	},
	{
		key = 'share',
		type = 'toggle',
		title = L['Automatically share quests'],
		default = false,
	},
	{
		key = 'autoquestgossip',
		type = 'toggle',
		title = L['Skip quest gossip options'],
		default = true,
	},
	{
		key = 'skipgossip',
		type = 'toggle',
		title = L['Automate gossip options'],
		default = true,
	},
	{
		key = 'skipgossipwhen',
		type = 'menu',
		title = L['When to automate gossip'],
		default = 2,
		options = {
			{value=1, label=NEVER},
			{value=2, label=L['Soloing']},
			{value=3, label=ALWAYS},
		},
		requires = 'skipgossip',
	},
	{
		key = 'paydarkmoonfaire',
		type = 'toggle',
		title = L['Pay Darkmoon Faire teleport'],
		default = true,
	},
	{
		key = 'pausekey',
		type = 'menu',
		title = L['Pause mode modifier'],
		tooltip = L['Hold this key to temporarily disable all automation'],
		default = 'SHIFT',
		options = {
			{value='ALT', label=ALT_KEY},
			{value='CTRL', label=CTRL_KEY},
			{value='SHIFT', label=SHIFT_KEY},
		},
	},
	{
		key = 'pausekeyreverse',
		type = 'toggle',
		title = L['Reverse pause mode'],
		tooltip = L["While the pause key is NOT held don't automate anything"],
		default = false,
		parent = 'pausekey'
	},
})

addon:RegisterSettingsSlash('/quickquest', '/qq')

-- the rest of this file is just blocklist options

local blocklistDefaults = {
	items = {
		-- Tiller Gifts
		[79264] = true, -- Ruby Shard
		[79265] = true, -- Blue Feather
		[79266] = true, -- Jade Cat
		[79267] = true, -- Lovely Apple
		[79268] = true, -- Marsh Lily

		-- Misc
		[88604] = true, -- Nat's Fishing Journal
	},
	npcs = {
		-- accidental resource waste
		[87391] = true, -- Fate-Twister Seress (gold, currencies)
		[88570] = true, -- Fate-Twister Tiklal (gold, currencies)
		[78495] = true, -- Shadow Hunter Ukambe (garrison missives)
		[81152] = true, -- Scout Valdez (garrison missives)
		[111243] = true, -- Archmage Lan'dalock (gold, currencies)
		[141584] = true, -- Zurvan (gold, currencies)
		[142063] = true, -- Tezran (gold, currencies)
		[193110] = true, -- Khadin (Dragon Shard of Knowledge)

		-- Sassy Imps
		[95139] = true,
		[95141] = true,
		[95142] = true,
		[95143] = true,
		[95144] = true,
		[95145] = true,
		[95146] = true,
		[95200] = true,
		[95201] = true,

		-- Teleportation
		[143925] = true, -- Dark Iron Mole Machine (Dark Iron Dwarf racial)
		[121602] = true, -- Manapoof in Dalaran
		[147666] = true, -- Manapoof in Boralus
		[147642] = true, -- Manapoof in Dazar'alor
	},
	quests = {
		-- 7.0 valuable resources
		[48634] = true, -- Further Supplying Krokuun
		[48635] = true, -- More Void Inoculation
		[48799] = true, -- Fuel for a Doomed World
		[48910] = true, -- Supplying Krokuun
		[48911] = true, -- Void Inoculation

		-- 8.0 emissaries
		[54451] = true, -- Baubles from the Seekers
		[53982] = true, -- Supplies From The Unshackled
		[54453] = true, -- Supplies from Magni
		[54454] = true, -- Supplies from 7th Legion
		[54455] = true, -- Supplies from Honorbound
		[54456] = true, -- Supplies from Order of Embers
		[54457] = true, -- Supplies from Storm Wake
		[54458] = true, -- Supplies from Proudmoore Admiralty
		[54460] = true, -- Supplies from Talanji's Expedition
		[54461] = true, -- Supplies from Voldunai Supplies
		[54462] = true, -- Supplies from Zandalari Empire
		[55348] = true, -- Supplies from the Rustbolt Resistance
		[55976] = true, -- Supplies From the Waveblade Ankoan

		-- 9.0 valuable resources
		[64541] = true, -- The Cost of Death (Ve'nari)

		-- 10.0 valuable resources
		[75164] = true, -- In Need of Primal Foci
		[75165] = true, -- In Need of Concentrated Primal Foci
		[75166] = true, -- In Need of Many Primal Foci
		[75167] = true, -- In Need of Many Concentrated Primal Foci
	}
}

local createAddButton
do
	StaticPopupDialogs[addonName .. 'BlocklistPopup'] = {
		button1 = ADD,
		button2 = CANCEL,
		hasEditBox = true,
		EditBoxOnEnterPressed = function(editBox, data)
			data.callback(editBox:GetText():trim())
			editBox:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function(editBox)
			editBox:GetParent():Hide()
		end,
		OnAccept = function(self)
			self.data.callback(self.editBox:GetText():trim())
		end,
		OnShow = function(self)
			self.editBox:SetFocus()
		end,
		OnHide = function(self)
			self.editBox:SetText('')
		end,
		hideOnEscape = true,
		timeout = 0,
	}

	StaticPopupDialogs[addonName .. 'BlocklistItemPopup'] = CopyTable(StaticPopupDialogs[addonName .. 'BlocklistPopup'])
	StaticPopupDialogs[addonName .. 'BlocklistItemPopup'].hasItemFrame = true
	StaticPopupDialogs[addonName .. 'BlocklistItemPopup'].OnShow = function(self)
		self.editBox:SetNumeric(true)
		self.editBox:SetFocus()
		self.editBox:ClearAllPoints()
		self.editBox:SetPoint('BOTTOM', 0, 100) -- fix pos, it's fucked by default for some reason
	end
	StaticPopupDialogs[addonName .. 'BlocklistItemPopup'].EditBoxOnTextChanged = function(editBox)
		local self = editBox:GetParent()
		local text = editBox:GetText():trim():match('[0-9]+')
		editBox:SetText(text or '')

		local itemID = C_Item.GetItemInfoInstant(tonumber(text) or '')
		if itemID then
			self.data = self.data or {}
			self.data.link = '|Hitem:' .. itemID .. '|h'
			self.ItemFrame:RetrieveInfo(self.data)
			self.ItemFrame:DisplayInfo(self.data.link, self.data.name, self.data.color, self.data.texture)
		else
			self.ItemFrame:DisplayInfo(nil, ERR_SOULBIND_INVALID_CONDUIT_ITEM, nil, [[Interface\Icons\INV_Misc_QuestionMark]])
		end
	end

	StaticPopupDialogs[addonName .. 'BlocklistTargetPopup'] = CopyTable(StaticPopupDialogs[addonName .. 'BlocklistPopup'])
	StaticPopupDialogs[addonName .. 'BlocklistTargetPopup'].button3 = TARGET
	StaticPopupDialogs[addonName .. 'BlocklistTargetPopup'].OnShow = function(self)
		self.editBox:SetNumeric(true)
		self.editBox:SetFocus()
	end
	StaticPopupDialogs[addonName .. 'BlocklistTargetPopup'].OnAlt = function(self)
		local id = addon:GetUnitID('target')
		if id then
			self.data.callback(id)
		end
	end

	function createAddButton(parent, title, callback, variant)
		local add = CreateFrame('Button', nil, parent, 'UIPanelButtonTemplate')
		add:SetPoint('TOPRIGHT', -130, 40)
		add:SetSize(96, 22)
		add:SetText(ADD)
		add:SetScript('OnClick', function()
			local popupName = addonName .. 'Blocklist' .. (variant or '') .. 'Popup'
			local popup = StaticPopupDialogs[popupName]
			popup.text = title

			StaticPopup_Show(popupName, nil, nil, {
				callback = callback,
			})
		end)
	end
end

local CURSOR_HELP_TEXT = string.format('|A:NPE_RightClick:18:18|a %s', REMOVE)
addon:RegisterSubSettingsCanvas(L['Item Blocklist'], function(canvas)
	local grid = addon:CreateScrollGrid(canvas)
	grid:SetInsets(10, 10, 10, 20)
	grid:SetElementType('Button')
	grid:SetElementSize(40)
	grid:SetElementSpacing(4)
	grid:SetElementOnLoad(function(element)
		element:RegisterForClicks('RightButtonUp')

		element.texture = element:CreateTexture(nil, 'BORDER')
		element.texture:SetAllPoints()

		local mask = element:CreateMaskTexture()
		mask:SetPoint('CENTER')
		mask:SetSize(54, 54)
		mask:SetTexture([[Interface\HUD\UIActionBarIconFrameMask]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		element.texture:AddMaskTexture(mask)

		local border = element:CreateTexture(nil, 'ARTWORK')
		border:SetPoint('TOPLEFT')
		border:SetSize(42, 41)
		border:SetAtlas('UI-HUD-ActionBar-IconFrame')
	end)
	grid:SetElementOnUpdate(function(element, data)
		local item = Item:CreateFromItemID(data)
		if item:IsItemDataCached() then
			element.texture:SetTexture(item:GetItemIcon())
		else
			item:ContinueOnItemLoad(function()
				element.texture:SetTexture(item:GetItemIcon())
			end)
		end
	end)
	grid:SetElementOnScript('OnClick', function(element)
		QuickQuestBlocklistDB.items[element.data] = false
		grid:RemoveData(element.data)
	end)
	grid:SetElementOnScript('OnEnter', function(element)
		GameTooltip:SetOwner(element, 'ANCHOR_TOPLEFT') -- TODO
		GameTooltip:SetItemByID(element.data)
		GameTooltip:AddLine(CURSOR_HELP_TEXT, 1, 0, 0)
		GameTooltip:Show()
	end)
	grid:AddDataByKeys(QuickQuestBlocklistDB.items)

	canvas:SetDefaultsHandler(function()
		QuickQuestBlocklistDB.items = CopyTable(blocklistDefaults.items)
		grid:ResetData()
		grid:AddDataByKeys(QuickQuestBlocklistDB.items)
	end)

	createAddButton(canvas, L['Block a new item by ID'], function(data)
		QuickQuestBlocklistDB.items[tonumber(data)] = true
		grid:AddData(tonumber(data))
	end, 'Item')
end)

local BACKDROP = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

addon:RegisterSubSettingsCanvas(L['NPC Blocklist'], function(canvas)
	local grid = addon:CreateScrollGrid(canvas)
	grid:SetInsets(10, 10, 10, 20)
	grid:SetElementType('Button')
	grid:SetElementSize(64)
	grid:SetElementSpacing(4)
	grid:SetElementOnLoad(function(element)
		element:RegisterForClicks('RightButtonUp')

		element.model = CreateFrame('PlayerModel', nil, element)
		element.model:SetPoint('TOPLEFT', 4, -4)
		element.model:SetPoint('BOTTOMRIGHT', -4, 4)

		Mixin(element, BackdropTemplateMixin)
		element:SetBackdrop(BACKDROP)
		element:SetBackdropColor(0, 7/255, 34/255, 1)
		element:SetBackdropBorderColor(0.5, 0.5, 0.5)
	end)
	grid:SetElementOnUpdate(function(element, data)
		element.model:SetCreature(data)
	end)
	grid:SetElementOnReset(function(element)
		element.model:ClearModel()
	end)
	grid:SetElementOnScript('OnClick', function(element)
		QuickQuestBlocklistDB.npcs[element.data] = false
		grid:RemoveData(element.data)
	end)
	grid:SetElementOnScript('OnEnter', function(element)
		GameTooltip:SetOwner(element, 'ANCHOR_TOPLEFT') -- TODO
		GameTooltip:AddLine(addon:GetNPCName(element.data) or UNKNOWN, 1, 1, 1)
		GameTooltip:AddLine(ID .. ': ' .. element.data)
		GameTooltip:AddLine(CURSOR_HELP_TEXT, 1, 0, 0)
		GameTooltip:Show()
	end)
	grid:AddDataByKeys(QuickQuestBlocklistDB.npcs)

	canvas:SetDefaultsHandler(function()
		QuickQuestBlocklistDB.npcs = CopyTable(blocklistDefaults.npcs)
		grid:ResetData()
		grid:AddDataByKeys(QuickQuestBlocklistDB.npcs)
	end)

	createAddButton(canvas, L['Block a new NPC by ID or target'], function(data)
		QuickQuestBlocklistDB.npcs[tonumber(data)] = true
		grid:AddData(tonumber(data))
	end, 'Target')
end)

addon:RegisterSubSettingsCanvas(L['Quest Blocklist'], function(canvas)
	local list = addon:CreateScrollList(canvas)
	list:SetInsets(nil, nil, 10, 20)
	list:SetElementType('Button')
	list:SetElementHeight(30)
	list:SetElementOnLoad(function(element)
		element:RegisterForClicks('RightButtonUp')

		element.text = element:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		element.text:SetPoint('LEFT', 10, 0)

		local highlight = element:CreateTexture(nil, 'HIGHLIGHT')
		highlight:SetPoint('TOPLEFT', 3.5, -3.5)
		highlight:SetPoint('BOTTOMRIGHT', -3.5, 3.5)
		highlight:SetColorTexture(1, 1, 0, 0.1)

		local mask = element:CreateMaskTexture()
		mask:SetPoint('CENTER')
		mask:SetSize(1218, 35)
		mask:SetTexture([[Interface\HUD\UIActionBarIconFrameMask]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		highlight:AddMaskTexture(mask)

		Mixin(element, BackdropTemplateMixin)
		element:SetBackdrop(BACKDROP)
		element:SetBackdropColor(0, 0, 0, 0.5)
		element:SetBackdropBorderColor(0.5, 0.5, 0.5)
	end)
	list:SetElementOnUpdate(function(element, data)
		element.text:SetText(data)

		if tonumber(data) then
			local questInfo = QuestCache:Get(data)
			if questInfo.title == '' then
				QuestEventListener:AddCallback(data, function()
					element.text:SetFormattedText('%d (%s)', data, QuestCache:Get(data).title)
				end)
			else
				element.text:SetFormattedText('%d (%s)', data, QuestCache:Get(data).title)
			end
		end
	end)
	list:SetElementOnScript('OnClick', function(element)
		QuickQuestBlocklistDB.quests[element.data] = false
		list:RemoveData(element.data)
	end)
	list:SetElementOnScript('OnEnter', function(element)
		GameTooltip:SetOwner(element, 'ANCHOR_TOPLEFT') -- TODO
		GameTooltip:AddLine(CURSOR_HELP_TEXT, 1, 0, 0)
		GameTooltip:Show()
	end)
	list:AddDataByKeys(QuickQuestBlocklistDB.quests)

	canvas:SetDefaultsHandler(function()
		QuickQuestBlocklistDB.quests = CopyTable(blocklistDefaults.quests)
		list:ResetData()
		list:AddDataByKeys(QuickQuestBlocklistDB.quests)
	end)

	createAddButton(canvas, L['Block a quest by title or ID'], function(data)
		data = tonumber(data) or data

		QuickQuestBlocklistDB.quests[data] = true
		list:AddData(data)
	end)
end)

function addon:OnLoad()
	if not QuickQuestBlocklistDB then
		-- set default
		QuickQuestBlocklistDB = CopyTable(blocklistDefaults)
	end

	-- inject new blocklist defaults
	for kind, values in next, blocklistDefaults do
		for key, value in next, values do
			if QuickQuestBlocklistDB[kind][key] == nil then
				QuickQuestBlocklistDB[kind][key] = value
			end
		end
	end

	-- migrate old settings
	-- TODO: remove this in 12.x
	if QuickQuestDB2 and QuickQuestDB2.profiles and QuickQuestDB2.profiles.Default then
		-- I never implemented profiles so everything will be in the default profile
		if QuickQuestDB2.profiles.Default.general then
			for key, value in next, QuickQuestDB2.profiles.Default.general do
				if key == 'skipgossipwhen' then
					value = value + 1
				end
				if QuickQuestDB3[key] ~= nil then
					addon:SetOption(key, value)
					addon:Printf("migrated setting '%s' from old savedvariables", key)
				end
			end
		end
		if QuickQuestDB2.profiles.Default.blocklist then
			local oldBlocklistDefaults = {
				items = {
					[79343] = true,
					[79340] = true,
					[79341] = true,
					[71635] = true,
					[71636] = true,
					[71637] = true,
					[71638] = true,
					[71715] = true,
					[71951] = true,
					[71952] = true,
					[71953] = true,
					[71716] = true,
					[79264] = true,
					[79265] = true,
					[79266] = true,
					[79267] = true,
					[79268] = true,
					[122424] = true,
					[122423] = true,
					[122418] = true,
					[122417] = true,
					[122400] = true,
					[122404] = true,
					[122420] = true,
					[122419] = true,
					[122402] = true,
					[122406] = true,
					[122413] = true,
					[122414] = true,
					[122403] = true,
					[122399] = true,
					[122421] = true,
					[122422] = true,
					[122411] = true,
					[122409] = true,
					[122412] = true,
					[122410] = true,
					[122408] = true,
					[122407] = true,
					[122416] = true,
					[122415] = true,
					[122405] = true,
					[122401] = true,
					[88604] = true,
				},
				npcs = {
					[103792] = true,
					[143925] = true,
					[86945] = true,
					[86933] = true,
					[86927] = true,
					[86934] = true,
					[86682] = true,
					[86964] = true,
					[86946] = true,
					[95139] = true,
					[95141] = true,
					[95142] = true,
					[95143] = true,
					[95144] = true,
					[95145] = true,
					[95146] = true,
					[95200] = true,
					[95201] = true,
					[121602] = true,
					[147666] = true,
					[147642] = true,
				},
				quests = {
					[36054] = true,
					[37454] = true,
					[37455] = true,
					[36055] = true,
					[37452] = true,
					[37453] = true,
					[36056] = true,
					[37456] = true,
					[37457] = true,
					[36057] = true,
					[43892] = true,
					[43893] = true,
					[43894] = true,
					[43895] = true,
					[43896] = true,
					[43897] = true,
					[47851] = true,
					[47864] = true,
					[47865] = true,
					[52834] = true,
					[52838] = true,
					[52835] = true,
					[52839] = true,
					[52837] = true,
					[52840] = true,
					[48910] = true,
					[48634] = true,
					[48911] = true,
					[48635] = true,
					[48799] = true,
					[54451] = true,
					[53982] = true,
					[54453] = true,
					[54454] = true,
					[54455] = true,
					[54456] = true,
					[54457] = true,
					[54458] = true,
					[54460] = true,
					[54461] = true,
					[54462] = true,
					[55348] = true,
					[55976] = true,
					[64541] = true,
					[70183] = true,
					[70184] = true,
					[70186] = true,
					[70187] = true,
					[70190] = true,
					[70188] = true,
					[70189] = true,
					[70191] = true,
					[70192] = true,
					[70193] = true,
					[70194] = true,
					[75164] = true,
					[75165] = true,
					[75166] = true,
					[75167] = true,
				},
			}

			for kind, values in next, QuickQuestDB2.profiles.Default.blocklist do
				for key, value in next, values do
					if value == false then
						-- user disabled this previously, check if it exists in the new settings and disable it there too
						if QuickQuestBlocklistDB[kind][key] ~= nil then
							QuickQuestBlocklistDB[kind][key] = value
							addon:Printf("migrated blocklist item '%s.%s' from old savedvariables", kind, key)
						end
					else
						-- if it used to be a default that is no longer there then ignore it
						if oldBlocklistDefaults[kind][key] and not blocklistDefaults[kind][key] then
							-- ignore it
						else
							QuickQuestBlocklistDB[kind][key] = value
							addon:Printf("migrated blocklist item '%s.%s' from old savedvariables", kind, key)
						end
					end
				end
			end
		end
	end
	QuickQuestDB2 = nil

	if QuickQuestDB3 and QuickQuestDB3.accept ~= nil and type(QuickQuestDB3.accept) == 'boolean' then
		QuickQuestDB3.accept = QuickQuestDB3.accept and 3 or 1
	end
	if QuickQuestDB3 and QuickQuestDB3.acceptRepeatables ~= nil and type(QuickQuestDB3.acceptRepeatables) == 'boolean' then
		QuickQuestDB3.acceptRepeatables = QuickQuestDB3.acceptRepeatables and 3 or 1
	end
end
