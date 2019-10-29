postool.chatcommand = {

	params = '',
	description = 'Configure HUD',
	func = function(sName, sParam)

		local oPlayer = minetest.get_player_by_name(sName)
		if not oPlayer then
			return false, S('Player not found')
		end

		postool.showConfigFormspec(oPlayer)

	end
}

