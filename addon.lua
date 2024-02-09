local _, addon = ...

local paused

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
local darkmoonFaireOptions = {
	[40563] = true, -- whack
	[28701] = true, -- cannon
	[31202] = true, -- shoot
	[39245] = true, -- tonk
	[40224] = true, -- ring toss
	[43060] = true, -- firebird
	[52651] = true, -- dance
	[41759] = true, -- pet battle 1
	[42668] = true, -- pet battle 2
	[40872] = true, -- cannon return (Teleportologist Fozlebub)
	[40007] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[40457] = true, -- Darkmoon Faire Mystic Mage (Alliance)
}

local function isQuestIgnored(questID)
	if ignoredQuests[questID] then
		return true
	end

	local questTitle = tonumber(questID) and C_QuestLog.GetTitleForQuestID(questID) or ''
	for key, value in next, addon.db.profile.blocklist.quests do
		if key == questID or questTitle:lower():find(tostring(key):lower()) then
			return value
		end
	end

	return false
end

local function isTrackingTrivialQuests()
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local name, _, isActive = C_Minimap.GetTrackingInfo(index)
		if name == MINIMAP_TRACKING_TRIVIAL_QUESTS then
			return isActive
		end
	end
end

function addon:GOSSIP_SHOW()
	-- triggered when the player interacts with an NPC that presents dialogue
	if paused then
		return
	end

	local npcID = addon:GetNPCID('npc')
	if addon.db.profile.blocklist.npcs[npcID] then
		return
	end

	-- we want to auto-accept the dialogues from Darkmoon Faire NPCs
	for _, info in next, C_GossipInfo.GetOptions() do
		if darkmoonFaireOptions[info.gossipOptionID] and addon.db.profile.general.paydarkmoonfaire then
			C_GossipInfo.SelectOption(info.gossipOptionID, '', true)
			return
		elseif FlagsUtil.IsSet(info.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend) and addon.db.profile.general.autoquestgossip then
			C_GossipInfo.SelectOption(info.gossipOptionID)
		end
	end

	if C_GossipInfo.GetNumActiveQuests() > 0 or C_GossipInfo.GetNumAvailableQuests() > 0 then
		-- bail if there is more than just dialogue
		return
	end

	local gossipOptions = C_GossipInfo.GetOptions()
	if #gossipOptions == 1 and addon.db.profile.general.skipgossip and gossipOptions[1].gossipOptionID then
		-- automatically skip single dialogue under certain conditions
		local _, instanceType = GetInstanceInfo()
		if instanceType == 'raid' and addon.db.profile.general.skipgossipwhen > 0 then
			if GetNumGroupMembers() <= 1 or addon.db.profile.general.skipgossipwhen == 2 then
				-- select dialogue if alone or when configured to "Always" while in a raid
				C_GossipInfo.SelectOption(gossipOptions[1].gossipOptionID)
				return
			end
		elseif instanceType ~= 'raid' then
			-- always select single dialogue while outside a raid
			C_GossipInfo.SelectOption(gossipOptions[1].gossipOptionID)
			return
		end
	end
end

function addon:GOSSIP_SHOW()
	-- triggered when the player interacts with an NPC that presents dialogue
	if paused then
		return
	end

	if addon.db.profile.blocklist.npcs[addon:GetNPCID('npc')] then
		return
	end

	-- turn in all completed quests
	if addon.db.profile.general.complete then
		for _, info in next, C_GossipInfo.GetActiveQuests() do
			if not isQuestIgnored(info.questID) then
				if info.isComplete and not C_QuestLog.IsWorldQuest(info.questID) then
					C_GossipInfo.SelectActiveQuest(info.questID)
				end
			end
		end
	end

	-- accept all available quests
	if addon.db.profile.general.accept then
		for _, info in next, C_GossipInfo.GetAvailableQuests() do
			if not isQuestIgnored(info.questID) then
				if (not info.isTrivial or isTrackingTrivialQuests()) and (not info.repeatable or addon.db.profile.general.acceptRepeatables) then
					C_GossipInfo.SelectAvailableQuest(info.questID)
				end
			end
		end
	end
end

function addon:QUEST_GREETING()
	-- triggered when the player interacts with an NPC that hands in/out quests
	if paused then
		return
	end

	if addon.db.profile.blocklist.npcs[addon:GetNPCID('npc')] then
		return
	end

	-- turn in all completed quests
	if addon.db.profile.general.complete then
		for index = 1, GetNumActiveQuests() do
			if not isQuestIgnored(GetActiveQuestID(index)) then
				local _, isComplete = GetActiveTitle(index)
				if isComplete and not C_QuestLog.IsWorldQuest(GetActiveQuestID(index)) then
					SelectActiveQuest(index)
				end
			end
		end
	end

	-- accept all available quests
	if addon.db.profile.general.accept then
		for index = 1, GetNumAvailableQuests() do
			local isTrivial, _, isRepeatable, _, questID = GetAvailableQuestInfo(index)
			if not isQuestIgnored(questID) then
				if (not isTrivial or isTrackingTrivialQuests()) and (not isRepeatable or addon.db.profile.general.acceptRepeatables) then
					SelectAvailableQuest(index)
				end
			end
		end
	end
