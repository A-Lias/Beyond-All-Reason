function widget:GetInfo()
	return {
		name = "Pregame Queue",
		desc = "Drawing and queue handling for pregame building",
		author = "Hobo Joe, based on buildmenu from assorted authors",
		date = "May 2023",
		license = "GNU GPL, v2 or later",
		layer = 1,
		enabled = true,
		handler = true,
	}
end


local spTestBuildOrder = Spring.TestBuildOrder

local buildQueue = {}
local selBuildQueueDefID
local facingMap = {south=0, east=1, north=2, west=3}

local isSpec = Spring.GetSpectatingState()
local myTeamID = Spring.GetMyTeamID()
local preGamestartPlayer = Spring.GetGameFrame() == 0 and not isSpec
local startDefID = Spring.GetTeamRulesParam(myTeamID, 'startUnit')
local metalMap = false

local unitshapes = {}

local armToCorNames = {
	['armmex'] = 'cormex',
	['armuwmex'] = 'coruwmex',
	['armsolar'] = 'corsolar',
	['armwin'] = 'corwin',
	['armtide'] = 'cortide',
	['armllt'] = 'corllt',
	['armrad'] = 'corrad',
	['armrl'] = 'corrl',
	['armtl'] = 'cortl',
	['armsonar'] = 'corsonar',
	['armfrt'] = 'corfrt',
	['armlab'] = 'corlab',
	['armvp'] = 'corvp',
	['armsy'] = 'corsy',
	['armmstor'] = 'cormstor',
	['armestor'] = 'corestor',
	['armmakr'] = 'cormakr',
	['armeyes'] = 'coreyes',
	['armdrag'] = 'cordrag',
	['armdl'] = 'cordl',
	['armap'] = 'corap',
	['armfrad'] = 'corfrad',
	['armuwms'] = 'coruwms',
	['armuwes'] = 'coruwes',
	['armfmkr'] = 'corfmkr',
	['armfdrag'] = 'corfdrag',
	['armptl'] = 'corptl',
}
-- convert unitname -> unitDefID
local armToCor = {}
for unitName, corUnitName in pairs(armToCorNames) do
	if UnitDefNames[unitName] and UnitDefNames[corUnitName] then
		armToCor[UnitDefNames[unitName].id] = UnitDefNames[corUnitName].id
	end
end
armToCorNames = nil

local corToArm = table.invert(armToCor)


local function buildFacingHandler(_, _, args)
	if not (preGamestartPlayer and selBuildQueueDefID) then
		return
	end

	local facing = Spring.GetBuildFacing()
	if args and args[1] == "inc" then
		facing = (facing + 1) % 4
		Spring.SetBuildFacing(facing)
		return true
	elseif args and args[1] == "dec" then
		facing = (facing - 1) % 4
		Spring.SetBuildFacing(facing)
		return true
	elseif args and facingMap[args[1]] then
		Spring.SetBuildFacing(facingMap[args[1]])
		return true
	end
end


------------------------------------------
---          QUEUE HANDLING            ---
------------------------------------------
local BUILDING_GRID_FORCE_SHOW_REASON = "gui_pregame_build"
local function setPreGamestartDefID(uDefID)
	selBuildQueueDefID = uDefID

	if WG['buildinggrid'] ~= nil and WG['buildinggrid'].setForceShow ~= nil then
		WG['buildinggrid'].setForceShow(BUILDING_GRID_FORCE_SHOW_REASON, uDefID ~= nil)
	end

	local isMex = UnitDefs[uDefID] and UnitDefs[uDefID].extractsMetal > 0

	if isMex then
		if Spring.GetMapDrawMode() ~= "metal" then
			Spring.SendCommands("ShowMetalMap")
		end
	elseif Spring.GetMapDrawMode() == "metal" then
		Spring.SendCommands("ShowStandard")
	end
end

