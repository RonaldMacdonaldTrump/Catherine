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
	command = "textadd",
	syntax = "[Text] [Size]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			PLUGIN:AddText( pl, args[ 1 ], tonumber( args[ 2 ] ) )
			
			catherine.util.NotifyLang( pl, "WallText_Notify_Add" )
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "textremove",
	syntax = "[Distance]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local i = PLUGIN:RemoveText( pl:GetShootPos( ), args[ 1 ] or 256 )
		
		if ( i == 0 ) then
			catherine.util.NotifyLang( pl, "WallText_Notify_NoText" )
		else
			catherine.util.NotifyLang( pl, "WallText_Notify_Remove", i )
		end
	end
} )