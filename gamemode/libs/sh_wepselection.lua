catherine.wep = catherine.wep or { }

if ( SERVER ) then
	concommand.Add( "cat.cmd.weaponselect", function( pl, _, args )
		pl:SelectWeapon( args[ 1 ] )
	end )
else
	catherine.wep.latestSlot = catherine.wep.latestSlot or 1
	catherine.wep.showTime = catherine.wep.showTime or CurTime( ) + 4
	catherine.wep.noShowTime = catherine.wep.noShowTime or CurTime( ) + 5
	catherine.wep.markup = catherine.wep.markup or nil
	
	hook.Add( "PlayerBindPress", "catherine.wep.latestSlot", function( pl, bind, pressed )
		return catherine.wep.DoWeaponSlotChange( pl, bind, pressed )
	end )
	
	hook.Add( "OnWeaponSlotChanged", "catherine.wep.OnWeaponSlotChanged", function( pl, slot )
		catherine.wep.showTime = CurTime( ) + 4
		catherine.wep.noShowTime = CurTime( ) + 5
		for k, v in pairs( pl:GetWeapons( ) ) do
			if ( k != catherine.wep.latestSlot ) then continue end
			if ( v.Instructions and v.Instructions:find( "%S" ) ) then
				catherine.wep.markup = markup.Parse( "<font=catherine_outline15>" .. v.Instructions .. "</font>" )
				return
			else
				catherine.wep.markup = nil
			end
		end
	end )
	
	function catherine.wep.Draw( pl )
		local scrW, scrH = ScrW( ), ScrH( )
		local defx = scrW * 0.175
		local defy = scrH * 0.4
		for k, v in pairs( pl:GetWeapons( ) ) do
			local color = Color( 255, 255, 255 )
			if ( k == catherine.wep.latestSlot ) then color = Color( 50, 50, 50 ) end
			color.a = math.Clamp( 255 - math.TimeFraction( catherine.wep.showTime, catherine.wep.noShowTime, CurTime( ) ) * 255, 0, 255 )
			draw.SimpleText( v:GetPrintName( ), "catherine_normal20", defx, defy + ( k * 25 ), color, TEXT_ALIGN_LEFT, 1 )
			if ( k == catherine.wep.latestSlot and catherine.wep.markup ) then
				catherine.wep.markup:Draw( defx + 128, defy + 24, 0, 1, color.a )
			end
		end
	end
	
	function catherine.wep.DoWeaponSlotChange( pl, bind, pressed )
		local wep = pl:GetActiveWeapon( )
		local weps = pl:GetWeapons( )
		if ( pl:InVehicle( ) or ( IsValid( wep ) and wep:GetClass( ) == "weapon_physgun" and pl:KeyDown( IN_ATTACK ) ) ) then return end
		bind = bind:lower( )
		if ( bind:find( "invnext" ) and pressed ) then
			catherine.wep.latestSlot = catherine.wep.latestSlot + 1
			if ( catherine.wep.latestSlot > #weps ) then
				catherine.wep.latestSlot = 1
			end
			hook.Run( "OnWeaponSlotChanged", pl, catherine.wep.latestSlot )
			return true
		elseif ( bind:find( "invprev" ) and pressed ) then
			catherine.wep.latestSlot = catherine.wep.latestSlot - 1
			if ( catherine.wep.latestSlot <= 0 ) then
				catherine.wep.latestSlot = #weps
			end
			hook.Run( "OnWeaponSlotChanged", pl, catherine.wep.latestSlot )
			return true
		elseif ( bind:find( "+attack" ) and pressed ) then
			if ( catherine.wep.noShowTime > CurTime( ) ) then
				catherine.wep.showTime = 0 catherine.wep.noShowTime = 0
				for k, v in pairs( weps ) do
					if ( k != catherine.wep.latestSlot ) then continue end
					RunConsoleCommand( "cat.cmd.weaponselect", v:GetClass( ) )
					return true
				end
			end
		elseif ( bind:find( "slot" ) ) then
			catherine.wep.latestSlot = math.Clamp( tonumber( bind:match( "slot(%d)" ) ) or 1, 1, #weps )
			catherine.wep.showTime = CurTime( ) + 4 catherine.wep.noShowTime = CurTime( ) + 5
			return true
		end
	end
end