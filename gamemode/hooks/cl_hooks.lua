
catherine.loading = catherine.loading or false
catherine.errorText = catherine.errorText or ""
catherine.alpha = catherine.alpha or 255
catherine.color = catherine.color or 0
catherine.textColor = catherine.textColor or 255
catherine.loadingStarting = catherine.loadingStarting or false
catherine.progressBar = catherine.progressBar or 0
catherine.percent = catherine.percent or 0


catherine.menuList = catherine.menuList or { }

for i = 15, 64 do
	surface.CreateFont( "catherine_font01_" .. i, { font = "Segoe UI", size = i, weight = 1000, antialias = true } )
end

function GM:HUDShouldDraw( element )
	if ( element == "CHudHealth" or element == "CHudBattery" or element == "CHudAmmo" or element == "CHudSecondaryAmmo" ) then
		return false
	end
	
	if ( element == "CHudCrosshair" ) then
		return false
	end

	return true
end


function GM:HUDDrawScoreBoard( )
	local scrW, scrH = ScrW( ), ScrH( )
	if ( catherine.loading ) then
		if ( catherine.loadingStarting ) then
			catherine.alpha = Lerp( 0.01, catherine.alpha, 255 )
			catherine.color = Lerp( 0.01, catherine.color, 0 )
			catherine.textColor = Lerp( 0.01, catherine.textColor, 255 )
		else
			catherine.color = Lerp( 0.01, catherine.color, 255 )
			catherine.alpha = Lerp( 0.01, catherine.alpha, 255 )
			catherine.textColor = Lerp( 0.01, catherine.textColor, 50 )
		end
	else
		catherine.alpha = Lerp( 0.005, catherine.alpha, 0 )
	end
	
	catherine.progressBar = Lerp( 0.05, catherine.progressBar, ( scrW - 20 ) * catherine.percent )

	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( catherine.color, catherine.color, catherine.color, catherine.alpha ) )
	
	surface.SetDrawColor( catherine.color - 55, catherine.color - 55, catherine.color - 55, catherine.alpha )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 0, scrW, scrH )

	surface.SetDrawColor( catherine.textColor, catherine.textColor, catherine.textColor, catherine.alpha )
	surface.SetMaterial( Material( "catherine/logo.png" ) )
	surface.DrawTexturedRect( scrW / 2 - 512 / 2, scrH / 2 - 256 / 2, 512, 256 )
	
	draw.RoundedBox( 0, 10, scrH - 20, scrW - 20, 10, Color( catherine.textColor * 2, catherine.textColor * 2, catherine.textColor * 2, catherine.alpha ) )
	draw.RoundedBox( 0, 10, scrH - 20, catherine.progressBar, 10, Color( catherine.textColor, catherine.textColor, catherine.textColor, catherine.alpha ) )
	
	draw.SimpleText( catherine.errorText, "catherine_font01_40", scrW / 2, scrH - 70, Color( catherine.textColor, catherine.textColor, catherine.textColor, catherine.alpha ), 1, 1 )
end

function GM:AddMenu( )
	catherine.RegisterMenuItem( "Inventory", "catherine.vgui.inventory", "Open the your inventory." )
end

netstream.Hook( "catherine.LoadingStatus", function( data )
	if ( data[ 2 ] == true ) then
		if ( data[ 1 ] == true ) then
			catherine.loading = true
			catherine.loadingStarting = false
		elseif ( data[ 1 ] == false ) then
			catherine.loading = true
			catherine.loadingStarting = true
		end
	elseif ( data[ 2 ] == false ) then
		catherine.loading = true
		catherine.errorText = data[ 3 ] or ""
	end
	catherine.percent = data[ 4 ]
	if ( data[ 5 ] == true ) then
		catherine.loading = false
		catherine.loadingStarting = false
	end
end )