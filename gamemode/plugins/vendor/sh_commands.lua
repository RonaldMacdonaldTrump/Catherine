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

catherine.command.Register( {
	command = "vendoradd",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		catherine.util.UniqueStringReceiver( pl, "Vendor_SpawnFunc_Name", LANG( pl, "Basic_UI_StringRequest" ), LANG( "Vendor_NameQ" ), "Johnson", function( _, val )
			local pos, ang = pl:GetEyeTraceNoCursor( ).HitPos, pl:EyeAngles( )
			ang.p = 0
			ang.y = ang.y - 180
			
			local ent = ents.Create( "cat_vendor" )
			ent:SetPos( pos )
			ent:SetAngles( ang )
			ent:Spawn( )
			ent:Activate( )
			
			PLUGIN:MakeVendor( ent, { name = val } )
			PLUGIN:SaveVendors( )
			catherine.util.NotifyLang( pl, "Vendor_Notify_Add" )
		end )
	end
} )

catherine.command.Register( {
	command = "vendorremove",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity
		
		if ( IsValid( ent ) and ent:GetClass( ) == "cat_vendor" ) then
			ent:Remove( )
			catherine.util.NotifyLang( pl, "Vendor_Notify_Remove" )
		else
			catherine.util.NotifyLang( pl, "Vendor_Notify_NotValid" )
		end
	end
} )