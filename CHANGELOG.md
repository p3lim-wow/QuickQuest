### Changes in 90200.53-Release:

- Added: Options for turning off auto-accepting/completing quests

### Changes in 90200.52-Release:

- Changed: Update Interface version

### Changes in 90100.51-Release:

- Added: Ve'nari repeatable to default blocklist

### Changes in 90100.50-Release:

- Changed: Update Interface version

### Changes in 90000.49-Release:

- Changed: Update Interface version
- Fixed: Completed quest popups not being automatically completed

### Changes in 90000.48-Release:

- Fixed: World map being "disabled" when a popup quest was active
- Fixed: Popup quests staying behind after quest was accepted/completed from it

### Changes in 90000.47-Release:

- Fixed: Excessive chat spam when opening interface options
- Fixed: Blocking quests not showing title when added by ID

### Changes in 90000.46-Release:

- Fixed: Blocked quests by ID not being blocked
- Fixed: Error when adding new quests to blocklist
- Fixed: Blocklists duplicate entries
- Fixed: Quest blocklist showing empty names

### Changes in 90000.45-Release:

- Fixed: Indexing error

### Changes in 90000.44-Release:

- Added: Quest blocklist (thanks @zgavin)
- Changed: Many blocked NPCs are now blocked quests instead by default
- Removed: Compatibility code for older game clients

### Changes in 90000.43-Release:

- Fixed: Gossip skipped even though turned off

### Changes in 90000.42-Release:

- Fixed: Incorrect Interface version

### Changes in 90000.41-Release:

- Added: NPC blocklist config
- Changed: Replaced custom config with Ace3
- Changed: Item blocklist is now sorted
- Changed: Update Interface version
- Fixed: Shadowlands compatibility

### Changes in 80200.40-Release:

- Changed: Update Interface version
- Fixed: Picking up quests in combat

### Changes in 80100.39-Release:

- Changed: Added Dark Iron Mole Machine to the blacklist
- Changed: Update Interface version

### Changes in 80000.38-Release:

- Added: Tezran to the ignore list

### Changes in 80000.37-Release:

- Added: Zurvan to the ignore list

### Changes in 80000.36-Release:

- Added: zhCN translations (thanks @EKE00372)
- Added: zhTW translations (thanks @EKE00372)
- Changed: Using mapID for withered training detection (thanks @siweia)

### Changes in 80000.35-Release:

- Changed: Update Interface version

### Changes in 70300.34-Release:

- Added: Nabiru and High Exarch Turalyon to the NPC blacklist

### Changes in 70300.33-Release:

- Added: Chieftain Hatuun to the NPC blacklist

### Changes in 70300.32-Release:

- Changed: Update Interface version
- Changed: Update embeds for regression fix

### Changes in 70200.31-Release:

- Changed: Proving Grounds is being ignored globally now
- Fixed: LibStub not being packaged recusively

### Changes in 70200.30-Release:

- Changes: No auto-gossip for class challenges

### Changes in 70200.29-Release:

- Fixed: Items not showing up in the blacklist on first load

### Changes in 70200.28-Release:

- Changed: Update Interface version
- Removed: Support for ignoring quests, removed by Blizzard

### Changes in 70100.27-Release:

- Fixed: Libraries path

### Changes in 70100.26-Release:

- Changed: Profession world quests ignoring now work on any locale

### Changes in 70100.25-Release:

- Changed: No longer attempts to automate delivery of "Supplies Needed" world quests

### Changes in 70100.24-Release:

- Changed: Update Interface version
- Changed: No longer attempts to automate delivery of work order world quests

### Changes in 70000.23-Release:

- Added: Option to disable during Withered Scenario (need localization help!)
- Added: Automated rogue class hall door opener
- Added: Exception for Nomi's (MoP version) daily cooking quests
- Changed: Added values to items from the Sixtrigger Brothers' quest chain
- Removed: Old beta client compatibility

### Changes in 70000.22-Release:

- Fixed: Incorrect path in the pagacker metadata file (internal fluff)

### Changes in 70000.21-Release:

