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
	alpha = 0,
	loading = false,
	intro = false,
	rotate = 90,
	rotateAlpha = 0
}
catherine.entityCaches = { }
catherine.weaponModels = catherine.weaponModels or { }
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
	if ( IsValid( catherine.vgui.character ) or !pl:IsCharacterLoaded( ) ) then
		local data = { }
		data.origin = catherine.configs.schematicViewPos.pos
		data.angles = catherine.configs.schematicViewPos.ang
		return data
	end

	local ent = Entity( pl:GetNetVar( "ragdollEnt", 0 ) )
	if ( IsValid( ent ) and catherine.player.IsRagdolled( pl ) ) then
		local index = ent:LookupAttachment( "eyes" )
		local view = { }
		
		if ( !index ) then return end
		local data = ent:GetAttachment( index )
		
		view.origin = data and data.Pos
		view.angles = data and data.Ang
		
		return view
	end
end

function GM:HUDDrawScoreBoard( )
	local scrW, scrH = ScrW( ), ScrH( )

	catherine.intro.rotate = math.Approach( catherine.intro.rotate, catherine.intro.rotate - 6, 6 )

	draw.NoTexture( )
	surface.SetDrawColor( 255, 255, 255, catherine.intro.rotateAlpha )
	catherine.geometry.DrawCircle( scrW / 2 - 50 / 2, scrH - 50, 20, 5, catherine.intro.rotate, 250, 100 )

	if ( catherine.intro.intro ) then
		catherine.intro.alpha = Lerp( 0.05, catherine.intro.alpha, 255 )
	else
		catherine.intro.alpha = Lerp( 0.05, catherine.intro.alpha, 0 )
	end

	if ( catherine.intro.loading ) then
		catherine.intro.rotateAlpha = Lerp( 0.05, catherine.intro.rotateAlpha, 255 )
	else
		catherine.intro.rotateAlpha = Lerp( 0.05, catherine.intro.rotateAlpha, 0 )
	end
	
	draw.SimpleText( "CATHERINE", "catherine_introTitle", scrW / 2, scrH / 2, Color( 235, 235, 235, catherine.intro.alpha ), 1, 1 )
	draw.SimpleText( Schema and Schema.Title or "Unknown", "catherine_introSchema", scrW / 2, scrH * 0.6, Color( 235, 235, 235, catherine.intro.alpha ), 1, 1 )
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
	if ( IsValid( catherine.vgui.character ) ) then return end
	local pl = LocalPlayer( )
	
	hook.Run( "HUDBackgroundDraw" )
	catherine.hud.Draw( )
	catherine.bar.Draw( )
	catherine.hint.Draw( )
	hook.Run( "HUDDraw" )
	
	if ( pl:Alive( ) ) then
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
	if ( !pl:GetWeaponRaised( ) ) then value = 100 end
	local fraction = ( pl.wepRaisedFraction or 0 ) / 100
	local lowerAngle = weapon.LowerAngles or Angle( 30, -30, -25 )
	
	eyeAng:RotateAroundAxis( eyeAng:Up( ), lowerAngle.p * fraction )
	eyeAng:RotateAroundAxis( eyeAng:Forward( ), lowerAngle.y * fraction )
	eyeAng:RotateAroundAxis( eyeAng:Right( ), lowerAngle.r * fraction )
	pl.wepRaisedFraction = Lerp( FrameTime( ) * 2, pl.wepRaisedFraction or 0, value )
	viewModel:SetAngles( eyeAng )
	return oldEyePos, eyeAng
end

function GM:GetSchemaInformation( )
	return {
		title = catherine.Name,
		desc = catherine.Desc,
		author = "Development and design by L7D."
	}
end

function GM:ScoreboardShow( )
	if ( !LocalPlayer( ):IsCharacterLoaded( ) ) then return end
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
--[[
function GM:PostPlayerDraw( pl )
	if ( !IsValid( pl ) or !pl:IsCharacterLoaded( ) ) then return end
	local wep = pl:GetActiveWeapon( )
	local curClass = ( IsValid( wep ) and wep:GetClass( ):lower( ) or "" )
	
	for k, v in pairs( pl:GetWeapons( ) ) do
		if ( !IsValid( v ) ) then continue end
		local wepClass = v:GetClass( ):lower( )
		local info = WEAPON_PLAYERDRAW_INFO[ wepClass ]
		if ( !info ) then continue end
		
		pl.CAT_weapon_Nyandraw = pl.CAT_weapon_Nyandraw or { }

		if ( !pl.CAT_weapon_Nyandraw[ wepClass ] or !IsValid( pl.CAT_weapon_Nyandraw[ wepClass ] ) ) then
			pl.CAT_weapon_Nyandraw[ wepClass ] = ClientsideModel( info.model, RENDERGROUP_TRANSLUCENT )
			pl.CAT_weapon_Nyandraw[ wepClass ]:SetNoDraw( true )
		else
			local drawEnt = pl.CAT_weapon_Nyandraw[ wepClass ]
			if ( !IsValid( drawEnt ) ) then continue end
			local index = pl:LookupBone( info.bone )

			if ( index and index > 0 ) then
				if ( curClass == wepClass ) then continue end
				local bonePos, boneAng = pl:GetBonePosition( index )
				drawEnt:SetRenderOrigin( bonePos )
				drawEnt:SetRenderAngles( boneAng )
				drawEnt:DrawModel( )
			end
		end
	end
	
	for k, v in pairs( pl.CAT_weapon_Nyandraw or { } ) do
		local wep = pl:GetWeapon( k )
		if ( wep or IsValid( wep ) ) then continue end
		v:Remove( )
	end
end
--]]

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
	timer.Simple( 1, function( )
		catherine.intro.loading = true
		catherine.intro.intro = true
	end )
end )

netstream.Hook( "catherine.IntroStop", function( )
	catherine.intro.intro = false
end )

netstream.Hook( "catherine.loadingFinished", function( )
	catherine.intro.loading = false
end )