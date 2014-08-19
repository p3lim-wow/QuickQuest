local WoD = select(4, GetBuildInfo()) >= 6e4

local QuickQuest = CreateFrame('Frame')
QuickQuest:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local DelayHandler
do
	local currentInfo = {}

	local Delayer = QuickQuest:CreateAnimationGroup()
	Delayer:CreateAnimation():SetDuration(1)
	Delayer:SetLooping('NONE')
	Delayer:SetScript('OnFinished', function()
		DelayHandler(unpack(currentInfo))
	end)

	local delayed = true
	function DelayHandler(func, ...)
		if(delayed) then
			delayed = false

			table.wipe(currentInfo)
			table.insert(currentInfo, func)

			for index = 1, select('#', ...) do
				local argument = select(index, ...)
				table.insert(currentInfo, argument)
			end

			Delayer:Play()
		else
			delayed = true
			func(...)
		end
	end
end

local atBank, atMail, atMerchant
local choiceQueue, autoCompleteIndex

local delayEvent = {
	GOSSIP_SHOW = true,
	GOSSIP_CONFIRM = true,
	QUEST_GREETING = true,
	QUEST_DETAIL = true,
	QUEST_ACCEPT_CONFIRM = true,
	QUEST_PROGRESS = true,
	QUEST_AUTOCOMPLETE = true
}

local modifier = false
function QuickQuest:Register(event, func, override)
	self:RegisterEvent(event)
	self[event] = function(...)
		if(override or QuickQuestDB.toggle and QuickQuestDB.reverse == modifier) then
			if(QuickQuestDB.delay and delayEvent[event]) then
				DelayHandler(func, ...)
			else
				func(...)
			end
		end
	end
end

local function IsTrackingTrivial()
	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if(name == MINIMAP_TRACKING_TRIVIAL_QUESTS) then
			return active
		end
	end
end

QuickQuest:Register('QUEST_GREETING', function()
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

local GetCreatureID
if(WoD) then
	function GetCreatureID()
		local type, _, _, _, _, id = string.split(':', UnitGUID('npc') or '')
		if(type == 'Creature' and id and tonumber(id)) then
			return tonumber(id)
		end
	end
else
	function GetCreatureID()
		return tonumber(string.sub(UnitGUID('npc') or '', -12, -9), 16)
	end
end

QuickQuest:Register('GOSSIP_SHOW', function()
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

	if(QuickQuestDB.gossip) then
		if(available == 0 and active == 0 and GetNumGossipOptions() == 1) then
			local _, instance = GetInstanceInfo()
			if(not (QuickQuestDB.gossipraid and instance == 'raid')) then
				local _, type = GetGossipOptions()
				if(type == 'gossip') then
					SelectGossipOption(1)
					return
				end
			end
		end
	end

	if(QuickQuestDB.faireport) then
		local creatureID = GetCreatureID()
		if(creatureID and creatureID == 57850) then
			-- See if 1 is the right option
			SelectGossipOption(1)
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

	local creatureID = GetCreatureID()
	if(creatureID and darkmoonNPC[creatureID]) then
		SelectGossipOption(index, '', true)
		StaticPopup_Hide('GOSSIP_CONFIRM')
	end
end)

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
end)

QuickQuest:Register('QUEST_PROGRESS', function()
	if(IsQuestCompletable()) then
		local requiredItems = GetNumQuestItems()
		if(requiredItems > 0) then
			for index = 1, requiredItems do
				local link = GetQuestItemLink('required', index)
				if(link) then
					local id = tonumber(string.match(link, 'item:(%d+)'))
					for _, itemID in next, QuickQuestDB.ignoredQuests do
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
	elseif(choices > 1) then
		local bestValue, bestIndex = 0

		for index = 1, choices do
			local link = GetQuestItemLink('choice', index)
			if(link) then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)

				if(string.match(link, 'item:45724:')) then
					-- Champion's Purse, contains 10 gold
					value = 1e5
				end

				if(value > bestValue) then
					bestValue, bestIndex = value, index
				end
			else
				choiceQueue = 'QUEST_COMPLETE'
				return GetQuestItemInfo('choice', index)
			end
		end

		if(bestIndex) then
			if(WoD) then
				QuestInfoFrame.rewardsFrame.RewardButton[bestIndex]:Click()
			else
				_G['QuestInfoItem' .. bestIndex]:Click()
			end
		end
	end
end)

QuickQuest:Register('QUEST_FINISHED', function()
	choiceQueue = nil
	autoCompleteIndex = nil
end)

QuickQuest:Register('QUEST_AUTOCOMPLETE', function(id)
	local index = GetQuestLogIndexByID(id)
	if(GetQuestLogIsAutoComplete(index)) then
		ShowQuestComplete(index)

		autoCompleteIndex = index
	end
end)

QuickQuest:Register('BAG_UPDATE_DELAYED', function()
	if(autoCompleteIndex) then
		ShowQuestComplete(autoCompleteIndex)

		autoCompleteIndex = nil
	end
end)

QuickQuest:Register('BANKFRAME_OPENED', function()
	atBank = true
end)

QuickQuest:Register('BANKFRAME_CLOSED', function()
	atBank = false
end)

QuickQuest:Register('GUILDBANKFRAME_OPENED', function()
	atBank = true
end)

QuickQuest:Register('GUILDBANKFRAME_CLOSED', function()
	atBank = false
end)

QuickQuest:Register('MAIL_SHOW', function()
	atMail = true
end)

QuickQuest:Register('MAIL_CLOSED', function()
	atMail = false
end)

QuickQuest:Register('MERCHANT_SHOW', function()
	atMerchant = true
end)

QuickQuest:Register('MERCHANT_CLOSED', function()
	atMerchant = false
end)

local sub = string.sub
QuickQuest:Register('MODIFIER_STATE_CHANGED', function(key, state)
	if(sub(key, 2) == QuickQuestDB.modifier) then
		modifier = state == 1
	end
end, true)

local questTip = CreateFrame('GameTooltip', 'QuickQuestTip', UIParent)
local questLevel = string.gsub(ITEM_MIN_LEVEL, '%%d', '(%%d+)')

local function GetQuestItemLevel()
	for index = 1, questTip:NumLines() do
		local level = string.match(_G['QuickQuestTipTextLeft' .. index]:GetText(), questLevel)
		if(level and tonumber(level)) then
			return tonumber(level)
		end
	end
end

local function BagUpdate(bag)
	if(not QuickQuestDB.items) then return end
	if(atBank or atMail or atMerchant) then return end

	for slot = 1, GetContainerNumSlots(bag) do
		local _, id, active = GetContainerItemQuestInfo(bag, slot)
		if(id and not active and not IsQuestFlaggedCompleted(id) and not QuickQuestDB.ignoredQuests[id]) then
			questTip:SetBagItem(bag, slot)
			questTip:Show()

			local level = GetQuestItemLevel()
			if(not level or level >= UnitLevel('player')) then
				UseContainerItem(bag, slot)
			end
		end
	end
end

QuickQuest:Register('PLAYER_LOGIN', function()
	QuickQuest:Register('BAG_UPDATE', BagUpdate)
end)

local errors = {
	[ERR_QUEST_ALREADY_DONE] = true,
	[ERR_QUEST_FAILED_LOW_LEVEL] = true,
	[ERR_QUEST_NEED_PREREQS] = true,
}

ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', function(self, event, message)
	return errors[message]
end)

QuestInfoDescriptionText.SetAlphaGradient = function() end
