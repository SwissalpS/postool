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
		.. tostring(tNode.x) .. postool.hudPosSeparator
		.. tostring(tNode.y) .. postool.hudPosSeparator
		.. tostring(tNode.z)


	local sBlock = postool.hudTitleBlock
		.. tostring(tBlock.x) .. postool.hudPosSeparator
		.. tostring(tBlock.y) .. postool.hudPosSeparator
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


postool.hasAdvancedTrains = function()
	return postool.has_advtrains_mod and advtrains.lines and advtrains.lines.rwt and true
end -- hasAdvancedTrains


postool.hasMeseconsDebug = function()
	return postool.has_mesecons_debug_mod
		and minetest.global_exists('mesecons_debug')
		and (mesecons_debug.max_usage_micros or mesecons_debug.avg_total_micros_per_second)
		and mesecons_debug.get_context
end -- hasMeseconsDebug


-- return a string to show on HUD containing info about biome that player is standing on
postool.getBiomeDataForPlayer = function(oPlayer)

	local tPos = oPlayer:get_pos()
	-- Biome data for node below feet, otherwise it may be innacurate
	-- due to y range limits.
	tPos.y = tPos.y - 1

	-- TODO: test what happens here if position is out of world
	-- also test if position needs to be rounded
	local tBD = minetest.get_biome_data(tPos)
--print(dump(tBD))

	return string.format('Biome=%s (%d) Heat=%.2f Humidity=%.2f',
		minetest.get_biome_name(tBD.biome),
		tBD.biome, tBD.heat, tBD.humidity)
	
end -- getBiomeDataForPlayer


-- return a string to show on HUD
postool.getTimeTrain = function()

	local sOut
	if postool.hasAdvancedTrains() then

		sOut = advtrains.lines.rwt.to_string(advtrains.lines.rwt.now(), true)

	else

		sOut = postool.hudTitleTrainNA

	end

	return sOut

end -- getTimeTrain

