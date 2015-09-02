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
	loading = true,
	noError = true,
	errorMessage = nil,
	loadingColor = Color( 90, 90, 90 ),
	backAlpha = 255,
	loadingAlpha = 0,
	rotate = 0,
	startTime = 0,
	sysTime = 0,
	reloadingWait = false,
	reloadingCount = 0,
	noReload = false,
	onlyMessage = false,
	alwaysFin = false,
	
	firstStageShowingTime = nil,
	firstStage = false,
	firstStageEnding = false,
	firstStageX = ScrW( ),
	firstStageEffect = false,
	
	secondStageShowingTime = nil,
	secondStage = false,
	secondStageEnding = false,
	secondStageX = ScrW( ),
	secondStageAlpha = 255,
	secondStageEffect = false,
	
	introDone = false
}
catherine.deathColAlpha = catherine.deathColAlpha or 0
catherine.screenResolution = catherine.screenResolution or { w = ScrW( ), h = ScrH( ) }
local entityCaches = { }
local nextEntityCacheWork = RealTime( )
local lastEntity = nil
local rpInformation_backgroundblurA = 0
local toscreen = FindMetaTable( "Vector" ).ToScreen
local OFFSET_PLAYER = Vector( 0, 0, 30 )
local OFFSET_AD_ESP = Vector( 0, 0, 50 )
local frameworkLogoMat = Material( catherine.configs.frameworkLogo )
local gradientUpMat = Material( "gui/gradient_up" )
local gradientCenterMat = Material( "gui/center_gradient" )
local introBooA = 0
local math_app = math.Approach
local hook_run = hook.Run
local trace_line = util.TraceLine

function GM:InitPostEntity( )
	catherine.pl = LocalPlayer( )
end

function GM:Initialize( )
	CAT_CONVAR_ADMIN_ESP = CreateClientConVar( "cat_convar_adminesp", "1", true, true )
	CAT_CONVAR_ALWAYS_ADMIN_ESP = CreateClientConVar( "cat_convar_alwaysadminesp", "0", true, true )
	CAT_CONVAR_HUD = CreateClientConVar( "cat_convar_hud", "1", true, true )
	CAT_CONVAR_BAR = CreateClientConVar( "cat_convar_bar", "1", true, true )
	CAT_CONVAR_CHAT_TIMESTAMP = CreateClientConVar( "cat_convar_chat_timestamp", "1", true, true )
	CAT_CONVAR_HINT = CreateClientConVar( "cat_convar_hint", "1", true, true )
end

function GM:HUDShouldDraw( name )
	for k, v in pairs( catherine.hud.GetBlockModules( ) ) do
		if ( v == name ) then
			return false
		end
	end
	
	return true
end

function GM:ContextMenuOpen( )
	return false
end

function GM:OnReloaded( )

end

function GM:AddHint( name, delay )

end

function GM:AddNotify( message, _, time )
	if ( message:sub( 1, 6 ) == "#Hint_" ) then
		return
	end
	
	catherine.notify.Add( message, time, false )
end

function GM:HUDPaintBackground( )
	local pl = catherine.pl
	
	if ( !pl:IsAdmin( ) or ( GetConVarString( "cat_convar_alwaysadminesp" ) == "0" and !pl:IsNoclipping( ) ) or GetConVarString( "cat_convar_adminesp" ) == "0" ) then return end
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( pl == v ) then continue end
		local pos = toscreen( v:LocalToWorld( v:OBBCenter( ) + OFFSET_AD_ESP ) )

		draw.SimpleText( v:Name( ), "catherine_normal15", pos.x, pos.y, team.GetColor( v:Team( ) ), 1, 1 )

		hook.Run( "AdminESPDrawed", pl, v, pos.x, pos.y )
	end
end

function GM:SpawnMenuOpen( )
	return catherine.pl:IsAdmin( )
end

function GM:CalcView( pl, pos, ang, fov )
	local viewData = self.BaseClass.CalcView( self.BaseClass, pl, pos, ang, fov )

	if ( catherine.intro.status ) then
		return {
			origin = Vector( 0, 0, 200000 )
		}
	end

	local ent = Entity( pl:GetNetVar( "ragdollIndex", 0 ) )
	
	if ( IsValid( ent ) and ent:GetClass( ) == "prop_ragdoll" ) then
		local index = ent:LookupAttachment( "eyes" )
		
		if ( index ) then
			local data = ent:GetAttachment( index )

			return {
				origin = data and data.Pos,
				angles = data and data.Ang
			}
		end
	end

	return self.BaseClass.CalcView( self.BaseClass, pl, pos, ang, fov )
