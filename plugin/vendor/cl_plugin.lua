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
PLUGIN.VENDOR_NOANI = PLUGIN.VENDOR_NOANI or false

catherine.netXync.Receiver( "catherine.plugin.vendor.RefreshRequest", function( data )
	PLUGIN.VENDOR_NOANI = true
	local menuID = nil
	if ( IsValid( catherine.vgui.vendor ) ) then
		menuID = catherine.vgui.vendor.currMenu
		catherine.vgui.vendor:Remove( )
		catherine.vgui.vendor = nil
	end
	
	catherine.vgui.vendor = vgui.Create( "catherine.vgui.vendor" )
	catherine.vgui.vendor:InitializeVendor( Entity( data ) )
	if ( menuID ) then
		catherine.vgui.vendor:ChangeMode( menuID )
	end
	PLUGIN.VENDOR_NOANI = false
end )

catherine.netXync.Receiver( "catherine.plugin.vendor.VendorUse", function( data )
	if ( IsValid( catherine.vgui.vendor ) ) then
		catherine.vgui.vendor:Remove( )
		catherine.vgui.vendor = nil
	end
	
	catherine.vgui.vendor = vgui.Create( "catherine.vgui.vendor" )
	catherine.vgui.vendor:InitializeVendor( Entity( data ) )
end )