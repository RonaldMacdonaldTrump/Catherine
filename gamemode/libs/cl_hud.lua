catherine.hud = catherine.hud or { }
catherine.hud.death = catherine.hud.death or { }
catherine.hud.death.alpha = catherine.hud.death.alpha or 0
catherine.hud.death.height = catherine.hud.death.height or 0
catherine.hud.ProgressBar = catherine.hud.ProgressBar or nil

function catherine.hud.Draw( )
	catherine.hud.ProgressBarDraw( )
end

function catherine.hud.ProgressBarAdd( message, endTime )
	catherine.hud.ProgressBar = {
		message = message,
		startTime = CurTime( ),
		endTime = CurTime( ) + endTime,
		w = 0
	}
end

function catherine.hud.ProgressBarDraw( )
	if ( !catherine.hud.ProgressBar ) then return end
	if ( catherine.hud.ProgressBar.endTime <= CurTime( ) ) then
		catherine.hud.ProgressBar = nil
		return
	end
	local scrW, scrH = ScrW( ), ScrH( )
	local fraction = 1 - math.TimeFraction( catherine.hud.ProgressBar.startTime, catherine.hud.ProgressBar.endTime, CurTime( ) )
	catherine.hud.ProgressBar.w = Lerp( 0.03, catherine.hud.ProgressBar.w, ( scrW * 0.4 ) * fraction )
	draw.RoundedBox( 0, scrW * 0.3, scrH * 0.5 - 20, scrW * 0.4, 40, Color( 80, 80, 80, 255 ) )
	draw.RoundedBox( 0, scrW * 0.3, scrH * 0.5 - 20, catherine.hud.ProgressBar.w, 40, Color( 235, 235, 235, 255 ) )
	draw.SimpleText( catherine.hud.ProgressBar.message or "", "catherine_font01_20", scrW / 2, scrH / 2, Color( 30, 30, 30, 255 ), 1, 1 )
end

function GM:GetCustomColorData( pl )
	local data = { }
	
	if ( !pl:Alive( ) ) then
		local spawnTime = LocalPlayer( ):GetNetworkValue( "nextSpawnTime", 0 )
		local fraction = 1 - math.TimeFraction( LocalPlayer( ):GetNetworkValue( "deathTime", 0 ), LocalPlayer( ):GetNetworkValue( "nextSpawnTime", 0 ), CurTime( ) )
		data.colour = math.Clamp( fraction, 0, 0.9 )
	end
	
	return data
end