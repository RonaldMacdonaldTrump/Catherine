catherine.hud = catherine.hud or { }
catherine.hud.death = catherine.hud.death or { }
catherine.hud.death.alpha = catherine.hud.death.alpha or 0
catherine.hud.death.height = catherine.hud.death.height or 0

function catherine.hud.Draw( )
	local scrW, scrH = ScrW( ), ScrH( )
	
	if ( LocalPlayer( ):Alive( ) ) then
		catherine.hud.death.height = Lerp( 0.01, catherine.hud.death.height, 0 )
		catherine.hud.death.alpha = Lerp( 0.05, catherine.hud.death.alpha, 0 )
	else
		catherine.hud.death.height = Lerp( 0.01, catherine.hud.death.height, scrH * 0.5 )
		catherine.hud.death.alpha = Lerp( 0.05, catherine.hud.death.alpha, 255 )
	end
	
	draw.RoundedBox( 0, 0, 0, scrW, catherine.hud.death.height, Color( 0, 0, 0, catherine.hud.death.alpha ) )
	draw.RoundedBox( 0, 0, scrH - catherine.hud.death.height, scrW, catherine.hud.death.height, Color( 0, 0, 0, catherine.hud.death.alpha ) )
	
	local spawnTime = LocalPlayer( ):GetNetworkValue( "nextSpawnTime", nil )
	if ( !spawnTime ) then return end
	
	draw.SimpleText( math.Round( math.max( spawnTime - CurTime( ), 0 ) ) .. " second after your are maybe spawn;", "catherine_font02_25", scrW / 2, scrH / 2, Color( 255, 255, 255, catherine.hud.death.alpha ), 1, 1 )
end