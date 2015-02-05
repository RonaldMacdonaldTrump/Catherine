
nexus.loading = nexus.loading or false
nexus.loadingText = nexus.loadingText or ""
nexus.loadingAlpha = nexus.loadingAlpha or 255
nexus.loadingImageRotated = nexus.loadingImageRotated or 0
nexus.loadingImageAlpha = nexus.loadingImageAlpha or 255

for i = 15, 64 do
	surface.CreateFont( "nexus_font01_" .. i, { font = "Segoe UI", size = i, weight = 1000, antialias = true } )
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
	if ( nexus.loading ) then
		nexus.loadingAlpha = Lerp( 0.01, nexus.loadingAlpha, 255 )
	else
		nexus.loadingAlpha = Lerp( 0.005, nexus.loadingAlpha, 0 )
		nexus.loadingImageAlpha = Lerp( 0.03, nexus.loadingImageAlpha, 0 )
		nexus.loadingImageRotated = Lerp( 0.03, nexus.loadingImageRotated, 0 )
	end
	
	if ( math.Round( nexus.loadingImageRotated ) <= 359 ) then
		nexus.loadingImageRotated = Lerp( 0.01, nexus.loadingImageRotated, 360 )
	else
		nexus.loadingImageRotated = 0
	end
	
	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 40, 40, 40, nexus.loadingAlpha ) )
	surface.SetDrawColor( 0, 0, 0, nexus.loadingAlpha )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 0, scrW, scrH )
	
	surface.SetDrawColor( 255, 255, 255, nexus.loadingImageAlpha )
	surface.SetMaterial( Material( "nexus/loading2.png" ) )
	surface.DrawTexturedRectRotated( scrW / 2, scrH / 2, 184, 184, nexus.loadingImageRotated )
	
	draw.SimpleText( nexus.loadingText, "nexus_font01_25", scrW / 2, scrH - 70, Color( 255, 255, 255, nexus.loadingAlpha ), 1, 1 )
end

netstream.Hook( "nexus.LoadingStatus", function( data )
	if ( type( data ) == "boolean" ) then
		nexus.loading = data
		nexus.loadingAlpha = 255
		nexus.loadingImageAlpha = 255
	else
		nexus.loadingText = data
	end
end )