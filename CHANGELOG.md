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
