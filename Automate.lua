local addon = CreateFrame('Frame')
addon:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local activeQuests = {}

function addon:Register(event, func)
	self:RegisterEvent(event)
	self[event] = function(...)
		if(not IsShiftKeyDown()) then
			func(...)
		end
	end
end

local function QuestCompleted(title)
	for quest, complete in pairs(activeQuests) do
		if(title:find(quest) and complete) then
			return true
		end
	end
end

addon:Register('GOSSIP_SHOW', function()
	for index = 1, NUMGOSSIPBUTTONS do
		local button = _G['GossipTitleButton' .. index]
		if(button and button:IsVisible()) then
			if(button.type == 'Available') then
				return button:Click()
			elseif(button.type == 'Active' and QuestCompleted(button:GetText())) then
				return button:Click()
			end
		end
	end
end)

addon:Register('QUEST_DETAIL', function()
	if(QuestGetAutoAccept()) then
		HideUIPanel(QuestFrame)
	else
		AcceptQuest()
	end
end)

addon:Register('QUEST_PROGRESS', function()
	if(IsQuestCompletable()) then
		CompleteQuest()
	end
end)

addon:Register('QUEST_COMPLETE', function(...)
	if(GetNumQuestChoices() <= 1) then
		GetQuestReward(QuestFrameRewardPanel.itemChoice)
	end
end)

addon:Register('QUEST_LOG_UPDATE', function(...)
	wipe(activeQuests)

	local quests = GetNumQuestLogEntries()
	if(quests > 0) then
		for index = 1, quests do
			local title, _, _, _, header, _, complete = GetQuestLogTitle(index)
			if(title and not header) then
				activeQuests[title] = complete or GetNumQuestLeaderBoards(index) == 0
			end
		end
	end
end)

addon:Register('UNIT_INVENTORY_CHANGED', function(unit)
	if(unit ~= 'player') then return end

	for bag = 1, 5 do
		for slot = 1, GetContainerNumSlots(bag) do
			local _, id, active = GetContainerItemQuestInfo(bag, slot)
			if(id and not active) then
				UseContainerItem(bag, slot)
			end
		end
	end
end)