catherine.bar = catherine.bar or { }
catherine.bar.Lists = { }

function catherine.bar.Register( target, targetMax, color, uniqueID )
	for k, v in pairs( catherine.bar.Lists ) do
		if ( !v.uniqueID ) then continue end
		if ( v.uniqueID == uniqueID ) then
			return
		end
	end
	
	catherine.bar.Lists[ #catherine.bar.Lists + 1 ] = {
		target = target,
		targetMax = targetMax,
		color = color,
		uniqueID = uniqueID,
		ani = 0,
		y = -10 + ( #catherine.bar.Lists + 1 ) * 14,
		alpha = 0
	}
end

function catherine.bar.Draw( )
	if ( catherine.option.Get( "CONVAR_BAR" ) == "0" ) then return end
	if ( !LocalPlayer( ):Alive( ) or !LocalPlayer( ):IsCharacterLoaded( ) ) then
		hook.Run( "HUDDrawBarBottom", 5, 5 )
		return
	end
	local count = 0
	for k, v in pairs( catherine.bar.Lists ) do
		if ( !v.target or !v.targetMax ) then continue end
		local percent = ( math.min( v.target( ) / v.targetMax( ), 1 ) )
		if ( percent == 0 ) then
			v.alpha = Lerp( 0.03, v.alpha, 0 )
		else
			count = count + 1
			v.alpha = Lerp( 0.03, v.alpha, 255 )
		end
		v.ani = Lerp( 0.03, v.ani, ( ScrW( ) * 0.3 ) * percent )
		v.y = Lerp( 0.03, v.y, -5 + count * 10 )
		
		surface.SetDrawColor( 255,255,255, v.alpha - 30 )
		surface.SetMaterial( Material( "CAT/bar_background.png", "smooth" ) )
		surface.DrawTexturedRect( 5, v.y + 4, ScrW( ) * 0.3, 1 )
		
		draw.RoundedBox( 0, 5, v.y, v.ani, 5, Color( v.color.r, v.color.g, v.color.b, v.alpha ) )
	end
	
	hook.Run( "HUDDrawBarBottom", 5, catherine.bar.Lists[ #catherine.bar.Lists ].y )
end

do
	catherine.bar.Register( function( )
		return LocalPlayer( ):Health( )
	end, function( )
		return LocalPlayer( ):GetMaxHealth( )
	end, Color( 255, 0, 150 ), "health" )

	catherine.bar.Register( function( )
		return LocalPlayer( ):Armor( )
	end, function( )
		return 255
	end, Color( 255, 255, 150 ), "armor" )
end