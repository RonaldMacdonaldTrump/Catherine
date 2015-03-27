if ( !catherine.option ) then
	catherine.util.Include( "cl_option.lua" )
end
catherine.hud = catherine.hud or {
	ProgressBar = nil,
	welcomeIntro = nil,
	blockedModules = { },
	clip1 = 0,
	pre = 0,
	vAlpha = 0,
	vAlphaTarget = 255,
	checkV = CurTime( ),
	deathAlpha = 0
}

netstream.Hook( "catherine.hud.WelcomeIntroStart", function( )
	catherine.hud.WelcomeIntroInitialize( )
end )

function catherine.hud.RegisterBlockModule( name )
	catherine.hud.blockedModules[ #catherine.hud.blockedModules + 1 ] = name
end

function catherine.hud.Draw( )
	if ( catherine.option.Get( "CONVAR_MAINHUD" ) == "0" ) then return end
	catherine.hud.Vignette( )
	catherine.hud.ScreenDamageDraw( )
	catherine.hud.AmmoDraw( )
	catherine.hud.DeathScreen( )
	catherine.hud.ProgressBarDraw( )
	catherine.hud.WelcomeIntroDraw( )
end

function catherine.hud.DeathScreen( )
	catherine.hud.deathAlpha = Lerp( 0.03, catherine.hud.deathAlpha, LocalPlayer( ):Alive( ) and 0 or 255 )
	
	draw.RoundedBox( 0, 0, 0, ScrW( ), ScrH( ), Color( 0, 0, 0, catherine.hud.deathAlpha ) )
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

function catherine.hud.WelcomeIntroInitialize( )
	local t = { }
	t.firstalpha = 0
	t.secondalpha = 0
	t.thirdalpha = 0
	t.backalpha = 200
	t.endIng = false
	t.endTime = CurTime( ) + 10
	t.first = false
	t.second = false
	t.start = CurTime( ) + 15
	t.firstTextTime = CurTime( )
	t.secondTextTime = CurTime( ) + 3
	t.thirdTextTime = CurTime( ) + 6
	
	catherine.hud.welcomeIntro = t
end

function catherine.hud.WelcomeIntroDraw( )
	if ( !catherine.hud.welcomeIntro ) then return end
	local t = catherine.hud.welcomeIntro
	if ( t.start <= CurTime( ) ) then
		catherine.hud.welcomeIntro = nil
		return
	end
	local scrW, scrH = ScrW( ), ScrH( )

	if ( t.first and t.second ) then
		t.firstalpha = Lerp( 0.03, t.firstalpha, 0 )
		t.secondalpha = Lerp( 0.03, t.secondalpha, 0 )
		t.thirdalpha = Lerp( 0.03, t.thirdalpha, 0 )
	end
	if ( t.firstTextTime + 3 <= CurTime( ) and t.secondTextTime + 3 <= CurTime( ) and !t.endIng ) then
		t.first = true
		t.firstalpha = Lerp( 0.03, t.firstalpha, 0 )
		t.secondalpha = Lerp( 0.03, t.secondalpha, 0 )
		t.thirdalpha = Lerp( 0.03, t.thirdalpha, 255 )
		t.backalpha = Lerp( 0.01, t.backalpha, 0 )
	end
	if ( t.thirdTextTime + 6 <= CurTime( ) ) then t.second = true t.endIng = true end
	if ( t.firstTextTime <= CurTime( ) and !t.first ) then t.firstalpha = Lerp( 0.03, t.firstalpha, 255 ) end
	if ( t.secondTextTime <= CurTime( ) and !t.first ) then t.secondalpha = Lerp( 0.03, t.secondalpha, 255 ) end
	local information = hook.Run( "GetSchemaInformation" )
	
	surface.SetDrawColor( 50, 50, 50, t.backalpha )
	surface.SetMaterial( Material( "gui/center_gradient" ) )
	surface.DrawTexturedRect( scrW / 2 - scrW / 2 / 2, scrH * 0.3 - ( scrH * 0.2 ) / 2, scrW / 2, scrH * 0.2 )
	
	draw.SimpleText( information.title, "catherine_schema_title", scrW / 2, scrH * 0.3 - 20, Color( 255, 255, 255, t.firstalpha ), 1, 1 )
	draw.SimpleText( information.desc, "catherine_normal30", scrW / 2, scrH * 0.35, Color( 255, 255, 255, t.secondalpha ), 1, 1 )
	draw.SimpleText( information.author, "catherine_normal20", scrW * 0.2, scrH * 0.8, Color( 255, 255, 255, t.thirdalpha ), 1, 1 )
end

function catherine.hud.ProgressBarAdd( message, endTime )
	catherine.hud.ProgressBar = {
		message = message,
		startTime = CurTime( ),
		endTime = CurTime( ) + endTime
	}
end

function catherine.hud.ProgressBarDraw( )
	if ( !catherine.hud.ProgressBar ) then return end
	if ( catherine.hud.ProgressBar.endTime <= CurTime( ) ) then catherine.hud.ProgressBar = nil return end
	local scrW, scrH = ScrW( ), ScrH( )
	local fraction = 1 - math.TimeFraction( catherine.hud.ProgressBar.startTime, catherine.hud.ProgressBar.endTime, CurTime( ) )
	
	surface.SetDrawColor( 50, 50, 50, 150 )
	surface.SetMaterial( Material( "gui/center_gradient" ) )
	surface.DrawTexturedRect( 0, scrH / 2 - 80, scrW, 110 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 90, 90, 90, 255 )
	catherine.geometry.DrawCircle( scrW / 2, scrH / 2 - 40, 15, 5, 90, 360, 100 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 255, 255, 255, 255 )
	catherine.geometry.DrawCircle( scrW / 2, scrH / 2 - 40, 15, 5, 90, 360 * fraction, 100 )
	
	draw.SimpleText( catherine.hud.ProgressBar.message or "", "catherine_normal25", scrW / 2, scrH / 2, Color( 255, 255, 255, 255 ), 1, 1 )
end

CAT_CONVAR_HUD = CreateClientConVar( "cat_convar_hud", 1, true, true )
CAT_CONVAR_BAR = CreateClientConVar( "cat_convar_bar", 1, true, true )

local modules = {
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo",
	"CHudCrosshair",
	"CHudDamageIndicator"
}
for i = 1, #modules do
	catherine.hud.RegisterBlockModule( modules[ i ] )
end