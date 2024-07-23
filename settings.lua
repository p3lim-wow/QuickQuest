local _, addon = ...
local L = addon.L

addon:RegisterSettings('QuickQuestDB3', {
	{
		key = 'accept',
		type = 'toggle',
		title = L['Automatically accept quests'],
		default = true,
	},
	{
		key = 'complete',
		type = 'toggle',
		title = L['Automatically complete quests'],
		default = true,
	},
	{
		key = 'acceptRepeatables',
		type = 'toggle',
		title = L['Automate repeatable quests'],
		default = true,
	},
	{
		key = 'selectreward',
		type = 'toggle',
		title = L['Highlight valuable reward'],
		default = true,
	},
	{
		key = 'share',
		type = 'toggle',
		title = L['Automatically share quests'],
		default = false,
	},
	{
		key = 'autoquestgossip',
		type = 'toggle',
		title = L['Skip quest gossip options'],
		default = true,
		new = true,
	},
	{
		key = 'skipgossip',
		type = 'toggle',
		title = L['Automate gossip options'],
		default = true,
	},
	{
		key = 'skipgossipwhen',
		type = 'menu',
		title = L['When to automate gossip'],
		default = 2,
		options = {
			L['Never'],
			L['Soloing'],
			L['Always'],
		},
	},
	{
		key = 'paydarkmoonfaire',
		type = 'toggle',
		title = L['Pay Darkmoon Faire teleport'],
		default = true,
	},
	{
		key = 'pausekey',
		type = 'menu',
		title = L['Pause mode modifier'],
		tooltip = L['Hold this key to temporarily disable all automation'],
		default = 'SHIFT',
		options = {
			ALT = L['ALT key'],
			CTRL = L['CTRL key'],
			SHIFT = L['SHIFT key'],
		},
	},
	{
		key = 'pausekeyreverse',
		type = 'toggle',
		title = L['Reverse pause mode'],
		tooltip = L["While the pause key is NOT held don't automate anything"],
		default = false,
	},
})

addon:RegisterSettingsSlash('/quickquest', '/qq')

-- the rest of this file is just blocklist options, ugh

local blocklistDefaults = {
	items = {
		-- Tiller Gifts
		[79264] = true, -- Ruby Shard
		[79265] = true, -- Blue Feather
		[79266] = true, -- Jade Cat
		[79267] = true, -- Lovely Apple
		[79268] = true, -- Marsh Lily

		-- Misc
		[88604] = true, -- Nat's Fishing Journal
	},
	npcs = {
		-- accidental resource waste
		[87391] = true, -- Fate-Twister Seress (gold, currencies)
		[88570] = true, -- Fate-Twister Tiklal (gold, currencies)
		[78495] = true, -- Shadow Hunter Ukambe (garrison missives)
		[81152] = true, -- Scout Valdez (garrison missives)
		[111243] = true, -- Archmage Lan'dalock (gold, currencies)
		[141584] = true, -- Zurvan (gold, currencies)
		[142063] = true, -- Tezran (gold, currencies)
		[193110] = true, -- Khadin (Dragon Shard of Knowledge)

		-- Sassy Imps
		[95139] = true,
		[95141] = true,
		[95142] = true,
		[95143] = true,
		[95144] = true,
		[95145] = true,
		[95146] = true,
		[95200] = true,
		[95201] = true,

		-- Teleportation
		[143925] = true, -- Dark Iron Mole Machine (Dark Iron Dwarf racial)
		[121602] = true, -- Manapoof in Dalaran
		[147666] = true, -- Manapoof in Boralus
		[147642] = true, -- Manapoof in Dazar'alor
	},
	quests = {
		-- 7.0 valuable resources
		[48634] = true, -- Further Supplying Krokuun
		[48635] = true, -- More Void Inoculation
		[48799] = true, -- Fuel for a Doomed World
		[48910] = true, -- Supplying Krokuun
		[48911] = true, -- Void Inoculation

		-- 8.0 emissaries
		[54451] = true, -- Baubles from the Seekers
		[53982] = true, -- Supplies From The Unshackled
		[54453] = true, -- Supplies from Magni
		[54454] = true, -- Supplies from 7th Legion
		[54455] = true, -- Supplies from Honorbound
		[54456] = true, -- Supplies from Order of Embers
		[54457] = true, -- Supplies from Storm Wake
		[54458] = true, -- Supplies from Proudmoore Admiralty
		[54460] = true, -- Supplies from Talanji's Expedition
		[54461] = true, -- Supplies from Voldunai Supplies
		[54462] = true, -- Supplies from Zandalari Empire
		[55348] = true, -- Supplies from the Rustbolt Resistance
		[55976] = true, -- Supplies From the Waveblade Ankoan

		-- 9.0 valuable resources
		[64541] = true, -- The Cost of Death (Ve'nari)

		-- 10.0 valuable resources
		[75164] = true, -- In Need of Primal Foci
		[75165] = true, -- In Need of Concentrated Primal Foci
		[75166] = true, -- In Need of Many Primal Foci
		[75167] = true, -- In Need of Many Concentrated Primal Foci
	}
}

addon:RegisterSubCanvas('Item Blocklist', function(canvas)
	-- TODO
end)

addon:RegisterSubCanvas('NPC Blocklist', function(canvas)
	-- TODO
end)

addon:RegisterSubCanvas('Quest Blocklist', function(canvas)
	-- TODO
end)

function addon:PLAYER_LOGIN()
	if not QuickQuestBlocklistDB then
		-- set default
		QuickQuestBlocklistDB = CopyTable(blocklistDefaults)
	end

	-- inject new blocklist defaults
	for kind, values in next, blocklistDefaults do
		for key, value in next, values do
			if QuickQuestBlocklistDB[kind][key] == nil then
				QuickQuestBlocklistDB[kind][key] = value
			end
		end
	end

	-- TODO: migrate old settings
end
