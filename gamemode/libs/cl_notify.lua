catherine.notify = catherine.notify or { }
catherine.notify.Lists = { }

function catherine.notify.Add( text, time )
	local scrW, scrH = ScrW( ), ScrH( )
	time = time or 5
	
	local notify = vgui.Create( "DPanel" )
	notify:ParentToHUD( )
	notify:SetSize( scrW * 0.5, 20 )
	notify:SetPos( scrW / 2 - notify:GetWide( ) / 2, scrH - ( ( 25 * ( #catherine.notify.Lists + 1 ) ) + 5 ) )
	notify.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 235 ) )
		
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
	end

	local message = vgui.Create( "DLabel", notify )
	message:SetColor( Color( 255, 255, 255, 255 ) )
	message:SetFont( "catherine_font01_15" )
	message:SetText( text )
	message:SizeToContents( )
	message:Center( )
	
	catherine.notify.Lists[ #catherine.notify.Lists + 1 ] = notify
	
	timer.Create( "Catherine.notify.FadeTimer_" .. #catherine.notify.Lists, time, 1, function( )
		for k, v in pairs( catherine.notify.Lists ) do
			if ( v == notify ) then
				table.remove( catherine.notify.Lists, k )
			end
		end
		notify:AlphaTo( 0, 0.5, 0 )
		timer.Simple( 0.5, function( )
			notify:Remove( )
			notify = nil
		end )
	end )
end