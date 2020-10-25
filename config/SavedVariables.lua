local addonName, ns = ...

local defaults = {
	profile = {
		general = {
			share = false,
			skipgossip = true,
			skipgossipwhen = 1,
			paydarkmoonfaire = true,
			pausekey = 'SHIFT',
			pausekeyreverse = false,
		},
		blocklist = {
			items = {
				-- Inscription weapons
				[31690] = 79343, -- Inscribed Tiger Staff
				[31691] = 79340, -- Inscribed Crane Staff
				[31692] = 79341, -- Inscribed Serpent Staff

				-- Darkmoon Faire artifacts
				[29443] = 71635, -- Imbued Crystal
				[29444] = 71636, -- Monstrous Egg
				[29445] = 71637, -- Mysterious Grimoire
				[29446] = 71638, -- Ornate Weapon
				[29451] = 71715, -- A Treatise on Strategy
				[29456] = 71951, -- Banner of the Fallen
				[29457] = 71952, -- Captured Insignia
				[29458] = 71953, -- Fallen Adventurer's Journal
				[29464] = 71716, -- Soothsayer's Runes

				-- Tiller Gifts
				['progress_79264'] = 79264, -- Ruby Shard
				['progress_79265'] = 79265, -- Blue Feather
				['progress_79266'] = 79266, -- Jade Cat
				['progress_79267'] = 79267, -- Lovely Apple
				['progress_79268'] = 79268, -- Marsh Lily

				-- Garrison scouting missives
				[38180] = 122424, -- Scouting Missive: Broken Precipice
				[38193] = 122423, -- Scouting Missive: Broken Precipice
				[38182] = 122418, -- Scouting Missive: Darktide Roost
				[38196] = 122417, -- Scouting Missive: Darktide Roost
				[38179] = 122400, -- Scouting Missive: Everbloom Wilds
				[38192] = 122404, -- Scouting Missive: Everbloom Wilds
				[38194] = 122420, -- Scouting Missive: Gorian Proving Grounds
				[38202] = 122419, -- Scouting Missive: Gorian Proving Grounds
				[38178] = 122402, -- Scouting Missive: Iron Siegeworks
				[38191] = 122406, -- Scouting Missive: Iron Siegeworks
				[38184] = 122413, -- Scouting Missive: Lost Veil Anzu
				[38198] = 122414, -- Scouting Missive: Lost Veil Anzu
				[38177] = 122403, -- Scouting Missive: Magnarok
				[38190] = 122399, -- Scouting Missive: Magnarok
				[38181] = 122421, -- Scouting Missive: Mok'gol Watchpost
				[38195] = 122422, -- Scouting Missive: Mok'gol Watchpost
				[38185] = 122411, -- Scouting Missive: Pillars of Fate
				[38199] = 122409, -- Scouting Missive: Pillars of Fate
				[38187] = 122412, -- Scouting Missive: Shattrath Harbor
				[38201] = 122410, -- Scouting Missive: Shattrath Harbor
				[38186] = 122408, -- Scouting Missive: Skettis
				[38200] = 122407, -- Scouting Missive: Skettis
				[38183] = 122416, -- Scouting Missive: Socrethar's Rise
				[38197] = 122415, -- Scouting Missive: Socrethar's Rise
				[38176] = 122405, -- Scouting Missive: Stonefury Cliffs
				[38189] = 122401, -- Scouting Missive: Stonefury Cliffs

				-- Misc
				[31664] = 88604, -- Nat's Fishing Journal
			},
			npcs = {
				-- misc
				[103792] = true, -- Griftah (his quests are scams)
				[143925] = true, -- Dark Iron Mole Machine (Dark Iron Dwarf racial)

				-- Bodyguards
				[86945] = true, -- Aeda Brightdawn (Horde)
				[86933] = true, -- Vivianne (Horde)
				[86927] = true, -- Delvar Ironfist (Alliance)
				[86934] = true, -- Defender Illona (Alliance)
				[86682] = true, -- Tormmok
				[86964] = true, -- Leorajh
				[86946] = true, -- Talonpriest Ishaal

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

			},
			quests = {
				-- 6.0 coins
				[36054] = true, -- Sealing Fate: Gold
				[37454] = true, -- Sealing Fate: Piles of Gold
				[37455] = true, -- Sealing Fate: Immense Fortune of Gold
				[36055] = true, -- Sealing Fate: Apexis Crystals
				[37452] = true, -- Sealing Fate: Heap of Apexis Crystals
				[37453] = true, -- Sealing Fate: Mountain of Apexis Crystals
				[36056] = true, -- Sealing Fate: Garrison Resources
				[37456] = true, -- Sealing Fate: Stockpiled Garrison Resources
				[37457] = true, -- Sealing Fate: Tremendous Garrison Resources
				[36057] = true, -- Sealing Fate: Honor

				-- 7.0 coins
				[43892] = true, -- Sealing Fate: Order Resources
				[43893] = true, -- Sealing Fate: Stashed Order Resources
				[43894] = true, -- Sealing Fate: Extraneous Order Resources
				[43895] = true, -- Sealing Fate: Gold
				[43896] = true, -- Sealing Fate: Piles of Gold
				[43897] = true, -- Sealing Fate: Immense Fortune of Gold
				[47851] = true, -- Sealing Fate: Marks of Honor
				[47864] = true, -- Sealing Fate: Additional Marks of Honor
				[47865] = true, -- Sealing Fate: Piles of Marks of Honor

				-- 8.0 coins
				[52834] = true, -- Seal of Wartorn Fate: Gold
				[52838] = true, -- Seal of Wartorn Fate: Piles of Gold
				[52835] = true, -- Seal of Wartorn Fate: Marks of Honor
				[52839] = true, -- Seal of Wartorn Fate: Additional Marks of Honor
				[52837] = true, -- Seal of Wartorn Fate: War Resources
				[52840] = true, -- Seal of Wartorn Fate: Stashed War Resources

				-- 7.0 valuable resources
				[48910] = true, -- Supplying Krokuun
				[48634] = true, -- Further Supplying Krokuun
				[48911] = true, -- Void Inoculation
				[48635] = true, -- More Void Inoculation
				[48799] = true, -- Fuel for a Doomed World
			},
		},
	},
}

