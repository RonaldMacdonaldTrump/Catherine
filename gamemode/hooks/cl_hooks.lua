catherine.loading = catherine.loading or {
	status = false,
	errorMsg = nil,
	alpha = 255,
	rotate = 0,
	msg = ""
}
catherine.hudHide = {
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo",
	"CHudCrosshair",
	"CHudDamageIndicator",
	"CHudChat"
}
catherine.entityCaches = { }
catherine.nextCacheDo = CurTime( )
local toscreen = FindMetaTable("Vector").ToScreen


function GM:HUDShouldDraw( name )
	for k, v in pairs( catherine.hudHide ) do
		if ( v == name ) then
			return false
		end
	end
	
	return true
end

function GM:CalcView( pl, pos, ang, fov )

end

function GM:DrawEntityTargetID( pl, ent, a )
	if ( ent:IsPlayer( ) ) then
		local pos = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		local x, y, x2, y2 = pos.x, pos.y - 100, 0, 0
		local playerName, playerDesc = hook.Run( "GetPlayerInformation", pl, ent )
		draw.SimpleText( playerName, "catherine_normal25", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20
		draw.SimpleText( playerDesc, "catherine_normal15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 15
		
		hook.Run( "PlayerInformationDraw", pl, ent, x, y, a )
	end
/* // have bug.
	local entPlayer = ent:GetNetworkValue( "player" )
	if ( ent:IsPlayer( ) and ent:Alive( ) ) then
		local lp = LocalPlayer( )
		local position = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		local x, y = position.x, position.y - 100
		local x2, y2 = 0, 0
		
		local targetInformation = hook.Run( "GetTargetInformation", lp, ent )
		draw.SimpleText( targetInformation[ 1 ], "catherine_normal25", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
		y = y + 20
		draw.SimpleText( targetInformation[ 2 ], "catherine_normal15", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
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
		draw.SimpleText( targetInformation[ 1 ], "catherine_normal25", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
		y = y + 20
		draw.SimpleText( targetInformation[ 2 ], "catherine_normal15", x, y, Color( 255, 255, 255, alpha ), 1, 1 )
		y = y + 15
		
		hook.Run( "PlayerInformationDraw", entPlayer, x, y, alpha )
	end
*/
end

function GM:PlayerInformationDraw( pl, target, x, y, a )
	if ( !pl:Alive( ) ) then
		local gText = ( pl:GetGender( ) == "male" and "He" ) or "She"
		draw.SimpleText( gText .. " was going to hell, RIP.", "catherine_normal15", x, y, Color( 255, 150, 150, a ), 1, 1 )
	end
end

function GM:HUDDrawScoreBoard( )
	local scrW, scrH = ScrW( ), ScrH( )
	local a = catherine.loading.alpha
	if ( !catherine.loading.status ) then
		catherine.loading.alpha = Lerp( 0.01, catherine.loading.alpha, 255 )
	else
		catherine.loading.alpha = Lerp( 0.008, catherine.loading.alpha, 0 )
	end
	
	catherine.loading.rotate = math.Approach( catherine.loading.rotate, catherine.loading.rotate - 3, 3 )
	
	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 235, 235, 235, a ) )
	
	surface.SetDrawColor( 150, 150, 150, a )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 0, scrW, scrH )

	surface.SetDrawColor( 255, 255, 255, a )
	surface.SetMaterial( Material( "CAT/logo67.png" ) )
	surface.DrawTexturedRect( scrW / 2 - 512 / 2, scrH / 2 - 256 / 2, 512, 256 )
	
	draw.SimpleText( "Ver 0.2", "catherine_normal15", 15, 20, Color( 50, 50, 50, a ), TEXT_ALIGN_LEFT, 1 )

	if ( catherine.loading.errorMsg ) then
		draw.NoTexture( )
		surface.SetDrawColor( 255, 0, 0, catherine.loading.alpha - 55 )
		catherine.geometry.DrawCircle( 50, scrH - 50, 20, 5, 90, 360, 100 )
		
		draw.SimpleText( catherine.loading.errorMsg, "catherine_normal20", 100, scrH - 50, Color( 80, 80, 80, a ), TEXT_ALIGN_LEFT, 1 )
	else
		draw.NoTexture( )
		surface.SetDrawColor( 90, 90, 90, catherine.loading.alpha - 55 )
		catherine.geometry.DrawCircle( 50, scrH - 50, 20, 5, 90, 360, 100 )
		
		draw.NoTexture( )
		surface.SetDrawColor( 255, 255, 255, catherine.loading.alpha )
		catherine.geometry.DrawCircle( 50, scrH - 50, 20, 5, catherine.loading.rotate, 100, 100 )
	
		draw.SimpleText( catherine.loading.msg, "catherine_normal15", 100, scrH - 50, Color( 80, 80, 80, a ), TEXT_ALIGN_LEFT, 1 )
	end
end

catherine.entityCaches = { }
catherine.nextCacheDo = CurTime( )

function GM:ProgressEntityTargetID( pl )
	if ( pl:IsCharacterLoaded( ) and catherine.nextCacheDo <= CurTime( ) ) then
		local tr = { }
		tr.start = pl:GetShootPos( )
		tr.endpos = tr.start + pl:GetAimVector( ) * 160
		tr.filter = pl
		local ent = util.TraceLine( tr ).Entity
		if ( IsValid( ent ) ) then 
			catherine.entityCaches[ ent ] = true
		else 
			catherine.entityCaches[ ent ] = nil
		end
		catherine.nextCacheDo = CurTime( ) + 0.5
	end
	
	for k, v in pairs( catherine.entityCaches ) do
		if ( !IsValid( k ) ) then 
			catherine.entityCaches[ k ] = nil
			continue
		end
		local a = Lerp( 0.03, k.alpha or 0, catherine.util.GetAlphaFromDistance( k:GetPos( ), LocalPlayer( ):GetPos( ), 412 ) )
		k.alpha = a
		if ( math.Round( a ) <= 0 ) then
			catherine.entityCaches[ k ] = nil
		end
		hook.Run( "DrawEntityTargetID", pl, k, a )
	end
end

function GM:HUDPaint( )
	if ( IsValid( catherine.vgui.character ) ) then return end
	local pl = LocalPlayer( )
	catherine.hud.Draw( )
	catherine.bar.Draw( )
	catherine.notify.Draw( )
	catherine.wep.Draw( pl )
	
	if ( pl:Alive( ) ) then
		hook.Run( "ProgressEntityTargetID", pl )
		draw.SimpleText( "Catherine Development Version", "catherine_normal20", ScrW( ) - 10, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
	end
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

function GM:RunCinematicIntro_Information( )
	return {
		title = Schema.IntroTitle,
		desc = Schema.IntroDesc,
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
	local data = hook.Run( "PostRenderScreenColor", LocalPlayer( ) ) or { }
	
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
	catherine.loading.status = data[ 1 ]
	catherine.loading.msg = data[ 2 ]
	if ( data[ 3 ] == true ) then
		catherine.loading.errorMsg = data[ 2 ]
		catherine.loading.msg = ""
	end
end )