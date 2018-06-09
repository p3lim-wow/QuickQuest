local addonName, L = ...
local defaults = {
	items = true,
	faireport = true,
	gossip = true,
	gossipraid = 1,
	modifier = 'SHIFT',
	reverse = false,
	share = false,
	withered = true,
	nomi = true,
}

local Options = LibStub('Wasabi'):New(addonName, 'QuickQuestDB', defaults)
Options:AddSlash('/qq')
Options:AddSlash('/quickquest')
Options:Initialize(function(self)
	local Title = self:CreateTitle()
	Title:SetPoint('TOPLEFT', 16, -16)
	Title:SetText(addonName)

	local Share = self:CreateCheckButton('share')
	Share:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -8)
	Share:SetText(L['Automatically share quests when picked up'])

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
			Modifier:SetText(L['Hold this key to to temporarily enable automation'])
		else
			Modifier:SetText(L['Hold this key to to temporarily disable automation'])
		end
	end)

	local Withered = self:CreateCheckButton('withered')
	Withered:SetPoint('TOPLEFT', Reverse, 'BOTTOMLEFT', -24, -8)
	Withered:SetText(L['Disable while doing the withered training scenario in Suramar'])
	Withered:SetNewFeature(true)

	local Nomi = self:CreateCheckButton('nomi')
	Nomi:SetPoint('TOPLEFT', Withered, 'BOTTOMLEFT', 0, -8)
	Nomi:SetText(L['Always accept and complete Nomi\'s daily quest, despite being low-level'])
	Nomi:SetNewFeature(true)
end)

local defaultBlacklist = {
	items = {
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
}

-- need this to get size of a pair table
local function tLength(t)
	local count = 0
	for _ in next, t do
		count = count + 1
	end
	return count
end

local Blacklist = Options:CreateChild('Item Blacklist', 'QuickQuestBlacklistDB', defaultBlacklist)
Blacklist:Initialize(function(self)
	local Title = self:CreateTitle()
	Title:SetPoint('TOPLEFT', 20, -16)
	Title:SetFontObject('GameFontNormalMed1')
	Title:SetText(L['Quests starting with and/or containing these items will not be automated.'])

	local Description = self:CreateDescription()
	Description:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -6)
	Description:SetText(L['Drag items into the window below to add more.'])

	local OnItemEnter = function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:SetItemByID(self.value)
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(L['Right-click to remove item'], 0, 1, 0)
		GameTooltip:Show()
	end

	local Items = self:CreateObjectContainer('items')
	Items:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', -20, -8)
	Items:SetSize(self:GetWidth(), 500)
	Items:SetObjectSize(34)
	Items:SetObjectSpacing(2)
	Items:On('ObjectCreate', function(self, event, Object)
		local Texture = Object:CreateTexture()
		Texture:SetAllPoints()

		Object:SetNormalTexture(Texture)
		Object:SetScript('OnEnter', OnItemEnter)
		Object:SetScript('OnLeave', GameTooltip_Hide)
	end)

	local queryItems = {}
	Items:On('ObjectUpdate', function(self, event, Object)
		local itemID = Object.value

		local _, _, _, _, _, _, _, _, _, textureFile = GetItemInfo(itemID)
		if(textureFile) then
			Object:SetNormalTexture(textureFile)
		elseif(not queryItems[itemID]) then
			queryItems[itemID] = Object.key -- questID
			self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
		end
	end)

	Items:On('ObjectClick', function(self, event, Object, button)
		if(button == 'RightButton') then
			Object:Remove()
		end
	end)

	Items:HookScript('OnEvent', function(self, event, itemID)
		if(event == 'GET_ITEM_INFO_RECEIVED') then
			local questID = queryItems[itemID]
			if(questID) then
				queryItems[itemID] = nil
				self:AddObject(questID, itemID)

				if(tLength(queryItems) == 0) then
					self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
				end
			end
		end
	end)

	Items:SetScript('OnMouseUp', function(self)
		if(CursorHasItem()) then
			local _, itemID, itemLink = GetCursorInfo()
			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					if(GetContainerItemLink(bag, slot) == itemLink) then
						local _, questID = GetContainerItemQuestInfo(bag, slot)
						if(not questID) then
							questID = 'progress_' .. itemID
						end

						if(not self:HasObject(questID)) then
							ClearCursor()
							self:AddObject(questID, itemID)
							return
						end
					end
				end
			end
		end
	end)
end)

-- Temporary import from old DB
local Temp = CreateFrame('Frame')
Temp:RegisterEvent('ADDON_LOADED')
Temp:SetScript('OnEvent', function(self, event, name)
	if(name == addonName) then
		self:UnregisterEvent(event)

		if(QuickQuestDB and QuickQuestDB.itemBlacklist) then
			QuickQuestBlacklistDB = QuickQuestDB.itemBlacklist
			QuickQuestDB.itemBlacklist = nil
		end
	end
end)
