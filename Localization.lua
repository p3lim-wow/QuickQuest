local _, L = ...

local ItemBlacklistTooltip = [[
Easily add more items to filter by
grabbing one from your inventory
and dropping it into the box below.

Just as easily you remove an existing
item by right-clicking on it.
]]

setmetatable(L, {__index = function(L, key)
	local value = key == 'ItemBlacklistTooltip' and ItemBlacklistTooltip or tostring(key)
	L[key] = value
	return value
end})

L['ALT key'] = ALT_KEY
L['CTRL key'] = CTRL_KEY
L['SHIFT key'] = SHIFT_KEY

local locale = GetLocale()
if(locale == 'deDE') then
	--@localization(locale="deDE", format="lua_additive_table")@
elseif(locale == 'esES') then
	--@localization(locale="esES", format="lua_additive_table")@
elseif(locale == 'esMX') then
	--@localization(locale="esMX", format="lua_additive_table")@
elseif(locale == 'frFR') then
	--@localization(locale="frFR", format="lua_additive_table")@
elseif(locale == 'itIT') then
	--@localization(locale="itIT", format="lua_additive_table")@
elseif(locale == 'koKR') then
	--@localization(locale="koKR", format="lua_additive_table")@
elseif(locale == 'ptBR') then
	--@localization(locale="ptBR", format="lua_additive_table")@
elseif(locale == 'ruRU') then
	--@localization(locale="ruRU", format="lua_additive_table")@
elseif(locale == 'zhCN') then
	--@localization(locale="zhCN", format="lua_additive_table")@
elseif(locale == 'zhTW') then
	--@localization(locale="zhTW", format="lua_additive_table")@
end
