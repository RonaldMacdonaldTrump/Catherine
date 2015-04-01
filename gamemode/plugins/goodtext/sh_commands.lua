--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

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
	command = "textadd",
	syntax = "[Text] [Size]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			PLUGIN:AddText( pl, args[ 1 ], tonumber( args[ 2 ] ) )
			catherine.util.Notify( pl, "You have added text to your desired location!" )
		else
			catherine.util.Notify( pl, "args[ 1 ] is missing!" )
		end
	end
} )

catherine.command.Register( {
	command = "textremove",
	syntax = "[Distance]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( !args[ 1 ] ) then args[ 1 ] = 256 end
		local count = PLUGIN:RemoveText( pl:GetShootPos( ), args[ 1 ] )
		if ( count == 0 ) then
			catherine.util.Notify( pl, "There are no texts at that location." )
		else
			catherine.util.Notify( pl, "You have removed " .. count .. "'s texts!" )
		end
	end
} )
