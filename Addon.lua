local _, ns = ...
if select(4, GetBuildInfo()) < 90000 then
	return
end

local EventHandler = ns.EventHandler

EventHandler:Register('GOSSIP_CONFIRM', function(index)
	-- triggered when a gossip confirm prompt is displayed
	--[[
		TODO:
		- disable if modifier is held
		- if this is a darkmoon faire teleport prompt, check if the user wants to do this (db) and accept
	--]]
end)

EventHandler:Register('GOSSIP_SHOW', function()
	-- triggered when the player interacts with an NPC that presents dialogue
	--[[
		TODO:
		- disable if modifier is held
		- stop if the npc should be ignored
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
	--[[
		TODO:
		- disable if modifier is held
		- stop if the npc should be ignored
		- iterate through active quests
		- iterate through available quests
		- handle trivial quests
	--]]
end)

EventHandler:Register('QUEST_DETAIL', function(questItemID)
	-- triggered when the information about an available quest is available
	--[[
		TODO:
		- disable if modifier is held
		- handle area quests
		- handle automatic quests
		- handle trivial quests
		- accept quest
	--]]
end)

EventHandler:Register('QUEST_PROGRESS', function()
	-- triggered when an active quest is selected during turn-in
	--[[
		TODO:
		- disable if modifier is held
		- stop if the npc should be ignored
		- stop if the quest has an item that is blocked
		- stop if the quest cannot be completed
		- complete quest
	--]]
end)

EventHandler:Register('QUEST_COMPLETE', function()
	-- triggered when an active quest is ready to be completed
	--[[
		TODO:
		- disable if modifier is held
		- highlight most valuable reward if there are multiple rewards
			- regardless of modifier
		- complete quest when there are 1 or less items rewarded
	--]]
end)

EventHandler:Register('QUEST_LOG_UPDATE', function()
	-- triggered when the player's quest log has been altered
	--[[
		TODO:
		- disable if modifier is held
		- iterate through quest popups (the ones in the watchlist)
	--]]
end)

EventHandler:Register('QUEST_ACCEPT_CONFIRM', function()
	-- triggered when a quest is shared in the party, but requires confirmation (like escorts)
	--[[
		TODO:
		- disable if modifier is held
		- accept quest, easy enoogh
	--]]
end)

EventHandler:Register('MODIFIER_STATE_CHANGED', function(key, state)
	-- triggered when the player clicks any modifier keys on the keyboard
	--[[
		TODO:
		- set the "global" state of event propagation being disabled based on the modifier
		- also reverse state
	--]]
end)

EventHandler:Register('PLAYER_LOGIN', function()
	-- triggered when the game has completed the login process
	--[[
		TODO:
		- get the disabled state depending on the modifier being reversed or not
	--]]
end)
