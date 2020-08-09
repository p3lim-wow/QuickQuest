-- compat for new API introduced in 9.0
if select(4, GetBuildInfo()) >= 90000 then
	return
end

C_GossipInfo = {}

local questInfo = {
	-- title
	-- questID
	-- questLevel
	-- isLegendary
	-- isTrivial
	-- isIgnored
	-- repeatable
	-- frequency
	-- isComplete
}

function C_GossipInfo.GetNumActiveQuests()
	return GetNumGossipActiveQuests()
end

function C_GossipInfo.GetNumAvailableQuests()
	return GetNumGossipAvailableQuests()
end

function C_GossipInfo.GetActiveQuests()
	table.wipe(questInfo)

	for index = 1, C_GossipInfo.GetNumActiveQuests() do
		local title, level, isTrivial, isComplete, isLegendary, isIgnored, questID = select(((index * 7) - 7) + 1, GetGossipActiveQuests())
		questInfo[index] = {
			title = title,
			questID = questID,
			questLevel = level,
			isLegendary = isLegendary,
			isTrivial = isTrivial,
			isIgnored = isIgnored,
			isComplete = isIgnored,
		}
	end

	return questInfo
end

function C_GossipInfo.GetAvailableQuests()
	table.wipe(questInfo)

	for index = 1, C_GossipInfo.GetAvailableQuests() do
		local title, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored, questID = select(((index * 8) - 8) + 1, GetGossipAvailableQuests())
		questInfo[index] = {
			title = title,
			questID = questID,
			questLevel = level,
			isLegendary = isLegendary,
			isTrivial = isTrivial,
			isIgnored = isIgnored,
			repeatable = isRepeatable,
			frequency = frequency,
		}
	end

	return questInfo
end

function C_GossipInfo.SelectActiveQuest(index)
	return SelectGossipActiveQuest(index)
end

function C_GossipInfo.SelectAvailableQuest(index)
	return SelectGossipAvailableQuest(index)
end
