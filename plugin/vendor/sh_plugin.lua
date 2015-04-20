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
PLUGIN.name = "Vendor"
PLUGIN.author = "L7D"
PLUGIN.desc = "Good stuff."
PLUGIN.randModels = {

}
local varsID = {
	"name",
	"desc",
	"factions",
	"classes",
	"inv",
	"cash",
	"setting",
	"status"
}
CAT_VENDOR_ACTION_BUY = 1 // Buy from player
CAT_VENDOR_ACTION_SELL = 2 // Sell to player
CAT_VENDOR_ACTION_SETTING_CHANGE = 3 // Setting change
CAT_VENDOR_ACTION_ITEM_CHANGE = 4
CAT_VENDOR_ACTION_ITEM_UNCHANGE = 5

PLUGIN.VENDOR_SOLD_DISCOUNTPER = 2

function PLUGIN:GetVendorDatas( ent )
	if ( !IsValid( ent ) or !ent.isVendor ) then return end
	local datas = { }

	for k, v in pairs( varsID ) do
		datas[ v ] = ent:GetNetVar( v )
	end
	
	return datas
end

function PLUGIN:GetVendorWorkingPlayers( )
	local players = { }

	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( !v:GetNetVar( "vendor_work" ) ) then continue end
		players[ #players + 1 ] = v
	end
	
	return players
end

catherine.util.Include( "sh_language.lua" )
catherine.util.Include( "sh_commands.lua" )
catherine.util.Include( "sv_plugin.lua" )
catherine.util.Include( "cl_plugin.lua" )