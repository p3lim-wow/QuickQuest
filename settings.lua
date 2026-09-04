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
		key = 'completereward',
		type = 'menu',
		title = L['Automatically choose reward'],
		tooltip = L['Pick the reward and complete the quest.\n\n|cffff0000Warning:|r "%s" will always pick something, even when there is no clear choice']:format(ALWAYS),
		default = 1,
		options = {
			{value=1, label=NEVER},
			{value=2, label=L['Always most valuable']},
			{value=3, label=L['Always for trivial quests']},
			{value=4, label=ALWAYS}
		},
		requires = 'selectreward',
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
		key = 'skipmovies',
		type = 'menu',
		title = L['Skip movies'],
		default = 1,
		options = {
			{value=1, label=NEVER},
			{value=2, label=L['Already seen']},
			{value=3, label=ALWAYS},
		},
	},
	{
		key = 'skipcinematics',
		type = 'menu',
		title = L['Skip cinematics'],
		default = 1,
		options = {
			{value=1, label=NEVER},
			{value=3, label=ALWAYS},
		},
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

		-- 12.0 bonus rolls
		[95279] = true, -- Nebulous Voidcores: Gold
		[95304] = true, -- Nebulous Voidcores: Veteran Dawncrest
		[95290] = true, -- Nebulous Voidcores: Voidlight Marl
	}
}

