local QuickQuest = CreateFrame('Frame')
QuickQuest:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local atBank, atMail, atMerchant
local choiceQueue, autoCompleteIndex, autoCompleteTicker

local metatable = {
	__call = function(methods, ...)
		for _, method in next, methods do
			method(...)
		end
	end
}

local modifier = false
function QuickQuest:Register(event, method, override)
	local newmethod
	if(not override) then
		newmethod = function(...)
			if(QuickQuestDB.toggle and QuickQuestDB.reverse == modifier) then
				method(...)
			end
		end
	end

	local methods = self[event]
	if(methods) then
		self[event] = setmetatable({methods, newmethod or method}, metatable)
	else
		self[event] = newmethod or method
		self:RegisterEvent(event)
	end
end

local function GetNPCID()
	return tonumber(string.match(UnitGUID('npc') or '', 'Creature%-.-%-.-%-.-%-.-%-(.-)%-'))
end

local function IsTrackingTrivial()
	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if(name == MINIMAP_TRACKING_TRIVIAL_QUESTS) then
			return active
		end
	end
end

local ignoreQuestNPC = {
	[88570] = true, -- Fate-Twister Tiklal
	[87391] = true, -- Fate-Twister Seress
}

QuickQuest:Register('QUEST_GREETING', function()
	local npcID = GetNPCID()
	if(ignoreQuestNPC[npcID]) then
		return
	end

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
			if(not IsAvailableQuestTrivial(index) or IsTrackingTrivial()) then
				SelectAvailableQuest(index)
			end
		end
	end
end)

-- This should be part of the API, really
local function IsGossipQuestCompleted(index)
	return not not select(((index * 5) - 5) + 4, GetGossipActiveQuests())
end

local function IsGossipQuestTrivial(index)
	return not not select(((index * 6) - 6) + 3, GetGossipAvailableQuests())
end

local ignoreGossipNPC = {
	-- Bodyguards
	[86945] = true, -- Aeda Brightdawn (Horde)
	[86933] = true, -- Vivianne (Horde)
	[86927] = true, -- Delvar Ironfist (Alliance)
	[86934] = true, -- Defender Illona (Alliance)
	[86682] = true, -- Tormmok
	[86964] = true, -- Leorajh
	[86946] = true, -- Talonpriest Ishaal

	-- Misc NPCs
	[79740] = true, -- Warmaster Zog (Horde)
	[79953] = true, -- Lieutenant Thorn (Alliance)

	-- Sassy Imps variants
	[95142] = true,
	[95201] = true,
	[95200] = true,
	[95141] = true,
	[95139] = true,
	[95144] = true,
	[95146] = true,
	[95143] = true,
	[95145] = true,
}

QuickQuest:Register('GOSSIP_SHOW', function()
	local npcID = GetNPCID()
	if(ignoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumGossipActiveQuests()
	if(active > 0) then
		for index = 1, active do
			if(IsGossipQuestCompleted(index)) then
				SelectGossipActiveQuest(index)
			end
		end
	end

	local available = GetNumGossipAvailableQuests()
	if(available > 0) then
		for index = 1, available do
			if(not IsGossipQuestTrivial(index) or IsTrackingTrivial()) then
				SelectGossipAvailableQuest(index)
			end
		end
	end

	if(available == 0 and active == 0 and GetNumGossipOptions() == 1) then
		local npcID = GetNPCID()
		if(QuickQuestDB.faireport) then
			if(npcID == 57850) then
				return SelectGossipOption(1)
			end
		end

		if(QuickQuestDB.gossip) then
			local _, instance = GetInstanceInfo()
			if(instance == 'raid' and QuickQuestDB.gossipraid > 0) then
				if(GetNumGroupMembers() > 1 and QuickQuestDB.gossipraid < 2) then
					return
				end

				SelectGossipOption(1)
			elseif(instance ~= 'raid' and not ignoreGossipNPC[npcID]) then
				SelectGossipOption(1)
			end
		end
	end
end)

local darkmoonNPC = {
	[57850] = true, -- Teleportologist Fozlebub
	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
}

QuickQuest:Register('GOSSIP_CONFIRM', function(index)
	if(not QuickQuestDB.faireport) then return end

	local npcID = GetNPCID()
	if(npcID and darkmoonNPC[npcID]) then
		SelectGossipOption(index, '', true)
		StaticPopup_Hide('GOSSIP_CONFIRM')
	end
end)

QuestFrame:UnregisterEvent('QUEST_DETAIL')
QuickQuest:Register('QUEST_DETAIL', function()
	if(not QuestGetAutoAccept() or not QuestIsFromAreaTrigger()) then
		QuestFrame_OnEvent(QuestFrame, 'QUEST_DETAIL')
	end
end, true)

QuickQuest:Register('QUEST_DETAIL', function()
	if(not QuestGetAutoAccept()) then
		AcceptQuest()
	end
end)

QuickQuest:Register('QUEST_ACCEPT_CONFIRM', AcceptQuest)

QuickQuest:Register('QUEST_ACCEPTED', function(id)
	if(QuestFrame:IsShown() and QuestGetAutoAccept()) then
		CloseQuest()
	end
end)

QuickQuest:Register('QUEST_ITEM_UPDATE', function()
	if(choiceQueue and QuickQuest[choiceQueue]) then
		QuickQuest[choiceQueue]()
	end
end, true)

QuickQuest:Register('QUEST_PROGRESS', function()
	if(IsQuestCompletable()) then
		local requiredItems = GetNumQuestItems()
		if(requiredItems > 0) then
			for index = 1, requiredItems do
				local link = GetQuestItemLink('required', index)
				if(link) then
					local id = tonumber(string.match(link, 'item:(%d+)'))
					for _, itemID in next, QuickQuestDB.itemBlacklist do
						if(itemID == id) then
							return
						end
					end
				else
					choiceQueue = 'QUEST_PROGRESS'
					return
				end
			end
		end

		CompleteQuest()
	end
end)

QuickQuest:Register('QUEST_COMPLETE', function()
	local choices = GetNumQuestChoices()
	if(choices <= 1) then
		GetQuestReward(1)
	end
end)

local cashRewards = {
	[45724] = 1e5, -- Champion's Purse
	[64491] = 2e6, -- Royal Reward
}

QuickQuest:Register('QUEST_COMPLETE', function()
	local choices = GetNumQuestChoices()
	if(choices > 1) then
		local bestValue, bestIndex = 0

		for index = 1, choices do
			local link = GetQuestItemLink('choice', index)
			if(link) then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
				value = cashRewards[tonumber(string.match(link, 'item:(%d+):'))] or value

				if(value > bestValue) then
					bestValue, bestIndex = value, index
				end
			else
				choiceQueue = 'QUEST_COMPLETE'
				return GetQuestItemInfo('choice', index)
			end
		end

		if(bestIndex) then
			QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[bestIndex])
		end
	end
end, true)

