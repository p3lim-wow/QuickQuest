local _, ns = ...

local EventHandler = ns.EventHandler
local paused

local DARKMOON_ISLE_MAP_ID = 407
local DARKMOON_FAIRE_TELEPORT_NPC_ID = 57850 -- Teleportologist Fozlebub

local ignoredQuests = {}
local cashRewards = {
	[45724] = 1e5, -- Champion's Purse, 10 gold
	[64491] = 2e6, -- Royal Reward, 200 gold

	-- items from the Sixtrigger brothers quest chain in Stormheim
	[138127] = 15, -- Mysterious Coin, 15 copper
	[138129] = 11, -- Swatch of Priceless Silk, 11 copper
	[138131] = 24, -- Magical Sprouting Beans, 24 copper
	[138123] = 15, -- Shiny Gold Nugget, 15 copper
	[138125] = 16, -- Crystal Clear Gemstone, 16 copper
	[138133] = 27, -- Elixir of Endless Wonder, 27 copper
}
local darkmoonNPCs = {
	-- Darkmoon Faire teleporation NPCs
	[57850] = true, -- Teleportologist Fozlebub
	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
}
local rogueNPCs = {
	-- Rogue class hall doors
	[97004] = true, -- "Red" Jack Findle
	[96782] = true, -- Lucian Trias
	[93188] = true, -- Mongar
}

local function IsQuestIgnored(questID)
	if ignoredQuests[questID] then
		return true
	end

	local questTitle = tonumber(questID) and C_QuestLog.GetTitleForQuestID(questID) or ''
	for key in next, ns.db.profile.blocklist.quests do
		if key == questID or questTitle:lower():find(tostring(key):lower()) then
			return true
		end
	end

	return false
end

EventHandler:Register('GOSSIP_CONFIRM', function(index)
	-- triggered when a gossip confirm prompt is displayed
	if paused then
		return
	end

	if ns.db.profile.general.paydarkmoonfaire and darkmoonNPCs[ns.GetNPCID()] then
		C_GossipInfo.SelectOption(index, '', true)

		-- this is considered an intrusive action, as we're modifying the UI
		StaticPopup_Hide('GOSSIP_CONFIRM')
	end
end)

EventHandler:Register('GOSSIP_SHOW', function()
	-- triggered when the player interacts with an NPC that presents dialogue
	if paused then
		return
	end

	local npcID = ns.GetNPCID()
	if ns.db.profile.blocklist.npcs[npcID] then
		return
	end

	if C_Map.GetBestMapForUnit('player') == DARKMOON_ISLE_MAP_ID then
		-- we want to auto-accept the dialogues from Darkmoon Faire NPCs
		for index, info in next, C_GossipInfo.GetOptions() do
			if info.name:find('FF008E8') then
				-- TODO: see if there is something else than the color we can easily match with
				C_GossipInfo.SelectOption(index)
				return
			end
		end
	end

	if C_GossipInfo.GetNumActiveQuests() > 0 or C_GossipInfo.GetNumAvailableQuests() > 0 then
		-- bail if there is more than just dialogue
		return
	end

	if rogueNPCs[npcID] then
		-- automatically open doors to the rogue class hall in Dalaran
		C_GossipInfo.SelectOption(1)
		return
	end

	if ns.db.profile.general.paydarkmoonfaire and npcID == DARKMOON_FAIRE_TELEPORT_NPC_ID then
		C_GossipInfo.SelectOption(1)
		return
	end

	if C_GossipInfo.GetNumOptions() == 1 and ns.db.profile.general.skipgossip then
		-- automatically skip single dialogue under certain conditions
		local _, instanceType = GetInstanceInfo()
		if instanceType == 'raid' and ns.db.profile.general.skipgossipwhen > 0 then
			if GetNumGroupMembers() == 0 or ns.db.profile.general.skipgossipwhen == 2 then
				-- select dialogue if alone or when configured to "Always" while in a raid
				C_GossipInfo.SelectOption(1)
				return
			end
		elseif instanceType ~= 'raid' then
			-- always select single dialogue while outside a raid
			C_GossipInfo.SelectOption(1)
			return
		end
	end
end)

