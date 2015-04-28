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
PLUGIN.name = "^WS_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^WS_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "WS_Plugin_Name" ] = "Weapon Select",
	[ "WS_Plugin_Desc" ] = "Good stuff."
} )

catherine.language.Merge( "korean", {
	[ "WS_Plugin_Name" ] = "무기 선택",
	[ "WS_Plugin_Desc" ] = "RP 에 맞는 무기 선택으로 바꿔줍니다."
} )

if ( SERVER ) then
	concommand.Add( "cat_ws_selectWeapon", function( pl, _, args )
		pl.SelectWeapon( pl, args[ 1 ] )
	end )
else
	PLUGIN.latestSlot = PLUGIN.latestSlot or 1
	PLUGIN.showTime = PLUGIN.showTime or CurTime( ) + 4
	PLUGIN.noShowTime = PLUGIN.noShowTime or CurTime( ) + 5
	PLUGIN.markup = PLUGIN.markup or nil
	
	function PLUGIN:PlayerBindPress( pl, bind, pressed )
		local wep = pl.GetActiveWeapon( pl )
		local weps = pl.GetWeapons( pl )
		if ( pl.InVehicle( pl ) or ( IsValid( wep ) and wep.GetClass( wep ) == "weapon_physgun" and pl.KeyDown( pl, IN_ATTACK ) ) ) then return end
		
		bind = bind.lower( bind )
		
		if ( bind.find( bind, "invnext" ) and pressed ) then
			self.latestSlot = self.latestSlot + 1
			
			if ( self.latestSlot > #weps ) then
				self.latestSlot = 1
			end
			
			hook.Run( "OnWeaponSlotChanged", pl, self.latestSlot )
			
			return true
		elseif ( bind.find( bind, "invprev" ) and pressed ) then
			self.latestSlot = self.latestSlot - 1
			
			if ( self.latestSlot <= 0 ) then
				self.latestSlot = #weps
			end
			
			hook.Run( "OnWeaponSlotChanged", pl, self.latestSlot )
			
			return true
		elseif ( bind.find( bind, "+attack" ) and pressed ) then
			if ( self.noShowTime > CurTime( ) ) then
				self.showTime = 0
				self.noShowTime = 0
				
				for k, v in pairs( weps ) do
					if ( k != self.latestSlot ) then continue end
					
					RunConsoleCommand( "cat_ws_selectWeapon", v.GetClass( v ) )
					
					return true
				end
			end
		elseif ( bind.find( bind, "slot" ) ) then
			self.latestSlot = math.Clamp( tonumber( bind.match( bind, "slot(%d)" ) ) or 1, 1, #weps )
			self.showTime = CurTime( ) + 4 self.noShowTime = CurTime( ) + 5
			
			return true
		end
	end
	
	function PLUGIN:OnWeaponSlotChanged( pl, slot )
		self.showTime = CurTime( ) + 4
		self.noShowTime = CurTime( ) + 5
		
		for k, v in pairs( pl.GetWeapons( pl ) ) do
			if ( k != self.latestSlot ) then continue end
			
			if ( v.Instructions and v.Instructions.find( v.Instructions, "%S" ) ) then
				self.markup = markup.Parse( "<font=catherine_outline15>" .. v.Instructions .. "</font>" )
				
				return
			else
				self.markup = nil
			end
		end
	end
	
	function PLUGIN:HUDDraw( )
		local defx, defy = ScrW( ) * 0.175, ScrH( ) * 0.4
		
		for k, v in pairs( LocalPlayer( ).GetWeapons( LocalPlayer( ) ) ) do
			local col = Color( 255, 255, 255 )
			
			col.a = math.Clamp( 255 - math.TimeFraction( self.showTime, self.noShowTime, CurTime( ) ) * 255, 0, 255 )
			
			if ( k == self.latestSlot ) then
				draw.SimpleText( ">", "catherine_normal25", defx - 20, defy + ( k * 30 ), col, TEXT_ALIGN_LEFT, 1 )
			end
			
			draw.SimpleText( v.GetPrintName( v ), "catherine_normal25", defx, defy + ( k * 30 ), col, TEXT_ALIGN_LEFT, 1 )
			
			if ( k == self.latestSlot and self.markup ) then
				self.markup:Draw( defx + 128, defy + 24, 0, 1, col.a )
			end
		end
	end
end