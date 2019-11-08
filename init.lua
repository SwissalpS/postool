-- Simple head-up display for current position and time.
-- Also Tool to graphicaly show current map-block.
-- read the readme.md for more info on origin.

-- safety check in case translation function does not exist
if nil == S then S = function(s) return s end end

--settings
postool = {
	-- Position of hud
	hudPosX = tonumber(minetest.settings:get('postool.hud.offsetx') or 0.8),
	hudPosY = tonumber(minetest.settings:get('postool.hud.offsety') or 0.95),
	hudPosSeparator = minetest.settings:get('postool.hud.posseparator') or ' | ',
	hudTitleTrain = minetest.settings:get('postool.hud.titletrain') or S('Railway Time') .. ': ',
	hudTitleTime = minetest.settings:get('postool.hud.titletime') or S('Time') .. ': ',
	hudTitleNode = minetest.settings:get('postool.hud.titlenode') or S('Node') .. ': ',
	hudTitleBlock = minetest.settings:get('postool.hud.titleblock') or S('Block') .. ': ',
	hudTitleMesecons = minetest.settings:get('postool.hud.titlemesecons') or S('Mesecons') .. ': ',
	hudTitleTrainNA = minetest.settings:get('postool.hud.titletrainna') or S('advtrains not enabled'),
	hudShowMain = 1 == tonumber(minetest.settings:get('postool.hud.defaultshowmain')),
	hudShowTrain = 1 == (tonumber(minetest.settings:get('postool.hud.defaultshowtrain')) or 0),
	hudShowTime = 1 == (tonumber(minetest.settings:get('postool.hud.defaultshowtime')) or 0),
	hudShowNode = 1 == (tonumber(minetest.settings:get('postool.hud.defaultshownode')) or 1),
	hudShowBlock = 1 == (tonumber(minetest.settings:get('postool.hud.defaultshowblock')) or 1),
	hudShowMesecons = 1 == (tonumber(minetest.settings:get('postool.hud.defaultshowmesecons')) or 0),
	hudShowMeseconsDetails = 1 == (tonumber(minetest.settings:get('postool.hud.defaultshowmeseconsdetails')) or 0),
	-- wait at least this long before updating hud
	hudMinUpdateInterval = tonumber(minetest.settings:get('postool.hud.minupdateinterval') or 2),
	toolGridDisplayDuration = tonumber(minetest.settings:get('postool.tool.griddisplayduration') or 12)
}

postool.hudColour = 0xFFFFFF  --text colour in hex format default is white

-- deps
postool.has_advtrains_mod = minetest.get_modpath('advtrains')
postool.has_mesecons_debug_mod = minetest.get_modpath('mesecons_debug')

-- base path
local sMP = minetest.get_modpath('postool')

dofile(sMP .. '/functions.lua')
dofile(sMP .. '/huds.lua')
dofile(sMP .. '/forms.lua')
dofile(sMP .. '/chatcommands.lua')
dofile(sMP .. '/tool.lua')

minetest.register_on_joinplayer(function(player) postool.initHud(player) end)
minetest.register_on_leaveplayer(postool.leavePlayerHud)
minetest.register_globalstep(postool.register_globalstep)
minetest.register_chatcommand('postool', postool.chatcommand)
minetest.register_on_player_receive_fields(postool.register_on_player_receive_fields)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
print('[postool] loaded')

