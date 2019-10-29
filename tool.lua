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

    on_place = function(oItemstack, oPlayer, oPointedThing)
		return postool.show(oPlayer, oPointedThing)
    end

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


postool.show = function(oPlayer, oPointedThing)

	-- sanity check
	if nil == oPointedThing or nil == oPlayer then return nil end

	-- attempt to get position from pointed thing
	local tPos = minetest.get_pointed_thing_position(oPointedThing, false)

	-- fallback to player position if that did not work
	if nil == tPos then	tPos = oPlayer:get_pos() end

	local _, tBlock = postool.getPositionTablesForPos(tPos)
	local tBlockOrigin = { x = tBlock.x * 16, y = tBlock.y * 16, z = tBlock.z * 16 }

	-- and show it
	minetest.add_entity(tBlockOrigin, 'postool:display')

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
			{ 15.55, 15.55, 15.55, 15.55, -.55, -.55 },
			-- top
			{ 15.55, 15.55, 15.55, -.55, 15.55, -.55 },
			-- north
			{ 15.55, 15.55, 15.55, -.55, -.55, 15.55 },
			-- block origin
			{ -.55, -.55, -.55, .55, .55, .55 },
		},
	},
	selection_box = {
		type = 'regular',
	},
	paramtype = 'light',
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	drop = ''

}) -- register_node
