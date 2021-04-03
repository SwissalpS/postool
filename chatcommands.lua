local S = postool.S

postool.chatcommand = {

	params = '[ resetHUD | stats | toggleChunk ]',
	description = 'Configure postool HUD\n'
			.. 'Commands are case insensitive. '
			.. 'resetHUD: resets to factory settings. '
			.. 'stats: ouptuts some information. '
			.. 'toggleChunk: toggles chunk indicator for player.',
	func = function(sName, sParam)

		local oPlayer = minetest.get_player_by_name(sName)
		if not oPlayer then
			return false, S('Player not found')
		end

		if 'resethud' == string.lower(sParam) then
			postool.resetHud(oPlayer)
			return true, S('Postool settings reset to factory settings.')
		elseif 'stats' == string.lower(sParam) then
			return true, postool.statsString(oPlayer)
		elseif 'togglechunk' == string.lower(sParam) then
			local bState = postool.toggleChunkMarker(oPlayer)
			return true, S('Chunk Marker ') .. (bState and S('ON') or S('OFF'))
		else
			return postool.showConfigFormspec(oPlayer)
		end

	end
}

