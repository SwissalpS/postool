-- return tables with players current position in node and block metrics
postool.getPositionTablesForPos = function(tPos)

	local x = math.floor(tPos.x + 0.5)
	local y = math.floor(tPos.y + 0.5)
	local z = math.floor(tPos.z + 0.5)

	return { x = x, y = y, z = z },
		{
			x = math.floor(x / 16),
			y = math.floor(y / 16),
			z = math.floor(z / 16)
		}

end -- getPositionTablesForPos


-- return two strings to show on HUD
postool.getPositions = function(oPlayer)

	local tNode, tBlock = postool.getPositionTablesForPos(oPlayer:get_pos())

	local sNode = postool.hudTitleNode
		.. tostring(tNode.x) .. postool.hudPosSeperator
		.. tostring(tNode.y) .. postool.hudPosSeperator
		.. tostring(tNode.z)


	local sBlock = postool.hudTitleBlock
		.. tostring(tBlock.x) .. postool.hudPosSeperator
		.. tostring(tBlock.y) .. postool.hudPosSeperator
		.. tostring(tBlock.z)

	return sNode, sBlock

end -- getPositions


-- time
-- from https://gitlab.com/Rochambeau/mthudclock/blob/master/init.lua
local function floormod(x, y) return math.floor(x) % y end


-- return a string to show on HUD
postool.getTime = function()

	local secs = (3600 * 24 * minetest.get_timeofday())
	local m = floormod(secs / 60, 60)
	local h = floormod(secs / 3600, 60)

	return ('%02d:%02d'):format(h, m)

end -- getTime


-- return a string to show on HUD
postool.getTimeTrain = function()

	local sOut
	if postool.has_advtrains_mod and advtrains.lines and advtrains.lines.rwt then

		sOut = advtrains.lines.rwt.to_string(advtrains.lines.rwt.now(), true)

	else

		sOut = postool.hudTitleTrainNA

	end

	return sOut

end -- getTimeTrain