end

function addon:QUEST_DETAIL()
	-- triggered when the information about an available quest is available
	if paused then
		return
	end

	if addon.db.profile.general.accept then
		if QuestIsFromAreaTrigger() then
			-- this type of quest is automatically accepted, but the dialogue is presented in a way that
			-- the player seems to have a choice to decline it, which they don't, so just accept it
			AcceptQuest()
		elseif QuestGetAutoAccept() then
			-- this type of quest is automatically accepted, but the dialogue persists
			AcknowledgeAutoAcceptQuest()
		elseif not C_QuestLog.IsQuestTrivial(GetQuestID()) or isTrackingTrivialQuests() then
			if isQuestIgnored(GetQuestID()) then
				CloseQuest()
			else
				AcceptQuest()
			end
		end
	end
end

local itemCacheQueue = {}
function addon:QUEST_ITEM_UPDATE()
	local i, event = next(itemCacheQueue)
	if i then
		table.remove(itemCacheQueue, i)
		addon[event]()
	end
end

function addon:QUEST_PROGRESS()
	-- triggered when an active quest is selected during turn-in
	if paused then
		return
	end

	if addon.db.profile.blocklist.npcs[addon:GetNPCID('npc')] then
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
			if addon.db.profile.blocklist.items[questItemID] then
				-- item is blocked, prevent this quest from opening again and close it
				ignoredQuests[GetQuestID()] = true
				CloseQuest()
				return
			end
		else
			-- item is not cached yet, trigger the item and wait for the cache to populate
			table.insert(itemCacheQueue, 'QUEST_PROGRESS')
			GetQuestItemInfo('required', index)
			return
		end
	end

	if addon.db.profile.general.complete then
		CompleteQuest()
	end
end

function addon:QUEST_COMPLETE()
	-- triggered when an active quest is ready to be completed
	if paused then
		return
	end

	if addon.db.profile.general.complete then
		if GetNumQuestChoices() <= 1 then
			-- complete the quest by accepting the first item
			GetQuestReward(1)
		end
	end
end

function addon:QUEST_COMPLETE()
	if not addon.db.profile.general.selectreward then
		return
	end

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
			table.insert(itemCacheQueue, 'QUEST_COMPLETE')
			GetQuestItemInfo('choice', index)
			return
		end
	end

	if highestItemValueIndex then
		-- this is considered an intrusive action, as we're modifying the UI
		QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[highestItemValueIndex])
	end
end

function addon:QUEST_LOG_UPDATE()
	-- triggered when the player's quest log has been altered
	if paused or WorldMapFrame:IsShown() then -- see #45
		return
	end

	-- check for quest popups whenever the quest log is updated, which also happens on login, and
	-- when the player loots an item that starts a quest
	if GetNumAutoQuestPopUps() > 0 then
		if UnitIsDeadOrGhost('player') then
			-- can't accept quests while we're dead
			addon:Defer(addon, 'QUEST_LOG_UPDATE', addon)
			return
		end

		-- this is considered an intrusive action, as we're modifying the UI
		local questID, questType = GetAutoQuestPopUp(1)
		if questType == 'OFFER' then
			if addon.db.profile.general.accept then
				ShowQuestOffer(questID)
			end
		elseif questType == 'COMPLETE' then
			if addon.db.profile.general.complete then
				ShowQuestComplete(questID)
			end
		end

		-- remove the popup once accepted/completed, the game logic doesn't handle this
		RemoveAutoQuestPopUp(questID)
	end
end

function addon:QUEST_ACCEPT_CONFIRM()
	-- triggered when a quest is shared in the party, but requires confirmation (like escorts)
	if paused then
		return
	end

	if addon.db.profile.general.accept then
		AcceptQuest()
	end
end

function addon:QUEST_ACCEPTED(questID)
	-- triggered when a quest has been accepted by the player
	if addon.db.profile.general.share then
		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
		if questLogIndex then
			QuestLogPushQuest(questLogIndex)
		end
	end
end

function addon:MODIFIER_STATE_CHANGED(key, state)
	-- triggered when the player clicks any modifier keys on the keyboard
	if string.sub(key, 2) == addon.db.profile.general.pausekey then
		-- change the paused state
		if addon.db.profile.general.pausekeyreverse then
			paused = state ~= 1
		else
			paused = state == 1
		end
	end
end

function addon:PLAYER_LOGIN()
	-- triggered when the game has completed the login process
	if addon.db.profile.general.pausekeyreverse then
		-- default to a paused state
		paused = true
	end
end
