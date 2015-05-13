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

if ( !catherine.option ) then
	catherine.util.Include( "cl_option.lua" )
end
catherine.hud = catherine.hud or {
	welcomeIntroWorkingData = nil,
	welcomeIntroAnimations = { },
	progressBar = nil,
	topNotify = nil,
	welcomeIntro = nil,
	clip1 = 0,
	pre = 0,
	vAlpha = 0,
	vAlphaTarget = 255,
	checkV = CurTime( ),
	deathAlpha = 0
}
local vignetteMat = Material( "CAT/vignette.png" ) or "__material__error"
local blockedModules = { }

netstream.Hook( "catherine.hud.WelcomeIntroStart", function( )
	catherine.hud.WelcomeIntroInitialize( )
end )

function catherine.hud.RegisterBlockModule( name )
	blockedModules[ #blockedModules + 1 ] = name
end

function catherine.hud.GetBlockModules( )
	return blockedModules
end

function catherine.hud.Draw( pl )
	if ( catherine.option.Get( "CONVAR_MAINHUD" ) == "0" ) then return end
	
	catherine.hud.ZipTie( pl )
	catherine.hud.Vignette( pl )
	catherine.hud.ScreenDamageDraw( pl )
	catherine.hud.AmmoDraw( pl )
	catherine.hud.DeathScreen( pl )
	catherine.hud.ProgressBarDraw( )
	catherine.hud.TopNotifyDraw( )
	catherine.hud.WelcomeIntroDraw( )
end

function catherine.hud.ZipTie( pl )
	if ( catherine.player.IsTied( pl ) ) then
		surface.SetDrawColor( 70, 70, 70, 255 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( ScrW( ) / 2 - ScrW( ) / 2 / 2, ScrH( ) * 0.3 - ( ScrH( ) * 0.2 ) / 2, ScrW( ) / 2, ScrH( ) * 0.1 )
		
		draw.SimpleText( LANG( "Item_Message03_ZT" ), "catherine_normal35", ScrW( ) / 2, ScrH( ) * 0.3 - 45, Color( 255, 255, 255, 255 ), 1, 1 )
	end
end

function catherine.hud.DeathScreen( pl )
	catherine.hud.deathAlpha = Lerp( 0.03, catherine.hud.deathAlpha, pl:Alive( ) and 0 or 255 )
	draw.RoundedBox( 0, 0, 0, ScrW( ), ScrH( ), Color( 0, 0, 0, catherine.hud.deathAlpha ) )
end

function catherine.hud.Vignette( pl )
	if ( vignetteMat == "__material__error" ) then return end
	if ( catherine.hud.checkV <= CurTime( ) ) then
		local data = { }
		data.start = pl:GetPos( )
		data.endpos = data.start + Vector( 0, 0, 2000 )
		local tr = util.TraceLine( data )
		
		if ( !tr.Hit or tr.HitSky ) then
			catherine.hud.vAlphaTarget = 125
		else
			catherine.hud.vAlphaTarget = 255
		end
		
		catherine.hud.checkV = CurTime( ) + 1.5
	end
	
	catherine.hud.vAlpha = math.Approach( catherine.hud.vAlpha, catherine.hud.vAlphaTarget, FrameTime( ) * 90 )
	
	surface.SetDrawColor( 0, 0, 0, catherine.hud.vAlpha )
	surface.SetMaterial( vignetteMat )
	surface.DrawTexturedRect( 0, 0, ScrW( ), ScrH( ) )
end

function catherine.hud.ScreenDamageDraw( pl )

end

function catherine.hud.AmmoDraw( pl )
	local wep = pl:GetActiveWeapon( )
	if ( !IsValid( wep ) or ( wep.DrawHUD == false ) ) then return end
	
	local clip1 = wep:Clip1( )
	local pre = pl:GetAmmoCount( wep:GetPrimaryAmmoType( ) )
	//local sec = LocalPlayer( ):GetAmmoCount( wep:GetSecondaryAmmoType( ) ) -- ^_^;
	
	catherine.hud.clip1 = Lerp( 0.03, catherine.hud.clip1, clip1 )
	catherine.hud.pre = Lerp( 0.03, catherine.hud.pre, pre )
	
	if ( clip1 > 0 or pre > 0 ) then
		draw.SimpleText( clip1 == -1 and pre or math.Round( catherine.hud.clip1 ) .. " / " .. math.Round( catherine.hud.pre ), "catherine_normal25", ScrW( ) - 30, ScrH( ) - 30, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
	end
end

function catherine.hud.WelcomeIntroInitialize( )
	catherine.hud.welcomeIntroWorkingData = {
		initStartTime = CurTime( )
	}
end

function catherine.hud.RegisterWelcomeIntroAnimation( key, text, font, startTime, showingTime, col, startX, startY, xAlign, yAlign )
	catherine.hud.welcomeIntroAnimations[ key ] = {
		text = "",
		font = font,
		targetText = text,
		startX = startX,
		startY = startY,
		startTime = startTime,
		showingTime = showingTime,
		a = 0,
		xAlign = xAlign,
		yAlign = yAlign,
		textSubCount = 1,
		textTime = CurTime( ),
		textTimeDelay = 0.09,
	}
end

function catherine.hud.WelcomeIntroDraw( )
	if ( !catherine.hud.welcomeIntroWorkingData ) then return end
	local data = catherine.hud.welcomeIntroWorkingData
	
	for k, v in pairs( catherine.hud.welcomeIntroAnimations ) do
		if ( data.initStartTime + v.startTime <= CurTime( ) ) then
			if ( !v.initStartTime ) then
				v.initStartTime = CurTime( )
			end

			if ( v.initStartTime + v.showingTime - 1 <= CurTime( ) ) then
				if ( v.a <= 0 ) then
					continue
				else
					v.a = Lerp( 0.03, v.a, 0 )
				end
			else
				v.a = Lerp( 0.03, v.a, 255 )
			end
			
			local targetText = type( v.targetText ) == "function" and v.targetText( ) or v.targetText
			
			if ( v.textTime <= CurTime( ) and string.utf8len( v.text ) < string.utf8len( targetText ) ) then
				local text = string.utf8sub( targetText, v.textSubCount, v.textSubCount )
				
				v.text = v.text .. text
				v.textSubCount = v.textSubCount + 1
				v.textTime = CurTime( ) + v.textTimeDelay
			end
			
			local col = v.col or Color( 255, 255, 255 )
			
			draw.SimpleText( v.text, v.font, v.startX, v.startY, Color( col.r, col.g, col.b, v.a ), v.xAlign or 1, v.yAlign or 1 )
		end
		
		if ( data.initStartTime + 60 <= CurTime( ) ) then
			catherine.hud.welcomeIntroWorkingData = nil
		end
	end
end

function catherine.hud.ProgressBarAdd( message, endTime )
	catherine.hud.progressBar = {
		message = message,
		startTime = CurTime( ),
		endTime = CurTime( ) + endTime
	}
end

function catherine.hud.TopNotifyAdd( message )
	catherine.hud.topNotify = {
		message = message
	}
end

function catherine.hud.TopNotifyDraw( )
	if ( !catherine.hud.topNotify ) then return end
	local scrW, scrH = ScrW( ), ScrH( )
	
	surface.SetDrawColor( 50, 50, 50, 150 )
	surface.SetMaterial( Material( "gui/center_gradient" ) )
	surface.DrawTexturedRect( 0, scrH / 2 - 80, scrW, 110 )
	draw.SimpleText( catherine.hud.topNotify.message or "", "catherine_normal25", scrW / 2, scrH / 2 - 30, Color( 255, 255, 255, 255 ), 1, 1 )
end

function catherine.hud.ProgressBarDraw( )
	if ( !catherine.hud.progressBar ) then return end
	if ( catherine.hud.progressBar.endTime <= CurTime( ) ) then
		catherine.hud.progressBar = nil
		return
	end
	
	local scrW, scrH = ScrW( ), ScrH( )
	local fraction = 1 - math.TimeFraction( catherine.hud.progressBar.startTime, catherine.hud.progressBar.endTime, CurTime( ) )
	
	surface.SetDrawColor( 50, 50, 50, 150 )
	surface.SetMaterial( Material( "gui/center_gradient" ) )
	surface.DrawTexturedRect( 0, scrH / 2 - 80, scrW, 110 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 90, 90, 90, 255 )
	catherine.geometry.DrawCircle( scrW / 2, scrH / 2 - 40, 15, 5, 90, 360, 100 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 255, 255, 255, 255 )
	catherine.geometry.DrawCircle( scrW / 2, scrH / 2 - 40, 15, 5, 90, 360 * fraction, 100 )
	
	draw.SimpleText( catherine.hud.progressBar.message or "", "catherine_normal25", scrW / 2, scrH / 2, Color( 255, 255, 255, 255 ), 1, 1 )
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

local information = hook.Run( "GetSchemaInformation" )

catherine.hud.RegisterWelcomeIntroAnimation( 1, function( )
	return information.title
end, "catherine_normal25", 2, 9, nil, ScrW( ) * 0.8, ScrH( ) * 0.55, TEXT_ALIGN_RIGHT )

catherine.hud.RegisterWelcomeIntroAnimation( 2, function( )
	return information.desc
end, "catherine_normal15", 6, 8, nil, ScrW( ) * 0.8, ScrH( ) * 0.55 + 35, TEXT_ALIGN_RIGHT )

catherine.hud.RegisterWelcomeIntroAnimation( 3, function( )
	return catherine.environment.GetDateString( ) .. " : " .. catherine.environment.GetTimeString( )
end, "catherine_normal15", 8, 10, nil, ScrW( ) * 0.8, ScrH( ) * 0.55 + 55, TEXT_ALIGN_RIGHT )

catherine.hud.RegisterWelcomeIntroAnimation( 4, function( )
	return information.author
end, "catherine_normal20", 7, 9, nil, ScrW( ) * 0.15, ScrH( ) * 0.8, TEXT_ALIGN_LEFT )