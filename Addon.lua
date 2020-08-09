local _, ns = ...
if select(4, GetBuildInfo()) < 90000 then
	return
end

local EventHandler = ns.EventHandler
local paused

local ignoredQuests = {}

EventHandler:Register('GOSSIP_CONFIRM', function(index)
	-- triggered when a gossip confirm prompt is displayed
	if paused then
		return
	end

	--[[
		TODO:
		- if this is a darkmoon faire teleport prompt, check if the user wants to do this (db) and accept
	--]]
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

	-- turn in all completed quests
	for index, info in next, C_GossipInfo.GetActiveQuests() do
		if not ignoredQuests[info.questID] then
			if info.isComplete and not C_QuestLog.IsWorldQuest(info.questID) then
				C_GossipInfo.SelectActiveQuest(index)
			end
		end
	end

	-- accept all available quests
	for index, info in next, C_GossipInfo.GetAvailableQuests() do
		if not ignoredQuests[info.questID] then
			if not info.isTrivial or ns.ShouldAcceptTrivialQuests() then
				C_GossipInfo.SelectAvailableQuest(index)
			end
		end
	end

	--[[
		TODO:
		- handle gossip when there's no active/available quests
		- handle gossip for rogue doors in dalaran
		- handle gossip for darkmoon faire teleports
		- handle single gossip options (with restrictions)
	--]]
end)

EventHandler:Register('QUEST_GREETING', function()
	-- triggered when the player interacts with an NPC that hands in/out quests
	if paused then
		return
	end

	local npcID = ns.GetNPCID()
	if ns.db.profile.blocklist.npcs[npcID] then
		return
	end

	-- turn in all completed quests
	for index = 1, GetNumActiveQuests() do
		if not ignoredQuests[GetActiveQuestID(index)] then
			local _, isComplete = GetActiveTitle(index)
			if isComplete and not C_QuestLog.IsWorldQuest(GetActiveQuestID(index)) then
				SelectActiveQuest(index)
			end
		end
	end

	-- accept all available quests
	for index = 1, GetNumAvailableQuests() do
		local isTrivial, _, _, _, questID = GetAvailableQuestInfo(index)
		if not ignoredQuests[questID] then
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
		if ignoredQuests[GetQuestID()] then
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

	local npcID = ns.GetNPCID()
	if ns.db.profile.blocklist.npcs[npcID] then
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
			for _, itemID in next, ns.db.profile.blocklist.items do
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

	--[[
		TODO:
		- complete quest
	--]]
end)

EventHandler:Register('QUEST_COMPLETE', function()
	-- triggered when an active quest is ready to be completed
	if paused then
		return
	end

	--[[
		TODO:
		- highlight most valuable reward if there are multiple rewards
			- regardless of modifier
		- complete quest when there are 1 or less items rewarded
	--]]
end)

EventHandler:Register('QUEST_LOG_UPDATE', function()
	-- triggered when the player's quest log has been altered
	if paused then
		return
	end

	--[[
		TODO:
		- iterate through quest popups (the ones in the watchlist)
	--]]
end)

EventHandler:Register('QUEST_ACCEPT_CONFIRM', function()
	-- triggered when a quest is shared in the party, but requires confirmation (like escorts)
	if paused then
		return
	end

	--[[
		TODO:
		- accept quest, easy enoogh
	--]]
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
