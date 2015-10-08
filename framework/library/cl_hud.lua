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

catherine.hud = catherine.hud or {
	welcomeIntroWorkingData = nil,
	welcomeIntroAnimations = { },
	progressBar = nil,
	topNotify = nil,
	welcomeIntro = nil,
	clip1 = 0,
	pre = 0,
	vAlpha = 0,
	vAlphaTarget = 255
}
local blockedModules = { }

--[[ Function Optimize :> ]]--
local gradient_center = Material( "gui/center_gradient" )
local vignetteMat = Material( "CAT/vignette.png" ) or "__material__error"
local animationApproach = math.Approach
local setColor = surface.SetDrawColor
local setMat = surface.SetMaterial
local drawMat = surface.DrawTexturedRect
local drawText = draw.SimpleText
local drawBox = draw.RoundedBox
local drawCircle = catherine.geometry.DrawCircle
local noTex = draw.NoTexture
local timeFrac = math.TimeFraction
local mathR = math.Round
local traceLine = util.TraceLine

function catherine.hud.RegisterBlockModule( name )
	blockedModules[ #blockedModules + 1 ] = name
end

function catherine.hud.GetBlockModules( )
	return blockedModules
end

function catherine.hud.Draw( pl )
	if ( GetConVarString( "cat_convar_hud" ) == "0" ) then return end
	local w, h = ScrW( ), ScrH( )
	
	catherine.hud.ZipTie( pl, w, h )
	catherine.hud.Vignette( pl, w, h )
	catherine.hud.ScreenDamage( pl, w, h )
	catherine.hud.Ammo( pl, w, h )
	catherine.hud.DeathScreen( pl, w, h )
	catherine.hud.ProgressBar( pl, w, h )
	catherine.hud.TopNotify( pl, w, h )
	catherine.hud.WelcomeIntro( pl, w, h )
end

function catherine.hud.ZipTie( pl, w, h )
	if ( !pl:IsTied( ) ) then return end
	
	setColor( 70, 70, 70, 100 )
	setMat( gradient_center )
	drawMat( w / 2 - w / 2 / 2, 0, w / 2, 40 )
	
	drawText( LANG( "Item_Message03_ZT" ), "catherine_normal20", w / 2, 20, Color( 255, 255, 255, 255 ), 1, 1 )
end

function catherine.hud.DeathScreen( pl, w, h )
	if ( !IsValid( pl ) or !pl:IsCharacterLoaded( ) ) then return end
	local deathTime = pl:GetNetVar( "deathTime", 0 )
	local nextSpawnTime = pl:GetNetVar( "nextSpawnTime", 0 )
	
	if ( deathTime == 0 or nextSpawnTime == 0 ) then return end
	
	local per = timeFrac( deathTime, nextSpawnTime, CurTime( ) )
	
	drawBox( 0, 0, 0, w, h, Color( 20, 20, 20, per * 255 ) )
end

timer.Create( "catherine.hud.VignetteCheck", 2, 0, function( )
	if ( vignetteMat == "__material__error" ) then return end
	local pl = catherine.pl
	
	if ( !IsValid( pl ) ) then return end
	if ( hook.Run( "ShouldCheckVignette", pl ) == false ) then return end
	
	
	local data = { start = pl:GetPos( ) }
	data.endpos = data.start + Vector( 0, 0, 2000 )
	local tr = traceLine( data )
	
	catherine.hud.vAlphaTarget = ( !tr.Hit or tr.HitSky ) and 125 or 255
end )

function catherine.hud.Vignette( pl, w, h )
	if ( vignetteMat == "__material__error" ) then return end
	if ( hook.Run( "ShouldDrawVignette", pl ) == false ) then return end
	
	catherine.hud.vAlpha = animationApproach( catherine.hud.vAlpha, catherine.hud.vAlphaTarget, FrameTime( ) * 90 )
	
	setColor( 0, 0, 0, catherine.hud.vAlpha )
	setMat( vignetteMat )
	drawMat( 0, 0, w, h )
end

function catherine.hud.ScreenDamage( pl, w, h )
	if ( hook.Run( "ShouldDrawScreenDamage", pl ) == false ) then return end
	
end

function catherine.hud.Ammo( pl, w, h )
	if ( hook.Run( "ShouldDrawAmmo", pl ) == false ) then return end
	local wep = pl:GetActiveWeapon( )
	if ( !IsValid( wep ) or wep.DrawHUD == false ) then return end
	local clip1 = wep:Clip1( )
	local pre = pl:GetAmmoCount( wep:GetPrimaryAmmoType( ) )
	//local sec = catherine.pl:GetAmmoCount( wep:GetSecondaryAmmoType( ) )
	
	catherine.hud.clip1 = Lerp( 0.03, catherine.hud.clip1, clip1 )
	catherine.hud.pre = Lerp( 0.03, catherine.hud.pre, pre )
	
	if ( clip1 > 0 or pre > 0 ) then
		drawText( clip1 == -1 and pre or mathR( catherine.hud.clip1 ) .. " / " .. mathR( catherine.hud.pre ), "catherine_normal25", w - 30, h - 30, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
	end
end

function catherine.hud.WelcomeIntroInitialize( noRun )
	local scrW, scrH = ScrW( ), ScrH( )
	local information = hook.Run( "GetSchemaInformation" )

	catherine.hud.RegisterWelcomeIntroAnimation( 1, function( )
		return information.title
	end, "catherine_normal25", 2, 9, nil, scrW * 0.8, scrH * 0.55, TEXT_ALIGN_RIGHT )

	catherine.hud.RegisterWelcomeIntroAnimation( 2, function( )
		return information.desc
	end, "catherine_normal15", 6, 8, nil, scrW * 0.8, scrH * 0.55 + 35, TEXT_ALIGN_RIGHT )

	catherine.hud.RegisterWelcomeIntroAnimation( 3, function( )
		return catherine.environment.GetDateString( ) .. " : " .. catherine.environment.GetTimeString( )
	end, "catherine_normal15", 8, 10, nil, scrW * 0.8, scrH * 0.55 + 55, TEXT_ALIGN_RIGHT )

	catherine.hud.RegisterWelcomeIntroAnimation( 4, function( )
		return information.author
	end, "catherine_normal20", 7, 9, nil, scrW * 0.15, scrH * 0.8, TEXT_ALIGN_LEFT )

	if ( !noRun ) then
		catherine.hud.welcomeIntroWorkingData = { initStartTime = CurTime( ) }
	end
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

function catherine.hud.WelcomeIntro( pl, w, h )
	if ( !catherine.hud.welcomeIntroWorkingData ) then return end
	if ( hook.Run( "ShouldDrawWelcomeIntro", pl ) == false ) then return end
	local data = catherine.hud.welcomeIntroWorkingData
	
	for k, v in pairs( catherine.hud.welcomeIntroAnimations ) do
		local curTime = CurTime( )
		
		if ( data.initStartTime + v.startTime <= curTime ) then
			if ( !v.initStartTime ) then
				v.initStartTime = curTime
			end

			if ( v.initStartTime + v.showingTime - 1 <= curTime ) then
				if ( v.a <= 0 ) then
					continue
				else
					v.a = Lerp( 0.03, v.a, 0 )
				end
			else
				v.a = Lerp( 0.03, v.a, 255 )
			end
			
			local targetText = type( v.targetText ) == "function" and v.targetText( ) or v.targetText
			
			if ( v.textTime <= curTime and v.text:utf8len( ) < targetText:utf8len( ) ) then
				local text = targetText:utf8sub( v.textSubCount, v.textSubCount )
				
				v.text = v.text .. text
				v.textSubCount = v.textSubCount + 1
				v.textTime = curTime + v.textTimeDelay
			end
			
			local col = v.col or Color( 255, 255, 255 )
			
			drawText( v.text, v.font, v.startX, v.startY, Color( col.r, col.g, col.b, v.a ), v.xAlign or 1, v.yAlign or 1 )
		end
		
		if ( data.initStartTime + 60 <= curTime ) then
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
	catherine.hud.topNotify = { message = message }
end

function catherine.hud.TopNotify( pl, w, h )
	if ( !catherine.hud.topNotify ) then return end
	if ( hook.Run( "ShouldDrawTopNotify", pl ) == false ) then return end

	setColor( 50, 50, 50, 150 )
	setMat( gradient_center )
	drawMat( 0, h / 2 - 80, w, 110 )
	
	drawText( catherine.hud.topNotify.message or "", "catherine_normal25", w / 2, h / 2 - 30, Color( 255, 255, 255, 255 ), 1, 1 )
end

function catherine.hud.ProgressBar( pl, w, h )
	if ( !catherine.hud.progressBar ) then return end
	if ( hook.Run( "ShouldDrawProgressBar", pl ) == false ) then return end
	local data = catherine.hud.progressBar
	
	if ( data.endTime <= CurTime( ) ) then
		catherine.hud.progressBar = nil
		return
	end

	local frac = 1 - timeFrac( data.startTime, data.endTime, CurTime( ) )
	
	setColor( 50, 50, 50, 150 )
	setMat( gradient_center )
	drawMat( 0, h / 2 - 80, w, 110 )
	
	noTex( )
	setColor( 90, 90, 90, 255 )
	drawCircle( w / 2, h / 2 - 40, 15, 5, 90, 360, 100 )
	
	noTex( )
	setColor( 255, 255, 255, 255 )
	drawCircle( w / 2, h / 2 - 40, 15, 5, 90, 360 * frac, 100 )
	
	drawText( data.message or "", "catherine_normal25", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
end

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

netstream.Hook( "catherine.hud.WelcomeIntroStart", function( )
	catherine.hud.WelcomeIntroInitialize( )
end )