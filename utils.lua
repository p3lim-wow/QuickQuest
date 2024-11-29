local _, addon = ...

-- cache
local questQueue = {}
function addon:QUEST_DATA_LOAD_RESULT(questID)
	-- TODO: deal with unsuccessful queries
	if questQueue[questID] then
		questQueue[questID]()
		questQueue[questID] = nil
	end
end

function addon:WaitForQuestData(questID, callback)
	questQueue[questID] = callback
	C_QuestLog.RequestLoadQuestByID(questID)
end

function addon:WaitForItemData(itemID, callback)
	Item:CreateFromItemID(itemID):ContinueOnItemLoad(callback)
end

local paused
function addon:MODIFIER_STATE_CHANGED(key, isPressed)
	if key:sub(2) == addon:GetOption('pausekey') then
		if addon:GetOption('pausekeyreverse') then
			paused = isPressed ~= 1
		else
			paused = isPressed == 1
		end
	end
end

-- settings
addon:RegisterOptionCallback('pausekeyreverse', function(value)
	-- TODO: consider keys being down while the setting is changed
	paused = value
end)

function addon:IsPaused()
	return paused
end

-- blocklists
function addon:IsNPCIgnored()
	local npcID = addon:GetUnitID('npc')
	if npcID then
		return QuickQuestBlocklistDB.npcs[npcID]
	end
end

function addon:IsQuestIgnored(questIDorTitle)
	local ignored = QuickQuestBlocklistDB.quests[questIDorTitle]
	if ignored then
		return true
	end

	-- also check the title if the arg is a questID
	local title = tonumber(questIDorTitle) and C_QuestLog.GetTitleForQuestID(questIDorTitle)
	if title then
		return QuickQuestBlocklistDB.quests[title]
	end
end

function addon:IsItemIgnored(itemID)
	return QuickQuestBlocklistDB.items[itemID]
end
