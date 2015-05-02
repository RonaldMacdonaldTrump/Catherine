--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

catherine.intro = catherine.intro or {
	status = true,
	backAlpha = 255,
	loading = true,
	rotate = 0,
	loadingAlpha = 0,
	startTime = 0,
	
	firstStageShowingTime = nil,
	firstStage = false,
	firstStageEnding = false,
	firstStageX = ScrW( ),
	firstStageEffect = false,
	
	secondStageShowingTime = nil,
	secondStage = false,
	secondStageEnding = false,
	secondStageX = ScrW( ),
	secondStageFade = 255,
	secondStageEffect = false,
	
	introDone = false
}
catherine.entityCaches = { }
catherine.weaponModels = catherine.weaponModels or { }
catherine.nextCacheDo = CurTime( )
local toscreen = FindMetaTable( "Vector" ).ToScreen
local OFFSET_PLAYER = Vector( 0, 0, 30 )
local OFFSET_AD_ESP = Vector( 0, 0, 50 )

function GM:HUDShouldDraw( name )
	for k, v in pairs( catherine.hud.blockedModules ) do
		if ( v == name ) then
			return false
		end
	end
	
	return true
end

function GM:ContextMenuOpen( )
	return false
end

function GM:HUDPaintBackground( )
	local lp = LocalPlayer( )
	if ( !lp.IsAdmin( lp ) or !lp.IsNoclipping( lp ) ) then return end
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( lp == v ) then continue end
		local pos = toscreen( v.LocalToWorld( v, v.OBBCenter( v ) + OFFSET_AD_ESP ) )

		draw.SimpleText( v.Name( v ), "catherine_normal15", pos.x, pos.y, team.GetColor( v.Team( v ) ), 1, 1 )

		hook.Run( "AdminESPDrawed", lp, v, pos.x, pos.y )
	end
end

function GM:SpawnMenuOpen( )
	return LocalPlayer( ).IsAdmin( LocalPlayer( ) )
end

function GM:ShouldDrawLocalPlayer( pl )
	if ( pl.GetNetVar( pl, "isActioning" ) ) then
		return true
	end
end

function GM:CalcView( pl, pos, ang, fov )
	if ( catherine.intro.status ) then
		return {
			origin = Vector( 0, 0, 200000 )
		}
	end
	
	if ( pl.GetNetVar( pl, "isActioning" ) ) then
		local data = util.TraceLine( {
			start = pos, 
			endpos = pos - ( ang.Forward( ang ) * 100 )
		} )

		return {
			origin = data.Fraction < 1 and ( data.HitPos + data.HitNormal * 5 ) or data.HitPos
		}
	end
	
	if ( IsValid( catherine.vgui.character ) or !pl.IsCharacterLoaded( pl ) ) then
		return {
			origin = catherine.configs.schematicViewPos.pos,
			angles = catherine.configs.schematicViewPos.ang
		}
	end

	local ent = Entity( pl.GetNetVar( pl, "ragdollIndex", 0 ) )

	if ( IsValid( ent ) and ent.GetClass( ent ) == "prop_ragdoll" and catherine.player.IsRagdolled( pl ) ) then
		local index = ent.LookupAttachment( ent, "eyes" )
		
		if ( index ) then
			local data = ent.GetAttachment( ent, index )

			return {
				origin = data and data.Pos,
				angles = data and data.Ang
			}
		end
	end
end


local introBombA = 0

