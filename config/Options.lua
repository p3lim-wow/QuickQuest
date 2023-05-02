local addonName, addon = ...
local L = addon.L

local function CreateOptions()
	CreateOptions = nop -- we only want to load this once

	LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, {
		type = 'group',
		get = function(info)
			return addon.db.profile.general[info[#info]]
		end,
		set = function(info, value)
			addon.db.profile.general[info[#info]] = value
		end,
		args = {
			accept = {
				order = 1,
				name = L['Automatically accept quests'],
				type = 'toggle',
				width = 'double',
			},
			complete = {
				order = 2,
				name = L['Automatically complete quests'],
				type = 'toggle',
				width = 'double',
			},
			selectreward = {
				order = 3,
				name = L['Automatically select the reward that\'s worth the most'],
				type = 'toggle',
				width = 'double',
			},
			acceptRepeatables = {
				order = 4,
				name = L['Automatically deliver repeatable delivery quests'],
				type = 'toggle',
				width = 'double',
			},
			share = {
				order = 5,
				name = L['Automatically share quests when picked up'],
				type = 'toggle',
				width = 'double',
			},
			skipgossip = {
				order = 6,
				name = L['Automatically select single gossip options'],
				type = 'toggle',
				width = 'double',
			},
			skipgossipwhen = {
				order = 7,
				name = L['When to select gossip while in a raid'],
				type = 'select',
				width = 'double',
				values = {
					[0] = L['Never'],
					[1] = L['Soloing'],
					[2] = L['Always']
				},
				disabled = function()
					return not addon.db.profile.general.skipgossip
				end,
			},
			paydarkmoonfaire = {
				order = 8,
				name = L['Automatically pay Darkmoon Faire teleporting fees'],
				type = 'toggle',
				width = 'double',
			},
			pausekey = {
				order = 9,
				name = L['Hold this key to to temporarily pause automation'],
				type = 'select',
				width = 'double',
				values = {
					ALT = L['ALT key'],
					CTRL = L['CTRL key'],
					SHIFT = L['SHIFT key']
				}
			},
			pausekeyreverse = {
				order = 10,
				name = L['Reverse the behaviour of the modifier key'],
				type = 'toggle',
				width = 'double',
			},
		},
	})

	LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addonName)
end

addon:HookSettings(function()
	CreateOptions() -- LoD
	addon.CreateBlocklistOptions() -- LoD
end)

addon:RegisterSlash('/quickquest', '/qq', function()
	CreateOptions() -- LoD
	addon.CreateBlocklistOptions() -- LoD

	addon:OpenSettings(addonName)
end)
