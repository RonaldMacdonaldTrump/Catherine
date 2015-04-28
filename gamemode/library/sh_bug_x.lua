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

catherine.bugX = catherine.bugX or { }
CAT_BUG_X_FLAG_PLUGIN = 1

if ( SERVER ) then
	catherine.bugX.plugin = catherine.bugX.plugin or { }

	function catherine.bugX.Work( flag, workTable, func )
		if ( flag == CAT_BUG_X_FLAG_PLUGIN ) then
			catherine.bugX.plugin[ workTable.pluginID ] = catherine.bugX.plugin[ workTable.pluginID ] or { }
			catherine.bugX.plugin[ workTable.pluginID ][ workTable.hookID ] = catherine.bugX.plugin[ workTable.pluginID ][ workTable.hookID ] + 1 or 0
		
			local count = catherine.bugX.plugin[ workTable.pluginID ][ workTable.hookID ]
			
			if ( count >= 15 ) then
				catherine.bugX.plugin[ workTable.pluginID ] = nil
				catherine.plugin.lists[ workTable.pluginID ] = nil
				catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING : Too many errors found, plugin is disabled. [" .. workTable.pluginID .. "]", true )
				MsgC( Color( 255, 0, 0 ), "[CAT BugX] WARNING : Too many errors found, plugin is disabled. [" .. workTable.pluginID .. "]\n" )
			else
				MsgC( Color( 0, 255, 255 ), "[CAT BugX] BugX working ... <" .. workTable.pluginID .. "/" .. workTable.hookID .. "/" .. count .. ">\n" )
			end
		end
	end
end