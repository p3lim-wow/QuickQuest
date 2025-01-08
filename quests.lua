local _, addon = ...

local ITEM_CASH_REWARDS = {
	-- some items have hidden values, like pouches
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

local function shouldAutomate(questID)
	if C_QuestLog.IsQuestRepeatableType(questID) then
		if addon:GetOption('acceptRepeatables') == 3 then
			return true
		elseif addon:GetOption('acceptRepeatables') == 2 then
			if not C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) then
				return true
			else
				return C_Minimap.IsTrackingAccountCompletedQuests()
			end
		end
	else
		if addon:GetOption('accept') == 3 then
			return true
		elseif addon:GetOption('accept') == 2 then
			if not C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) then
				return true
			else
				return C_Minimap.IsTrackingAccountCompletedQuests()
			end
		end
	end
end

local ignoredQuests = {}
local function isQuestIgnored(questID, title, override)
	local ignore
	if ignoredQuests[questID] then
		return true
	elseif addon:IsQuestIgnored(questID) then
		ignore = true
	elseif title and addon:IsQuestIgnored(title) then
		ignore = true
	elseif C_QuestLog.IsWorldQuest(questID) then
		-- these are usually always material delivery quests, don't want to waste that
		ignore = true
	elseif override then
		-- this is so we can override popup quests that are not being tracked, as they can
		-- get quite annoying
		ignore = false
	elseif C_QuestLog.IsQuestTrivial(questID) and not C_Minimap.IsTrackingHiddenQuests() then
		ignore = true
	end

	if ignore then
		-- ignore this quest for the rest of the session, to avoid it being selected again
		ignoredQuests[questID] = true
		return true
	end
end

local function wipeIgnore()
	table.wipe(ignoredQuests)
end

addon:RegisterEvent('MINIMAP_UPDATE_TRACKING', wipeIgnore)
addon:RegisterOptionCallback('accept', wipeIgnore)
addon:RegisterOptionCallback('acceptRepeatables', wipeIgnore)

local function handleGossipQuests()
	if addon:IsPaused() or addon:IsNPCIgnored() then
		return
	end

	if addon:GetOption('accept') > 1 then
		for _, questInfo in next, C_GossipInfo.GetActiveQuests() do
			if not questInfo.questLevel or questInfo.questLevel == 0 then
				-- not cached yet
				addon:WaitForQuestData(questInfo.questID, handleGossipQuests)
			elseif isQuestIgnored(questInfo.questID, questInfo.title) then
				-- ignore
			elseif questInfo.isComplete and shouldAutomate(questInfo.questID) then
				C_GossipInfo.SelectActiveQuest(questInfo.questID)
			end
		end

		for _, questInfo in next, C_GossipInfo.GetAvailableQuests() do
			if questInfo.questID == 82449 then
				-- "The Call of the Worldsoul"
				-- this quest is buggy, it's repeatable (weekly) but the APIs don't report that,
				-- and all this quest does is open an option of other quests, so we should
				-- automatically accept it
				C_GossipInfo.SelectAvailableQuest(questInfo.questID)
			elseif not questInfo.questLevel or questInfo.questLevel == 0 then
				-- not cached yet
				addon:WaitForQuestData(questInfo.questID, handleGossipQuests)
			elseif isQuestIgnored(questInfo.questID, questInfo.title) then
				-- ignore
			elseif shouldAutomate(questInfo.questID) then
				C_GossipInfo.SelectAvailableQuest(questInfo.questID)
			end
		end
	end
end

local function handleQuestList()
	if addon:IsPaused() or addon:IsNPCIgnored() then
		return
	end

	if addon:GetOption('accept') > 1 then
		for index = 1, GetNumActiveQuests() do
			local questID = GetActiveQuestID(index)
			local title, isComplete = GetActiveTitle(index)
			if not isComplete then
				-- ignore
			elseif isQuestIgnored(questID, title) then
				-- ignore
			elseif shouldAutomate(questID) then
				SelectActiveQuest(index)
			end
		end

		for index = 1, GetNumAvailableQuests() do
			local _, _, _, _, questID = GetAvailableQuestInfo(index)
			local questLevel = GetAvailableLevel(index)
			if not questLevel or questLevel == 0 then
				-- not cached yet, invalid isTrivial flag
				addon:WaitForQuestData(questID, handleQuestList)
			elseif isQuestIgnored(questID, GetAvailableTitle(index)) then
				-- ignore
			elseif shouldAutomate(questID) then
				SelectAvailableQuest(index)
			end
		end
	end
end

local popups = {}
local function handleQuestDetail()
	if addon:IsPaused() or addon:IsNPCIgnored() then
		return
	end

	local questID = GetQuestID()
	if not questID or questID == 0 then
		return
	end

	if addon:GetOption('accept') == 1 then
		return
	end

	local questLevel = C_QuestLog.GetQuestDifficultyLevel(questID)
	if not questLevel or questLevel == 0 then
		addon:WaitForQuestData(questID, handleQuestDetail)
		return
	end

	if QuestGetAutoAccept() then
		-- these kinds of quests are already accepted, the popup only exists to notify the user
		AcknowledgeAutoAcceptQuest()
		RemoveAutoQuestPopUp(questID)
	elseif QuestIsFromAreaTrigger() then
		-- when not triggered in combination with QuestGetAutoAccept-style quests this is just
		-- a normal quest popup, as if it was shared by an unknown player, so we'll just accept it
		AcceptQuest()
	elseif isQuestIgnored(questID, nil, popups[questID]) then
		return
	elseif shouldAutomate(questID) then
		AcceptQuest()
	end

	if popups[questID] then
		-- just remove the already accepted/completed quest from the tracker
		RemoveAutoQuestPopUp(questID)
	end