end

local iconMat = Material( "icon16/server.png" )

function GM:OnPlayerChat( pl, text, teamOnly, isDead )
	if ( !IsValid( pl ) ) then
		chat.AddText( iconMat, Color( 150, 150, 150 ), LANG( "Chat_Str_Console" ), Color( 255, 255, 255 ), " : ".. text )
	end

	return true
end

function GM:ChatText( index, name, text )
	if ( index == 0 ) then
		chat.AddText( iconMat, Color( 255, 255, 255 ), text )
	end
end

function GM:ShouldDrawBar( pl )
	return !IsValid( catherine.vgui.question ) and pl:Alive( ) and pl:IsCharacterLoaded( )
end

function GM:ShouldDrawHint( pl, hintTable )

end

function GM:GetChatIcon( pl, chatClass, text )

end

function GM:HUDDrawScoreBoard( )
	if ( catherine.pl:IsCharacterLoaded( ) or ( catherine.intro.introDone and catherine.intro.backAlpha <= 0 ) ) then return end
	local scrW, scrH = ScrW( ), ScrH( )
	local realTime = RealTime( ) // YES, this is real time, thats all.

	// Backgrounds
	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 255, 255, 255, catherine.intro.backAlpha ) )
	
	surface.SetDrawColor( 200, 200, 200, catherine.intro.backAlpha )
	surface.SetMaterial( gradientUpMat )
	surface.DrawTexturedRect( 0, 0, scrW, scrH )

	if ( catherine.intro.status ) then
		catherine.intro.backAlpha = Lerp( 0.03, catherine.intro.backAlpha, 255 )
	else
		catherine.intro.backAlpha = Lerp( 0.03, catherine.intro.backAlpha, 0 )
	end

	if ( catherine.intro.noError or catherine.intro.onlyMessage ) then
		catherine.intro.loadingColor.r = Lerp( 0.05, catherine.intro.loadingColor.r, 90 )
		catherine.intro.loadingColor.g = Lerp( 0.05, catherine.intro.loadingColor.g, 90 )
		catherine.intro.loadingColor.b = Lerp( 0.05, catherine.intro.loadingColor.b, 90 )
	else
		catherine.intro.backAlpha = 255
		catherine.intro.loadingColor.r = Lerp( 0.05, catherine.intro.loadingColor.r, 255 )
		catherine.intro.loadingColor.g = Lerp( 0.05, catherine.intro.loadingColor.g, 0 )
		catherine.intro.loadingColor.b = Lerp( 0.05, catherine.intro.loadingColor.b, 0 )
	end
	
	if ( catherine.intro.loading ) then
		catherine.intro.loadingAlpha = Lerp( 0.03, catherine.intro.loadingAlpha, 255 )
	else
		catherine.intro.loadingAlpha = Lerp( 0.03, catherine.intro.loadingAlpha, 0 )
	end
	
	// Intro codes
	if ( catherine.intro.status and catherine.intro.startTime != 0 ) then
		if ( catherine.intro.startTime <= realTime ) then
			catherine.intro.firstStage = true

			if ( catherine.intro.firstStageX >= scrW / 2 - 512 / 2 ) then
				catherine.intro.firstStageX = math.Approach( catherine.intro.firstStageX, scrW / 2 - 512 / 2, 25 )
			end
			
			if ( !catherine.intro.firstStageEffect ) then
				introBooA = 255
				surface.PlaySound( "CAT/intro_slide_2.wav" ) // Tooong!
				catherine.intro.firstStageEffect = true
			end
			
			if ( !catherine.intro.firstStageShowingTime ) then
				catherine.intro.firstStageShowingTime = realTime
			end
			
			if ( catherine.intro.firstStageShowingTime + 3 <= realTime ) then
				if ( !catherine.intro.secondStageShowingTime ) then
					catherine.intro.secondStageShowingTime = realTime
				end
			
				catherine.intro.secondStage = true
				
				if ( !catherine.intro.secondStageEffect ) then
					introBooA = 255
					surface.PlaySound( "CAT/intro_slide_2.wav" ) // Tooong!
					catherine.intro.secondStageEffect = true
				end
				
				catherine.intro.firstStageX = math.Approach( catherine.intro.firstStageX, 0 - 512, 25 )
				
				if ( !catherine.intro.secondStageEnding ) then
					catherine.intro.secondStageX = math.Approach( catherine.intro.secondStageX, scrW / 2 - 512 / 2, 25 )
				end
				
				if ( catherine.intro.firstStageEnding ) then
					catherine.intro.firstStage = false
				else
					if ( catherine.intro.firstStageX <= 0 - 512 ) then
						catherine.intro.firstStageEnding = true
					end
				end
				
				if ( catherine.intro.secondStageShowingTime + 2 <= realTime ) then
					catherine.intro.secondStageX = math.Approach( catherine.intro.secondStageX, 0 - 512, 25 )

					if ( !catherine.intro.secondStageEnding ) then
						surface.PlaySound( "CAT/intro_done.wav" ) // Sike!
						catherine.intro.secondStageEnding = true
					end

					if ( catherine.intro.secondStageX <= 0 - 512 and !catherine.intro.introDone ) then
						catherine.intro.introDone = true

						if ( !catherine.intro.loading and catherine.intro.noError and catherine.intro.introDone ) then
							catherine.intro.status = false
							catherine.intro.alwaysFin = true
							
							if ( catherine.question.CanQuestion( ) ) then
								catherine.question.Start( )
							else
								catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
							end
							// Call panel
						end
					end
				end
			end
		end
		
		introBooA = Lerp( 0.02, introBooA, 0 )
	end
	
	if ( !catherine.intro.alwaysFin and !catherine.intro.noReload and !catherine.intro.reloadingWait and catherine.intro.loading and catherine.intro.noError and catherine.intro.introDone and catherine.intro.sysTime + 10 <= SysTime( ) ) then
		catherine.intro.reloadingWait = true
		catherine.intro.reloadingCount = catherine.intro.reloadingCount + 1
		catherine.intro.noError = false
		catherine.intro.onlyMessage = false
		catherine.intro.errorMessage = LANG( "Basic_Error_LoadTimeoutWait", catherine.intro.reloadingCount )

		timer.Simple( 5, function( )
			catherine.intro.introDone = false
			catherine.intro.onlyMessage = true
			catherine.intro.noError = true
			catherine.intro.errorMessage = LANG( "Basic_Error_Reloading" )
			catherine.intro.sysTime = SysTime( )
			catherine.intro.reloadingWait = false
			
			netstream.Start( "catherine.player.Initialize_Reload" )
		end )

	elseif ( !catherine.intro.loading and catherine.intro.noError and catherine.intro.introDone and !catherine.intro.alwaysFin ) then
		catherine.intro.alwaysFin = true
		catherine.intro.noReload = true
		catherine.intro.noError = true
		catherine.intro.onlyMessage = false
		catherine.intro.errorMessage = nil
		catherine.intro.reloadingWait = false
		catherine.intro.status = false

		if ( catherine.question.CanQuestion( ) ) then
			catherine.question.Start( )
		else
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		end
		
		// Call panel
	end

	if ( catherine.intro.loadingAlpha > 0 ) then
		// Loading circle
		if ( catherine.intro.noError or catherine.intro.onlyMessage ) then
			catherine.intro.rotate = math.Approach( catherine.intro.rotate, catherine.intro.rotate - 4, 4 )
			
			draw.NoTexture( )
			surface.SetDrawColor( catherine.intro.loadingColor.r / 2, catherine.intro.loadingColor.g / 2, catherine.intro.loadingColor.b / 2, catherine.intro.loadingAlpha / 3 )
			catherine.geometry.DrawCircle( 40, scrH - 40, 15, 5, 90, 360, 100 )
			
			draw.NoTexture( )
			surface.SetDrawColor( catherine.intro.loadingColor.r, catherine.intro.loadingColor.g, catherine.intro.loadingColor.b, catherine.intro.loadingAlpha )
			catherine.geometry.DrawCircle( 40, scrH - 40, 15, 5, catherine.intro.rotate, 70, 100 )
		else
			draw.NoTexture( )
			surface.SetDrawColor( catherine.intro.loadingColor.r, catherine.intro.loadingColor.g, catherine.intro.loadingColor.b, catherine.intro.loadingAlpha )
			catherine.geometry.DrawCircle( 40, scrH - 40, 15, 5, catherine.intro.rotate, 360, 100 )
		end
	end

	// Framework logo
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( frameworkLogoMat )
	surface.DrawTexturedRect( catherine.intro.firstStageX, scrH / 2 - 256 / 2, 512, 256 )

	// Schema logo
	surface.SetDrawColor( 255, 255, 255, catherine.intro.secondStageAlpha )
	surface.SetMaterial( Material( catherine.configs.schemaLogo ) )
	surface.DrawTexturedRect( catherine.intro.secondStageX, scrH / 2 - 256 / 2, 512, 256 )

	// Catherine version
	draw.SimpleText( LANG( "Version_UI_YourVer_AV", catherine.GetVersion( ) .. " " .. catherine.GetBuild( ) ), "catherine_normal15", 15, 20, Color( 50, 50, 50, catherine.intro.backAlpha ), TEXT_ALIGN_LEFT, 1 )
	
	// Error message
	if ( ( !catherine.intro.noError or catherine.intro.onlyMessage ) and catherine.intro.errorMessage ) then
		draw.SimpleText( LANG( "Basic_Sorry" ), "catherine_normal20", 85, scrH - 55, Color( 0, 0, 0, catherine.intro.backAlpha ), TEXT_ALIGN_LEFT, 1 )
		draw.SimpleText( catherine.intro.errorMessage, "catherine_normal15", 85, scrH - 25, Color( 50, 50, 50, catherine.intro.backAlpha ), TEXT_ALIGN_LEFT, 1 )
	end
	
	// Whitescreen
	draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 255, 255, 255, introBooA ) )
