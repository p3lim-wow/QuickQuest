if GetLocale() ~= 'zhTW' then return end
local L = select(2, ...).L('zhTW')

-- Config
L['Automatically accept quests'] = '自動接受任務'
L['Automatically complete quests'] = '自動完成任務'
L['Automatically share quests when picked up'] = '接受任務後自動分享'
L['Automatically select single gossip options'] = '自動選擇單一對話選項'
L['When to select gossip while in a raid'] = '當你在團隊中，是否啟用自動選擇對話選項的功能'
L['Automatically pay Darkmoon Faire teleporting fees'] = '自動支付暗月馬戲團傳送費'
L['Reverse the behaviour of the modifier key'] = '反轉輔助鍵的行為（勾選後，按下按鍵才啟用自動交接）'
L['Hold this key to to temporarily pause automation'] = '按下此按鍵來暫時跳過自動化'
L['Automatically select the most valuable reward']  = '自動選擇比較值錢的獎勵'
L['Automatically deliver repeatable delivery quests'] = '自動提交重複的每日任務'

L['Item Blocklist'] = '物品阻擋清單'
L['NPC Blocklist'] = 'NPC阻擋清單'
L['Title Blocklist'] = '抬頭阻擋清單'
L['Block Item'] = '阻擋物品'
L['Block NPC'] = '阻擋NPC'
L['Block Title'] = '阻擋抬頭'
L['Quests containing items in this list will not be automated.'] = '在此清單中包含物品的任務將不會自動化。'
L['Quests and dialogue from NPCs in this list will not be automated.'] = '在此清單中來自NPC的對話與任務將不會自動化。'

L['Block a new item by ID'] = '阻擋新的物品根據ID'
L['Block a new NPC by ID'] = '阻擋新的NPC根據ID'
-- L['Quests (by partial title or ID) in this list will not be automated.'] = '' -- MISSING!

L['ALT key'] = ALT_KEY
L['CTRL key'] = CTRL_KEY
L['SHIFT key'] = SHIFT_KEY

L['Never'] = NEVER
L['Always'] = ALWAYS
L['Soloing'] = '單人'

L['Accept'] = ACCEPT
L['Cancel'] = CANCEL
L['Target'] = TARGET
L['Invalid Item'] = ERR_SOULBIND_INVALID_CONDUIT_ITEM