function GM:HUDDrawScoreBoard( )
	if ( LocalPlayer( ).IsCharacterLoaded( LocalPlayer( ) ) or ( catherine.intro.introDone and catherine.intro.backAlpha <= 0 ) ) then return end
	local scrW, scrH = ScrW( ), ScrH( )

	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 255, 255, 255, catherine.intro.backAlpha ) )
		
	surface.SetDrawColor( 200, 200, 200, catherine.intro.backAlpha )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 0, scrW, scrH )

	if ( catherine.intro.status ) then
		catherine.intro.backAlpha = Lerp( 0.03, catherine.intro.backAlpha, 255 )
	else
		catherine.intro.backAlpha = Lerp( 0.03, catherine.intro.backAlpha, 0 )
	end

	if ( catherine.intro.loading ) then
		catherine.intro.loadingAlpha = Lerp( 0.03, catherine.intro.loadingAlpha, 255 )
	else
		catherine.intro.loadingAlpha = Lerp( 0.03, catherine.intro.loadingAlpha, 0 )
	end
	
	if ( catherine.intro.status and catherine.intro.startTime != 0 ) then
		if ( catherine.intro.startTime + 5 <= CurTime( ) ) then
			catherine.intro.firstStage = true

			if ( catherine.intro.firstStageX >= scrW / 2 - 512 / 2 ) then
				catherine.intro.firstStageX = math.Approach( catherine.intro.firstStageX, scrW / 2 - 512 / 2, 33 )
			end
			
			if ( !catherine.intro.firstStageEffect ) then
				introBombA = 255
				surface.PlaySound( "CAT/intro_slide.wav" )
				catherine.intro.firstStageEffect = true
			end
			
			if ( !catherine.intro.firstStageShowingTime ) then
				catherine.intro.firstStageShowingTime = CurTime( )
			end
			
			if ( catherine.intro.firstStageShowingTime + 4 <= CurTime( ) ) then
				if ( !catherine.intro.secondStageShowingTime ) then
					catherine.intro.secondStageShowingTime = CurTime( )
				end
			
				catherine.intro.secondStage = true
				
				if ( !catherine.intro.secondStageEffect ) then
					introBombA = 255
					surface.PlaySound( "CAT/intro_slide.wav" )
					catherine.intro.secondStageEffect = true
				end
				
				catherine.intro.firstStageX = math.Approach( catherine.intro.firstStageX, 0 - 512, 33 )
				
				if ( !catherine.intro.secondStageEnding ) then
					catherine.intro.secondStageX = math.Approach( catherine.intro.secondStageX, scrW / 2 - 512 / 2, 33 )
				end
				
				if ( catherine.intro.firstStageEnding ) then
					catherine.intro.firstStage = false
				else
					if ( catherine.intro.firstStageX <= 0 - 512 ) then
						catherine.intro.firstStageEnding = true
					end
				end
				
				if ( catherine.intro.secondStageShowingTime + 4 <= CurTime( ) ) then
					catherine.intro.secondStageX = math.Approach( catherine.intro.secondStageX, 0 - 512, 33 )

					if ( !catherine.intro.secondStageEnding ) then
						surface.PlaySound( "CAT/UI/intro_done.wav" )
						catherine.intro.secondStageEnding = true
					end

					if ( catherine.intro.secondStageX <= 0 - 512 and !catherine.intro.introDone ) then
						catherine.intro.introDone = true
						catherine.intro.status = false
						
						if ( !catherine.intro.loading and catherine.intro.introDone and !IsValid( catherine.vgui.character ) ) then
							catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
						end
					end
				end
			end
		end
		
		introBombA = Lerp( 0.02, introBombA, 0 )
	end

	if ( catherine.intro.loadingAlpha > 0 ) then
		catherine.intro.rotate = math.Approach( catherine.intro.rotate, catherine.intro.rotate - 5, 5 )
		
		draw.NoTexture( )
		surface.SetDrawColor( 90, 90, 90, catherine.intro.loadingAlpha )
		catherine.geometry.DrawCircle( 40, scrH - 40, 15, 5, catherine.intro.rotate, 250, 100 )
	end
	
	if ( catherine.intro.firstStage ) then
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.SetMaterial( Material( catherine.configs.frameworkLogo ) )
		surface.DrawTexturedRect( catherine.intro.firstStageX, scrH / 2 - 256 / 2, 512, 256 )
	end
	
	surface.SetDrawColor( 255, 255, 255, catherine.intro.secondStageFade )
	surface.SetMaterial( Material( catherine.configs.schemaLogo ) )
	surface.DrawTexturedRect( catherine.intro.secondStageX, scrH / 2 - 256 / 2, 512, 256 )

	draw.SimpleText( LANG( "Version_UI_YourVer_AV", catherine.version.Ver ), "catherine_normal15", scrW - 20, scrH - 25, Color( 50, 50, 50, catherine.intro.backAlpha ), TEXT_ALIGN_RIGHT, 1 )

	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 255, 255, 255, introBombA ) )
end

