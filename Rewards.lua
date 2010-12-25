local addon = CreateFrame('Frame')
addon:RegisterEvent('QUEST_COMPLETE')
addon:SetScript('OnEvent', function()
	local bestValue, bestIndex = 0

	for index = 1, GetNumQuestChoices() do
		local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(GetQuestItemLink('choice', index))
		local _, _, quantity = GetQuestItemInfo('choice', index)

		if(value and (value * (quantity or 1) > bestValue)) then
			bestValue, bestIndex = value * (quantity or 1), index
		end
	end

	if(bestIndex) then
		QuestInfoItem_OnClick(_G['QuestInfoItem' .. bestIndex])
	end
end)
