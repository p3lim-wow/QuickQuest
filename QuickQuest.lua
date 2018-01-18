local QuickQuest = CreateFrame('Frame')
QuickQuest:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local L = select(2, ...)

local metatable = {
	__call = function(methods, ...)
		for _, method in next, methods do
			method(...)
		end
	end
}

local modifier, DISABLED = false
function QuickQuest:Register(event, method, override)
	local newmethod
	if(not override) then
		newmethod = function(...)
			if(QuickQuestDB.reverse == modifier and not DISABLED) then
				method(...)
			end
		end
	end

	local methods = self[event]
	if(methods) then
		self[event] = setmetatable({methods, newmethod or method}, metatable)
	else
		self[event] = newmethod or method
		self:RegisterEvent(event)
	end
end

local function GetNPCID()
	return tonumber(string.match(UnitGUID('npc') or '', 'Creature%-.-%-.-%-.-%-.-%-(.-)%-'))
end

local function IsTrackingHidden()
	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if(name == (MINIMAP_TRACKING_TRIVIAL_QUESTS or MINIMAP_TRACKING_HIDDEN_QUESTS)) then
			return active
		end
	end
end

local ignoreQuestNPC = {
	[88570] = true, -- Fate-Twister Tiklal
	[87391] = true, -- Fate-Twister Seress
	[111243] = true, -- Archmage Lan'dalock
	[103792] = true, -- Griftah (one of his quests is a scam)
}

local function GetQuestLogQuests(onlyComplete)
	local quests = {}
	for index = 1, GetNumQuestLogEntries() do
		local title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
		if(not isHeader) then
			if(onlyComplete and isComplete or not onlyComplete) then
				quests[title] = questID
			end
		end
	end

	return quests
end