local function GetUnitCanCompleteQueue(uID)
	local uDefID = Spring.GetUnitDefID(uID)
	if uDefID == startDefID then
		return true
	end

	-- What can this unit build ?
	local uCanBuild = {}
	local uBuilds = UnitDefs[uDefID].buildOptions
	for i = 1, #uBuilds do
		uCanBuild[uBuilds[i]] = true
	end

	-- Can it build everything that was queued ?
	for i = 1, #buildQueue do
		if not uCanBuild[buildQueue[i][1]] then
			return false
		end
	end

	return true
end

local function clearPregameBuildQueue()
	if not preGamestartPlayer then return end

	setPreGamestartDefID()
	buildQueue = {}

	return true
end

local function buildmenuPregameDeselectHandler()
	if not (preGamestartPlayer and selBuildQueueDefID) then return end

	setPreGamestartDefID()

	return true
end


------------------------------------------
---               INIT                 ---
------------------------------------------
function widget:Initialize()

	-- For some reason when handler = true widgetHandler:AddAction is not available
	widgetHandler.actionHandler:AddAction(self, "stop", clearPregameBuildQueue, nil, "p")
	widgetHandler.actionHandler:AddAction(self, "buildfacing", buildFacingHandler, nil, "p")
	widgetHandler.actionHandler:AddAction(self, "buildmenu_pregame_deselect", buildmenuPregameDeselectHandler, nil, "p")

	-- Get our starting unit
	if preGamestartPlayer then
		if not startDefID or startDefID ~= Spring.GetTeamRulesParam(myTeamID, 'startUnit') then
			startDefID = Spring.GetTeamRulesParam(myTeamID, 'startUnit')
		end
	end

	metalMap = WG["resource_spot_finder"].isMetalMap

	WG['pregame-build'] = {}
	WG['pregame-build'].getPreGameDefID = function()
		return selBuildQueueDefID
	end
	WG['pregame-build'].setPreGamestartDefID = function(value)
		setPreGamestartDefID(value)
	end

	WG['pregame-build'].setBuildQueue = function(value)
		buildQueue = value
	end
	WG['pregame-build'].getBuildQueue = function()
		return buildQueue
	end
	widgetHandler:RegisterGlobal(widget, 'GetPreGameDefID', WG['pregame-build'].getPreGameDefID)
	widgetHandler:RegisterGlobal(widget, 'GetBuildQueue', WG['pregame-build'].getBuildQueue)

end

local function GetBuildingDimensions(uDefID, facing)
	local bDef = UnitDefs[uDefID]
	if (facing % 2 == 1) then
		return 4 * bDef.zsize, 4 * bDef.xsize
	else
		return 4 * bDef.xsize, 4 * bDef.zsize
	end
end

local function DoBuildingsClash(buildData1, buildData2)
	local w1, h1 = GetBuildingDimensions(buildData1[1], buildData1[5])
	local w2, h2 = GetBuildingDimensions(buildData2[1], buildData2[5])

	return math.abs(buildData1[2] - buildData2[2]) < w1 + w2 and
		math.abs(buildData1[4] - buildData2[4]) < h1 + h2
end

local function removeUnitShape(id)
	if unitshapes[id] then
		WG.StopDrawUnitShapeGL4(unitshapes[id])
		unitshapes[id] = nil
	end
end

local function addUnitShape(id, unitDefID, px, py, pz, rotationY, teamID)
	if unitshapes[id] then
		removeUnitShape(id)
	end
	unitshapes[id] = WG.DrawUnitShapeGL4(unitDefID, px, py, pz, rotationY, 1, teamID, nil, nil)
	return unitshapes[id]
end