- Added: Sassy Imps to the blacklist
- Added: Option to automatically share quests (warning: prone to be annoying)
- Added: Support for ignored quests
- Added: (Hopefully) proper support for auto-completing quests
- Added: Legion's new bonus roll currency NPC to the blacklist
- Changed: Update Interface version
- Changed: Using a library to create the options
- Changed: Using a library to handle API inconsistencies
- Fixed: Garrison scouting missions not being ignored
- Fixed: Auto-accept quests' window getting stuck
- Fixed: String error in the options
- Fixed: Garrison "Mission Specialist" NPC for Alliance not being ignored
- Removed: Auto-accepting quests that start from items (handled by the default UI now)

### Changes in 60100.20-Release

- Added: Garrison scouting missives to the default item blacklist

### Changes in 60100.19-Release:

- Changed: Update Interface version
- Fixed: Sealing Fate automation still running (quest was changed)

### Changes in 60000.18-Release:

- Added: Royal Reward as cash reward from quests in Uldum
- Added: Blacklist for auto-accepting weekly seal quests
- Changed: Improved behavior for auto-accepting quests
- Changed: Blacklist more commonly misclicked NPCs

### Changes in 60000.17-Release:

- Added: More options for handling gossip in raids
- Changed: Blacklisted bodyguards from auto-gossip
- Changed: Disabled localizations until they are more mature
- Fixed: Modifier not working when inverted
- Fixed: Quest rewards sometimes not highlighting properly
- Removed: Delay option

### Changes in 60000.16-Release:

- Added: Changelog
- Added: Localization
- Changed: Update Interface version
- Fixed: "Auto quests" should now complete properly
- Fixed: Further issues brought on by the beta client
- Removed: Compatibility code for "Mists of Pandaria"

### Changes in 50400.15-Release:

- Added: Support for "Warlords of Draenor" expansion

### Changes in 50400.14-Release:

- Fixed: Darkmoon Faire teleporting option

### Changes in 50400.13-Release:

- Added: License
- Added: Metadata file for the curseforge packager
- Added: Custom dropdown to avoid tainting default UI
- Changed: Renamed the addon to "QuickQuest"

### Changes in 50400.12-Release:

- Added: Automatically accept area-triggered quests
- Changed: Update Interface version
- Fixed: Starting-area quests
- Fixed: Options not being selected/shown when using chat command
- Fixed: Item caching
- Removed: Forced quest tracking logic

### Changes in 50300.11-Release:

- Added: Information on tooltip for items in the filter options
- Added: Support for filtering items that is part of a quest
- Fixed: Items in the filter options not having textures

### Changes in 50300.10-Release:

- Added: Delay option
- Changed: Update Interface version

### Changes in 50200.9-Beta:

- Added: Item filter options
- Changed: Update Interface version
- Fixed: Make sure we're able to start the quest from an item before we try to start it

### Changes in 50001.8-Beta:

- Fixed: Errors during login due to early BAG_UPDATE event firing
- Fixed: Logic behind reverse modifier behavior

### Changes in 50001.7-Beta:

- Added: Options
- Fixed: Make sure the quest is tracked on accepting it
- Fixed: Issue with area-triggered quests
- Fixed: Remove even more spam from the chat

### Changes in 50001.6-Beta:

- Added: Item filter for specific repeatable quests
- Changed: Disable auto-accepting quest items while at a merchant
- Fixed: Remove more spam from the chat
- Removed: Quest log modifications

### Changes in 50001.5-Beta:

- Added: Support for "Mists of Pandaria" expansion
- Added: Champion's Purse real value (10 gold)
- Changed: Update Interface version
- Fixed: Select the first quest reward automatically if there's only one
- Fixed: Get the correct index for gossip quests
- Fixed: Taints caused by Blizzard leaking a global variable
- Removed: Quest querying system

### Changes in 40300.4-Beta:

- Added: Automatically pay the Darkmoon Faire teleporters
- Added: Spam filter for auto-accepting quest items
- Changed: Disable auto-accepting quest items while at a mail box, bank or guild bank
- Changed: Disable auto-gossip feature while in a raid

### Changes in 40300.3-Beta:

- Changed: Disable while at the guild bank
- Changed: Let quest querying be forced if needed
- Changed: Manually add quests to the completed list

### Changes in 40300.2-Beta:

- Fixed: Quest querying

### Changes in 40300.1-Beta:

- First public release
