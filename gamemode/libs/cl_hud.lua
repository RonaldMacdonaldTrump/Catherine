if ( !catherine.option ) then
	catherine.util.Include( "cl_option.lua" )
end
catherine.hud = catherine.hud or { }
catherine.hud.ProgressBar = catherine.hud.ProgressBar or nil
catherine.hud.CinematicIntro = catherine.hud.CinematicIntro or nil
catherine.hud.clip1 = catherine.hud.clip1 or 0
catherine.hud.pre = catherine.hud.pre or 0
catherine.hud.vAlpha = catherine.hud.vAlpha or 0
catherine.hud.vAlphaTarget = catherine.hud.vAlphaTarget or 255
catherine.hud.checkV = catherine.hud.checkV or CurTime( )

netstream.Hook( "catherine.hud.CinematicIntro_Init", function( )
	catherine.hud.CinematicIntroInit( )
end )

function catherine.hud.Draw( )
	catherine.hud.Vignette( )
	catherine.hud.ScreenDamageDraw( )
	catherine.hud.AmmoDraw( )
	catherine.hud.ProgressBarDraw( )
	catherine.hud.CinematicIntroDraw( )
end

function catherine.hud.Vignette( )
	if ( catherine.hud.checkV <= CurTime( ) ) then
		local data = { }
		data.start = LocalPlayer( ):GetPos( )
		data.endpos = data.start + Vector( 0, 0, 2000 )
		local tr = util.TraceLine( data )
		if ( !tr.Hit or tr.HitSky ) then
			catherine.hud.vAlphaTarget = 125
		else
			catherine.hud.vAlphaTarget = 255
		end
		catherine.hud.checkV = CurTime( ) + 1
	end
	
	catherine.hud.vAlpha = math.Approach( catherine.hud.vAlpha, catherine.hud.vAlphaTarget, FrameTime( ) * 90 )
	
	surface.SetDrawColor( 0, 0, 0, catherine.hud.vAlpha )
	surface.SetMaterial( Material( "CAT/vignette.png" ) )
	surface.DrawTexturedRect( 0, 0, ScrW( ), ScrH( ) )
end

function catherine.hud.ScreenDamageDraw( ) end

function catherine.hud.AmmoDraw( )
	local wep = LocalPlayer( ):GetActiveWeapon( )
	if ( !IsValid( wep ) or ( wep.DrawHUD == false ) ) then return end
	local clip1 = wep:Clip1( )
	local pre = LocalPlayer( ):GetAmmoCount( wep:GetPrimaryAmmoType( ) )
	//local sec = LocalPlayer( ):GetAmmoCount( wep:GetSecondaryAmmoType( ) ) -- ^_^;
	catherine.hud.clip1 = Lerp( 0.03, catherine.hud.clip1, clip1 )
	catherine.hud.pre = Lerp( 0.03, catherine.hud.pre, pre )
	if ( clip1 > 0 or pre > 0 ) then
		draw.SimpleText( clip1 == -1 and pre or math.Round( catherine.hud.clip1 ) .. " / " .. math.Round( catherine.hud.pre ), "catherine_normal25", ScrW( ) - 30, ScrH( ) - 30, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
	end
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
	if ( catherine.hud.CinematicIntro.thirdTextTime + 6 <= CurTime( ) ) then catherine.hud.CinematicIntro.second = true catherine.hud.CinematicIntro.endIng = true end
	if ( catherine.hud.CinematicIntro.firstTextTime <= CurTime( ) and !catherine.hud.CinematicIntro.first ) then catherine.hud.CinematicIntro.firstalpha = Lerp( 0.03, catherine.hud.CinematicIntro.firstalpha, 255 ) end
	if ( catherine.hud.CinematicIntro.secondTextTime <= CurTime( ) and !catherine.hud.CinematicIntro.first ) then catherine.hud.CinematicIntro.secondalpha = Lerp( 0.03, catherine.hud.CinematicIntro.secondalpha, 255 ) end
	local information = hook.Run( "GetSchemaInformation" )
	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 50, 50, 50, catherine.hud.CinematicIntro.backalpha ) )
	draw.SimpleText( information.title, "catherine_schema_title", scrW / 2, scrH / 2, Color( 255, 255, 255, catherine.hud.CinematicIntro.firstalpha ), 1, 1 )
	draw.SimpleText( information.desc, "catherine_normal30", scrW / 2, scrH / 2 + 50, Color( 255, 255, 255, catherine.hud.CinematicIntro.secondalpha ), 1, 1 )
	draw.SimpleText( information.author, "catherine_normal20", scrW * 0.2, scrH * 0.8, Color( 255, 255, 255, catherine.hud.CinematicIntro.thirdalpha ), 1, 1 )
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
	if ( catherine.hud.ProgressBar.endTime <= CurTime( ) ) then catherine.hud.ProgressBar = nil return end
	local scrW, scrH = ScrW( ), ScrH( )
	local fraction = 1 - math.TimeFraction( catherine.hud.ProgressBar.startTime, catherine.hud.ProgressBar.endTime, CurTime( ) )
	catherine.hud.ProgressBar.w = Lerp( 0.03, catherine.hud.ProgressBar.w, ( scrW * 0.4 ) * fraction )
	draw.RoundedBox( 0, scrW * 0.3, scrH * 0.5 - 20, scrW * 0.4, 40, Color( 120, 120, 120, 255 ) )
	draw.RoundedBox( 0, scrW * 0.3, scrH * 0.5 - 20, catherine.hud.ProgressBar.w, 40, Color( 235, 235, 235, 255 ) )
	draw.SimpleText( catherine.hud.ProgressBar.message or "", "catherine_normal20", scrW / 2, scrH / 2, Color( 30, 30, 30, 255 ), 1, 1 )
end

function GM:PostRenderScreenColor( pl )
	local data = { }
	
	if ( !pl:Alive( ) ) then
		local spawnTime = catherine.network.GetNetVar( LocalPlayer( ), "nextSpawnTime", 0 )
		local fraction = 1 - math.TimeFraction( catherine.network.GetNetVar( LocalPlayer( ), "deathTime", 0 ), catherine.network.GetNetVar( LocalPlayer( ), "nextSpawnTime", 0 ), CurTime( ) )
		data.colour = math.Clamp( fraction, 0, 0.9 )
	else
		data.contrast = math.max( math.min( LocalPlayer( ):Health( ) / LocalPlayer( ):GetMaxHealth( ), 1 ), 0.3 )
	end
	
	hook.Run( "OnRenderScreenColor", pl, data )
	
	return data
end

CAT_CONVAR_HUD = CreateClientConVar( "cat_convar_hud", 1, true, true )

catherine.option.Register( "CONVAR_HUD", CAT_CONVAR_HUD, "Show HUD", "", {
	onSet = function( conVarObject, newVal )
		RunConsoleCommand( "cat_convar_hud", newVal )
	end
} )