QuickQuest:Register('QUEST_FINISHED', function()
	choiceQueue = nil
	autoCompleteIndex = nil

	if(autoCompleteTicker) then
		autoCompleteTicker:Cancel()
		autoCompleteTicker = nil
	end

	if(GetNumAutoQuestPopUps() > 0) then
		QuickQuest:QUEST_AUTOCOMPLETE()
	end
end)

local function CompleteAutoComplete(self)
	if(not autoCompleteIndex and GetNumAutoQuestPopUps() > 0) then
		local id, type = GetAutoQuestPopUp(1)
		if(type == 'COMPLETE') then
			local index = GetQuestLogIndexByID(id)
			ShowQuestComplete(index)
			autoCompleteIndex = index
		end

		self:Cancel()
	end
end

QuickQuest:Register('QUEST_AUTOCOMPLETE', function(questID)
	autoCompleteTicker = C_Timer.NewTicker(1/4, CompleteAutoComplete, 20)
end)

QuickQuest:Register('BAG_UPDATE_DELAYED', function()
	if(autoCompleteIndex) then
		ShowQuestComplete(autoCompleteIndex)
		autoCompleteIndex = nil
	end
end)

QuickQuest:Register('BANKFRAME_OPENED', function()
	atBank = true
end, true)

QuickQuest:Register('BANKFRAME_CLOSED', function()
	atBank = false
end, true)

QuickQuest:Register('GUILDBANKFRAME_OPENED', function()
	atBank = true
end, true)

QuickQuest:Register('GUILDBANKFRAME_CLOSED', function()
	atBank = false
end, true)

QuickQuest:Register('MAIL_SHOW', function()
	atMail = true
end, true)

QuickQuest:Register('MAIL_CLOSED', function()
	atMail = false
end, true)

QuickQuest:Register('MERCHANT_SHOW', function()
	atMerchant = true
end, true)

QuickQuest:Register('MERCHANT_CLOSED', function()
	atMerchant = false
end, true)

local sub = string.sub
QuickQuest:Register('MODIFIER_STATE_CHANGED', function(key, state)
	if(sub(key, 2) == QuickQuestDB.modifier) then
		modifier = state == 1
	end
end, true)

local questTip = CreateFrame('GameTooltip', 'QuickQuestTip', UIParent, 'GameTooltipTemplate')
local questString = string.gsub(ITEM_MIN_LEVEL, '%%d', '(%%d+)')

local function GetContainerItemQuestLevel(bag, slot)
	questTip:SetOwner(UIParent, 'ANCHOR_NONE')
	questTip:SetBagItem(bag, slot)

	for index = 1, questTip:NumLines() do
		local level = tonumber(string.match(_G['QuickQuestTipTextLeft' .. index]:GetText(), questString))
		if(level) then
			return level
		end
	end

	return 1
end

local function BagUpdate(bag)
	if(not QuickQuestDB.items) then return end
	if(atBank or atMail or atMerchant) then return end

	for slot = 1, GetContainerNumSlots(bag) do
		local _, id, active = GetContainerItemQuestInfo(bag, slot)
		if(id and not active and not IsQuestFlaggedCompleted(id) and not QuickQuestDB.itemBlacklist[id]) then
			local level = GetContainerItemQuestLevel(bag, slot)
			if(level <= UnitLevel('player')) then
				UseContainerItem(bag, slot)
			end
		end
	end
end

QuickQuest:Register('PLAYER_LOGIN', function()
	QuickQuest:Register('BAG_UPDATE', BagUpdate)

	if(GetNumAutoQuestPopUps() > 0) then
		QuickQuest:QUEST_AUTOCOMPLETE()
	end
end)
