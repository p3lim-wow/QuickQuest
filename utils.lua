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

local function isPauseKeyDown()
	local pauseKey = addon:GetOption('pausekey')
	if pauseKey == 'ALT' then
		return IsAltKeyDown()
	elseif pauseKey == 'CTRL' then
		return IsControlKeyDown()
	elseif pauseKey == 'SHIFT' then
		return IsShiftKeyDown()
	end
end

function addon:IsPaused()
	if InteractiveWormholes and InteractiveWormholes:IsActive() then
		return true
	end

	local pauseKeyDown = isPauseKeyDown()
	if addon:GetOption('pausekeyreverse') then
		return not pauseKeyDown
	end

	return pauseKeyDown
end

-- blocklists
function addon:IsNPCIgnored()
	local npcID
	if UnitCreatureID then
		npcID = UnitCreatureID('npc')
		if npcID ~= nil and issecretvalue(npcID) then
			npcID = nil
		end
	else
		npcID = addon:GetUnitID('npc')
	end

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