local function DrawBuilding(buildData, borderColor, drawRanges)
	local bDefID, bx, by, bz, facing = buildData[1], buildData[2], buildData[3], buildData[4], buildData[5]
	local bw, bh = GetBuildingDimensions(bDefID, facing)

	gl.DepthTest(false)
	gl.Color(borderColor)

	gl.Shape(GL.LINE_LOOP, { { v = { bx - bw, by, bz - bh } },
							 { v = { bx + bw, by, bz - bh } },
							 { v = { bx + bw, by, bz + bh } },
							 { v = { bx - bw, by, bz + bh } } })

	if drawRanges then
		local isMex = UnitDefs[bDefID] and UnitDefs[bDefID].extractsMetal > 0
		if isMex then
			gl.Color(1.0, 0.0, 0.0, 0.5)
			gl.DrawGroundCircle(bx, by, bz, Game.extractorRadius, 50)
		end

		local wRange = false --unitMaxWeaponRange[bDefID]
		if wRange then
			gl.Color(1.0, 0.3, 0.3, 0.7)
			gl.DrawGroundCircle(bx, by, bz, wRange, 40)
		end
	end
	WG['pregame-build'].selectedID = nil
	if WG.StopDrawUnitShapeGL4 then
		local id = buildData[1]..'_'..buildData[2]..'_'..buildData[3]..'_'..buildData[4]..'_'..buildData[5]
		addUnitShape(id, buildData[1], buildData[2], buildData[3], buildData[4], buildData[5]*(math.pi/2), myTeamID)
		WG['pregame-build'].selectedID = buildData[1]
	end
end

