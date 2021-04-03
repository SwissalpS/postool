-- Simple head-up display for current position and time.
-- Also Tool to graphicaly show current map-block.
-- read the readme.md for more info on origin.

-- safety check in case translation function does not exist
local S = (minetest.global_exists('S') and S) or function(s) return s end

--settings
postool = {
	version = 20210403.1612,
	S = S,
	-- Position of hud
	hudPosX = tonumber(minetest.settings:get('postool.hud.offsetx') or 0.8),
	hudPosY = tonumber(minetest.settings:get('postool.hud.offsety') or 0.95),
	hudPosZ = tonumber(minetest.settings:get('postool.hud.offsetz') or -111),
	hudPosSeparator = minetest.settings:get('postool.hud.posseparator') or ' | ',
	hudTitleTrain = minetest.settings:get('postool.hud.titletrain') or S('Railway Time') .. ': ',
	hudTitleTime = minetest.settings:get('postool.hud.titletime') or S('Time') .. ': ',
	hudTitleNode = minetest.settings:get('postool.hud.titlenode') or S('Node') .. ': ',
	hudTitleBlock = minetest.settings:get('postool.hud.titleblock') or S('Block') .. ': ',
	hudTitleMesecons = minetest.settings:get('postool.hud.titlemesecons') or S('Mesecons') .. ': ',
	hudTitleTrainNA = minetest.settings:get('postool.hud.titletrainna') or S('advtrains not enabled'),
	hudShowMain = minetest.settings:get_bool('postool.hud.defaultshowmain') or false,
	hudShowTrain = minetest.settings:get_bool('postool.hud.defaultshowtrain') or false,
	hudShowTime = minetest.settings:get_bool('postool.hud.defaultshowtime') or false,
	hudShowNode = minetest.settings:get_bool('postool.hud.defaultshownode'),
	hudShowBlock = minetest.settings:get_bool('postool.hud.defaultshowblock'),
	hudShowMesecons = minetest.settings:get_bool('postool.hud.defaultshowmesecons') or false,
	hudShowMeseconsDetails = minetest.settings:get_bool('postool.hud.defaultshowmeseconsdetails') or false,
	-- wait at least this long before updating hud
	hudMinUpdateInterval = tonumber(minetest.settings:get('postool.hud.minupdateinterval') or 2),
	iCountToolUses = 0,
	-- chunk size used by this server in mapblocks (not sure this is correct way of getting actually used size)
	serverChunkSize = math.max(1, tonumber(minetest.settings:get('chunksize') or 5)),
	toolGridDisplayDuration = tonumber(minetest.settings:get('postool.tool.griddisplayduration') or 12),
	toolSuppressChunkIndicator = minetest.settings:get_bool('postool.tool.suppresschunkindicator') or false,
}
if nil == postool.hudShowNode then postool.hudShowNode = true end
if nil == postool.hudShowBlock then postool.hudShowBlock = true end

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

