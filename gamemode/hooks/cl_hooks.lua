catherine.loading = catherine.loading or {
	status = false,
	errorMsg = nil,
	alpha = 255,
	rotate = 90,
	blurAmount = 5,
	msg = "Catherine is now booting ..."
}
catherine.entityCaches = { }
catherine.nextCacheDo = CurTime( )
local toscreen = FindMetaTable("Vector").ToScreen

function GM:HUDShouldDraw( name )
	for k, v in pairs( catherine.hud.blockedModules ) do
		if ( v == name ) then
			return false
		end
	end
	return true
end

function GM:CalcView( pl, pos, ang, fov )
	if ( !catherine.loading.status or ( IsValid( catherine.vgui.character ) and !pl:IsCharacterLoaded( ) ) ) then
		local data = { }
		data.origin = catherine.configs.schematicViewPos.pos
		data.angles = catherine.configs.schematicViewPos.ang
		return data
	end
end

function GM:HUDDrawScoreBoard( )
	local scrW, scrH = ScrW( ), ScrH( )
	if ( catherine.loading.status ) then
		catherine.loading.alpha = Lerp( 0.008, catherine.loading.alpha, 0 )
		catherine.loading.blurAmount = Lerp( 0.01, catherine.loading.blurAmount, 0 )
	else
		catherine.loading.alpha = Lerp( 0.01, catherine.loading.alpha, 255 )
		catherine.loading.blurAmount = Lerp( 0.01, catherine.loading.blurAmount, 5 )
	end
	
	if ( math.Round( catherine.loading.blurAmount ) > 0 ) then
		catherine.util.BlurDraw( 0, 0, scrW, scrH, catherine.loading.blurAmount )
	end
	
	catherine.loading.rotate = math.Approach( catherine.loading.rotate, catherine.loading.rotate - 3, 3 )

	if ( catherine.loading.errorMsg ) then
		draw.NoTexture( )
		surface.SetDrawColor( 255, 255, 255, catherine.loading.alpha - 55 )
		catherine.geometry.DrawCircle( 50, scrH - 50, 20, 5, 90, 360, 100 )
		
		draw.SimpleText( catherine.loading.errorMsg, "catherine_normal25", 100, scrH - 50, Color( 255, 255, 255, catherine.loading.alpha ), TEXT_ALIGN_LEFT, 1 )
	else
		draw.NoTexture( )
		surface.SetDrawColor( 255, 255, 255, catherine.loading.alpha )
		catherine.geometry.DrawCircle( 50, scrH - 50, 20, 5, catherine.loading.rotate, 100, 100 )
	
		draw.SimpleText( catherine.loading.msg, "catherine_normal20", 100, scrH - 50, Color( 255, 255, 255, catherine.loading.alpha ), TEXT_ALIGN_LEFT, 1 )
	end
end

function GM:ShouldDrawLocalPlayer( )
	return !catherine.loading.status
end

function GM:DrawEntityTargetID( pl, ent, a )
	if ( !ent:IsPlayer( ) ) then return end
	local pos = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
	local x, y, x2, y2 = pos.x, pos.y - 100, 0, 0
	local name, desc = hook.Run( "GetPlayerInformation", pl, ent )
	draw.SimpleText( name, "catherine_normal25", x, y, Color( 255, 255, 255, a ), 1, 1 )
	y = y + 20
	draw.SimpleText( desc, "catherine_normal15", x, y, Color( 255, 255, 255, a ), 1, 1 )
	y = y + 15
	
	hook.Run( "PlayerInformationDraw", pl, ent, x, y, a )
end

function GM:PlayerInformationDraw( pl, target, x, y, a )
	if ( target:Alive( ) ) then return end
	draw.SimpleText( ( target:GetGender( ) == "male" and "He" or "She" ) .. " was going to hell.", "catherine_normal15", x, y, Color( 255, 150, 150, a ), 1, 1 )
end

function GM:ProgressEntityCache( pl )
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
		if ( !IsValid( k ) ) then catherine.entityCaches[ k ] = nil continue end
		local a = Lerp( 0.03, k.alpha or 0, catherine.util.GetAlphaFromDistance( k:GetPos( ), pl:GetPos( ), 100 ) )
		k.alpha = a
		if ( math.Round( a ) <= 0 ) then
			catherine.entityCaches[ k ] = nil
		end
		if ( k.DrawEntityTargetID ) then
			k:DrawEntityTargetID( pl, k, a )
		end
		hook.Run( "DrawEntityTargetID", pl, k, a )
	end
end

function GM:HUDPaint( )
	if ( IsValid( catherine.vgui.character ) or !catherine.loading.status ) then return end
	local pl = LocalPlayer( )
	
	hook.Run( "HUDBackgroundDraw" )
	catherine.hud.Draw( )
	catherine.bar.Draw( )
	catherine.notify.Draw( )
	catherine.wep.Draw( pl )
	catherine.hint.Draw( )
	
	hook.Run( "HUDDraw" )
	if ( pl:Alive( ) ) then
		hook.Run( "ProgressEntityCache", pl )
	end
end

function GM:CalcViewModelView( weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAng )
	if ( !IsValid( weapon ) ) then return end
	local pl = LocalPlayer( )
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

function GM:GetSchemaInformation( )
	return {
		title = catherine.Name,
		desc = catherine.Desc,
		author = "Design and development by L7D."
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
	
	if ( !catherine.loading.status ) then
		tab[ "$pp_colour_colour" ] = 0
	end
	
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