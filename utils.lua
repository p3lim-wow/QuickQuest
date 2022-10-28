local _, ns = ...

local EventHandler = CreateFrame('Frame')
EventHandler.events = {}
EventHandler:SetScript('OnEvent', function(self, event, ...)
	self:Trigger(event, ...)
end)

function EventHandler:Register(event, func)
	local registered = not not self.events[event]
	if not registered then
		self.events[event] = {}
	end

	for _, f in next, self.events[event] do
		if f == func then
			-- avoid the same function being registered multiple times for the same event
			return
		end
	end

	table.insert(self.events[event], func)

	if not registered then
		self:RegisterEvent(event)
	end
end

function EventHandler:Unregister(event, func)
	local funcs = self.events[event]
	if funcs then
		for i, f in next, funcs do
			if f == func then
				funcs[i] = nil
				break
			end
		end
	end

	if funcs and #funcs == 0 then
		self:UnregisterEvent(event)
	end
end

function EventHandler:Trigger(event, ...)
	local funcs = self.events[event]
	if funcs then
		for _, func in next, funcs do
			if type(func) == 'string' then
				self:Trigger(func, ...)
			else
				if func(...) then
					self:Unregister(event, func)
				end
			end
		end
	end
end

ns.EventHandler = EventHandler

local NPC_ID_PATTERN = '%w+%-.-%-.-%-.-%-.-%-(.-)%-'
function ns.GetNPCID(unit)
	local npcGUID = UnitGUID(unit or 'npc')
	if npcGUID then
		return tonumber(npcGUID:match(NPC_ID_PATTERN))
	end
end

function ns.ShouldAcceptTrivialQuests()
	for index = 1, GetNumTrackingTypes() do
		local name, _, isActive = GetTrackingInfo(index)
		if name == MINIMAP_TRACKING_TRIVIAL_QUESTS then
			return isActive
		end
	end
end

function ns.tLength(t)
	local count = 0
	for _ in next, t do
		count = count + 1
	end
	return count
end
