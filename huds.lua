local HUD_POSITION = { x = postool.hudPosX, y = postool.hudPosY }
local HUD_ALIGNMENT = { x = 1, y = 0 }
local HUD_SCALE = { x = 100, y = 100 }
local HUD_STATBAR_SIZE = { x = 160, y = 18 }

-- hud id map (playername -> { playername = { tIDs = { hud-ids }, tb = { toggles }, ... )
postool.tHudDB = {}
-- holds the train time portion that is same for all players
postool.sTrain = ''
-- all players have same time
postool.sTime = ''


-- returns tb (flags), bMain, nX (X-offset)
-- from player meta
function postool.readPlayerToggles(oPlayer)

	local tMetaRef = oPlayer:get_meta()
	local sFlags = tMetaRef:get_string('postoolHUDflags')

	if '' == sFlags then
		tMetaRef:set_float('postoolHUDx', postool.hudPosX)
		return {
			true == postool.hudShowTrain,
			true == postool.hudShowTime,
			true == postool.hudShowNode,
			true == postool.hudShowBlock,
			true == postool.hudShowMesecons,
			true == postool.hudShowMeseconsDetails,
			false -- show chunk indicator
		}, true == postool.hudShowMain, postool.hudPosX
	end -- if has none yet

	local tb = {}
	for i = 2, #sFlags do
		tb[i -1] = '1' == sFlags:sub(i, i)
	end

	-- add chunk border toggle for tool usage, if not yet existing
	if 6 == #sFlags then sFlags[7] = false end

	return tb, '1' == sFlags:sub(1, 1), tMetaRef:get_float('postoolHUDx')

end -- readPlayerToggles


local function boolToString(b) if b then return '1' else return '0' end end
function postool.savePlayerToggles(oPlayer)

	local _, tb, bMain, nX = postool.getPlayerTables(oPlayer)

	local sOut = boolToString(bMain)
	for _, b in ipairs(tb) do
		sOut = sOut .. boolToString(b)
	end

	local tMetaRef = oPlayer:get_meta()
	tMetaRef:set_string('postoolHUDflags', sOut)
	tMetaRef:set_float('postoolHUDx', nX)

end -- savePlayerToggles


function postool.playerWantsChunkIndicator(oPlayer)

	local tDB = postool.getPlayerTables(oPlayer, true)
	local bWantsChunk = tDB.tb[7]

	return bWantsChunk

end -- playerWantsChunkIndicator


-- return to default values
function postool.resetHud(oPlayer)

	local sName = postool.removeHud(oPlayer)

	oPlayer:get_meta():set_string('postoolHUDflags', '')

	postool.initHud(oPlayer)

end -- resetHud


-- send some stats
function postool.statsString(oPlayer)

	local lCount = {}
	local iCountP = 0
	lCount[0] = 0 lCount[1] = 0 lCount[2] = 0 lCount[3] = 0 lCount[4] = 0
	lCount[5] = 0 lCount[6] = 0 lCount[7] = 0
	for sName, tDB in pairs(postool.tHudDB) do
		iCountP = iCountP + 1
		if tDB.bMain then
			lCount[0] = lCount[0] + 1
			for i, b in ipairs(tDB.tb) do
				if b then lCount[i] = lCount[i] + 1 end
			end
		end
	end

	local sOut = '[postool] ' .. tostring(postool.version)
			.. '\nSince last reboot, postool has been used '
			.. tostring(postool.iCountToolUses) .. ' times.\n'
			.. tostring(lCount[0]) .. ' of the ' .. tostring(iCountP)
			.. ' currently online players have postool HUD on.\n'

	-- nobody has it activated so no need to gather more information
	if 0 == lCount[0] then return sOut end

	local S = postool.S
	local lTitles = {
		S('Train Time'),
		S('Time'),
		S('Nodes'),
		S('Blocks'),
		S('Mesecons'),
		S('Details'),
		S('Chunks'),
	}
	for i = 1, 7 do
		sOut = sOut .. lCount[i] .. ' ' .. lTitles[i] .. ' '
	end

	return sOut

end -- statsString


-- toggle chunk marker state
function postool.toggleChunkMarker(oPlayer)

	local tDB = postool.getPlayerTables(oPlayer, true)
	tDB.tb[7] = not tDB.tb[7]
	postool.savePlayerToggles(oPlayer)

	return tDB.tb[7]

end -- toggleChunkMarker


-- return the runtime cache for player
-- if bRef == true then only a tableref is returned
postool.getPlayerTables = function(oPlayer, bRef)

	local sName = oPlayer:get_player_name()

	local tDB = postool.tHudDB[sName]

	if not tDB then
		print('[postool]getPlayerTables: this should never happen')
		postool.initHud(oPlayer);
		tDB = postool.tHudDB[sName]
	end

	if bRef then return tDB end

	return tDB.tIDs, tDB.tb, tDB.bMain, tDB.nX

end -- getPlayerTables


-- position element vertically
local function setHudYoffset(oPlayer, iID, iY)

	if nil == iID then return end

	oPlayer:hud_change(iID, 'offset', { x = 0, y = iY })

end -- setHudYoffset


-- toggle between left and right side of screen
postool.toggleHudPosition = function(oPlayer)

	local tDB = postool.getPlayerTables(oPlayer, true)

	tDB.nX = 1 - tDB.nX

	-- make new position
	local tPosNew = {
		x = tDB.nX,
		y = HUD_POSITION.y
	}

	-- apply new position
	for _, iID in pairs(tDB.tIDs) do

		oPlayer:hud_change(iID, 'position', tPosNew)

	end

end -- toggleHudPosition


-- recalculate y offset and clear if needed
postool.rebuildHud = function(oPlayer)

	local tIDs, tb, bMain, nX = postool.getPlayerTables(oPlayer)

	if not bMain then
		postool.removeHudElements(oPlayer)
		return
	end -- if turned off


	local tPosition = HUD_POSITION
	tPosition.x = nX

	local iY = 0
	local iDiff = -18

	local bAdvTrains = postool.hasAdvancedTrains()
	local bMesecons = postool.hasMeseconsDebug()

	local iID = tIDs.meseconsUsageFG
	if tb[5] and bMesecons then

		if nil == iID then
			tIDs.meseconsUsageFG = oPlayer:hud_add({
				hud_elem_type = 'statbar',
				name = 'postoolMeseconsUsageFG',
				position = tPosition,
				offset = { x = -2, y = iY - 27 },
				text = 'mesecons_use_fg.png',
				scale = HUD_SCALE,
				size = { x = 1, y = HUD_STATBAR_SIZE.y },
				alignment = HUD_ALIGNMENT,
				number = 4,
				z_index = postool.hudPosZ,
			})
			tIDs.meseconsPenalty = oPlayer:hud_add({
				hud_elem_type = 'text',
				name = 'postoolMeseconsPenalty',
				position = tPosition,
				offset = { x = 0, y = -16 },
				text = 'Initializing...',
				scale = HUD_SCALE,
				alignment = HUD_ALIGNMENT,
				number = postool.hudColour,
				z_index = postool.hudPosZ,
			})
		end -- if not yet generated

		iY = iY + (iDiff * 2)

	elseif nil ~= iID then

		oPlayer:hud_remove(iID)
		oPlayer:hud_remove(tIDs.meseconsUsageFG)
		tIDs.meseconsUsageFG = nil
		oPlayer:hud_remove(tIDs.meseconsPenalty)
		tIDs.meseconsPenalty = nil

	end -- mesecons

	iID = tIDs.block
	if tb[4] then
		if nil == iID then
			tIDs.block = oPlayer:hud_add({
				hud_elem_type = 'text',
				name = 'postoolBlock',
				position = tPosition,
				offset = { x = 0, y = iY },
				text = 'Initializing...',
				scale = HUD_SCALE,
				alignment = HUD_ALIGNMENT,
				number = postool.hudColour,
				z_index = postool.hudPosZ,
			})
		else
			setHudYoffset(oPlayer, iID, iY)
		end

		iY = iY + iDiff

	elseif nil ~= iID then

		oPlayer:hud_remove(iID)
		tIDs.block = nil

	end -- block

	iID = tIDs.node
	if tb[3] then

		if nil == iID then
			tIDs.node = oPlayer:hud_add({
				hud_elem_type = 'text',
				name = 'postoolNode',
				position = tPosition,
				offset = { x = 0, y = iY },
				text = 'Initializing...',
				scale = HUD_SCALE,
				alignment = HUD_ALIGNMENT,
				number = postool.hudColour,
				z_index = postool.hudPosZ,
			})
		else
			setHudYoffset(oPlayer, iID, iY)
		end

		iY = iY + iDiff

	elseif nil ~= iID then

		oPlayer:hud_remove(iID)
		tIDs.node = nil

	end -- node

	iID = tIDs.time
	if tb[2] then

		if nil == iID then
			tIDs.time = oPlayer:hud_add({
				hud_elem_type = 'text',
				name = 'postoolTime',
				position = tPosition,
				offset = { x = 0, y = iY },
				text = 'Initializing...',
				scale = HUD_SCALE,
				alignment = HUD_ALIGNMENT,
				number = postool.hudColour,
				z_index = postool.hudPosZ,
			})
		else
			setHudYoffset(oPlayer, iID, iY)
		end

		iY = iY + iDiff

	elseif nil ~= iID then

		oPlayer:hud_remove(iID)
		tIDs.time = nil

	end -- time

	iID = tIDs.trainTime
	if tb[1] and bAdvTrains then

		if nil == iID then
			tIDs.trainTime = oPlayer:hud_add({
				hud_elem_type = 'text',
				name = 'postoolTrainTime',
				position = tPosition,
				offset = { x = 0, y = iY },
				text = 'Initializing...',
				scale = HUD_SCALE,
				alignment = HUD_ALIGNMENT,
				number = postool.hudColour,
				z_index = postool.hudPosZ,
			})
		else
			setHudYoffset(oPlayer, iID, iY)
		end

		iY = iY + iDiff

	elseif nil ~= iID then

		oPlayer:hud_remove(iID)
		tIDs.trainTime = nil

	end -- train

end -- rebuildHud


-- called when player joins or activates the formspec/hud
-- initialize the cache
postool.initHud = function(oPlayer)

	local sName = oPlayer:get_player_name()

	-- already set up?
	if postool.tHudDB[sName] then return end

	local tb, bMain, nX = postool.readPlayerToggles(oPlayer)

	postool.tHudDB[sName] = {
		tIDs = {},
		tb = tb,
		bMain = bMain,
		nX = nX,
		iCountRuns = 0
	}

end -- initHud


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

		local sDetails = '\nUsage: ' .. tostring(tCtx.avg_micros) .. ' us/s ('
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
	oPlayer:hud_change(tIDs.meseconsUsageFG, 'size', {
		x = math.max(8, .01 * nPercent * HUD_STATBAR_SIZE.x),
		y = HUD_STATBAR_SIZE.y + math.floor(tCtx.penalty * 16)
	})
end -- updateHudMesecons


-- show new text
postool.updateHud = function(oPlayer)

	local tIDs, tb, bMain = postool.getPlayerTables(oPlayer)

	if tb[1] and tIDs.trainTime then

		oPlayer:hud_change(tIDs.trainTime, 'text', postool.sTrain)

	end -- rwt

	if tb[2] and tIDs.time then

		oPlayer:hud_change(tIDs.time, 'text', postool.sTime)

	end -- time

	postool.updateHudMesecons(oPlayer)

	-- need to get positon strings at all?
	if not (tb[3] or tb[4]) then return end

	local sNode, sBlock = postool.getPositions(oPlayer)

	if tb[3] and tIDs.node then

		oPlayer:hud_change(tIDs.node, 'text', sNode)

	end -- node

	if tb[4] and tIDs.block then

		oPlayer:hud_change(tIDs.block, 'text', sBlock)

	end -- block

end -- updateHud


-- remove hud elements and return players name
postool.removeHudElements = function(oPlayer)

	local sName = oPlayer:get_player_name()
	local tDB = postool.tHudDB[sName]
	if not tDB then return sName end

	-- remove each hud
	for i, iID in pairs(tDB.tIDs) do

		oPlayer:hud_remove(iID)
		tDB.tIDs[i] = nil

	end

	return sName

end -- removeHudElements


-- called after player leaves
postool.removeHud = function(oPlayer)

	-- remove hud elements
	local sName = postool.removeHudElements(oPlayer)

	-- remove cache
	postool.tHudDB[sName] = nil

end -- removeHud


-- called after player has left
postool.removeHudByName = function(sName)

	-- there is no point in trying to get
	-- player object, as this function is called
	-- after log-out

	if sName and 0 < #sName then

		-- remove cache
		postool.tHudDB[sName] = nil

	end

end -- removeHudByName


-- called when player is leaving
postool.leavePlayerHud = function(oPlayer)

	local sName = oPlayer:get_player_name()

	minetest.after(1, postool.removeHudByName, sName)

end -- leavePlayerHud


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
			print('[postool]register_globalstep: player not yet registered, globalstep fired before on join player has run')

		else

			-- is this the first run for this player?
			if 1 > tDB.iCountRuns then

				tDB.iCountRuns = tDB.iCountRuns + 1

			elseif 1 == tDB.iCountRuns then

				tDB.iCountRuns = 4
				if tDB.bMain then
					postool.rebuildHud(oPlayer)
					bUpdate = true
				end

			-- check if player has turned on hud at all
			elseif tDB.bMain then
				bUpdate = true
			end

			if bUpdate then
				postool.updateHud(oPlayer)
			end

		end -- if got entry at all

	end -- loop players

end -- register_globalstep