function GM:PostDrawTranslucentRenderables( depth, skybox )
	if ( depth or skybox ) then return end

	for k, v in pairs( ents.FindInSphere( LocalPlayer( ).GetPos( LocalPlayer( ) ), 256 ) ) do
		if ( !IsValid( v ) or !catherine.entity.IsDoor( v ) or catherine.door.IsDoorDisabled( v ) ) then continue end
		
		hook.Run( "DrawDoorText", v, v.GetPos( v ), v.GetAngles( v ) )
	end
end

function GM:PlayerBindPress( pl, code, pressed )
	if ( code.find( code, "messagemode" ) and pressed ) then
		catherine.chat.SetStatus( true )
		
		return true
	end
end

function GM:DrawDoorText( ent, pos, ang )
	if ( catherine.door.IsDoorDisabled( ent ) ) then return end
	local a = catherine.util.GetAlphaFromDistance( ent.GetPos( ent ), LocalPlayer( ).GetPos( LocalPlayer( ) ), 256 )

	if ( math.Round( a ) <= 0 ) then
		return
	end
	
	local data = catherine.door.CalcDoorTextPos( ent )
	
	local title = ent.GetNetVar( ent, "title", LANG( "Door_UI_Default" ) )
	local desc = catherine.door.GetDetailString( ent )
	
	surface.SetFont( "catherine_normal50" )
	local titleW, titleH = surface.GetTextSize( title )
	local descW, descH = surface.GetTextSize( desc )
	
	local longW = titleW

	if ( descW > longW ) then
		longW = descW
	end

	local scale = math.abs( ( data.w * 0.8 ) / longW )
	local titleScale = math.min( scale, 0.1 )
	local descScale = math.min( scale, 0.03 )
	local longH = titleH + descScale + 8
	
	cam.Start3D2D( data.pos, data.ang, titleScale )
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0 - longW / 2, 0 - 40, longW, 1 )
		
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0 - longW / 2, 80, longW, 1 )
		
		draw.SimpleText( title, "catherine_normal40", 0, 0, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
	
	cam.Start3D2D( data.posBack, data.angBack, titleScale )
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0 - longW / 2, 0 - 40, longW, 1 )
		
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0 - longW / 2, 80, longW, 1 )
		
		draw.SimpleText( title, "catherine_normal40", 0, 0, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
	
	cam.Start3D2D( data.pos, data.ang, descScale )
		draw.SimpleText( desc, "catherine_normal50", 0, 90, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
	
	cam.Start3D2D( data.posBack, data.angBack, descScale )
		draw.SimpleText( desc, "catherine_normal50", 0, 90, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
end

function GM:StartChat( )
	netstream.Start( "catherine.IsTyping", true )
end

function GM:FinishChat( )
	netstream.Start( "catherine.IsTyping", false )
end

function GM:DrawEntityTargetID( pl, ent, a )
	if ( ent.GetNetVar( ent, "noDrawOriginal" ) == true or ( ent.IsPlayer( ent ) and catherine.player.IsRagdolled( ent ) ) ) then
		return
	end
	
	local entPlayer = ent
	
	if ( ent.GetClass( ent ) == "prop_ragdoll" ) then
		entPlayer = ent.GetNetVar( ent, "player" )
	end
	
	if ( !IsValid( entPlayer ) or !entPlayer.IsPlayer( entPlayer ) ) then return end

	local index = ent.LookupBone( ent, "ValveBiped.Bip01_Head1" )

	if ( index ) then
		local pos = toscreen( ent.GetBonePosition( ent, index ) )
		local x, y = pos.x, pos.y - 100
		local name, desc = hook.Run( "GetPlayerInformation", pl, entPlayer, true )
		local col = team.GetColor( entPlayer.Team( entPlayer ) )
		
		draw.SimpleText( name, "catherine_normal20", x, y, Color( col.r, col.g, col.b, a ), 1, 1 )
		y = y + 20
		
		draw.SimpleText( desc, "catherine_normal15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20

		hook.Run( "PlayerInformationDraw", pl, entPlayer, x, y, a )
	end
end

function GM:PlayerInformationDraw( pl, target, x, y, a )
	if ( catherine.player.IsRagdolled( target ) ) then
		draw.SimpleText( LANG( "Player_Message_Ragdolled_HUD" ), "catherine_normal15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20
	end
	
	if ( catherine.player.IsTied( target ) ) then
		draw.SimpleText( LANG( "Player_Message_UnTie" ), "catherine_normal15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20
	end
	
	if ( !target.Alive( target ) ) then
		draw.SimpleText( LANG( "Player_Message_Dead_HUD" ), "catherine_normal15", x, y, Color( 255, 255, 255, a ), 1, 1 )
	end
end

function GM:GetUnknownTargetName( pl, target )
	return LANG( "Recognize_UI_Unknown" )
end

function GM:ProgressEntityCache( pl )
	if ( pl.IsCharacterLoaded( pl ) and catherine.nextCacheDo <= CurTime( ) ) then
		local data = { }
		data.start = pl.GetShootPos( pl )
		data.endpos = data.start + pl.GetAimVector( pl ) * 160
		data.filter = pl
		local ent = util.TraceLine( data ).Entity

		catherine.entityCaches[ ent ] = IsValid( ent ) and true or nil
		catherine.nextCacheDo = CurTime( ) + 0.5
	end
	
	for k, v in pairs( catherine.entityCaches ) do
		if ( !IsValid( k ) ) then
			catherine.entityCaches[ k ] = nil
			continue
		end
		
		local a = Lerp( 0.03, k.alpha or 0, catherine.util.GetAlphaFromDistance( k.GetPos( k ), pl.GetPos( pl ), 256 ) )
		k.alpha = a

		if ( math.Round( a ) <= 0 ) then
			catherine.entityCaches[ k ] = nil
			continue
		end
		
		if ( k.DrawEntityTargetID ) then
			k:DrawEntityTargetID( pl, k, a )
		else
			hook.Run( "DrawEntityTargetID", pl, k, a )
		end
	end
end

function GM:HUDPaint( )
	if ( IsValid( catherine.vgui.character ) ) then return end
	local pl = LocalPlayer( )
	
	hook.Run( "HUDBackgroundDraw" )
	catherine.hud.Draw( pl )
	catherine.bar.Draw( pl )
	catherine.hint.Draw( pl )
	hook.Run( "HUDDraw" )
	
	if ( pl.Alive( pl ) ) then
		hook.Run( "ProgressEntityCache", pl )
	end
end

function GM:PostRenderVGUI( )
	if ( IsValid( catherine.vgui.character ) ) then return end
	
	catherine.notify.Draw( )
end

function GM:CalcViewModelView( weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAng )
	if ( !IsValid( weapon ) ) then return end
	local pl = LocalPlayer( )
	local value = 0
	if ( !pl.GetWeaponRaised( pl ) ) then value = 100 end
	local fraction = ( pl.wepRaisedFraction or 0 ) / 100
	local lowerAngle = weapon.LowerAngles or Angle( 30, -30, -25 )
	
	eyeAng:RotateAroundAxis( eyeAng.Up( eyeAng ), lowerAngle.p * fraction )
	eyeAng:RotateAroundAxis( eyeAng.Forward( eyeAng ), lowerAngle.y * fraction )
	eyeAng:RotateAroundAxis( eyeAng.Right( eyeAng ), lowerAngle.r * fraction )
	pl.wepRaisedFraction = Lerp( FrameTime( ) * 2, pl.wepRaisedFraction or 0, value )
	viewModel:SetAngles( eyeAng )
	
	return oldEyePos, eyeAng
end

function GM:GetSchemaInformation( )
	return {
		title = catherine.Name,
		desc = catherine.Desc,
		author = LANG( "Basic_Framework_Author", catherine.Author )
	}
end

function GM:ScoreboardShow( )
	if ( !LocalPlayer( ).IsCharacterLoaded( LocalPlayer( ) ) ) then return end
	
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

netstream.Hook( "catherine.ShowHelp", function( )
	if ( IsValid( catherine.vgui.information ) ) then
		catherine.vgui.information:Close( )
		return
	end
	
	catherine.vgui.information = vgui.Create( "catherine.vgui.information" )
end )

netstream.Hook( "catherine.IntroStart", function( )
	catherine.intro.loading = true
	catherine.intro.status = true
	catherine.intro.startTime = CurTime( )
end )

netstream.Hook( "catherine.IntroStop", function( )
	catherine.intro.status = false
end )

netstream.Hook( "catherine.loadingFinished", function( )
	catherine.intro.loading = false
end )