local sPosToolFormNameConfig = 'postoolConfig'

postool.showConfigFormspec = function(oPlayer)

	local sName = oPlayer:get_player_name()
	local tDB = postool.tHudDB[sName]
	if not tDB then
		print('[postool]forms:showConfigFormspec: Something is wrong with DB')
		return
	end

	local sFormspec = 'size[3,3.25;]'
		.. 'label[0.6,0;' .. S('PosTool HUD Configuration') .. ']'
		.. 'checkbox[1,0.25;bMain;' .. S('Main') .. ';' .. tostring(tDB.bMain) .. ']'
		.. 'checkbox[0,0.75;bTrain;' .. postool.hudTitleTrain .. ';' .. tostring(tDB.tb[1]) .. ']'
		.. 'checkbox[2,0.75;bTime;' .. postool.hudTitleTime .. ';' .. tostring(tDB.tb[2]) .. ']'
		.. 'checkbox[0,1.25;bNode;' .. postool.hudTitleNode .. ';' .. tostring(tDB.tb[3]) .. ']'
		.. 'checkbox[2,1.25;bBlock;' .. postool.hudTitleBlock .. ';' .. tostring(tDB.tb[4]) .. ']'
		.. 'checkbox[0,1.75;bMesecons;' .. postool.hudTitleMesecons .. ';' .. tostring(tDB.tb[5]) .. ']'
		.. 'button[0,2.5;3,1;butToggle;' .. S('Toggle Position') .. ']'

	minetest.show_formspec(sName, sPosToolFormNameConfig, sFormspec)

end -- showConfigFormspec


postool.register_on_player_receive_fields = function(oPlayer, sFormName, tFields)

	if sFormName ~= sPosToolFormNameConfig then return end

	local sName = oPlayer:get_player_name()
	local tDB = postool.tHudDB[sName]
	if not tDB then
		print('[postool]forms:on_player_receive_fields: Something is wrong with DB')
		return
	end

	-- Checkboxes respond on change
	-- we get a table with just one element in it.
	if nil ~= tFields.bMain then
		tDB.bMain = 'true' == tFields.bMain
	end

	if nil ~= tFields.bTrain then
		tDB.tb[1] = 'true' == tFields.bTrain
	end

	if nil ~= tFields.bTime then
		tDB.tb[2] = 'true' == tFields.bTime
	end

	if nil ~= tFields.bNode then
		tDB.tb[3] = 'true' == tFields.bNode
	end

	if nil ~= tFields.bBlock then
		tDB.tb[4] = 'true' == tFields.bBlock
	end

	if nil ~= tFields.bMesecons then
		tDB.tb[5] = 'true' == tFields.bMesecons
	end

	-- Buttons also respond right away
	if nil ~= tFields.butToggle then
		postool.toggleHudPosition(oPlayer)
		return
	end

	-- There is also a 'quit = true' message when user presses Esc
	if nil ~= tFields.quit then return end

	postool.rebuildHud(oPlayer)

end -- register_on_player_receive_fields

