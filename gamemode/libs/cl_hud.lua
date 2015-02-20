catherine.hud = catherine.hud or { }
catherine.hud.death = catherine.hud.death or { }
catherine.hud.death.alpha = catherine.hud.death.alpha or 0
catherine.hud.death.height = catherine.hud.death.height or 0
catherine.hud.ProgressBar = catherine.hud.ProgressBar or nil
catherine.hud.CinematicIntro = catherine.hud.CinematicIntro or nil

netstream.Hook( "catherine.hud.CinematicIntro_Init", function( )
	catherine.hud.CinematicIntroInit( )
end )

function catherine.hud.Draw( )
	catherine.hud.ProgressBarDraw( )
	catherine.hud.CinematicIntroDraw( )
end

function catherine.hud.CinematicIntroInit( )
	catherine.hud.CinematicIntro = { }
	catherine.hud.CinematicIntro.firstalpha = 0
	catherine.hud.CinematicIntro.secondalpha = 0
	catherine.hud.CinematicIntro.thirdalpha = 0
	catherine.hud.CinematicIntro.backalpha = 200
	catherine.hud.CinematicIntro.endIng = false
	catherine.hud.CinematicIntro.endTime = CurTime( ) + 10
	
	catherine.hud.CinematicIntro.first = false
	catherine.hud.CinematicIntro.second = false
	
	catherine.hud.CinematicIntro.firstTextTime = CurTime( )
	catherine.hud.CinematicIntro.secondTextTime = CurTime( ) + 3
	catherine.hud.CinematicIntro.thirdTextTime = CurTime( ) + 6
end



function catherine.hud.CinematicIntroDraw( )
	if ( !catherine.hud.CinematicIntro ) then return end
	local scrW, scrH = ScrW( ), ScrH( )
	if ( catherine.hud.CinematicIntro.first and catherine.hud.CinematicIntro.second ) then
		catherine.hud.CinematicIntro.firstalpha = Lerp( 0.03, catherine.hud.CinematicIntro.firstalpha, 0 )
		catherine.hud.CinematicIntro.secondalpha = Lerp( 0.03, catherine.hud.CinematicIntro.secondalpha, 0 )
		catherine.hud.CinematicIntro.thirdalpha = Lerp( 0.03, catherine.hud.CinematicIntro.thirdalpha, 0 )
		catherine.hud.CinematicIntro.backalpha = Lerp( 0.01, catherine.hud.CinematicIntro.backalpha, 0 )
	end
	if ( catherine.hud.CinematicIntro.firstTextTime + 3 <= CurTime( ) and catherine.hud.CinematicIntro.secondTextTime + 3 <= CurTime( ) and !catherine.hud.CinematicIntro.endIng ) then
		catherine.hud.CinematicIntro.first = true
		catherine.hud.CinematicIntro.firstalpha = Lerp( 0.03, catherine.hud.CinematicIntro.firstalpha, 0 )
		catherine.hud.CinematicIntro.secondalpha = Lerp( 0.03, catherine.hud.CinematicIntro.secondalpha, 0 )
		catherine.hud.CinematicIntro.thirdalpha = Lerp( 0.03, catherine.hud.CinematicIntro.thirdalpha, 255 )
	end
	
	if ( catherine.hud.CinematicIntro.thirdTextTime + 6 <= CurTime( ) ) then
		catherine.hud.CinematicIntro.second = true
		catherine.hud.CinematicIntro.endIng = true
	end
	
	if ( catherine.hud.CinematicIntro.firstTextTime <= CurTime( ) and !catherine.hud.CinematicIntro.first ) then
		catherine.hud.CinematicIntro.firstalpha = Lerp( 0.03, catherine.hud.CinematicIntro.firstalpha, 255 )
	end
	if ( catherine.hud.CinematicIntro.secondTextTime <= CurTime( ) and !catherine.hud.CinematicIntro.first ) then
		catherine.hud.CinematicIntro.secondalpha = Lerp( 0.03, catherine.hud.CinematicIntro.secondalpha, 255 )
	end
	
	local information = hook.Run( "RunCinematicIntro_Information" )
	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 50, 50, 50, catherine.hud.CinematicIntro.backalpha ) )
	draw.SimpleText( information.title, "catherine_font01_50", scrW / 2, scrH / 2, Color( 255, 255, 255, catherine.hud.CinematicIntro.firstalpha ), 1, 1 )
	draw.SimpleText( information.desc, "catherine_font01_30", scrW / 2, scrH / 2 + 50, Color( 255, 255, 255, catherine.hud.CinematicIntro.secondalpha ), 1, 1 )
	draw.SimpleText( information.author, "catherine_font01_20", scrW * 0.3, scrH * 0.7, Color( 255, 255, 255, catherine.hud.CinematicIntro.thirdalpha ), 1, 1 )
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