EventHandler:Register('GOSSIP_SHOW', function()
	-- triggered when the player interacts with an NPC that presents dialogue
	if paused then
		return
	end

	if ns.db.profile.blocklist.npcs[ns.GetNPCID()] then
		return
	end

	-- turn in all completed quests
	for index, info in next, C_GossipInfo.GetActiveQuests() do
		if not IsQuestIgnored(info.questID) then
			if info.isComplete and not C_QuestLog.IsWorldQuest(info.questID) then
				C_GossipInfo.SelectActiveQuest(index)
			end
		end
	end

	-- accept all available quests
	for index, info in next, C_GossipInfo.GetAvailableQuests() do
		if not IsQuestIgnored(info.questID) then
			if not info.isTrivial or ns.ShouldAcceptTrivialQuests() then
				C_GossipInfo.SelectAvailableQuest(index)
			end
		end
	end
end)

EventHandler:Register('QUEST_GREETING', function()
	-- triggered when the player interacts with an NPC that hands in/out quests
	if paused then
		return
	end

	if ns.db.profile.blocklist.npcs[ns.GetNPCID()] then
		return
	end

	-- turn in all completed quests
	for index = 1, GetNumActiveQuests() do
		if not IsQuestIgnored(GetActiveQuestID(index)) then
			local _, isComplete = GetActiveTitle(index)
			if isComplete and not C_QuestLog.IsWorldQuest(GetActiveQuestID(index)) then
				SelectActiveQuest(index)
			end
		end
	end

	-- accept all available quests
	for index = 1, GetNumAvailableQuests() do
		local isTrivial, _, _, _, questID = GetAvailableQuestInfo(index)
		if not IsQuestIgnored(questID) then
			if not isTrivial or ns.ShouldAcceptTrivialQuests() then
				SelectAvailableQuest(index)
			end
		end
	end
end)

EventHandler:Register('QUEST_DETAIL', function(questItemID)
	-- triggered when the information about an available quest is available
	if paused then
		return
	end

	if QuestIsFromAreaTrigger() then
		-- this type of quest is automatically accepted, but the dialogue is presented in a way that
		-- the player seems to have a choice to decline it, which they don't, so just accept it
		AcceptQuest()
	elseif QuestGetAutoAccept() then
		-- this type of quest is automatically accepted, but the dialogue persists
		AcknowledgeAutoAcceptQuest()
	elseif not C_QuestLog.IsQuestTrivial(GetQuestID()) or ns.ShouldAcceptTrivialQuests() then
		if IsQuestIgnored(GetQuestID()) then
			CloseQuest()
		else
			AcceptQuest()
		end
	end
end)

EventHandler:Register('QUEST_PROGRESS', function()
	-- triggered when an active quest is selected during turn-in
	if paused then
		return
	end

	if ns.db.profile.blocklist.npcs[ns.GetNPCID()] then
		return
	end

	if not IsQuestCompletable() then
		return
	end

	-- iterate through the items part of the quest
	for index = 1, GetNumQuestItems() do
		local itemLink = GetQuestItemLink('required', index)
		if itemLink then
			-- check to see if the item is blocked
			local questItemID = GetItemInfoFromHyperlink(itemLink)
			for itemID in next, ns.db.profile.blocklist.items do
				if itemID == questItemID then
					-- item is blocked, prevent this quest from opening again and close it
					ignoredQuests[GetQuestID()] = true
					CloseQuest()
					return
				end
			end
		else
			-- item is not cached yet, trigger the item and wait for the cache to populate
			EventHandler:Register('QUEST_ITEM_UPDATE', 'QUEST_PROGRESS')
			GetQuestItemInfo('required', index)
			return
		end
	end

	CompleteQuest()
	EventHandler:Unregister('QUEST_ITEM_UPDATE', 'QUEST_PROGRESS')
end)