end

local function handleQuestProgress()
	if addon:IsPaused() or addon:IsNPCIgnored() then
		return
	end

	if not IsQuestCompletable() or addon:GetOption('accept') == 1 then
		return
	end

	local questID = GetQuestID()
	if ignoredQuests[questID] then
		return
	elseif not shouldAutomate(questID) then
		return
	end

	-- make sure the quest doesn't contain an ignored item
	for index = 1, GetNumQuestItems() do
		local _, _, _, _, _, itemID = GetQuestItemInfo('required', index)
		if itemID then
			if addon:IsItemIgnored(itemID) then
				-- ignore this quest to prevent it from being selected again
				ignoredQuests[questID] = true
				return
			end
		end
	end

	CompleteQuest()
end

local function handleQuestComplete()
	if addon:IsPaused() or addon:IsNPCIgnored() then
		return
	end

	if GetNumQuestChoices() > 1 then
		return
	end

	local questID = GetQuestID()
	if isQuestIgnored(questID) or not shouldAutomate(questID) then
		return
	end

	GetQuestReward(1)
end

local function handleQuestReward()
	local numChoices = GetNumQuestChoices()
	if addon:GetOption('selectreward') and numChoices > 1 then
		local highestValue, highestValueIndex = 0
		for index = 1, numChoices do
			local _, _, _, _, _, itemID = GetQuestItemInfo('choice', index)
			local isCached, _, _, _, _, _, _, _, _, _, itemValue = C_Item.GetItemInfo(itemID)
			if not isCached then
				addon:WaitForItemData(itemID, handleQuestReward)
			else
				itemValue = ITEM_CASH_REWARDS[itemID] or itemValue

				if itemValue > highestValue then
					highestValue = itemValue
					highestValueIndex = index
				end
			end
		end

		if highestValueIndex then
			if not (QuestInfoRewardsFrame and QuestInfoRewardsFrame.RewardButtons and QuestInfoRewardsFrame.RewardButtons[highestValueIndex]) then
				return
			end

			-- "intrusive" action
			QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[highestValueIndex])
		end
	end
end

local function handleQuestPopup()
	if addon:IsPaused() then
		return
	end

	if WorldMapFrame:IsShown() then
		-- https://github.com/p3lim-wow/QuickQuest/issues/45
		return
	end

	if QuestFrame:IsShown() then
		-- don't try to deal with quests while we already deal with one
		return
	end

	local numPopups = GetNumAutoQuestPopUps()
	if numPopups == 0 then
		return
	end

	if UnitIsDeadOrGhost('player') then
		-- can't accept quests while dead
		if not addon:IsUnitEventRegistered('PLAYER_FLAGS_CHANGED', 'player', handleQuestPopup) then
			-- TODO: should probably unregister this afterwards
			addon:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player', handleQuestPopup)
		end
		return
	end

	for index = 1, numPopups do
		local questID, questType = GetAutoQuestPopUp(index)
		if questID then
			popups[questID] = true

			if questType == 'OFFER' and shouldAutomate(questID) then
				ShowQuestOffer(questID)
			elseif questType == 'COMPLETE' and shouldAutomate(questID) then
				ShowQuestComplete(questID)
			end
		else
			addon:WaitForQuestData(questID, handleQuestPopup)
		end
	end
end

addon:RegisterEvent('GOSSIP_SHOW', handleGossipQuests) -- quest list with gossips
addon:RegisterEvent('QUEST_GREETING', handleQuestList) -- quest list without gossips
addon:RegisterEvent('QUEST_DETAIL', handleQuestDetail) -- quest details before accepting
addon:RegisterEvent('QUEST_PROGRESS', handleQuestProgress) -- quest details when delivering
addon:RegisterEvent('QUEST_COMPLETE', handleQuestComplete) -- quest details when completing
addon:RegisterEvent('QUEST_COMPLETE', handleQuestReward) -- quest details when completing
addon:RegisterEvent('QUEST_LOG_UPDATE', handleQuestPopup) -- popups

function addon:QUEST_ACCEPTED(questID)
	if addon:GetOption('share') then
		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
		if questLogIndex then
			-- no way to check if the user _can_ share it, we'll just try to share it
			QuestLogPushQuest(questLogIndex)
		end
	end
end

function addon:QUEST_ACCEPT_CONFIRM(_, questTitle)
	-- triggered when a quest is shared but requires confirmation (like escorts),
	-- always accept these regardless of tracking/settings for warband
	if not addon:IsPaused() and addon:GetOption('accept') > 1 then
		if not addon:IsQuestIgnored(questTitle) then
			ConfirmAcceptQuest()
		end
	end
	-- XXX: the questID is not available at this time, needs more testing
end
