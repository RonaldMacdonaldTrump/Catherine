catherine.loaded = catherine.loaded or false
catherine.loaded2 = catherine.loaded2 or false
catherine.errorText = catherine.errorText or ""
catherine.alpha = catherine.alpha or 255
catherine.progressBar = catherine.progressBar or 0
catherine.percent = catherine.percent or 0

catherine.menuList = catherine.menuList or { }
catherine.locationRandom = catherine.locationRandom or table.Random( catherine.configs.locationRandom )
catherine.hudHide = {
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo",
	"CHudCrosshair",
	"CHudDamageIndicator",
	"CHudChat"
}
catherine.entityCache = { }
catherine.nextRefresh = catherine.nextRefresh or CurTime( )
local toscreen = FindMetaTable("Vector").ToScreen

for i = 15, 64 do
	surface.CreateFont( "catherine_font01_" .. i, { font = "Segoe UI", size = i, weight = 1000, antialias = true } )
	surface.CreateFont( "catherine_font02_" .. i, { font = "Segoe UI", size = i, weight = 1000, antialias = true, outline = true } )
end

function GM:HUDShouldDraw( name )
	for k, v in pairs( catherine.hudHide ) do
		if ( v == name ) then
			return false
		end
	end
	
	return true
end

function GM:CalcView( pl, pos, ang, fov )
	if ( IsValid( catherine.vgui.character ) ) then
		local sin = math.sin( CurTime( ) / 4 )
		local sin2 = math.sin( CurTime( ) / 5 )
		viewSin = ( 10 / 1 ) * sin
		viewSin2 = ( 10 / 1 ) * sin2
		local view = { }
		view.origin = catherine.locationRandom.pos
		view.angles = Angle( catherine.locationRandom.ang.p + ( viewSin / 2 ), catherine.locationRandom.ang.y + ( viewSin2 / 2 ), catherine.locationRandom.ang.r ) 
		view.fov = fov
		return view
	end
end