function widget:MousePress(x, y, button)
	if Spring.IsGUIHidden() then
		return
	end
	if WG['topbar'] and WG['topbar'].showingQuit() then
		return
	end

	-- Special handling for buildings before game start, since there isn't yet a unit spawned to give normal orders to
	if preGamestartPlayer then
		local mx, my = Spring.GetMouseState()
		local _, pos = Spring.TraceScreenRay(mx, my, true)

		if selBuildQueueDefID then
			if button == 1 then
				local isMex = UnitDefs[selBuildQueueDefID] and UnitDefs[selBuildQueueDefID].extractsMetal > 0
				if WG.ExtractorSnap then
					local snapPos = WG.ExtractorSnap.position
					if snapPos then
						pos = { snapPos.x, snapPos.y, snapPos.z }
					end
				end

				if not pos then
					return
				end

				local bx, by, bz = Spring.Pos2BuildPos(selBuildQueueDefID, pos[1], pos[2], pos[3])
				local buildFacing = Spring.GetBuildFacing()
				local buildData = { selBuildQueueDefID, bx, by, bz, buildFacing }
				local cx, cy, cz = Spring.GetTeamStartPosition(myTeamID) -- Returns -100, -100, -100 when none chosen
				local _, _, meta, shift = Spring.GetModKeyState()

				if (meta or not shift) and cx ~= -100 then
					local cbx, cby, cbz = Spring.Pos2BuildPos(startDefID, cx, cy, cz)

					if DoBuildingsClash(buildData, { startDefID, cbx, cby, cbz, 1 }) then -- avoid clashing building and commander position
						return true
					end
				end

				if Spring.TestBuildOrder(selBuildQueueDefID, bx, by, bz, buildFacing) ~= 0 then
					if meta then
						table.insert(buildQueue, 1, buildData)

					elseif shift then

						local anyClashes = false
						for i = #buildQueue, 1, -1 do
							if DoBuildingsClash(buildData, buildQueue[i]) then
								anyClashes = true
								table.remove(buildQueue, i)
							end
						end

						if isMex and not metalMap then
							-- Special handling to check if mex position is valid
							local spot = WG["resource_spot_finder"].GetClosestMexSpot(bx, bz)
							local validPos = spot and WG["resource_spot_finder"].IsMexPositionValid(spot, bx, bz) or false
							local spotIsTaken = spot and WG["resource_spot_builder"].SpotHasExtractorQueued(spot) or false
							if not validPos or spotIsTaken then
								return true
							end
						end

						if not anyClashes then
							buildQueue[#buildQueue + 1] = buildData
						end
					else
						-- don't place mex if the spot is not valid
						if isMex then
							if WG.ExtractorSnap.position or metalMap then
								buildQueue = { buildData }
							end
						else
							buildQueue = { buildData }
						end

					end

					if not shift then
						setPreGamestartDefID(nil)
					end
				end

				return true
			elseif button == 3 then
				setPreGamestartDefID(nil)
			end
		elseif button == 1 and #buildQueue > 0 and pos then -- avoid clashing first building and commander position
			local cbx, cby, cbz = Spring.Pos2BuildPos(startDefID, pos[1], pos[2], pos[3])

			if DoBuildingsClash({ startDefID, cbx, cby, cbz, 1 }, buildQueue[1]) then
				return true
			end
		end
	end
end

function widget:DrawWorld()
	if not WG.StopDrawUnitShapeGL4 then return end

	-- remove unit shape queue to re-add again later
	for id, _ in pairs(unitshapes) do
		removeUnitShape(id)
	end

	-- Avoid unnecessary overhead after buildqueue has been setup in early frames
	if Spring.GetGameFrame() > 0 then
		widgetHandler:RemoveWidgetCallIn('DrawWorld', self)
		return
	end

	if not preGamestartPlayer then return end

	-- draw pregame build queue
	local buildDistanceColor = { 0.3, 1.0, 0.3, 0.6 }
	local buildLinesColor = { 0.3, 1.0, 0.3, 0.6 }
	local borderNormalColor = { 0.3, 1.0, 0.3, 0.5 }
	local borderClashColor = { 0.7, 0.3, 0.3, 1.0 }
	local borderValidColor = { 0.0, 1.0, 0.0, 1.0 }
	local borderInvalidColor = { 1.0, 0.0, 0.0, 1.0 }

	gl.LineWidth(1.49)

	-- We need data about currently selected building, for drawing clashes etc
	local selBuildData
	if selBuildQueueDefID then
		local x, y, _ = Spring.GetMouseState()
		local _, pos = Spring.TraceScreenRay(x, y, true)
		if pos then
			local bx, by, bz = Spring.Pos2BuildPos(selBuildQueueDefID, pos[1], pos[2], pos[3])
			local buildFacing = Spring.GetBuildFacing()
			selBuildData = { selBuildQueueDefID, bx, by, bz, buildFacing }
		end
	end

	if startDefID ~= Spring.GetTeamRulesParam(myTeamID, 'startUnit') then
		startDefID = Spring.GetTeamRulesParam(myTeamID, 'startUnit')
	end

	local sx, sy, sz = Spring.GetTeamStartPosition(myTeamID) -- Returns -100, -100, -100 when none chosen
	local startChosen = (sx ~= -100)
	if startChosen and startDefID then
		-- Correction for start positions in the air
		sy = Spring.GetGroundHeight(sx, sz)

		-- Draw start units build radius
		gl.Color(buildDistanceColor)
		gl.DrawGroundCircle(sx, sy, sz, UnitDefs[startDefID].buildDistance, 40)
	end

	-- Check for faction change
	for b = 1, #buildQueue do
		local buildData = buildQueue[b]
		local buildDataId = buildData[1]
		if startDefID == UnitDefNames["armcom"].id then
			if corToArm[buildDataId] ~= nil then
				buildData[1] = corToArm[buildDataId]
				buildQueue[b] = buildData
			end
		elseif startDefID == UnitDefNames["corcom"].id then
			if armToCor[buildDataId] ~= nil then
				buildData[1] = armToCor[buildDataId]
				buildQueue[b] = buildData
			end
		end
	end

	-- Draw all the buildings
	local queueLineVerts = startChosen and { { v = { sx, sy, sz } } } or {}
	for b = 1, #buildQueue do
		local buildData = buildQueue[b]

		if selBuildData and DoBuildingsClash(selBuildData, buildData) then
			DrawBuilding(buildData, borderClashColor)
		else
			DrawBuilding(buildData, borderNormalColor)
		end

		queueLineVerts[#queueLineVerts + 1] = { v = { buildData[2], buildData[3], buildData[4] } }
	end

	-- Draw queue lines
	gl.Color(buildLinesColor)
	gl.LineStipple("springdefault")
	gl.Shape(GL.LINE_STRIP, queueLineVerts)
	gl.LineStipple(false)

	-- Draw selected building
	if selBuildData then
		-- mmm, convoluted logic. Pregame handling is hell
		local isMex = UnitDefs[selBuildQueueDefID] and UnitDefs[selBuildQueueDefID].extractsMetal > 0
		local testOrder = spTestBuildOrder(selBuildQueueDefID, selBuildData[2], selBuildData[3], selBuildData[4], selBuildData[5]) ~= 0
		if not isMex then
			local color = testOrder and borderValidColor or borderInvalidColor
			DrawBuilding(selBuildData, color, true)
		elseif isMex then
			if WG.ExtractorSnap.position or metalMap then
				DrawBuilding(selBuildData, borderValidColor, true)
			else
				DrawBuilding(selBuildData, borderInvalidColor, true)
			end
		else
			DrawBuilding(selBuildData, borderValidColor, true)
		end
	end

	-- Reset gl
	gl.Color(1, 1, 1, 1)
	gl.LineWidth(1.0)
end

function widget:GameFrame(n)
	-- Avoid unnecessary overhead after buildqueue has been setup in early frames
	if #buildQueue == 0 then
		widgetHandler:RemoveWidgetCallIn('GameFrame', self)
		widgetHandler:RemoveWidget(self)
		return
	end

	-- handle the pregame build queue
	if not (n <= 90 and n > 1) then return end

	-- inform gadget how long is our queue
	local t = 0
	for i = 1, #buildQueue do
		t = t + UnitDefs[buildQueue[i][1]].buildTime
	end
	if startDefID then
		local buildTime = t / UnitDefs[startDefID].buildSpeed
		Spring.SendCommands("luarules initialQueueTime " .. buildTime)
	end

	local tasker
	-- Search for our starting unit
	local units = Spring.GetTeamUnits(Spring.GetMyTeamID())
	for u = 1, #units do
		local uID = units[u]
		if GetUnitCanCompleteQueue(uID) then
			tasker = uID
			if Spring.GetUnitRulesParam(uID, "startingOwner") == Spring.GetMyPlayerID() then
				-- we found our com even if cooping, assigning queue to this particular unit
				break
			end
		end
	end
	if tasker then
		for b = 1, #buildQueue do
			local buildData = buildQueue[b]
			Spring.GiveOrderToUnit(tasker, -buildData[1], { buildData[2], buildData[3], buildData[4], buildData[5] }, { "shift" })
		end
		buildQueue = {}
	end
end


function widget:GameStart()
	preGamestartPlayer = false

	-- Deattach pregame action handlers
	widgetHandler.actionHandler:RemoveAction(self, "stop")
	widgetHandler.actionHandler:RemoveAction(self, "buildfacing")
	widgetHandler.actionHandler:RemoveAction(self, "buildmenu_pregame_deselect")
end

function widget:Shutdown()
	-- Stop drawing all ghosts
	if WG.StopDrawUnitShapeGL4 then
		for id, _ in pairs(unitshapes) do
			removeUnitShape(id)
		end
	end
	widgetHandler:DeregisterGlobal(widget, 'GetPreGameDefID')
	widgetHandler:DeregisterGlobal(widget, 'GetBuildQueue')
	WG['pregame-build'] = nil
	if WG['buildinggrid'] ~= nil and WG['buildinggrid'].setForceShow ~= nil then
		WG['buildinggrid'].setForceShow(BUILDING_GRID_FORCE_SHOW_REASON, false)
	end
end

function widget:GetConfigData()
	return {
		buildQueue = buildQueue,
	}
end

function widget:SetConfigData(data)
	if data.buildQueue and Spring.GetGameFrame() == 0 and data.gameID and data.gameID == Game.gameID then
		buildQueue = data.buildQueue
	end
end
