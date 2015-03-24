catherine.hint = catherine.hint or { }
catherine.hint.Lists = { }

function catherine.hint.Register(  message, canLook )
	local index = #catherine.hint.Lists + 1
	catherine.hint.Lists[ index ] = { index = index, message = message, canLook = canLook }
end

if ( SERVER ) then
	catherine.hint.SendCurTime = catherine.hint.SendCurTime or CurTime( ) + catherine.configs.hintInterval
	
	function catherine.hint.Work( )
		local randHint = table.Random( catherine.hint.Lists )
		if ( !randHint ) then return end
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( v:GetInfo( "cat_convar_hint" ) == "0" ) then continue end
			local canLook = randHint.canLook and randHint.canLook( v ) or true
			if ( !canLook ) then continue end
			netstream.Start( v, "catherine.hint.Receive", randHint.index )
		end
	end
	
	function catherine.hint.Think( )
		if ( #catherine.hint.Lists == 0 ) then return end
		if ( catherine.hint.SendCurTime <= CurTime( ) ) then
			catherine.hint.Work( )
			catherine.hint.SendCurTime = CurTime( ) + catherine.configs.hintInterval + math.random( 10, 20 )
		end
	end

	hook.Add( "Think", "catherine.hint.Think", catherine.hint.Think )
else
	catherine.hint.Hints = catherine.hint.Hints or nil
	
	CAT_CONVAR_HINT = CreateClientConVar( "cat_convar_hint", 1, true, true )
	catherine.option.Register( "CONVAR_HINT", "cat_convar_hint", "Hint", "Displays the hint.", "Framework Settings", CAT_OPTION_SWITCH )
	
	netstream.Hook( "catherine.hint.Receive", function( data )
		catherine.hint.Hints = {
			message = catherine.hint.Lists[ data ].message or "",
			time = CurTime( ) + 10,
			a = 0
		}
	end )
	
	function catherine.hint.Draw( )
		if ( !catherine.hint.Hints ) then return end
		local t = catherine.hint.Hints
		if ( t.time <= CurTime( ) ) then
			t.a = Lerp( 0.01, t.a, 0 )
			if ( math.Round( t.a ) <= 0 ) then
				catherine.hint.Hints = nil
				return
			end
		else
			t.a = Lerp( 0.01, t.a, 255 )
		end
		draw.SimpleText( t.message, "catherine_normal25", ScrW( ) - 10, 5, Color( 255, 255, 255, t.a ), TEXT_ALIGN_RIGHT )
	end
end

catherine.hint.Register( "Type // before your message to talk out-of-character." )
catherine.hint.Register( "Type .// or [[ before your message to talk out-of-character locally." )
catherine.hint.Register( "Press 'F1 key' to view your character and roleplay information." )
catherine.hint.Register( "Press 'Tab key' to view the main menu." )