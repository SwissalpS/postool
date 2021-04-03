-- register item
minetest.register_craftitem('postool:wand', {

	description = 'PosTool',
	inventory_image = 'postool_wand.png',
	groups = {},
	wield_image = '',
	wield_scale = { x = 1, y = 1, z = 1 },
	liquids_pointable = true,
	node_placement_prediction = nil,

	on_use = function(oItemstack, oPlayer, oPointedThing)
		return postool.show(oPlayer, oPointedThing)
	end,

--[[
	on_place = function(oItemstack, oPlayer, oPointedThing)
		return postool.show(oPlayer, oPointedThing)
	end
--]]

}) -- register_craftitem


-- register craft
minetest.register_craft({

	output = 'postool:wand 1',
	recipe = {
		{ '', '', 'default:glass' },
		{ '', 'default:torch', '' },
		{ 'default:stick', '', '' }
	}

}) -- register_craft

-- 'constants' for this session
local tChunkConstants = {
	iChunkLength = 16 * postool.serverChunkSize,
	iChunkDiff = 16 * (math.ceil(.5 * postool.serverChunkSize)),
	dMultiplier = 1 / postool.serverChunkSize,
}

postool.show = function(oPlayer, oPointedThing)

	-- sanity check
	if nil == oPointedThing or nil == oPlayer then return nil end

	-- increment use count for stats
	postool.iCountToolUses = postool.iCountToolUses + 1

	-- attempt to get position from pointed thing
	local tPos = minetest.get_pointed_thing_position(oPointedThing, false)

	-- fallback to player position if that did not work
	if nil == tPos then tPos = oPlayer:get_pos() end

	local _, tBlock = postool.getPositionTablesForPos(tPos)
	local tBlockOrigin = { x = tBlock.x * 16, y = tBlock.y * 16, z = tBlock.z * 16 }

	-- and show it
	minetest.add_entity(tBlockOrigin, 'postool:display')

	-- CHUNK INDICATOR --
	-- respect server wide suppression
	if postool.toolSuppressChunkIndicator then return nil end

	local bWantsChunk

	-- does player want to toggle his chunk indicator setting
	local tKeys = oPlayer:get_player_control()
	if true == tKeys.zoom and true == tKeys.aux1 and true == tKeys.sneak then
		bWantsChunk = postool.toggleChunkMarker(oPlayer)
	else
		-- read players tool settings
		bWantsChunk = postool.playerWantsChunkIndicator(oPlayer)
	end

	-- only show chunk indicator if player has 'unlocked' it
	if not bWantsChunk then return nil end

	-- do some math magic to figure out where in the current block
	-- to place the chunk indicator. First make some alias to avoid long lines.
	local tBO = tBlockOrigin
	local dM = tChunkConstants.dMultiplier
	local iCD = tChunkConstants.iChunkDiff
	local iCL = tChunkConstants.iChunkLength
	local tChunkOffset = {
		x = math.floor((dM * ((tBO.x - iCD) % iCL)) + 1),
		y = math.floor((dM * ((tBO.y - iCD) % iCL)) + 1),
		z = math.floor((dM * ((tBO.z - iCD) % iCL)) + 1),
	}

	-- if player is in centre block of chunk, don't show chunk indicator
	-- This helps confirm in a fast manner. Your milleage may vary depending on
	-- your mapgen settings. Tested with chunksizes 3, 4 and 5
	-- This works fine with 3 and 5 but 4 will not have a centre block.
	local bX = 6 <= tChunkOffset.x and 8 >= tChunkOffset.x
	local bY = 6 <= tChunkOffset.y and 8 >= tChunkOffset.y
	local bZ = 6 <= tChunkOffset.z and 8 >= tChunkOffset.z
	if bX and bY and bZ then return nil end

	local tChunkOrigin = vector.add(tBlockOrigin, tChunkOffset)
	minetest.add_entity(tChunkOrigin, 'postool:display_chunk')

	return nil

end -- show


-- display entity shown when postool is used
minetest.register_entity('postool:display', {

	physical = false,
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	visual = 'wielditem',
	-- wielditem seems to be scaled to 1.5 times original node size
	visual_size = { x = 0.67, y = 0.67 },
	textures = {'postool:display_node'},
	timer = 0,
	glow = 10,

	on_step = function(self, dtime)

		self.timer = self.timer + dtime

		-- remove after set number of seconds
		if self.timer > postool.toolGridDisplayDuration then
			self.object:remove()
		end

	end -- on_step

}) -- register_entity


-- display entity shown when postool is used near a chunk border
minetest.register_entity('postool:display_chunk', {

	physical = false,
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	visual = 'wielditem',
	-- wielditem seems to be scaled to 1.5 times original node size
	visual_size = { x = 0.67, y = 0.67 },
	textures = {'postool:display_chunk_node'},
	timer = 0,
	glow = 10,

	on_step = function(self, dtime)

		self.timer = self.timer + dtime

		-- remove after set number of seconds
		if self.timer > postool.toolGridDisplayDuration then
			self.object:remove()
		end

	end -- on_step

}) -- register_entity

-- Display-zone node, Do NOT place the display as a node,
-- it is made to be used as an entity (see above)
minetest.register_node('postool:display_node', {

	tiles = { 'postool_display.png' },
	use_texture_alpha = true,
	walkable = false,
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {
			-- we can simply do this, but it only shows when you exit the block
			--{ -.55,-.55,-.55, 15.55,15.55,15.55 },
			-- west
			{ -.55, -.55, -.55, -.55, 15.55, 15.55 },
			-- bottom
			{ -.55, -.55, -.55, 15.55, -.55, 15.55 },
			-- south
			{ -.55, -.55, -.55, 15.55, 15.55, -.55 },
			-- east
			{ 15.55, -.55, -.55, 15.55, 15.55, 15.55 },
			-- top
			{ -.55, 15.55, -.55, 15.55, 15.55, 15.55 },
			-- north
			{ -.55, -.55, 15.55, 15.55, 15.55, 15.55 },
			-- have not noticed more or less glitchiness with this on and it
			-- shows from which side to expect most glitch
			-- block origin
			{ -.45, -.45, -.45, .55, .55, .55 },
			-- while this works, it is glitchy, so disabled
			-- centre eight nodes
			--{ 6.45, 6.45, 6.45, 8.55, 8.55, 8.55 },
		},
	},
	selection_box = {
		type = 'regular',
	},
	paramtype = 'light',
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	drop = ''

}) -- register_node postool:display_node

-- Display-chunk node, Do NOT place the display as a node,
-- it is made to be used as an entity (see above)
minetest.register_node('postool:display_chunk_node', {

	tiles = { 'postool_display.png' },
	use_texture_alpha = true,
	walkable = false,
	color = '#0fff0f', --#ff0f0f',
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {
			{ -.55,-.55,-.55, 1.55,1.55,1.55 },
		},
	},
	selection_box = {
		type = 'regular',
	},
	paramtype = 'light',
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	drop = ''

}) -- register_node chunk indicator