end

function GM:PostDrawTranslucentRenderables( depth, skybox )
	if ( depth or skybox ) then return end

	for k, v in pairs( ents.FindInSphere( catherine.pl:GetPos( ), 256 ) ) do
		if ( !IsValid( v ) or !v:IsDoor( ) or v:GetNoDraw( ) or catherine.door.IsDoorDisabled( v ) ) then continue end
		
		hook.Run( "DrawDoorText", v )
	end
end

function GM:GetCharacterPanelLoadModel( characterDatas )
	return characterDatas._model
end

function GM:PlayerBindPress( pl, code, pressed )
	if ( code:find( "messagemode" ) and pressed ) then
		catherine.chat.Show( )
		
		return true
	end
	
	if ( !pl:GetNetVar( "gettingup" ) and pl:IsRagdolled( ) and !pl:GetNetVar( "isForceRagdolled" ) and code:find( "+jump" ) and pressed ) then
		catherine.command.Run( "&uniqueID_charGetUp" )
		
		return true
	end
end

function GM:DrawDoorText( ent )
	if ( catherine.door.IsDoorDisabled( ent ) ) then return end
	local a = catherine.util.GetAlphaFromDistance( ent:GetPos( ), catherine.pl:GetPos( ), 256 )

	if ( math.Round( a ) <= 0 ) then
		return
	end
	
	local data = catherine.door.CalcDoorTextPos( ent )
	local title = ent:GetNetVar( "title", LANG( "Door_UI_Default" ) )
	local desc = catherine.door.GetDetailString( ent )
	
	surface.SetFont( "catherine_outline35" )
	
	local titleW, titleH = surface.GetTextSize( title )
	local descW, descH = surface.GetTextSize( desc )
	local longW = descW > titleW and descW or titleW
	//local longH = titleH + descScale + 8 // We don't need this :)
	local scale = math.abs( ( data.w * 0.8 ) / longW )
	local titleScale = math.min( scale, 0.1 )
	local descScale = math.min( scale, 0.03 )
	local pos, posBack = data.pos, data.posBack
	local ang, angBack = data.ang, data.angBack
	
	cam.Start3D2D( pos, ang, titleScale )
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( gradientCenterMat )
		surface.DrawTexturedRect( 0 - longW / 2, 0 - 40, longW, 1 )
		
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( gradientCenterMat )
		surface.DrawTexturedRect( 0 - longW / 2, 80, longW, 1 )
		
		draw.SimpleText( title, "catherine_outline35", 0, 0, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
	
	cam.Start3D2D( posBack, angBack, titleScale )
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( gradientCenterMat )
		surface.DrawTexturedRect( 0 - longW / 2, 0 - 40, longW, 1 )
		
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( gradientCenterMat )
		surface.DrawTexturedRect( 0 - longW / 2, 80, longW, 1 )
		
		draw.SimpleText( title, "catherine_outline35", 0, 0, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
	
	cam.Start3D2D( pos, ang, descScale )
		draw.SimpleText( desc, "catherine_outline50", 0, 140, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
	
	cam.Start3D2D( posBack, angBack, descScale )
		draw.SimpleText( desc, "catherine_outline50", 0, 140, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
end

function GM:StartChatDelay( )
	netstream.Start( "catherine.IsTyping", true )
end

function GM:FinishChatDelay( )
	netstream.Start( "catherine.IsTyping", false )
end

function GM:FinishChat( )
	if ( IsValid( catherine.pl ) and catherine.pl:IsChatTyping( ) ) then
		netstream.Start( "catherine.IsTyping", false )
	end
end

function GM:DrawEntityTargetID( pl, ent, a )
	if ( ent:IsPlayer( ) or ent:GetClass( ) == "prop_ragdoll" ) then
		if ( ent:GetNetVar( "noDrawOriginal" ) == true or ( ent:IsPlayer( ) and ent:IsRagdolled( ) ) ) then return end
		
		local entPlayer = ent:GetClass( ) == "prop_ragdoll" and ent:GetNetVar( "player" ) or ent
		
		if ( !IsValid( entPlayer ) or !entPlayer:IsPlayer( ) ) then return end

		local index = ent:LookupBone( "ValveBiped.Bip01_Head1" )

		if ( index ) then
			local pos = toscreen( ent:GetBonePosition( index ) )
			local x, y = pos.x, pos.y - 100
			local name, desc = hook.Run( "GetPlayerInformation", pl, entPlayer, true )
			local col = team.GetColor( entPlayer:Team( ) )
			
			draw.SimpleText( name, "catherine_outline25", x, y, Color( col.r, col.g, col.b, a ), 1, 1 )
			y = y + 25
			
			local descTexts = catherine.util.GetWrapTextData( desc, ScrW( ) / 2, "catherine_outline15" )
			
			for k, v in pairs( descTexts ) do
				draw.SimpleText( v, "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
				y = y + 20
			end

			hook.Run( "PlayerInformationDraw", pl, entPlayer, x, y, a )
		end
	elseif ( ent:IsWeapon( ) ) then
		local pos = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		local x, y = pos.x, pos.y
		
		draw.SimpleText( ent:GetPrintName( ), "catherine_outline25", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 25
		
		draw.SimpleText( LANG( "Weapon_MapEntity_Desc" ), "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
	end
end

function GM:PlayerInformationDraw( pl, target, x, y, a )
	if ( target:IsRagdolled( ) ) then
		draw.SimpleText( LANG( "Player_Message_Ragdolled_HUD" ), "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20
	end
	
	if ( target:IsTied( ) ) then
		draw.SimpleText( LANG( "Player_Message_UnTie" ), "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20
	end
	
	if ( !target:Alive( ) ) then
		draw.SimpleText( LANG( "Player_Message_Dead_HUD" ), "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20
	end
end

function GM:GetUnknownTargetName( pl, target )
	return LANG( "Recognize_UI_Unknown" )
end

function GM:EntityCacheWork( pl )
	local realTime = RealTime( )
	
	if ( nextEntityCacheWork <= realTime ) then
		local data = { }
		data.start = pl:GetShootPos( )
		data.endpos = data.start + pl:GetAimVector( ) * 160
		data.filter = pl
		
		lastEntity = trace_line( data ).Entity

		if ( IsValid( lastEntity ) ) then
			entityCaches[ lastEntity ] = true
		end

		nextEntityCacheWork = realTime + 0.5
	end
	
	for k, v in pairs( entityCaches ) do
		if ( !IsValid( k ) ) then
			entityCaches[ k ] = nil
			continue
		end
		
		if ( lastEntity != k ) then
			entityCaches[ k ] = false
		end
		
		local targetAlpha = v and 255 or 0
		local a = math_app( k.CAT_entityCacheAlpha or 0, targetAlpha, FrameTime( ) * 120 )

		if ( a > 0 and hook_run( "CantDrawEntityTargetID", pl, k, a ) != true ) then
			if ( k.DrawEntityTargetID ) then
				k:DrawEntityTargetID( pl, k, a )
			else
				hook_run( "DrawEntityTargetID", pl, k, a )
			end
		end
		
		k.CAT_entityCacheAlpha = a
		
		if ( targetAlpha == 0 and a == 0 ) then
			entityCaches[ k ] = nil
		end
	end
end

local getCharVar = catherine.character.GetCharVar

function GM:HUDPaint( )
	if ( IsValid( catherine.vgui.character ) ) then return end
	local pl = catherine.pl
	
	if ( getCharVar( pl, "charBanned" ) ) then
		local scrW, scrH = ScrW( ), ScrH( )
		
		draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 255, 255, 255, 255 ) )
	
		surface.SetDrawColor( 200, 200, 200, 255 )
		surface.SetMaterial( gradientUpMat )
		surface.DrawTexturedRect( 0, 0, scrW, scrH )
		
		draw.SimpleText( ":(", "catherine_normal50", scrW / 2, scrH / 2, Color( 0, 0, 0, 255 ), 1, 1 )
		draw.SimpleText( LANG( "Character_Notify_CharBanned" ), "catherine_normal25", scrW / 2, scrH / 2 + 60, Color( 0, 0, 0, 255 ), 1, 1 )
		
		return
	end
	
	hook_run( "HUDBackgroundDraw" )
	catherine.hud.Draw( pl )
	catherine.bar.Draw( pl )
	catherine.hint.Draw( pl )
	hook_run( "HUDDraw" )
	
	if ( pl:Alive( ) and pl:IsCharacterLoaded( ) ) then
		hook_run( "EntityCacheWork", pl )
	end
	
	hook_run( "HUDDrawTop" )
end

function GM:HUDDrawTop( )
	if ( !catherine.util.dermaMenuTitle ) then return end
	local dermaMenuData = catherine.util.dermaMenuTitle
	
	if ( IsValid( dermaMenuData.menuPanel ) ) then
		local panel = dermaMenuData.menuPanel
		local w, h = panel:GetSize( )
		local x, y = panel:GetPos( )

		draw.RoundedBox( 0, x - 5, y - 5, w + 10, h + 10, Color( 50, 50, 50, 255 ) )
		draw.SimpleText( dermaMenuData.title or "", "catherine_outline20", x + w / 2, y - 20, Color( 255, 255, 255, 255 ), 1, 1 )
	else
		catherine.util.dermaMenuTitle = nil
	end
end

function GM:PostRenderVGUI( )
	if ( hook.Run( "CantDrawNotify" ) == true or IsValid( catherine.vgui.character ) ) then return end
	
	if ( IsValid( catherine.vgui.menu ) and catherine.vgui.menu:IsVisible( ) ) then
		catherine.notify.DrawMenuType( )
	else
		catherine.notify.Draw( )
	end
end

function GM:MainMenuJoined( )
	catherine.notify.ConvertType( true )
end

function GM:MainMenuExited( )
	catherine.notify.ConvertType( )
end

function GM:CalcViewModelView( wep, viewMdl, oldEyePos, oldEyeAngles, eyePos, eyeAng )
	if ( !IsValid( wep ) ) then return end
	local pl = catherine.pl
	local fraction = ( pl.CAT_wepRaisedFraction or 0 ) / 100
	local lowerAng = wep.LowerAngles or Angle( 30, -30, -25 )
	
	eyeAng:RotateAroundAxis( eyeAng:Up( ), lowerAng.p * fraction )
	eyeAng:RotateAroundAxis( eyeAng:Forward( ), lowerAng.y * fraction )
	eyeAng:RotateAroundAxis( eyeAng:Right( ), lowerAng.r * fraction )
	
	pl.CAT_wepRaisedFraction = Lerp( FrameTime( ) * 2, pl.CAT_wepRaisedFraction or 0, pl:GetWeaponRaised( ) and 0 or 100 )
	
	viewMdl:SetAngles( eyeAng )
	
	return oldEyePos, eyeAng
end

function GM:PlayerCantLookScoreboard( pl )
	return false
end

function GM:ScoreboardPlayerOption( pl, target )
	local menu = DermaMenu( )
	
	menu:AddOption( LANG( "Scoreboard_PlayerOption01_Str" ), function( )
		gui.OpenURL( "http://steamcommunity.com/profiles/" .. target:SteamID64( ) )
	end )

	if ( pl:IsSuperAdmin( ) ) then
		local whitelistGive = menu:AddSubMenu( LANG( "Scoreboard_PlayerOption03_Str" ) )
		
		for k, v in pairs( catherine.faction.GetAll( ) ) do
			if ( !v.isWhitelist ) then continue end
			
			whitelistGive:AddOption( catherine.util.StuffLanguage( v.name ), function( )
				catherine.command.Run( "&uniqueID_plyGiveWhitelist", target:Name( ), v.uniqueID )
			end ):SetToolTip( catherine.util.StuffLanguage( v.desc ) )
		end
		
		menu:AddOption( LANG( "Scoreboard_PlayerOption05_Str" ), function( )
			Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption05_Q" ), "", function( val )
					catherine.command.Run( "&uniqueID_flagGive", target:Name( ), val )
				end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
			)
		end )
		
		menu:AddOption( LANG( "Scoreboard_PlayerOption06_Str" ), function( )
			netstream.Start( "catherine.flag.Scoreboard_PlayerOption06", target )
		end )
	end
	
	if ( pl:IsAdmin( ) ) then
		menu:AddOption( LANG( "Scoreboard_PlayerOption04_Str" ), function( )
			Derma_Query( LANG( "Scoreboard_PlayerOption04_Q" ), "", LANG( "Basic_UI_OK" ), function( )
					catherine.command.Run( "&uniqueID_charBan", target:Name( ) )
				end, LANG( "Basic_UI_NO" ), function( ) end
			)
		end )
		
		menu:AddOption( LANG( "Scoreboard_PlayerOption02_Str" ), function( )
			Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption02_Q" ), target:Name( ), function( val )
					catherine.command.Run( "&uniqueID_charSetName", target:Name( ), val )
				end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
			)
		end )
	end
	
	if ( pl:HasFlag( "i" ) ) then
		menu:AddOption( LANG( "Scoreboard_PlayerOption07_Str" ), function( )
			Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption07_Q1" ), "", function( val )
					Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption07_Q2" ), "1", function( val2 )
							catherine.command.Run( "&uniqueID_itemGive", target:Name( ), val, val2 or 1 )
						end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
					)
				end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
			)
		end )
	end
	
	menu:Open( )
end

function GM:GetSchemaInformation( )
	return {
		title = catherine.Name,
		desc = catherine.Desc,
		author = LANG( "Basic_Framework_Author", catherine.Author )
	}
end

function GM:ScoreboardShow( )
	if ( !catherine.pl:IsCharacterLoaded( ) ) then return end
	
	if ( getCharVar( catherine.pl, "charBanned" ) ) then
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:Remove( )
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		else
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		end
	else
		if ( IsValid( catherine.vgui.menu ) and !catherine.vgui.menu:IsVisible( ) ) then
			catherine.vgui.menu:Show( )
			gui.EnableScreenClicker( false )
		else
			catherine.vgui.menu = vgui.Create( "catherine.vgui.menu" )
			gui.EnableScreenClicker( true )
		end
	end
end

function GM:PostRenderScreenColor( pl )
	if ( pl:Alive( ) ) then
		catherine.deathColAlpha = Lerp( 0.03, catherine.deathColAlpha, 1 )
	else
		catherine.deathColAlpha = Lerp( 0.03, catherine.deathColAlpha, 0 )
	end
	
	return {
		colour = catherine.deathColAlpha
	}
end

function GM:RenderScreenspaceEffects( )
	local data = hook.Run( "PostRenderScreenColor", catherine.pl ) or { }
	
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
	
	if ( catherine.util.motionBlur ) then
		local motionBlurData = catherine.util.motionBlur

		if ( motionBlurData.status == false and motionBlurData.fadeTime ) then
			motionBlurData.drawAlpha = Lerp( motionBlurData.fadeTime, motionBlurData.drawAlpha, 0 )

			if ( math.Round( motionBlurData.drawAlpha ) <= 0 ) then
				catherine.util.motionBlur = nil
				return
			end
		end
		
		DrawMotionBlur( motionBlurData.addAlpha, motionBlurData.drawAlpha, motionBlurData.delay )
	end
end

function GM:CharacterMenuJoined( pl )
	if ( IsValid( catherine.chat.backPanel ) ) then
		catherine.chat.backPanel:SetVisible( false )
	end
end

function GM:CharacterMenuExited( pl )
	if ( IsValid( catherine.chat.backPanel ) ) then
		catherine.chat.backPanel:SetVisible( true )
	end
end

function GM:AddRPInformation( pnl, data, pl )
	data[ #data + 1 ] = LANG( "Cash_UI_HasStr", catherine.cash.Get( pl ) )
end

function GM:ScreenResolutionFix( )
	catherine.hud.WelcomeIntroInitialize( true )
	
	catherine.chat.SetSizePosData( ScrW( ) * 0.5, ScrH( ) * 0.3, 5, ScrH( ) - ( ScrH( ) * 0.3 ) - 5 )
	catherine.chat.SizePosFix( )
	
	catherine.menu.Rebuild( )
end

function GM:CantStartChat( pl )
	return !pl:IsCharacterLoaded( )
end

function GM:PopulateToolMenu( )
	local toolGun = weapons.GetStored( "gmod_tool" )

	for k, v in pairs( catherine.tool.GetAll( ) ) do
		toolGun.Tool[ v.Mode ] = v

		if ( v.AddToMenu != false ) then
			spawnmenu.AddToolMenuOption( v.Tab or "Main",
				v.Category or "Category",
				k,
				v.Name or "#" .. k,
				v.Command or "gmod_tool " .. k, 
				v.ConfigName or k,
				v.BuildCPanel
			)
		end
		
		language.Add( "tool." .. v.UniqueID .. ".name", v.Name )
		language.Add( "tool." .. v.UniqueID .. ".desc", v.Desc )
		language.Add( "tool." .. v.UniqueID .. ".0", v.HelpText )
	end
end

timer.Create( "Catherine.timer.ScreenResolutionCheck", 3, 0, function( )
	if ( catherine.screenResolution.w != ScrW( ) or catherine.screenResolution.h != ScrH( ) ) then
		hook.Run( "ScreenResolutionFix" )
		
		catherine.screenResolution = {
			w = ScrW( ),
			h = ScrH( )
		}
	end
end )

timer.Remove( "HintSystem_Annoy1" )
timer.Remove( "HintSystem_Annoy2" )
timer.Remove( "HintSystem_OpeningMenu" )

netstream.Hook( "catherine.ShowHelp", function( )
	if ( IsValid( catherine.vgui.information ) ) then
		catherine.vgui.information:Close( )
	else
		catherine.vgui.information = vgui.Create( "catherine.vgui.information" )
	end
end )

netstream.Hook( "catherine.SetModel", function( data )
	local pl = data[ 1 ]
	local model = data[ 2 ]
	
	if ( IsValid( pl ) and model ) then
		pl:SetModel( model )
	end
end )

netstream.Hook( "catherine.introStart", function( )
	catherine.intro.loading = true
	catherine.intro.status = true
	catherine.intro.startTime = RealTime( )
	catherine.intro.sysTime = SysTime( )
end )

netstream.Hook( "catherine.introStop", function( )
	catherine.intro.status = false
end )

netstream.Hook( "catherine.loadingFinished", function( )
	catherine.intro.loading = false
end )

netstream.Hook( "catherine.loadingError", function( data )
	local message = data[ 1 ]
	
	catherine.intro.loading = false
	catherine.intro.noError = false
	catherine.intro.errorMessage = message
	catherine.intro.noReload = data[ 2 ] or false
	
	MsgC( Color( 255, 0, 0 ), "[CAT ERROR] " .. message .. "\n" )
end )