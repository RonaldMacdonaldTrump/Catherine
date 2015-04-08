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
PLUGIN.name = "Spawnpoint"
PLUGIN.author = "L7D"
PLUGIN.desc = "Good stuff."

catherine.util.Include( "sh_language.lua" )
catherine.util.Include( "sv_plugin.lua" )

catherine.command.Register( {
	command = "spawnpointadd",
	syntax = "[Faction Name]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local factionTable = catherine.faction.FindByName( args[ 1 ] )
			if ( factionTable ) then
				local map = game.GetMap( )
				local faction = factionTable.uniqueID
				PLUGIN.Lists[ map ] = PLUGIN.Lists[ map ] or { }
				PLUGIN.Lists[ map ][ faction ] = PLUGIN.Lists[ map ][ faction ] or { }
				PLUGIN.Lists[ map ][ faction ][ #PLUGIN.Lists[ map ][ faction ] + 1 ] = pl:GetPos( )
				
				PLUGIN:SavePoints( )
				
				catherine.util.NotifyAllLang( "Spawnpoint_Notify_Add", factionTable.name )
			else
				catherine.util.NotifyLang( pl, "Faction_Notify_NotValid" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "spawnpointremove",
	syntax = "[Range]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local rad = math.max( tonumber( args[ 1 ] or "" ) or 140, 8 )
		local pos = pl:GetPos( )
		local map = game.GetMap( )
		local i = 0

		for k, v in pairs( PLUGIN.Lists[ map ] ) do
			if ( v:Distance( pos ) <= rad ) then
				i = i + 1
				table.remove( PLUGIN.Lists[ map ], k )
			end
		end
		
		if ( i != 0 ) then
			catherine.util.NotifyLang( pl, "Spawnpoint_Notify_Remove", i )
		else
			catherine.util.NotifyLang( pl, "Spawnpoint_Notify_Remove_No" )
		end
	end
} )