ns.EventHandler:Register('ADDON_LOADED', function(...)
	if(... == addonName) then
		-- initialize database with defaults
		ns.db = LibStub('AceDB-3.0'):New('QuickQuestDB2', defaults, true)

		-- migrate old dbs
		if(QuickQuestDB) then
			if(QuickQuestDB.itemBlacklist) then
				for key, value in next, QuickQuestDB.itemBlacklist do
					if not ns.db.profile.blocklist.items[key] then
						ns.db.profile.blocklist.items[key] = value
					end
				end
			end

			if(QuickQuestDB.share ~= nil) then
				ns.db.profile.general.share = QuickQuestDB.share
			end
			if(QuickQuestDB.gossip ~= nil) then
				ns.db.profile.general.skipgossip = QuickQuestDB.gossip
			end
			if(QuickQuestDB.gossipraid ~= nil) then
				ns.db.profile.general.skipgossipwhen = QuickQuestDB.gossipraid
			end
			if(QuickQuestDB.faireport ~= nil) then
				ns.db.profile.general.paydarkmoonfaire = QuickQuestDB.faireport
			end
			if(QuickQuestDB.modifier ~= nil) then
				ns.db.profile.general.pausekey = QuickQuestDB.modifier
			end
			if(QuickQuestDB.reverse ~= nil) then
				ns.db.profile.general.pausekeyreverse = QuickQuestDB.reverse
			end

			QuickQuestDB = nil
		end
		if(QuickQuestBlacklistDB and QuickQuestBlacklistDB.items) then
			for key, value in next, QuickQuestBlacklistDB.items do
				if not ns.db.profile.blocklist.items[key] then
					ns.db.profile.blocklist.items[key] = value
				end
			end

			QuickQuestBlacklistDB = nil
		end

		return true -- unregister
	end
end)
