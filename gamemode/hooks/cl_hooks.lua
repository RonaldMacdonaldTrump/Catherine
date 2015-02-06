
catherine.loading = catherine.loading or false
catherine.loadingText = catherine.loadingText or ""
catherine.loadingAlpha = catherine.loadingAlpha or 255
catherine.loadingImageRotated = catherine.loadingImageRotated or 0
catherine.loadingImageAlpha = catherine.loadingImageAlpha or 255




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
		catherine.loadingAlpha = Lerp( 0.01, catherine.loadingAlpha, 255 )
	else
		catherine.loadingAlpha = Lerp( 0.005, catherine.loadingAlpha, 0 )
		catherine.loadingImageAlpha = Lerp( 0.03, catherine.loadingImageAlpha, 0 )
		catherine.loadingImageRotated = Lerp( 0.03, catherine.loadingImageRotated, 0 )
	end
	
	if ( math.Round( catherine.loadingImageRotated ) <= 359 ) then
		catherine.loadingImageRotated = Lerp( 0.01, catherine.loadingImageRotated, 360 )
	else
		catherine.loadingImageRotated = 0
	end
	
	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 40, 40, 40, catherine.loadingAlpha ) )
	surface.SetDrawColor( 0, 0, 0, catherine.loadingAlpha )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 0, scrW, scrH )
	--[[
	surface.SetDrawColor( 255, 255, 255, catherine.loadingImageAlpha )
	surface.SetMaterial( Material( "catherine/loading2.png" ) )
	surface.DrawTexturedRectRotated( scrW / 2, scrH / 2, 184, 184, catherine.loadingImageRotated )
	--]]
	draw.SimpleText( catherine.loadingText, "catherine_font01_25", scrW / 2, scrH - 70, Color( 255, 255, 255, catherine.loadingAlpha ), 1, 1 )
end

catherine.menuList = catherine.menuList or { }

function GM:AddMenu( )
	catherine.menuList = { }
	catherine.menuList[ #catherine.menuList + 1 ] = {
		text = "Inventory",
		func = function( )
		
		end
	}
end

netstream.Hook( "catherine.LoadingStatus", function( data )
	if ( type( data ) == "boolean" ) then
		catherine.loading = data
		catherine.loadingAlpha = 255
		catherine.loadingImageAlpha = 255
	else
		catherine.loadingText = data
	end
end )