QuickQuest:Register('QUEST_GREETING', function()
	local npcID = GetNPCID()
	if(ignoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumActiveQuests()
	if(active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, complete = GetActiveTitle(index)
			if(complete) then
				local questID = logQuests[name]
				if(not questID) then
					SelectActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if(not worldQuest) then
						SelectActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumAvailableQuests()
	if(available > 0) then
		for index = 1, available do
			local isTrivial, _, _, _, isIgnored = GetAvailableQuestInfo(index)
			if((not isTrivial and not isIgnored) or IsTrackingHidden()) then
				SelectAvailableQuest(index)
			end
		end
	end
end)

local ignoreGossipNPC = {
	-- Bodyguards
	[86945] = true, -- Aeda Brightdawn (Horde)
	[86933] = true, -- Vivianne (Horde)
	[86927] = true, -- Delvar Ironfist (Alliance)
	[86934] = true, -- Defender Illona (Alliance)
	[86682] = true, -- Tormmok
	[86964] = true, -- Leorajh
	[86946] = true, -- Talonpriest Ishaal

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

	-- Misc NPCs
	[117871] = true, -- War Councilor Victoria (Class Challenges @ Broken Shore)
}

local ignoredQuestsIDs = {
	[48634] = true, -- Further Supplying Krokuun
	[48635] = true, -- More Void Inoculation
	[48636] = true, -- Fueling the Antoran Campaign	
}

local rogueClassHallInsignia = {
	[97004] = true, -- "Red" Jack Findle
	[96782] = true, -- Lucian Trias
	[93188] = true, -- Mongar
}

QuickQuest:Register('GOSSIP_SHOW', function()
	local npcID = GetNPCID()
	if(ignoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumGossipActiveQuests()
	if(active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, _, _, _, completed = GetActiveGossipQuestInfo(index)
			if(completed) then
				local questID = logQuests[name]
				if(not questID) then
					SelectGossipActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if(not worldQuest) then
						SelectGossipActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumGossipAvailableQuests()
	if(available > 0) then
		for index = 1, available do
			local _, _, trivial, ignored = GetAvailableGossipQuestInfo(index)
			if((not trivial and not ignored) or IsTrackingHidden()) then
				SelectGossipAvailableQuest(index)
			elseif(trivial and npcID == 64337 and QuickQuestDB.nomi) then
				SelectGossipAvailableQuest(index)
			end
		end
	end

	if(rogueClassHallInsignia[npcID]) then
		return SelectGossipOption(1)
	end

	if(available == 0 and active == 0 and GetNumGossipOptions() == 1) then
		if(string.match((GetGossipOptions()), TRACKER_HEADER_PROVINGGROUNDS)) then
			-- ignore proving grounds queue
			return
		end

		if(QuickQuestDB.faireport) then
			if(npcID == 57850) then
				return SelectGossipOption(1)
			end
		end

		if(QuickQuestDB.gossip) then
			local _, instance = GetInstanceInfo()
			if(instance == 'raid' and QuickQuestDB.gossipraid > 0) then
				if(GetNumGroupMembers() > 1 and QuickQuestDB.gossipraid < 2) then
					return
				end

				SelectGossipOption(1)
			elseif(instance ~= 'raid' and not ignoreGossipNPC[npcID]) then
				SelectGossipOption(1)
			end
		end
	end
end)

local darkmoonNPC = {
	[57850] = true, -- Teleportologist Fozlebub
	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
}

QuickQuest:Register('GOSSIP_CONFIRM', function(index)
	if(not QuickQuestDB.faireport) then return end

	local npcID = GetNPCID()
	if(npcID and darkmoonNPC[npcID]) then
		SelectGossipOption(index, '', true)
		StaticPopup_Hide('GOSSIP_CONFIRM')
	end
end)

QuestFrame:UnregisterEvent('QUEST_DETAIL')
QuickQuest:Register('QUEST_DETAIL', function(...)
	if(not QuestGetAutoAccept() and not QuestIsFromAreaTrigger() and not QuickQuestBlacklistDB[GetQuestID()]) then
		QuestFrame_OnEvent(QuestFrame, 'QUEST_DETAIL', ...)
	end
end, true)

QuickQuest:Register('QUEST_DETAIL', function(questStartItemID)
	if(QuestGetAutoAccept() or (questStartItemID ~= nil and questStartItemID ~= 0)) then
		AcknowledgeAutoAcceptQuest()
	else
		-- XXX: no way to tell if the quest is trivial
		AcceptQuest()
	end
end)

local function AttemptAutoComplete(event)
	if(GetNumAutoQuestPopUps() > 0) then
		if(UnitIsDeadOrGhost('player')) then
			QuickQuest:Register('PLAYER_REGEN_ENABLED', AttemptAutoComplete)
			return
		end

		local questID, popUpType = GetAutoQuestPopUp(1)
		if(popUpType == 'OFFER') then
			ShowQuestOffer(GetQuestLogIndexByID(questID))
		else
			ShowQuestComplete(GetQuestLogIndexByID(questID))
		end
	else
		C_Timer.After(1, AttemptAutoComplete)
	end

	if(event == 'PLAYER_REGEN_ENABLED') then
		QuickQuest:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end
end

QuickQuest:Register('PLAYER_LOGIN', AttemptAutoComplete)
QuickQuest:Register('QUEST_AUTOCOMPLETE', AttemptAutoComplete)
QuickQuest:Register('QUEST_ACCEPT_CONFIRM', AcceptQuest)

QuickQuest:Register('QUEST_ACCEPTED', function(id)
	if(QuickQuestDB.share) then
		QuestLogPushQuest(id)
	end
end)

local choiceQueue
QuickQuest:Register('QUEST_ITEM_UPDATE', function()
	if(choiceQueue and QuickQuest[choiceQueue]) then
		QuickQuest[choiceQueue]()
	end
end, true)

QuickQuest:Register('QUEST_PROGRESS', function()
	if(IsQuestCompletable()) then
		local requiredItems = GetNumQuestItems()
		if(requiredItems > 0) then
			for index = 1, requiredItems do
				local link = GetQuestItemLink('required', index)
				if(link) then
					local id = GetItemInfoFromHyperlink(link)
					for _, itemID in next, QuickQuestBlacklistDB.items do
						if(itemID == id) then
							return
						end
					end
				else
					choiceQueue = 'QUEST_PROGRESS'
					return
				end
			end
		end

		-- check for ignored QuestID's stored in the table "ignoredQuestsIDs"
		local QuestID = GetQuestID()
		if QuestID and ignoredQuestsIDs[QuestID] then
			return
		end
		
		CompleteQuest()
	end
end)

QuickQuest:Register('QUEST_COMPLETE', function()
	local choices = GetNumQuestChoices()
	if(choices <= 1) then
		GetQuestReward(1)
	end
end)

local cashRewards = {
	[45724] = 1e5, -- Champion's Purse, 10 gold
	[64491] = 2e6, -- Royal Reward, 200 gold

	-- Items from the Sixtrigger brothers quest chain in Stormheim
	[138127] = 15, -- Mysterious Coin, 15 copper
	[138129] = 11, -- Swatch of Priceless Silk, 11 copper
	[138131] = 24, -- Magical Sprouting Beans, 24 copper
	[138123] = 15, -- Shiny Gold Nugget, 15 copper
	[138125] = 16, -- Crystal Clear Gemstone, 16 copper
	[138133] = 27, -- Elixir of Endless Wonder, 27 copper
}

QuickQuest:Register('QUEST_COMPLETE', function()
	local choices = GetNumQuestChoices()
	if(choices > 1) then
		local bestValue, bestIndex = 0

		for index = 1, choices do
			local link = GetQuestItemLink('choice', index)
			if(link) then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
				value = cashRewards[(GetItemInfoFromHyperlink(link))] or value

				if(value > bestValue) then
					bestValue, bestIndex = value, index
				end
			else
				choiceQueue = 'QUEST_COMPLETE'
				return GetQuestItemInfo('choice', index)
			end
		end

		if(bestIndex) then
			QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[bestIndex])
		end
	end
end, true)

local sub = string.sub
QuickQuest:Register('MODIFIER_STATE_CHANGED', function(key, state)
	if(sub(key, 2) == QuickQuestDB.modifier) then
		modifier = state == 1
	end
end, true)

local function CheckScenario()
	if(QuickQuestDB.withered) then
		local name = C_Scenario.IsInScenario() and C_Scenario.GetInfo()
		DISABLED = name == L['The Collapse']
	end
end

QuickQuest:Register('PLAYER_ENTERING_WORLD', CheckScenario, true)