local createAddButton
do
	local questClassAtlas = {
		[Enum.QuestClassification.Important] = 'UI-QuestPoiImportant-QuestBang',
		[Enum.QuestClassification.Legendary] = 'UI-QuestPoiLegendary-QuestBang',
		[Enum.QuestClassification.Campaign] = 'Quest-Campaign-Available',
		-- [Enum.QuestClassification.Calling] = '',
		[Enum.QuestClassification.Meta] = 'UI-QuestPoiWrapper-QuestBang',
		[Enum.QuestClassification.Recurring] = 'UI-QuestPoiRecurring-QuestBang',
		-- [Enum.QuestClassification.Questline] = '',
		[Enum.QuestClassification.Normal] = 'QuestNormal',
		-- [Enum.QuestClassification.BonusObjective] = '',
		-- [Enum.QuestClassification.Threat] = '',
		-- [Enum.QuestClassification.WorldQuest] = '',
	}

	local dialog
	local dialogMixin = {}
	function dialogMixin:AskItem(title, callback)
		self.title:SetText(title)
		self.editbox:Show()
		self.editbox:SetText('')
		self.editbox:SetNumeric(true)
		self.editbox:SetFocus()
		self.itemLink = nil
		self.acceptButton:SetScript('OnClick', function()
			callback(self.editbox:GetText():trim())
			self:Hide()
		end)
		self.targetButton:Hide()
		self.itemPreview:Show()
		self.questPreview:Hide()
		self:Show()
	end

	function dialogMixin:AskNPC(title, callback)
		self.title:SetText(title)
		self.editbox:Show()
		self.editbox:SetText('')
		self.editbox:SetNumeric(true)
		self.editbox:SetFocus()
		self.acceptButton:SetScript('OnClick', function()
			callback(self.editbox:GetText():trim())
			self:Hide()
		end)
		self.targetButton:Show()
		self.itemPreview:Hide()
		self.questPreview:Hide()
		self:Show()
	end

	function dialogMixin:AskQuest(title, callback)
		self.title:SetText(title)
		self.editbox:Show()
		self.editbox:SetText('')
		self.editbox:SetNumeric(false)
		self.editbox:SetFocus()
		self.acceptButton:SetScript('OnClick', function()
			callback(self.editbox:GetText():trim())
			self:Hide()
		end)
		self.targetButton:Hide()
		self.itemPreview:Hide()
		self.questPreview:Show()
		self:Show()
	end

	local function getDialog()
		if dialog then
			return dialog
		end

		-- can't trust blizzard's implementation because of taint issues

		dialog = Mixin(CreateFrame('Frame', addonName .. 'Dialog', UIParent), dialogMixin)
		dialog:SetPoint('TOP', 0, -135)
		dialog:SetSize(400, 200)
		dialog:SetToplevel(true)
		dialog:SetFrameStrata('DIALOG')
		dialog:Hide()
		dialog:EnableMouse(true) -- avoid click-throughs
		table.insert(UISpecialFrames, dialog:GetName())

		dialog.NineSlice = CreateFrame('Frame', nil, dialog, 'NineSlicePanelTemplate')
		NineSliceUtil.ApplyLayoutByName(dialog.NineSlice, 'Dialog', dialog.NineSlice:GetFrameLayoutTextureKit())

		local bg = dialog:CreateTexture(nil, 'BACKGROUND', nil, -1)
		bg:SetPoint('TOPLEFT', 11, -11)
		bg:SetPoint('BOTTOMRIGHT', -11, 11)
		bg:SetColorTexture(0, 0, 0, 4/5)

		dialog.title = dialog:CreateFontString(nil, nil, 'GameFontHighlight')
		dialog.title:SetPoint('TOP', 0, -28)
		dialog.title:SetPoint('LEFT', 20, 0)
		dialog.title:SetPoint('RIGHT', -20, 0)
		dialog.title:SetJustifyH('CENTER')

		dialog.editbox = CreateFrame('EditBox', nil, dialog, 'InputBoxTemplate')
		dialog.editbox:SetPoint('TOP', dialog.title, 'BOTTOM', 0, -14)
		dialog.editbox:SetSize(200, 30)
		dialog.editbox:SetAutoFocus(false)
		dialog.editbox:SetScript('OnEnterPressed', function()
			dialog.acceptButton:GetScript('OnClick')(dialog.acceptButton)
		end)
		dialog.editbox:SetScript('OnEscapePressed', function()
			dialog:Hide()
		end)

		dialog.itemPreview = addon:CreateFrame('ItemButton', nil, dialog)
		dialog.itemPreview:SetPoint('TOPLEFT', dialog.editbox, 'BOTTOMLEFT', 0, -5)
		dialog.itemPreview:SetSize(37, 37)
		dialog.itemPreview:EnableMouse(false)
		dialog.itemPreview:EnableMouseMotion(true)

		dialog.itemPreview:SetScript('OnLeave', GameTooltip_Hide)
		dialog.itemPreview:SetScript('OnEnter', function(self)
			if dialog.itemLink then
				GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
				GameTooltip:SetHyperlink(dialog.itemLink)
				GameTooltip:Show()
			end
		end)

		local itemBox = dialog.itemPreview:CreateTexture(nil, 'ARTWORK')
		itemBox:SetPoint('LEFT', 30, 1)
		itemBox:SetPoint('TOPRIGHT', dialog.editbox, 'BOTTOMRIGHT', 10, 6)
		itemBox:SetHeight(60)
		itemBox:SetTexture([[Interface\QuestFrame\UI-QuestItemNameFrame]])

		local itemName = dialog.itemPreview:CreateFontString(nil, nil, 'GameFontNormal')
		itemName:SetPoint('LEFT', dialog.itemPreview, 'RIGHT', 8, 0)
		itemName:SetSize(103, 38)

		local lastItemID
		local function updateItemPreview()
			local name, link, quality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(lastItemID)
			if name then
				dialog.itemLink = link
				dialog.itemPreview:SetItemButtonTexture(texture)
				dialog.itemPreview:SetItemButtonQuality(quality, lastItemID)

				local r, g, b = C_Item.GetItemQualityColor(quality)
				itemName:SetText(name)
				itemName:SetTextColor(r, g, b)
			else
				dialog.itemLink = link
				dialog.itemPreview.icon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
				dialog.itemPreview:SetItemButtonQuality()

				itemName:SetText(RETRIEVING_ITEM_INFO)
				itemName:SetTextColor(1, 0.125, 0.125)
			end
		end

		dialog.editbox:SetScript('OnTextChanged', function(self)
			if not dialog.itemPreview:IsShown() then
				return
			end

			local text = self:GetText():trim():match('[0-9]+')
			self:SetText(text or '')

			local itemID = C_Item.GetItemInfoInstant(tonumber(text) or '')
			if itemID then
				lastItemID = itemID
				ItemEventListener:AddCallback(itemID, updateItemPreview)
			else
				dialog.itemLink = nil
				dialog.itemPreview.icon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
				dialog.itemPreview:SetItemButtonQuality()

				itemName:SetText('')
				itemName:SetTextColor(1, 1, 1)
			end
		end)

		dialog.questPreview = CreateFrame('Frame', nil, dialog, 'InputBoxVisualTemplate') -- hack the template
		dialog.questPreview.Left:SetVertexColor(1/2, 1/2, 1/2)
		dialog.questPreview.Right:SetVertexColor(1/2, 1/2, 1/2)
		dialog.questPreview.Middle:SetVertexColor(1/2, 1/2, 1/2)
		dialog.questPreview:SetPoint('TOPLEFT', dialog.editbox, 'BOTTOMLEFT', -45, -5)
		dialog.questPreview:SetPoint('TOPRIGHT', dialog.editbox, 'BOTTOMRIGHT', 45, -5)
		dialog.questPreview:SetHeight(37)

		local questName = dialog.questPreview:CreateFontString(nil, nil, 'GameFontNormal')
		questName:SetAllPoints()
		questName:SetJustifyH('LEFT')
		questName:SetWordWrap(false)
		questName:SetMaxLines(1)

		local lastQuestID
		local function updateQuestPreview()
			if lastQuestID then
				local class = C_QuestInfoSystem.GetQuestClassification(lastQuestID)
				local atlas = questClassAtlas[class or Enum.QuestClassification.Normal]
				local icon = CreateAtlasMarkupWithAtlasSize(atlas)
				local name = C_QuestLog.GetTitleForQuestID(lastQuestID)
				questName:SetFormattedText('%s%s', icon or '', name or '')
			end
		end

		dialog.editbox:HookScript('OnTextChanged', function(self)
			if not dialog.questPreview:IsShown() then
				return
			end

			local questID = tonumber(self:GetText():trim())
			if questID then
				lastQuestID = questID
				QuestEventListener:AddCallback(questID, updateQuestPreview)
			else
				lastQuestID = nil
				questName:SetText('')
			end
		end)

		dialog.targetButton = CreateFrame('Button', nil, dialog, 'UIPanelButtonTemplate')
		dialog.targetButton:SetPoint('TOP', dialog.editbox, 'BOTTOM', -2, 0) -- some weird x-axis offset here to match editbox
		dialog.targetButton:SetText(TARGET)
		dialog.targetButton:SetWidth(208) -- match editbox
		dialog.targetButton:SetScript('OnClick', function()
			local npcID = UnitCreatureID('target')
			if npcID ~= nil and issecretvalue(npcID) then
				npcID = nil
			end

			if npcID then
				dialog.editbox:SetText(npcID)
			end
		end)

		dialog.acceptButton = CreateFrame('Button', nil, dialog, 'UIPanelButtonTemplate')
		dialog.acceptButton:SetPoint('BOTTOMRIGHT', dialog, 'BOTTOM', -5, 18)
		dialog.acceptButton:SetText(ADD)
		dialog.acceptButton:SetWidth(120)

		local cancelButton = CreateFrame('Button', nil, dialog, 'UIPanelButtonTemplate')
		cancelButton:SetPoint('BOTTOMLEFT', dialog, 'BOTTOM', 5, 18)
		cancelButton:SetText(CANCEL)
		cancelButton:SetWidth(120)
		cancelButton:SetScript('OnClick', function()
			dialog:Hide()
		end)

		return dialog
	end

	function createAddButton(parent, title, callback, variant)
		local add = CreateFrame('Button', nil, parent, 'UIPanelButtonTemplate')
		add:SetPoint('TOPRIGHT', -130, 40)
		add:SetSize(96, 22)
		add:SetText(ADD)
		add:SetScript('OnClick', function()
			local dialog = getDialog()
			if variant == 'item' then
				dialog:AskItem(title, callback)
			elseif variant == 'npc' then
				dialog:AskNPC(title, callback)
			elseif variant == 'quest' then
				dialog:AskQuest(title, callback)
			end
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
	end, 'item')
end)

local BACKDROP = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

addon:RegisterSubSettingsCanvas(L['NPC Blocklist'], function(canvas)
	local function setModel(element, npcID)
		element:ClearModel() -- remove any existing models
		element:SetCreature(npcID)

		-- make sure we have the model cached
		local ticker
		local attempts = 0
		ticker = C_Timer.NewTimer(0.25, function()
			if element:GetModelFileID() or not element:IsVisible() or attempts > 10 then
				ticker:Cancel()
			else
				element:SetCreature(npcID)
				attempts = attempts + 1
			end
		end)
	end

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
		setModel(element.model, data)
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
		GameTooltip:AddLine(addon:GetCreatureName(element.data) or UNKNOWN, 1, 1, 1)
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
	end, 'npc')
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
	end, 'quest')
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
end
