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

catherine.language.Merge( "english", {
	[ "Vendor_Notify_Buy" ] = "You are brought '%s' at '%s' from this vendor!",
	[ "Vendor_Notify_Sell" ] = "You are sold '%s' at '%s' from this vendor!",
	[ "Vendor_Notify_VendorNoHasCash" ] = "This vendor has not enough %s!",
	[ "Vendor_Notify_NoHasStock" ] = "This vendor don't have this kind of item anymore!",
	[ "Vendor_Notify_NotValid" ] = "This is not vendor!",
	[ "Vendor_Notify_Add" ] = "You are added vendor.",
	[ "Vendor_Notify_Remove" ] = "You are removed this vendor.",
	[ "Vendor_Message_CantUse" ] = "You don't have permission using this vendor!",
	[ "Vendor_NameQ" ] = "What are you want vendor name ?"
} )