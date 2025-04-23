std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'212/element', -- unused argument element
	'211/L', -- unused variable L
	'312/event', -- unused value of argument event
	'312/unit', -- unused value of argument unit
	'431', -- shadowing an upvalue
	'542', -- empty if branch
	'614', -- trailing whitespace in a comment
	'631', -- line is too long
}

globals = {
	-- savedvariables
	'QuickQuestDB3',
	'QuickQuestBlocklistDB',

	-- old savedvariables for migration
	'QuickQuestDB2',

	-- mutating globals
	'StaticPopupDialogs',
}

read_globals = {
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'BackdropTemplateMixin',
	'FlagsUtil',
	'GameTooltip',
	'Item',
	'Mixin',
	'QuestCache',
	'QuestEventListener',
	'QuestFrame',
	'QuestInfoRewardsFrame',
	'WorldMapFrame',

	-- FrameXML functions
	'CopyTable',
	'GameTooltip_Hide',
	'QuestInfoItem_OnClick',
	'StaticPopup_Show',

	-- GlobalStrings
	'ACCEPT',
	'ACCOUNT_QUEST_LABEL',
	'ADD',
	'ALT_KEY',
	'ALWAYS',
	'CANCEL',
	'CTRL_KEY',
	'ERR_SOULBIND_INVALID_CONDUIT_ITEM',
	'ID',
	'INT_SPELL_POINTS_SPREAD_TEMPLATE',
	'MINIMAP_TRACKING_ACCOUNT_COMPLETED_QUESTS',
	'NEVER',
	'REMOVE',
	'SHIFT_KEY',
	'TARGET',
	'UNKNOWN',

	-- namespaces
	'C_GossipInfo',
	'C_Item',
	'C_Minimap',
	'C_PlayerInteractionManager',
	'C_QuestLog',
	'C_Timer',
	'C_TooltipInfo',
	'Enum',

	-- API
	'AcceptQuest',
	'AcknowledgeAutoAcceptQuest',
	-- 'CloseQuest',
	'CompleteQuest',
	'ConfirmAcceptQuest',
	'CreateFrame',
	'GetActiveQuestID',
	'GetActiveTitle',
	'GetAutoQuestPopUp',
	'GetAvailableLevel',
	'GetAvailableQuestInfo',
	'GetAvailableTitle',
	'GetInstanceInfo',
	'GetNumActiveQuests',
	'GetNumAutoQuestPopUps',
	'GetNumAvailableQuests',
	'GetNumGroupMembers',
	'GetNumQuestChoices',
	'GetNumQuestItems',
	'GetQuestID',
	'GetQuestItemInfo',
	'GetQuestReward',
	'IsQuestCompletable',
	'QuestGetAutoAccept',
	'QuestIsFromAreaTrigger',
	'QuestLogPushQuest',
	'RemoveAutoQuestPopUp',
	'SelectActiveQuest',
	'SelectAvailableQuest',
	'SetPortraitTextureFromCreatureDisplayID',
	'ShowQuestComplete',
	'ShowQuestOffer',
	'UnitIsDeadOrGhost',

	-- addons
	'InteractiveWormholes',
}
