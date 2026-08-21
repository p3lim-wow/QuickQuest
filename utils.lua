local _, addon = ...

-- cache
local questQueue = {}
function addon:QUEST_DATA_LOAD_RESULT(questID)
	-- TODO: deal with unsuccessful queries
	if questQueue[questID] then
		questQueue[questID]()
		questQueue[questID] = nil
	end
end

function addon:WaitForQuestData(questID, callback)
	questQueue[questID] = callback
	C_QuestLog.RequestLoadQuestByID(questID)
end

function addon:WaitForItemData(itemID, callback)
	Item:CreateFromItemID(itemID):ContinueOnItemLoad(callback)
end

local function isPauseKeyDown()
	local pauseKey = addon:GetOption('pausekey')
	if pauseKey == 'ALT' then
		return IsAltKeyDown()
	elseif pauseKey == 'CTRL' then
		return IsControlKeyDown()
	elseif pauseKey == 'SHIFT' then
		return IsShiftKeyDown()
	end
end

function addon:IsPaused()
	if InteractiveWormholes and InteractiveWormholes:IsActive() then
		return true
	end

	local pauseKeyDown = isPauseKeyDown()
	if addon:GetOption('pausekeyreverse') then
		return not pauseKeyDown
	end

	return pauseKeyDown
end

-- blocklists
function addon:IsNPCIgnored()
	local npcID = UnitCreatureID('npc')
	if npcID ~= nil and issecretvalue(npcID) then
		npcID = nil
	end

	if npcID then
		return QuickQuestBlocklistDB.npcs[npcID]
	end
end

function addon:IsQuestIgnored(questIDorTitle)
	local ignored = QuickQuestBlocklistDB.quests[questIDorTitle]
	if ignored then
		return true
	end

	-- also check the title if the arg is a questID
	local title = tonumber(questIDorTitle) and C_QuestLog.GetTitleForQuestID(questIDorTitle)
	if title then
		return QuickQuestBlocklistDB.quests[title]
	end
end

function addon:IsItemIgnored(itemID)
	return QuickQuestBlocklistDB.items[itemID]
end

do -- scrollbox
	local function defaultSort(a, b)
		-- convert to string first so we can sort mixed types
		return tostring(a) > tostring(b)
	end

	local function initialize(scroll)
		if scroll._provider then
			return
		end

		local view
		if scroll.kind == 'list' then
			view = CreateScrollBoxListLinearView(scroll._insetTop or 0, scroll._insetBottom or 0, scroll._insetLeft or 0, scroll._insetRight or 0, scroll._spacingHorizontal or 0)
			view:SetElementExtentCalculator(function()
				return scroll._elementHeight
			end)
		elseif scroll.kind == 'grid' then
			local width = scroll:GetWidth() - scroll.bar:GetWidth() - (scroll._insetLeft or 0) - (scroll._insetRight or 0)
			local stride = math.floor((width - (scroll._spacingHorizontal or 0)) / (scroll._elementWidth + (scroll._spacingHorizontal or 0)))
			view = CreateScrollBoxListGridView(stride or 1, scroll._insetTop or 0, scroll._insetBottom or 0, scroll._insetLeft or 0, scroll._insetRight or 0, scroll._spacingHorizontal or 0, scroll._spacingVertical or 0)
			view:SetStrideExtent(scroll._elementWidth)
			view:SetElementSizeCalculator(function()
				return scroll._elementWidth, scroll._elementHeight
			end)
		end

		view:SetElementInitializer(scroll._elementType, function(element, data)
			if scroll._elementWidth and scroll.kind == 'grid' then
				element:SetWidth(scroll._elementWidth)
			end
			if scroll._elementHeight then
				element:SetHeight(scroll._elementHeight)
			end

			if not element._initialized then
				element._initialized = true

				if scroll._scripts then
					for script, callback in next, scroll._scripts do
						element:SetScript(script, callback)

						if script == 'OnEnter' and not scroll._scripts.OnLeave then
							element:SetScript('OnLeave', GameTooltip_Hide)
						end
					end
				end

				if scroll._onLoad then
					local successful, err = pcall(scroll._onLoad, element)
					if not successful then
						error(err)
					end
				end
			end

			element.data = data

			if scroll._onUpdate then
				local successful, err = pcall(scroll._onUpdate, element, data)
				if not successful then
					error(err)
				end
			end
		end)

		if scroll._onReset then
			scroll:HookScript('OnHide', function()
				for _, element in next, view:GetFrames() do
					local successful, err = pcall(scroll._onReset, element)
					if not successful then
						error(err)
					end
				end
			end)
		end

		ScrollUtil.InitScrollBoxListWithScrollBar(scroll, scroll.bar, view)
		ScrollUtil.AddManagedScrollBarVisibilityBehavior(scroll, scroll.bar) -- auto-hide the scroll bar

		local provider = CreateDataProvider()
		provider:SetSortComparator(scroll._sort or defaultSort, true)
		view:SetDataProvider(provider)
		scroll._provider = provider
	end

	local scrollMixin = {}
	function scrollMixin:SetInsets(top, bottom, left, right)
		self._insetTop = top
		self._insetBottom = bottom
		self._insetLeft = left
		self._insetRight = right
	end
	function scrollMixin:SetElementType(kind)
		self._elementType = kind
	end
	function scrollMixin:SetElementHeight(height)
		self._elementHeight = height
	end
	function scrollMixin:SetElementWidth(width)
		self._elementWidth = width
	end
	function scrollMixin:SetElementSize(width, height)
		self:SetElementWidth(width)
		self:SetElementHeight(height or width)
	end
	function scrollMixin:SetElementSpacing(horizontal, vertical)
		self._spacingHorizontal = horizontal
		self._spacingVertical = vertical or horizontal
	end
	function scrollMixin:SetElementSortingMethod(callback)
		self._sort = callback
	end
	function scrollMixin:SetElementOnLoad(callback)
		self._onLoad = callback
	end
	function scrollMixin:SetElementOnScript(script, callback)
		self._scripts = self._scripts or {}
		self._scripts[script] = callback
	end
	function scrollMixin:SetElementOnUpdate(callback)
		self._onUpdate = callback
	end
	function scrollMixin:SetElementOnReset(callback)
		self._onReset = callback
	end
	function scrollMixin:AddData(...)
		initialize(self)
		self._provider:Insert(...)
	end
	function scrollMixin:AddDataByKeys(data)
		for key, value in next, data do
			if value then -- must be truthy
				self:AddData(key)
			end
		end
	end
	function scrollMixin:RemoveData(...)
		self._provider:Remove(...)
	end
	function scrollMixin:ResetData()
		self._provider:Flush()
	end

	local function createScrollWidget(parent, kind)
		local box = CreateFrame('Frame', nil, parent, 'WowScrollBoxList')
		box:SetPoint('TOPLEFT')
		box:SetPoint('BOTTOMRIGHT', -8, 0) -- offset to not overlap scrollbar
		box.kind = kind

		local bar = CreateFrame('EventFrame', nil, parent, 'MinimalScrollBar')
		bar:SetPoint('TOPLEFT', box, 'TOPRIGHT')
		bar:SetPoint('BOTTOMLEFT', box, 'BOTTOMRIGHT')
		box.bar = bar

		return Mixin(box, scrollMixin)
	end

	function addon:CreateScrollList(parent)
		return createScrollWidget(parent, 'list')
	end

	function addon:CreateScrollGrid(parent)
		return createScrollWidget(parent, 'grid')
	end
end