function GM:DrawEntityInformation( ent, alpha )
	local entPlayer = ent:GetNetworkValue( "player" )
	if ( ent:IsPlayer( ) and ent:Alive( ) ) then
		local lp = LocalPlayer( )
		local position = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		local x, y = position.x, position.y - 100
		local x2, y2 = 0, 0
		
		local targetInformation = hook.Run( "GetTargetInformation", lp, ent )
		draw.SimpleText( targetInformation[ 1 ], "catherine_font02_25", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
		y = y + 20
		draw.SimpleText( targetInformation[ 2 ], "catherine_font02_15", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
		y = y + 15
		
		hook.Run( "PlayerInformationDraw", ent, x, y, alpha )
	elseif ( entPlayer and entPlayer:IsPlayer( ) ) then
		local ragdollID = ent:GetNetworkValue( "ragdollID", nil )
		if ( !ragdollID ) then return end
		local entFix = Entity( ragdollID )
		if ( !IsValid( entFix ) ) then return end
		local lp = LocalPlayer( )
		local position = toscreen( entFix:LocalToWorld( entFix:OBBCenter( ) ) )
		local x, y = position.x, position.y - 100
		local x2, y2 = 0, 0
		
		local targetInformation = hook.Run( "GetTargetInformation", lp, entPlayer )
		draw.SimpleText( targetInformation[ 1 ], "catherine_font02_25", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
		y = y + 20
		draw.SimpleText( targetInformation[ 2 ], "catherine_font02_15", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
		y = y + 15
		
		hook.Run( "PlayerInformationDraw", entPlayer, x, y, alpha )
	end
end

function GM:PlayerInformationDraw( pl, x, y, alpha )
	if ( !pl:Alive( ) ) then
		local gText = ( pl:GetGender( ) == "male" and "He" ) or "She"
		draw.SimpleText( gText .. " has going to hell, RIP.", "catherine_font02_15", x, y, Color( 255, 150, 150, alpha ), 1, 1 )
	end
end

function GM:HUDDrawScoreBoard( )
	local scrW, scrH = ScrW( ), ScrH( )
	if ( !catherine.loaded ) then
		catherine.alpha = Lerp( 0.01, catherine.alpha, 255 )
	else
		catherine.alpha = Lerp( 0.005, catherine.alpha, 0 )
	end
	
	catherine.progressBar = Lerp( 0.05, catherine.progressBar, ( scrW - 40 ) * catherine.percent )

	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 255, 255, 255, catherine.alpha ) )
	
	surface.SetDrawColor( 200, 200, 200, catherine.alpha )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 0, scrW, scrH )

	surface.SetDrawColor( 0, 0, 0, catherine.alpha )
	surface.SetMaterial( Material( "catherine/catherine_logo.png" ) )
	surface.DrawTexturedRect( scrW / 2 - 512 / 2, scrH / 2 - 256 / 2, 512, 256 )
	
	draw.SimpleText( "Catherine version 0.2 - Development version", "catherine_font01_15", 15, 20, Color( 50, 50, 50, catherine.alpha ), TEXT_ALIGN_LEFT, 1 )
	if ( catherine.percent != 0 ) then
		draw.RoundedBox( 0, 20, scrH - 15, scrW - 40, 3, Color( 50, 50, 50, catherine.alpha ) )
		draw.RoundedBox( 0, 20, scrH - 15, catherine.progressBar, 3, Color( 255, 255, 255, catherine.alpha ) )
	end
	draw.SimpleText( catherine.errorText, "catherine_font01_25", scrW / 2, scrH - 25, Color( 80, 80, 80, catherine.alpha ), 1, 1 )
end

function GM:ProgressEntityCache( )
	if ( LocalPlayer( ):IsCharacterLoaded( ) and catherine.nextRefresh < CurTime( ) ) then
		local ent

		local trace = { }
		trace.start = LocalPlayer( ):GetShootPos( )
		trace.endpos = trace.start + LocalPlayer( ):GetAimVector() * 160
		trace.filter = LocalPlayer( )

		ent = util.TraceLine( trace ).Entity

		if ( IsValid( ent ) ) then catherine.entityCache[ ent ] = true
		else catherine.entityCache[ ent ] = nil end
		catherine.nextRefresh = CurTime( ) + 0.5
	end
	
	for k, v in pairs( catherine.entityCache ) do
		if ( !IsValid( k ) ) then catherine.entityCache[ k ] = nil continue end
		local distance = k:GetPos( ):Distance( LocalPlayer( ):GetPos( ) )
		local a = Lerp( 0.03, k.alpha or 0, 255 - ( distance ) )
		k.alpha = a

		if ( math.Round( a ) <= 0 ) then catherine.entityCache[ k ] = nil end
		hook.Run( "DrawEntityInformation", k, a )
	end
end

function GM:HUDPaint( )
	if ( IsValid( catherine.vgui.character ) ) then return end
	catherine.hud.Draw( )
	catherine.bar.Draw( )
	catherine.notify.Draw( )
	catherine.wep.Draw( LocalPlayer( ) )
	
	if ( !LocalPlayer( ):Alive( ) ) then return end
	hook.Run( "ProgressEntityCache" )
	
	draw.SimpleText( "Catherine Development Version", "catherine_font01_20", ScrW( ) - 10, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

function GM:CalcViewModelView( weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAng )
	if ( !IsValid( weapon ) ) then return end
	local pl = LocalPlayer()
	local value = 0
	if ( !pl:GetWeaponRaised( ) ) then value = 100 end

	local fraction = ( pl.wepRaisedFraction or 0 ) / 100
	local lowerAngle = weapon.LowerAngles or Angle( 30, -30, -25 )
	
	eyeAng:RotateAroundAxis( eyeAng:Up( ), lowerAngle.p * fraction)
	eyeAng:RotateAroundAxis( eyeAng:Forward( ), lowerAngle.y * fraction)
	eyeAng:RotateAroundAxis( eyeAng:Right( ), lowerAngle.r * fraction)

	pl.wepRaisedFraction = Lerp( FrameTime( ) * 2, pl.wepRaisedFraction or 0, value )

	viewModel:SetAngles( eyeAng )
	return oldEyePos, eyeAng
end

function GM:AddMenu( )
	catherine.RegisterMenuItem( "Inventory", "catherine.vgui.inventory", "Open the your inventory." )
	catherine.RegisterMenuItem( "Scoreboard", "catherine.vgui.scoreboard", "Open the your scoreboard." )
end

function GM:RunCinematicIntro_Information( )
	return {
		title = Schema.Title,
		desc = Schema.Desc,
		author = "The roleplaying schema development and design by " .. Schema.Author .. "."
	}
end

function GM:ScoreboardShow()
	if ( IsValid( catherine.vgui.menu ) ) then
		catherine.vgui.menu:Close( )
		gui.EnableScreenClicker( false )
	else
		catherine.vgui.menu = vgui.Create( "catherine.vgui.menu" )
		gui.EnableScreenClicker( true )
	end
end

function GM:RenderScreenspaceEffects( )
	local data = hook.Run( "GetCustomColorData", LocalPlayer( ) ) or { }
	
	local tab = { }
	tab[ "$pp_colour_addr" ] = data.addr or 0
	tab[ "$pp_colour_addg" ] = data.addg or 0
	tab[ "$pp_colour_addb" ] = data.addb or 0
	tab[ "$pp_colour_brightness" ] = data.brightness or 0
	tab[ "$pp_colour_contrast" ] = data.contrast or 1
	tab[ "$pp_colour_colour" ] = data.colour or 0.9
	tab[ "$pp_colour_mulr" ] = data.mulr or 0
	tab[ "$pp_colour_mulg" ] = data.mulg or 0
	tab[ "$pp_colour_mulb" ] = data.mulb or 0
	
	DrawColorModify( tab )
end

netstream.Hook( "catherine.LoadingStatus", function( data )
	catherine.loaded = data[ 1 ]
	catherine.percent = data[ 2 ]
	if ( data[ 3 ] and data[ 3 ] != "" ) then
		catherine.errorText = data[ 3 ]
		catherine.percent = 0
	end
end )