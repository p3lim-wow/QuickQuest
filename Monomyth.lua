local addon = CreateFrame('Frame')
addon:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local CURRENT
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

addon:Register('QUEST_GREETING', function()
	local active = GetNumActiveQuests()
	if(active > 0) then
		for index = 1, active do
			local _, complete = GetActiveTitle(index)
			if(complete) then
				SelectActiveQuest(index)
			end
		end
	end

	local available = GetNumAvailableQuests()
	if(available > 0) then
		for index = 1, available do
			SelectAvailableQuest(index)
		end
	end
end)

addon:Register('GOSSIP_SHOW', function()
	for index = 1, NUMGOSSIPBUTTONS do
		local button = _G['GossipTitleButton' .. index]

		if(button and button:IsVisible()) then
			if(button.type == 'Active' and _G['GossipTitleButton' .. index .. 'GossipIcon']:GetTexture() == COMPLETE) then
				return button:Click()
			elseif(button.type == 'Available') then
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

		if(GetQuestID() == CURRENT) then
			addon:RegisterEvent('BAG_UPDATE')
		end
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
			local link = GetQuestItemLink('choice', index)
			if(not link) then
				-- Item is not located in the cache yet, let it request it
				-- from the server and run this again after its received
				return
			end

			local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
			if(value > bestValue) then
				bestValue, bestIndex = value, index
			end
		end

		if(bestIndex) then
			_G['QuestInfoItem' .. bestIndex]:Click()
		end
	end
end)

addon:Register('QUEST_AUTOCOMPLETE', function()
	for index = 1, GetNumAutoQuestPopUps() do
		local quest, type = GetAutoQuestPopUp(index)

		if(type == 'COMPLETE') then
			-- The quest may not be considered complete by the server
			-- We should check then queue and try again when it is
			ShowQuestComplete(GetQuestLogIndexByID(quest))
		end
	end
end)

addon:Register('BAG_UPDATE', function(bag)
	if(bag < 0) then return end

	for slot = 1, GetContainerNumSlots(bag) do
		local _, id, active = GetContainerItemQuestInfo(bag, slot)
		if(id and not active) then
			CURRENT = id
			UseContainerItem(bag, slot)
			addon:UnregisterEvent('BAG_UPDATE')
		end
	end
end)
