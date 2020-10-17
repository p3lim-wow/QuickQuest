local addonName, ns = ...
local L = ns.L

local function CreateOptions()
	CreateOptions = nop -- we only want to load this once

	LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, {
		type = 'group',
		get = function(info)
			return ns.db.profile.general[info[#info]]
		end,
		set = function(info, value)
			ns.db.profile.general[info[#info]] = value
		end,
		args = {
			share = {
				order = 1,
				name = L['Automatically share quests when picked up'],
				type = 'toggle',
				width = 'double',
			},
			skipgossip = {
				order = 2,
				name = L['Automatically select single gossip options'],
				type = 'toggle',
				width = 'double',
			},
			skipgossipwhen = {
				order = 3,
				name = L['When to select gossip while in a raid'],
				type = 'select',
				width = 'double',
				values = {
					[0] = L['Never'],
					[1] = L['Soloing'],
					[2] = L['Always']
				},
				disabled = function()
					return not ns.db.profile.general.skipgossip
				end,
			},
			paydarkmoonfaire = {
				order = 4,
				name = L['Automatically pay Darkmoon Faire teleporting fees'],
				type = 'toggle',
				width = 'double',
			},
			pausekey = {
				order = 5,
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
				order = 6,
				name = L['Reverse the behaviour of the modifier key'],
				type = 'toggle',
				width = 'double',
			},
		},
	})

	LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addonName)
end

InterfaceOptionsFrameAddOns:HookScript('OnShow', function()
	CreateOptions() -- LoD
	ns.CreateBlocklistOptions() -- LoD

	-- we load too late, so we have to manually refresh the list
	InterfaceAddOnsList_Update()
end)

_G['SLASH_' .. addonName .. '1'] = '/quickquest'
_G['SLASH_' .. addonName .. '2'] = '/qq'
SlashCmdList[addonName] = function()
	CreateOptions() -- LoD
	ns.CreateBlocklistOptions() -- LoD

	InterfaceOptionsFrame_OpenToCategory(addonName)
	InterfaceOptionsFrame_OpenToCategory(addonName) -- load twice due to an old bug
end
