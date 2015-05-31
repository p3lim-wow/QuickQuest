local addonName, L = ...
local defaults = {
	items = true,
	faireport = true,
	gossip = true,
	gossipraid = 1,
	modifier = 'SHIFT',
	reverse = false,
	share = false,
}

local Options = LibStub('Wasabi'):New(addonName, 'QuickQuestDB', defaults)
Options:AddSlash('/qq')
Options:AddSlash('/quickquest')
Options:Initialize(function(self)
	local Title = self:CreateTitle()
	Title:SetPoint('TOPLEFT', 16, -16)
	Title:SetText(addonName)

	local Items = self:CreateCheckButton('items')
	Items:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -8)
	Items:SetText(L['Automatically start quests from items'])

	local Share = self:CreateCheckButton('share')
	Share:SetPoint('TOPLEFT', Items, 'BOTTOMLEFT', 0, -8)
	Share:SetText(L['Automatically share quests when picked up'])
	Share:SetNewFeature(true)

	local Gossip = self:CreateCheckButton('gossip')
	Gossip:SetPoint('TOPLEFT', Share, 'BOTTOMLEFT', 0, -8)
	Gossip:SetText(L['Automatically select single gossip options'])

	local GossipRaid = self:CreateDropDown('gossipraid')
	GossipRaid:SetPoint('TOPLEFT', Gossip, 'BOTTOMLEFT', 24, -10)
	GossipRaid:SetText(L['When to select gossip while in a raid'])
	GossipRaid:SetValues({
		[0] = L['Never'],
		[1] = L['Soloing'],
		[2] = L['Always']
	})

	Gossip:On('Update', 'Click', function(self)
		GossipRaid:SetEnabled(self:GetChecked())
	end)

	local Darkmoon = self:CreateCheckButton('faireport')
	Darkmoon:SetPoint('TOPLEFT', GossipRaid, 'BOTTOMLEFT', -24, -8)
	Darkmoon:SetText(L['Automatically pay Darkmoon Faire teleporting fees'])

	local Modifier = self:CreateDropDown('modifier')
	Modifier:SetPoint('TOPLEFT', Darkmoon, 'BOTTOMLEFT', 0, -14)
	Modifier:SetValues({
		ALT = L['ALT key'],
		CTRL = L['CTRL key'],
		SHIFT = L['SHIFT key']
	})

	local Reverse = self:CreateCheckButton('reverse')
	Reverse:SetPoint('TOPLEFT', Modifier, 'BOTTOMLEFT', 24, -8)
	Reverse:SetText(L['Reverse the behaviour of the modifier key'])
	Reverse:On('Update', 'Click', function(self)
		if(Reverse:GetChecked()) then
			Modifier:SetText(L['Hold this key to to temporarily disable automation'])
		else
			Modifier:SetText(L['Hold this key to to temporarily enable automation'])
		end
	end)
end)

local defaultBlacklist = {
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

	-- Garrison scouting missives
	[38180] = 122424, -- Scouting Missive: Broken Precipice
	[38193] = 122423, -- Scouting Missive: Broken Precipice
	[38182] = 122418, -- Scouting Missive: Darktide Roost
	[38196] = 122417, -- Scouting Missive: Darktide Roost
	[38179] = 122400, -- Scouting Missive: Everbloom Wilds
	[38192] = 122404, -- Scouting Missive: Everbloom Wilds
	[38194] = 122420, -- Scouting Missive: Gorian Proving Grounds
	[38202] = 122419, -- Scouting Missive: Gorian Proving Grounds
	[38178] = 122402, -- Scouting Missive: Iron Siegeworks
	[38191] = 122406, -- Scouting Missive: Iron Siegeworks
	[38184] = 122413, -- Scouting Missive: Lost Veil Anzu
	[38198] = 122414, -- Scouting Missive: Lost Veil Anzu
	[38177] = 122403, -- Scouting Missive: Magnarok
	[38190] = 122399, -- Scouting Missive: Magnarok
	[38181] = 122421, -- Scouting Missive: Mok'gol Watchpost
	[38195] = 122422, -- Scouting Missive: Mok'gol Watchpost
	[38185] = 122411, -- Scouting Missive: Pillars of Fate
	[38199] = 122409, -- Scouting Missive: Pillars of Fate
	[38187] = 122412, -- Scouting Missive: Shattrath Harbor
	[38201] = 122410, -- Scouting Missive: Shattrath Harbor
	[38186] = 122408, -- Scouting Missive: Skettis
	[38200] = 122407, -- Scouting Missive: Skettis
	[38183] = 122416, -- Scouting Missive: Socrethar's Rise
	[38197] = 122415, -- Scouting Missive: Socrethar's Rise
	[38176] = 122405, -- Scouting Missive: Stonefury Cliffs
	[38189] = 122401, -- Scouting Missive: Stonefury Cliffs

	-- Misc
	[31664] = 88604, -- Nat's Fishing Journal
}

local Blacklist = Options:CreateChild('Item Blacklist', 'QuickQuestItemBlacklist', defaultBlacklist)
Blacklist:Initialize(function(self)
	local Title = self:CreateTitle()
	Title:SetPoint('TOPLEFT', 20, -20)
	Title:SetFontObject('GameFontHighlight')
	Title:SetText(L['Quests starting and/or containing these items will not be automated. Drag items into this window to add more.'])

	local Items = self:CreateItemPanel()
	Items:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', -12, -8)
	Items:SetPoint('BOTTOMRIGHT', -8, 8)
	Items.OnItemEnter = function()
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(L['Right-click to remove from blacklist'], 0, 1, 0)
		GameTooltip:Show()
	end
end)

-- Temporary import from old DB
local Temp = CreateFrame('Frame')
Temp:RegisterEvent('ADDON_LOADED')
Temp:SetScript('OnEvent', function(self, event, name)
	if(name == addonName) then
		self:UnregisterEvent(event)

		if(QuickQuestDB and QuickQuestDB.itemBlacklist) then
			QuickQuestItemBlacklist = QuickQuestDB.itemBlacklist
			QuickQuestDB.itemBlacklist = nil
		end
	end
end)
