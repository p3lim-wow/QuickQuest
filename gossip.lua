local _, addon = ...

local DARKMOON_GOSSIP = {
	[40007] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[40457] = true, -- Darkmoon Faire Mystic Mage (Alliance)
}

local QUEST_GOSSIP = {
	-- usually only addeed if they're repeatable
	[109275] = true, -- Soridormi - begin time rift
	[120619] = true, -- Big Dig task
	[120620] = true, -- Big Dig task
	[120555] = true, -- Awakening The Machine
	[120733] = true, -- Theater Troupe

	-- Darkmoon Faire
	[40563] = true, -- whack
	[28701] = true, -- cannon
	[31202] = true, -- shoot
	[39245] = true, -- tonk
	[40224] = true, -- ring toss
	[43060] = true, -- firebird
	[52651] = true, -- dance
	[41759] = true, -- pet battle 1
	[42668] = true, -- pet battle 2
	[40872] = true, -- cannon return (Teleportologist Fozlebub)
}

local IGNORE_GOSSIP = {
	-- when we don't want to automate gossip because it's counter-intuitive
	[122442] = true, -- leave the dungeon in remix

	-- avoid accidental teleports
	[44733] = true,
	[125350] = true, -- siren isle
	[125351] = true, -- siren isle
	[131324] = true, -- winter veil hillsbrad
	[131325] = true, -- winter veil hillsbrad
}

function addon:GOSSIP_SHOW()
	if addon:IsPaused() or addon:IsNPCIgnored() then
		return
	end

	if C_PlayerInteractionManager.IsInteractingWithNpcOfType(Enum.PlayerInteractionType.TaxiNode) then
		-- don't annoy taxi addons
		return
	end

	if InteractiveWormholes and InteractiveWormholes:IsActive() then
		-- respect other addons
		return
	end

	-- need to iterate all the options first before we can select them
	local gossipQuests = {}
	local gossipSkips = {}

	local gossip = C_GossipInfo.GetOptions()
	for _, info in next, gossip do
		if DARKMOON_GOSSIP[info.gossipOptionID] and addon:GetOption('paydarkmoonfaire') then
			-- we can select this one directly since it never interferes with the others
			C_GossipInfo.SelectOption(info.gossipOptionID, '', true)
			return
		elseif QUEST_GOSSIP[info.gossipOptionID] then
			table.insert(gossipQuests, info.gossipOptionID)
		elseif FlagsUtil.IsSet(info.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend) then
			table.insert(gossipQuests, info.gossipOptionID)
		elseif info.name:sub(1, 11) == '|cFFFF0000<' then
			-- TODO: this might get a flag in the future
			table.insert(gossipSkips, info.gossipOptionID)
		end
	end

	if #gossipSkips == 1 and addon:GetOption('autoquestgossip') then
		C_GossipInfo.SelectOption(gossipSkips[1])
		return
	elseif #gossipQuests == 1 and addon:GetOption('autoquestgossip') then
		C_GossipInfo.SelectOption(gossipQuests[1])
		return
	end

	if (C_GossipInfo.GetNumActiveQuests() + C_GossipInfo.GetNumAvailableQuests()) > 0 then
		-- don't automate misc gossip if the NPC is a quest giver
		return
	end

	if #gossip ~= 1 then
		-- more than 1 option
		return
	end

	if not addon:GetOption('skipgossip') then
		return
	end

	if not gossip[1].gossipOptionID then
		-- intentionally blocked gossip
		return
	end

	if IGNORE_GOSSIP[gossip[1].gossipOptionID] then
		return
	end

	local _, instanceType = GetInstanceInfo()
	if instanceType == 'raid' and addon:GetOption('skipgossipwhen') > 1 then
		if GetNumGroupMembers() <= 1 or addon:GetOption('skipgossipwhen') == 3 then
			C_GossipInfo.SelectOption(gossip[1].gossipOptionID)
		end
	elseif instanceType ~= 'raid' then
		C_GossipInfo.SelectOption(gossip[1].gossipOptionID)
	end
end
