std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'212/element', -- unused argument element
	'312/event', -- unused value of argument event
	'312/unit', -- unused value of argument unit
	'431', -- shadowing an upvalue
	'614', -- trailing whitespace in a comment
	'631', -- line is too long
}

exclude_files = {}

globals = {
	-- FrameXML objects we mutate
	'SlashCmdList', -- FrameXML/ChatFrame.lua
	'StaticPopupDialogs', -- FrameXML/StaticPopup.lua

	-- savedvariables
	'QuickQuestDB',
	'QuickQuestBlacklistDB',
}

read_globals = {
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'GameTooltip', -- ???
	'Item', -- FrameXML/ObjectAPI/Item.lua
	'WorldMapFrame', -- FrameXML/WorldMapFrame.xml
	'QuestInfoRewardsFrame', -- FrameXML/QuestInfo.xml
	'QuestCache', -- 'FrameXML/ObjectAPI/Quest.lua'
	'QuestEventListener', -- FrameXML/ObjectAPI/AsyncCallbackSystem.lua

	'InterfaceOptionsFrameAddOns', -- OLD
	'InterfaceOptionsFramePanelContainer', -- OLD

	-- FrameXML functions
	'nop', -- FrameXML/UIParent.lua
	'GameTooltip_Hide', -- FrameXML/GameTooltip.lua
	'StaticPopup_Show', -- FrameXML/StaticPopup.lua
	'StaticPopup_Hide', -- FrameXML/StaticPopup.lua
	'QuestInfoItem_OnClick', -- FrameXML/QuestInfo.lua

	'InterfaceOptions_AddCategory', -- OLD
	'InterfaceAddOnsList_Update', -- OLD
	'InterfaceOptionsFrame_OpenToCategory', -- OLD

	-- SharedXML objects
	'FlagsUtil', -- SharedXML/Flags.lua
	'Settings', -- SharedXML/Settings/Blizzard_Settings.lua
	'SettingsPanel', -- SharedXML/Settings/Blizzard_SettingsPanel.xml
	'TooltipUtil', -- SharedXML/Tooltip/TooltipUtil.lua

	-- SharedXML functions
	'Mixin', -- SharedXML/Mixin.lua
	'CreateFramePool', -- SharedXML/Pools.lua
	'FramePool_HideAndClearAnchors', -- SharedXML/Pools.lua
	'GetItemInfoFromHyperlink', -- SharedXML/LinkUtil.lua

	-- GlobalStrings
	'ACCEPT',
	'ALT_KEY',
	'ALWAYS',
	'CANCEL',
	'CTRL_KEY',
	'ERR_SOULBIND_INVALID_CONDUIT_ITEM',
	'MINIMAP_TRACKING_TRIVIAL_QUESTS',
	'NEVER',
	'SHIFT_KEY',
	'TARGET',
	'UNKNOWN',

	-- namespaces
	'C_GossipInfo',
	'C_Map',
	'C_Minimap',
	'C_QuestLog',
	'C_Timer',
	'C_TooltipInfo',
	'Enum',

	-- API
	'AcceptQuest',
	'AcknowledgeAutoAcceptQuest',
	'CloseQuest',
	'CompleteQuest',
	'CreateFrame',
	'GetActiveQuestID',
	'GetActiveTitle',
	'GetAutoQuestPopUp',
	'GetAvailableQuestInfo',
	'GetBuildInfo',
	'GetInstanceInfo',
	'GetItemInfo',
	'GetItemInfoInstant',
	'GetLocale',
	'GetNumActiveQuests',
	'GetNumAutoQuestPopUps',
	'GetNumAvailableQuests',
	'GetNumGroupMembers',
	'GetNumQuestChoices',
	'GetNumQuestItems',
	'GetNumTrackingTypes',
	'GetQuestID',
	'GetQuestItemInfo',
	'GetQuestItemLink',
	'GetQuestReward',
	'GetTrackingInfo',
	'IsQuestCompletable',
	'QuestGetAutoAccept',
	'QuestIsFromAreaTrigger',
	'QuestLogPushQuest',
	'RemoveAutoQuestPopUp',
	'SelectActiveQuest',
	'SelectAvailableQuest',
	'ShowQuestComplete',
	'ShowQuestOffer',
	'UnitGUID',
	'UnitIsDeadOrGhost',

	-- exposed from other addons
	'LibStub',
}
