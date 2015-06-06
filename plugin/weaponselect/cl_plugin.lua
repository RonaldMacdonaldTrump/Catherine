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

local PLUGIN = PLUGIN
PLUGIN.curSlot = 1
PLUGIN.weapons = PLUGIN.weapons or { }
PLUGIN.showTime = 0
PLUGIN.fadeTime = 0
PLUGIN.maxHighX = 0
PLUGIN.curSlotY = 0
PLUGIN.curSlotX = 0
local gradient_left = Material( "gui/gradient" )

catherine.hud.RegisterBlockModule( "CHudWeaponSelection" )

function PLUGIN:PlayerBindPress( pl, bind, pressed )
	local wep = pl:GetActiveWeapon( )
	if ( pl:InVehicle( ) or ( IsValid( wep ) and wep:GetClass( ) == "weapon_physgun" and pl:KeyDown( IN_ATTACK ) ) ) then return end
	local weps = pl:GetWeapons( )
	if ( #weps == 0 ) then return end
	local wepsCount = #weps
	
	if ( bind == "+attack" and pressed ) then
		if ( self.fadeTime > CurTime( ) ) then
			local selectWeapon = self.weapons[ self.curSlot ]
			
			if ( selectWeapon and pl:HasWeapon( selectWeapon.uniqueID ) ) then
				RunConsoleCommand( "cat_ws_selectWeapon", selectWeapon.uniqueID )
				
				surface.PlaySound( "ui/buttonclickrelease.wav" )
				
				self.showTime = CurTime( )
				self.fadeTime = CurTime( )
			end
		
			return true
		end
	end
	
	if ( ( self.nextBind or 0 ) <= CurTime( ) ) then
		if ( bind == "invnext" or bind == "slot1" ) then
			if ( self.curSlot < wepsCount ) then
				self.curSlot = self.curSlot + 1
			elseif ( self.curSlot >= wepsCount ) then
				self.curSlot = 1
			end
			
			surface.PlaySound( "common/talk.wav" )
			
			self.nextBind = CurTime( ) + 0.08
			self.showTime = CurTime( )
			self.fadeTime = CurTime( ) + 3
			
			hook.Run( "OnWeaponSlotChanged", pl, self.curSlot )
			
			return true
		elseif ( bind == "invprev" or bind == "slot2" ) then
			if ( self.curSlot > 1 ) then
				self.curSlot = self.curSlot - 1
			elseif ( self.curSlot <= 1 ) then
				self.curSlot = wepsCount
			end
			
			surface.PlaySound( "common/talk.wav" )
			
			self.nextBind = CurTime( ) + 0.08
			self.showTime = CurTime( )
			self.fadeTime = CurTime( ) + 3
			
			hook.Run( "OnWeaponSlotChanged", pl, self.curSlot )
			
			return true
		end
	end
end

function PLUGIN:HUDDraw( )
	if ( !LocalPlayer( ):IsCharacterLoaded( ) or !LocalPlayer( ):Alive( ) ) then return end
	
	local scrW, scrH = ScrW( ), ScrH( )
	
	for k, v in pairs( self.weapons ) do
		if ( self.showTime <= CurTime( ) ) then
			if ( self.fadeTime <= CurTime( ) ) then
				v.a = Lerp( 0.03, v.a, 0 )
				v.x = Lerp( 0.05, v.x, 0 - ScrW( ) * 0.2 )
				
				self.curSlotX = v.x
				self.maxHighX = v.x
			else
				v.a = Lerp( 0.03, v.a, 255 )
				v.x = Lerp( 0.05, v.x, ScrW( ) * 0.2 )
				
				self.curSlotX = v.x
			end
		end
		
		if ( math.Round( v.a ) <= 0 ) then continue end
		
		surface.SetFont( "catherine_normal25" )
		local tw, th = surface.GetTextSize( v.name )
		local x = v.x - 5 + ( tw + 10 )
		local y = scrH * 0.3 + ( k * 30 )
		
		if ( self.curSlot == k ) then
			self.curSlotY = Lerp( 0.08, self.curSlotY, y )
			
			local markupObject = v.markupObject
			
			if ( markupObject ) then
				surface.SetDrawColor( 80, 80, 80, v.a )
				surface.SetMaterial( gradient_left )
				surface.DrawTexturedRect( self.maxHighX + 20, scrH * 0.3 + 20, 230, markupObject:GetHeight( ) + 10 )
	
				markupObject:Draw( self.maxHighX + 30, scrH * 0.3 + 25, 0, TEXT_ALIGN_LEFT, v.a )
			end
		end

		if ( self.maxHighX < x ) then
			self.maxHighX = x
		end
		
		draw.RoundedBox( 0, v.x - 5, y - th / 2 + 1, tw + 10, th, Color( 80, 80, 80, v.a / 2 ) )
		draw.SimpleText( v.name, "catherine_normal25", v.x, y, Color( 255, 255, 255, v.a ), TEXT_ALIGN_LEFT, 1 )
	end
	
	if ( #self.weapons != 0 ) then
		draw.RoundedBox( 0, self.curSlotX - 15, self.curSlotY - 22 / 2, 10, 25, Color( 255, 255, 255, self.weapons[ #self.weapons ].a ) )
	end
end

local languageStuff = catherine.util.StuffLanguage

function PLUGIN:LanguageChanged( )
	self.curSlot = 1
	self.weapons = { }
		
	for k, v in pairs( LocalPlayer( ):GetWeapons( ) ) do
		if ( !v or !IsValid( v ) ) then return end
		
		local markupText = "<font=catherine_normal20>"
		local markupObject = nil
		local markupFound = false
		
		if ( v.Instructions and v.Instructions != "" ) then
			markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Instructions_Title" ) .. "</color>\n<font=catherine_normal15>" .. languageStuff( v.Instructions ) .. "</font>\n\n"
			markupFound = true
		end
		
		if ( v.Author and v.Author != "" ) then
			markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Author_Title" ) .. "</color>\n<font=catherine_normal15>" .. languageStuff( v.Author ) .. "</font>\n\n"
			markupFound = true
		end
		
		if ( v.Purpose and v.Purpose != "" ) then
			markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Purpose_Title" ) .. "</color>\n<font=catherine_normal15>" .. languageStuff( v.Purpose ) .. "</font>\n\n"
			markupFound = true
		end
		
		if ( markupFound ) then
			markupObject = markup.Parse( markupText .. "</font>", 230 )
		end

		self.weapons[ #self.weapons + 1 ] = {
			name = v:GetPrintName( ),
			uniqueID = v:GetClass( ),
			x = ScrW( ) * 0.25,
			a = 0,
			xMinus = 0,
			markupObject = markupObject
		}
	end
end

netstream.Hook( "catherine.plugin.weaponselect.Refresh", function( data )
	local id = data[ 1 ]
	local uniqueID = data[ 2 ]
	
	if ( id == 1 ) then
		local wep = LocalPlayer( ):GetWeapon( uniqueID )
		
		if ( !wep ) then return end
		
		local markupText = "<font=catherine_normal20>"
		local markupObject = nil
		local markupFound = false
		
		if ( wep.Instructions and wep.Instructions != "" ) then
			markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Instructions_Title" ) .. "</color>\n<font=catherine_normal15>" .. languageStuff( wep.Instructions ) .. "</font>\n\n"
			markupFound = true
		end
		
		if ( wep.Author and wep.Author != "" ) then
			markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Author_Title" ) .. "</color>\n<font=catherine_normal15>" .. languageStuff( wep.Author ) .. "</font>\n\n"
			markupFound = true
		end
		
		if ( wep.Purpose and wep.Purpose != "" ) then
			markupText = markupText .. "<color=220,220,220,255>" .. LANG( "Weapon_Purpose_Title" ) .. "</color>\n<font=catherine_normal15>" .. languageStuff( wep.Purpose ) .. "</font>\n\n"
			markupFound = true
		end
		
		if ( markupFound ) then
			markupObject = markup.Parse( markupText .. "</font>", 230 )
		end

		PLUGIN.weapons[ #PLUGIN.weapons + 1 ] = {
			name = wep:GetPrintName( ),
			uniqueID = uniqueID,
			x = ScrW( ) * 0.25,
			a = 0,
			xMinus = 0,
			markupObject = markupObject
		}
	elseif ( id == 2 ) then
		for k, v in pairs( PLUGIN.weapons ) do
			if ( v.uniqueID == uniqueID ) then
				table.remove( PLUGIN.weapons, k )
				
				return
			end
		end
	elseif ( id == 3 ) then
		PLUGIN.curSlot = 1
		PLUGIN.weapons = { }
	end
end )