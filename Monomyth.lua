local addon = CreateFrame('Frame')
addon:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local COMPLETE = [=[Interface\GossipFrame\ActiveQuestIcon]=]

function addon:Register(event, func)
	self:RegisterEvent(event)
	self[event] = function(...)
		if(IsShiftKeyDown()) then
			if(event == 'QUEST_DETAIL') then
				QuestFrame_OnEvent(nil, event)
			end
		else
			func(...)
		end
	end
end

addon:Register('GOSSIP_SHOW', function()
	for index = 1, NUMGOSSIPBUTTONS do
		local button = _G['GossipTitleButton' .. index]

		if(button and button:IsVisible()) then
			if(button.type == 'Available') then
				return button:Click()
			elseif(button.type == 'Active' and _G['GossipTitleButton' .. index .. 'GossipIcon']:GetTexture() == COMPLETE) then
				return button:Click()
			end
		end
	end
end)

QuestFrame:UnregisterEvent('QUEST_DETAIL')
addon:Register('QUEST_DETAIL', function()
	if(QuestGetAutoAccept()) then
		CloseQuest()
	else
		QuestFrame_OnEvent(nil, 'QUEST_DETAIL')
		AcceptQuest()
	end
end)

addon:Register('QUEST_ACCEPT_CONFIRM', AcceptQuest)

addon:Register('QUEST_PROGRESS', function()
	if(IsQuestCompletable()) then
		CompleteQuest()
	end
end)

addon:Register('QUEST_COMPLETE', function()
	if(GetNumQuestChoices() <= 1) then
		GetQuestReward(QuestFrameRewardPanel.itemChoice)
	elseif(GetNumQuestChoices() > 1) then
		local bestValue, bestIndex = 0

		for index = 1, GetNumQuestChoices() do
			local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(GetQuestItemLink('choice', index))
			
			if(value > bestValue) then
				bestValue, bestIndex = value, index
			end
		end

		if(bestIndex) then -- XXX: Debug this one
			_G['QuestInfoItem' .. bestIndex]:Click()
		end
	end
end)

addon:Register('QUEST_AUTOCOMPLETE', function()
	for index = 1, GetNumAutoQuestPopUps() do
		local quest, type = GetAutoQuestPopUp(index)

		if(type == 'COMPLETE') then
			ShowQuestComplete(GetQuestLogIndexByID(quest))
		end
	end
end)

addon:Register('BAG_UPDATE', function(bag)
	if(bag < 0) then return end

	for slot = 1, GetContainerNumSlots(bag) do
		local _, id, active = GetContainerItemQuestInfo(bag, slot)
		if(id and not active) then
			UseContainerItem(bag, slot)
		end
	end
end)
