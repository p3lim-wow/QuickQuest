local _, ns = ...
if select(4, GetBuildInfo()) < 90000 then
	return
end

local EventHandler = ns.EventHandler
local paused

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

	--[[
		TODO:
		- iterate through active quests
		- iterate through available quests
		- handle trivial quests
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

	--[[
		TODO:
		- iterate through active quests
		- iterate through available quests
		- handle trivial quests
	--]]
end)

EventHandler:Register('QUEST_DETAIL', function(questItemID)
	-- triggered when the information about an available quest is available
	if paused then
		return
	end

	--[[
		TODO:
		- handle area quests
		- handle automatic quests
		- handle trivial quests
		- accept quest
	--]]
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

	--[[
		TODO:
		- stop if the quest has an item that is blocked
		- stop if the quest cannot be completed
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
