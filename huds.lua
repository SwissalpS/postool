local HUD_POSITION = { x = postool.hudPosX, y = postool.hudPosY }
local HUD_ALIGNMENT = { x = 1, y = 0 }
local HUD_SCALE = { x = 100, y = 100 }

-- hud id map (playername -> { playername = { tIDs = { hud-ids }, tb = { toggles }, ... )
postool.tHudDB = {}
-- holds the train time portion that is same for all players
postool.sTrain = ''
-- all players have same time
postool.sTime = ''


postool.readPlayerToggles = function(oPlayer)

	local tMetaRef = oPlayer:get_meta()
	local sFlags = tMetaRef:get_string('postoolHUDflags')

	if '' == sFlags then
		return {
			true == postool.hudShowTrain,
			true == postool.hudShowTime,
			true == postool.hudShowNode,
			true == postool.hudShowBlock,
			true == postool.hudShowMesecons,
			true == postool.hudShowMeseconsDetails
		}, true == postool.hudShowMain, postool.hudPosX
	end -- if has none yet

	local tb = {}
	for i = 2, #sFlags do
		tb[i -1] = '1' == sFlags:sub(i, i)
	end

	return tb, '1' == sFlags:sub(1, 1), tMetaRef:get_float('postoolHUDx')

end -- readPlayerToggles


local function boolToString(b) if b then return '1' else return '0' end end
postool.savePlayerToggles = function(oPlayer)

	local _, tb, bMain, nX = postool.getPlayerTables(oPlayer)

	local sOut = boolToString(bMain)
	for _, b in ipairs(tb) do
		sOut = sOut .. boolToString(b)
	end

	local tMetaRef = oPlayer:get_meta()
	tMetaRef:set_string('postoolHUDflags', sOut)
	tMetaRef:set_float('postoolHUDx', nX)

end -- savePlayerToggles


-- return the runtime cache for player
-- if bRef == true then only a tableref is returned
postool.getPlayerTables = function(oPlayer, bRef)

	local sName = oPlayer:get_player_name()

	local tDB = postool.tHudDB[sName]

	if not tDB then
		postool.generateHud(oPlayer)
		tDB = postool.tHudDB[sName]
	end

	if bRef then return tDB end

	return tDB.tIDs, tDB.tb, tDB.bMain, tDB.nX

end -- getPlayerTables


-- 'hide' an element
local function clearHud(oPlayer, iID)

	if nil == iID then return end

	oPlayer:hud_change(iID, 'text', '')

end -- clearHud


-- position element vertically
local function setHudYoffset(oPlayer, iID, iY)

	if nil == iID then return end

	oPlayer:hud_change(iID, 'offset', { x = 0, y = iY })

end -- setHudYoffset


-- toggle between left and right side of screen
postool.toggleHudPosition = function(oPlayer)

	local tDB = postool.getPlayerTables(oPlayer, true)

	-- get current definition
	local tDef = oPlayer:hud_get(tDB.tIDs.time)

	-- make new position
	local tPosNew = {
		x = 1 - tDef.position.x,
		y = tDef.position.y
	}

	tDB.nX = tPosNew.x

	-- apply new position
	for _, iID in pairs(tDB.tIDs) do

		oPlayer:hud_change(iID, 'position', tPosNew)

	end

end -- toggleHudPosition


-- recalculate y offset and clear if needed
postool.rebuildHud = function(oPlayer)

	local tIDs, tb, bMain = postool.getPlayerTables(oPlayer)

	local iY = 0
	local iDiff = -18
	local bOff = not bMain

	local iID = tIDs.meseconsUsageBG
	if tb[5] then

		iY = iY + (iDiff * 2)

		if bOff then
			clearHud(oPlayer, iID)
			clearHud(oPlayer, tIDs.meseconsUsageFG)
			clearHud(oPlayer, tIDs.meseconsPenalty)
		else
			oPlayer:hud_change(iID, 'text', 'mesecons_use_bg.png')
			oPlayer:hud_change(tIDs.meseconsUsageFG, 'text', 'mesecons_use_fg.png')
		end

	else

		clearHud(oPlayer, iID)
		clearHud(oPlayer, tIDs.meseconsUsageFG)
		clearHud(oPlayer, tIDs.meseconsPenalty)

	end -- mesecons

	iID = tIDs.block
	if tb[4] then

		setHudYoffset(oPlayer, iID, iY)

		iY = iY + iDiff

		if bOff then clearHud(oPlayer, iID) end

	else

		clearHud(oPlayer, iID)

	end -- block

	iID = tIDs.node
	if tb[3] then

		setHudYoffset(oPlayer, iID, iY)

		iY = iY + iDiff

		if bOff then clearHud(oPlayer, iID) end

	else

		clearHud(oPlayer, iID)

	end -- node

	iID = tIDs.time
	if tb[2] then

		setHudYoffset(oPlayer, iID, iY)

		iY = iY + iDiff

		if bOff then clearHud(oPlayer, iID) end

	else

		clearHud(oPlayer, iID)

	end -- time

	iID = tIDs.trainTime
	if tb[1] then

		setHudYoffset(oPlayer, iID, iY)

		iY = iY + iDiff

		if bOff then clearHud(oPlayer, iID) end

	else

		clearHud(oPlayer, iID)

	end -- train

end -- rebuildHud


-- called when player joins
-- initialize the hud elements
postool.generateHud = function(oPlayer)

	local sName = oPlayer:get_player_name()

	if postool.tHudDB[sName] then
		-- already set up
		return
	end

	local bAdvTrains = postool.hasAdvancedTrains()
	local bMesecons = postool.hasMeseconsDebug()

	local tb, bMain, nX = postool.readPlayerToggles(oPlayer)
	local tPosition = HUD_POSITION
	tPosition.x = nX

	local tDB = {
		tIDs = {},
		tb = tb,
		bMain = bMain,
		nX = nX,
		iCountRuns = 0
	}

	if bAdvTrains then
	tDB.tIDs.trainTime = oPlayer:hud_add({
		hud_elem_type = 'text',
		name = 'postoolTrainTime',
		position = tPosition,
		offset = { x = 0, y = -54 },
		text = 'Initializing...',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = postool.hudColour
	})
	end -- if got trains
	tDB.tIDs.time = oPlayer:hud_add({
		hud_elem_type = 'text',
		name = 'postoolTime',
		position = tPosition,
		offset = { x = 0, y = -36 },
		text = 'Initializing...',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = postool.hudColour
	})
	tDB.tIDs.node = oPlayer:hud_add({
		hud_elem_type = 'text',
		name = 'postoolNode',
		position = tPosition,
		offset = { x = 0, y = -18 },
		text = 'Initializing...',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = postool.hudColour
	})
	tDB.tIDs.block = oPlayer:hud_add({
		hud_elem_type = 'text',
		name = 'postoolBlock',
		position = tPosition,
		offset = { x = 0, y = 0 },
		text = 'Initializing...',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = postool.hudColour
	})
	if bMesecons then
	tDB.tIDs.meseconsUsageBG = oPlayer:hud_add({
		hud_elem_type = 'statbar',
		name = 'postoolMeseconsUsageBG',
		position = tPosition,
		offset = { x = 0, y = -18 },
		text = 'mesecons_use_bg.png',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = 3
	})
	tDB.tIDs.meseconsUsageFG = oPlayer:hud_add({
		hud_elem_type = 'statbar',
		name = 'postoolMeseconsUsageFG',
		position = tPosition,
		offset = { x = 0, y = -18 },
		text = 'mesecons_use_fg.png',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = 4
	})
	tDB.tIDs.meseconsPenalty = oPlayer:hud_add({
		hud_elem_type = 'text',
		name = 'postoolMeseconsPenalty',
		position = tPosition,
		offset = { x = 0, y = 0 },
		text = 'Initializing...',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = postool.hudColour
	})
	end -- if got mesecons_debug

	postool.tHudDB[sName] = tDB

	-- this had no effect, so we use first-run-method
	--postool.rebuildHud(oPlayer)

end -- generatHud


postool.updateHudMesecons = function(oPlayer)

	local tIDs, tb = postool.getPlayerTables(oPlayer)

	-- not active or no mesecons at all
	-- we check for existance of hud-element rather than using function to check
	if not (tb[5] and tIDs.meseconsPenalty) then return end

	local tPos = oPlayer:get_pos()
	local tCtx = mesecons_debug.get_context(tPos)

	local nPercent = math.floor(tCtx.avg_micros / mesecons_debug.max_usage_micros * 100)

	local sPenalty = 'Penalty: ' .. tostring(math.floor(tCtx.penalty * 10) / 10) .. ' s'

	if tb[6] then

		local sDetails = 'Usage: ' .. tostring(tCtx.avg_micros) .. ' us/s ('
						.. tostring(nPercent) .. '%) \n'

		sPenalty = sDetails .. sPenalty

	end -- if show more details

	local sTexture
	if 0.1 >= tCtx.penalty then
		sTexture = 'mesecons_use_fg.png' --0x00FF00
	elseif 0.5 > tCtx.penalty then
		sTexture = 'mesecons_use_fg_mid.png' --0xFFFF00
	else
		sTexture = 'mesecons_use_fg_high.png' --0xFF0000
	end

	oPlayer:hud_change(tIDs.meseconsPenalty, 'text', sPenalty)
	oPlayer:hud_change(tIDs.meseconsUsageFG, 'text', sTexture)
	-- give a minimum to show, so can see red penalty even when no usage
	oPlayer:hud_change(tIDs.meseconsUsageFG, 'number', math.max(8, nPercent * 3))

end -- updateHudMesecons


-- show new text
postool.updateHud = function(oPlayer)

	local tIDs, tb, bMain = postool.getPlayerTables(oPlayer)

	if tb[1] and tIDs.trainTime then

		oPlayer:hud_change(tIDs.trainTime, 'text', postool.sTrain)

	end -- rwt

	if tb[2] then

		oPlayer:hud_change(tIDs.time, 'text', postool.sTime)

	end -- time

	postool.updateHudMesecons(oPlayer)

	-- need to get positon strings at all?
	if not (tb[3] or tb[4]) then return end

	local sNode, sBlock = postool.getPositions(oPlayer)

	if tb[3] then

		oPlayer:hud_change(tIDs.node, 'text', sNode)

	end -- node

	if tb[4] then

		oPlayer:hud_change(tIDs.block, 'text', sBlock)

	end -- block

end -- updateHud


-- called after player leaves
-- remove hud elements
postool.removeHud = function(oPlayer)

	local sName = oPlayer:get_player_name()
	local tDB = postool.tHudDB[sName]
	if not tDB then return end

	-- remove each hud
	for _, iID in pairs(tDB.tIDs) do

		oPlayer:hud_remove(iID)

	end

	-- remove metadata
	postool.tHudDB[sName] = nil

end -- removeHud


-- track time of last call
local iTimeNext = 0

postool.register_globalstep = function()

	-- check if need to update
	local iTimeNow = os.clock()
	if iTimeNext > iTimeNow then
		-- not yet
		return
	end

	iTimeNext = iTimeNow + postool.hudMinUpdateInterval

	-- Update hud text that is the same for all players
	postool.sTrain = postool.hudTitleTrain .. postool.getTimeTrain()
	postool.sTime = postool.hudTitleTime .. postool.getTime()

	local sName
	local tDB
	local bUpdate
	for _, oPlayer in ipairs(minetest.get_connected_players()) do

		bUpdate = false
		sName = oPlayer:get_player_name()
		tDB = postool.tHudDB[sName]
		if not tDB then
			postool.generateHud(oPlayer)
			tDB = postool.tHudDB[sName]
		end

		-- is this the first run for this player?
		if 1 > tDB.iCountRuns then

			tDB.iCountRuns = tDB.iCountRuns + 1

		elseif 1 == tDB.iCountRuns then

			postool.rebuildHud(oPlayer)
			tDB.iCountRuns = 4
			if tDB.bMain then bUpdate = true end

		-- check if player has turned on hud at all
		elseif tDB.bMain then
			bUpdate = true
		end

		if bUpdate then
			postool.updateHud(oPlayer)
		end

	end -- loop players

end -- register_globalstep

