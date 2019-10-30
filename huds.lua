local HUD_POSITION = { x = postool.hudPosX, y = postool.hudPosY }
local HUD_ALIGNMENT = { x = 1, y = 0 }
local HUD_SCALE = { x = 100, y = 100 }

-- hud id map (playername -> { playername = { tIDs = { hud-ids }, tb = { toggles }, ... )
postool.tHudDB = {}


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

	local sName = oPlayer:get_player_name()

	local tDB = postool.tHudDB[sName]

	if not tDB then
		-- should never happen
		print('[postool]huds:toggleHudPosition: DB corruption!')
		return
	end

	-- get current definition
	local tDef = oPlayer:hud_get(tDB.tIDs.time)

	-- make new position
	local tPosNew = {
		x = 1 - tDef.position.x,
		y = tDef.position.y
	}

	-- apply new position
	for _, iID in pairs(tDB.tIDs) do

		oPlayer:hud_change(iID, 'position', tPosNew)

	end

end -- toggleHudPosition


-- recalculate y offset and clear if needed
postool.rebuildHud = function(oPlayer)

	local sName = oPlayer:get_player_name()

	local tDB = postool.tHudDB[sName]

	if not tDB then
		-- should never happen
		print('[postool]huds:rebuildHud: DB corruption!')
		return
	end

	local iY = 0
	local iDiff = -18
	local bOff = not tDB.bMain

	local iID = tDB.tIDs.meseconsUsageBG
	if tDB.tb[5] then

		iY = iY + (iDiff * 2)

		if bOff then
			clearHud(oPlayer, iID)
			clearHud(oPlayer, tDB.tIDs.meseconsUsageFG)
			clearHud(oPlayer, tDB.tIDs.meseconsPenalty)
		else
			oPlayer:hud_change(iID, 'text', 'mesecons_use_bg.png')
			oPlayer:hud_change(tDB.tIDs.meseconsUsageFG, 'text', 'mesecons_use_fg.png')
		end

	else

		clearHud(oPlayer, iID)
		clearHud(oPlayer, tDB.tIDs.meseconsUsageFG)
		clearHud(oPlayer, tDB.tIDs.meseconsPenalty)

	end -- mesecons

	iID = tDB.tIDs.block
	if tDB.tb[4] then

		setHudYoffset(oPlayer, iID, iY)

		iY = iY + iDiff

		if bOff then clearHud(oPlayer, iID) end

	else

		clearHud(oPlayer, iID)

	end -- block

	iID = tDB.tIDs.node
	if tDB.tb[3] then

		setHudYoffset(oPlayer, iID, iY)

		iY = iY + iDiff

		if bOff then clearHud(oPlayer, iID) end

	else

		clearHud(oPlayer, iID)

	end -- node

	iID = tDB.tIDs.time
	if tDB.tb[2] then

		setHudYoffset(oPlayer, iID, iY)

		iY = iY + iDiff

		if bOff then clearHud(oPlayer, iID) end

	else

		clearHud(oPlayer, iID)

	end -- time

	iID = tDB.tIDs.trainTime
	if tDB.tb[1] then

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

	local tDB = {
		tIDs = {},
		tb = {
			true == postool.hudShowTrain,
			true == postool.hudShowTime,
			true == postool.hudShowNode,
			true == postool.hudShowBlock,
			true == postool.hudShowMesecons,
			true == postool.hudShowMeseconsDetails
		},
		bMain = true == postool.hudShowMain,
		bDefaultPosition = true,
		bFirstRun = true
	}

	if bAdvTrains then
	tDB.tIDs.trainTime = oPlayer:hud_add({
		hud_elem_type = 'text',
		name = 'postoolTrainTime',
		position = HUD_POSITION,
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
		position = HUD_POSITION,
		offset = { x = 0, y = -36 },
		text = 'Initializing...',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = postool.hudColour
	})
	tDB.tIDs.node = oPlayer:hud_add({
		hud_elem_type = 'text',
		name = 'postoolNode',
		position = HUD_POSITION,
		offset = { x = 0, y = -18 },
		text = 'Initializing...',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = postool.hudColour
	})
	tDB.tIDs.block = oPlayer:hud_add({
		hud_elem_type = 'text',
		name = 'postoolBlock',
		position = HUD_POSITION,
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
		position = HUD_POSITION,
		offset = { x = 0, y = -18 },
		text = 'mesecons_use_bg.png',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = 3
	})
	tDB.tIDs.meseconsUsageFG = oPlayer:hud_add({
		hud_elem_type = 'statbar',
		name = 'postoolMeseconsUsageFG',
		position = HUD_POSITION,
		offset = { x = 0, y = -18 },
		text = 'mesecons_use_fg.png',
		scale = HUD_SCALE,
		alignment = HUD_ALIGNMENT,
		number = 4
	})
	tDB.tIDs.meseconsPenalty = oPlayer:hud_add({
		hud_elem_type = 'text',
		name = 'postoolMeseconsPenalty',
		position = HUD_POSITION,
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

	local sName = oPlayer:get_player_name()
	local tDB = postool.tHudDB[sName]

	-- not active or no mesecons at all
	if not (tDB.tb[5] and tDB.tIDs.meseconsPenalty) then return end

	local tPos = oPlayer:get_pos()
	local tCtx = mesecons_debug.get_context(tPos)

	local nPercent = math.floor(tCtx.avg_micros / mesecons_debug.max_usage_micros * 100)

	local sPenalty = 'Penalty: ' .. tostring(math.floor(tCtx.penalty * 10) / 10) .. ' s'

	if tDB.tb[6] then

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

	oPlayer:hud_change(tDB.tIDs.meseconsPenalty, 'text', sPenalty)
	oPlayer:hud_change(tDB.tIDs.meseconsUsageFG, 'text', sTexture)
	-- give a minimum to show, so can see red penalty even when no usage
	oPlayer:hud_change(tDB.tIDs.meseconsUsageFG, 'number', math.max(8, nPercent * 3))

end -- updateHudMesecons


-- show new text
postool.updateHud = function(oPlayer, sTrain, sTime)

	local sName = oPlayer:get_player_name()
	local tDB = postool.tHudDB[sName]

	if tDB.tb[1] and tDB.tIDs.trainTime then

		oPlayer:hud_change(tDB.tIDs.trainTime, 'text', sTrain)

	end -- rwt

	if tDB.tb[2] then

		oPlayer:hud_change(tDB.tIDs.time, 'text', sTime)

	end -- time

	postool.updateHudMesecons(oPlayer)

	-- need to get positon strings at all?
	if not (tDB.tb[3] or tDB.tb[4]) then return end

	local sNode, sBlock = postool.getPositions(oPlayer)

	if tDB.tb[3] then

		oPlayer:hud_change(tDB.tIDs.node, 'text', sNode)

	end -- node

	if tDB.tb[4] then

		oPlayer:hud_change(tDB.tIDs.block, 'text', sBlock)

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
	local sTrain = postool.hudTitleTrain .. postool.getTimeTrain()
	local sTime = postool.hudTitleTime .. postool.getTime()

	for _, oPlayer in ipairs(minetest.get_connected_players()) do

		local sName = oPlayer:get_player_name()

		local tDB = postool.tHudDB[sName]
		if not tDB then
			print('[postool]huds:globalstep: strange, no hud data for player: ' .. sName)
			postool.generateHud(oPlayer)
			tDB = postool.tHudDB[sName]
		end
--[[
		if not tDB.tIDs then
			print('[postool]huds:globalstep: very strange, no hud IDs for player: ' .. sName)
			return
		end
--]]

		-- is this the first run for this player?
		if tDB.bFirstRun then

			postool.rebuildHud(oPlayer)
			tDB.bFirstRun = false

		-- check if player has turned on hud at all
		elseif tDB.bMain then

			postool.updateHud(oPlayer, sTrain, sTime)

		end

	end -- loop players

end -- register_globalstep