EventHandler:Register('QUEST_COMPLETE', function()
	-- triggered when an active quest is ready to be completed
	if paused then
		return
	end

	if GetNumQuestChoices() <= 1 then
		-- complete the quest by accepting the first item
		GetQuestReward(1)
	end
end)

EventHandler:Register('QUEST_COMPLETE', function()
	-- triggered when an active quest is ready to be completed
	local numItemRewards = GetNumQuestChoices()
	if numItemRewards <= 1 then
		-- no point iterating over a single item or none at all
		return
	end

	local highestItemValue, highestItemValueIndex = 0

	-- iterate through the item rewards and automatically select the one worth the most
	for index = 1, numItemRewards do
		local itemLink = GetQuestItemLink('choice', index)
		if itemLink then
			-- check the value on the item and compare it to the others
			local _, _, _, _, _, _, _, _, _, _, itemValue = GetItemInfo(itemLink)
			local itemID = GetItemInfoFromHyperlink(itemLink)

			-- some items are containers that contains currencies of worth
			itemValue = cashRewards[itemID] or itemValue

			-- compare the values
			if itemValue > highestItemValue then
				highestItemValue = itemValue
				highestItemValueIndex = index
			end
		else
			-- item is not cached yet, trigger the item and wait for the cache to populate
			EventHandler:Register('QUEST_ITEM_UPDATE', 'QUEST_COMPLETE')
			GetQuestItemInfo('choice', index)
			return
		end
	end

	if highestItemValueIndex then
		-- this is considered an intrusive action, as we're modifying the UI
		QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[highestItemValueIndex])
	end

	EventHandler:Unregister('QUEST_ITEM_UPDATE', 'QUEST_COMPLETE')
end)

EventHandler:Register('QUEST_LOG_UPDATE', function()
	-- triggered when the player's quest log has been altered
	if paused or WorldMapFrame:IsShown() then -- see #45
		return
	end

	-- check for quest popups whenever the quest log is updated, which also happens on login, and
	-- when the player loots an item that starts a quest
	if GetNumAutoQuestPopUps() > 0 then
		if UnitIsDeadOrGhost('player') then
			-- can't accept quests while we're dead
			EventHandler:Register('PLAYER_REGEN_ENABLED', 'QUEST_LOG_UPDATE')
			return
		end

		EventHandler:Unregister('PLAYER_REGEN_ENABLED', 'QUEST_LOG_UPDATE')

		-- this is considered an intrusive action, as we're modifying the UI
		local questID, questType = GetAutoQuestPopUp(1)
		if questType == 'OFFER' then
			ShowQuestOffer(questID)
		elseif questType == 'COMPLETE' then
			ShowQuestComplete(questID)
		end

		-- remove the popup once accepted/completed, the game logic doesn't handle this,
		-- but this calls FrameXML API which might cause taints, we'll see
		AutoQuestPopupTracker_RemovePopUp(questID)
	end
end)

EventHandler:Register('QUEST_ACCEPT_CONFIRM', function()
	-- triggered when a quest is shared in the party, but requires confirmation (like escorts)
	if paused then
		return
	end

	AcceptQuest()
end)

EventHandler:Register('QUEST_ACCEPTED', function(questID)
	-- triggered when a quest has been accepted by the player
	if ns.db.profile.general.share then
		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
		if questLogIndex then
			QuestLogPushQuest(questLogIndex)
		end
	end
end)

EventHandler:Register('MODIFIER_STATE_CHANGED', function(key, state)
	-- triggered when the player clicks any modifier keys on the keyboard
	if string.sub(key, 2) == ns.db.profile.general.pausekey then
		-- change the paused state
		if ns.db.profile.general.pausekeyreverse then
			paused = state ~= 1
		else
			paused = state == 1
		end
	end
end)

EventHandler:Register('PLAYER_LOGIN', function()
	-- triggered when the game has completed the login process
	if ns.db.profile.general.pausekeyreverse then
		-- default to a paused state
		paused = true
	end
end)
