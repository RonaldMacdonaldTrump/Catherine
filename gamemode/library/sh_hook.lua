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

catherine.hook = catherine.hook or { }
catherine.hook.caches = { }

hook.CallCatHooks = hook.CallCatHooks or hook.Call

function hook.Call( hookID, gamemode, ... )
	local cacheData = catherine.hook.caches[ hookID ]
	
	if ( cacheData ) then
		for k, v in pairs( cacheData ) do
			local success, result = pcall( v, k, ... )

			if ( success ) then
				result = { result }
				
				if ( #result > 0 ) then
					return unpack( result )
				end
			else
				catherine.bugX.Work( CAT_BUG_X_FLAG_PLUGIN, {
					pluginID = k.uniqueID,
					hookID = hookID
				} )
				
				ErrorNoHalt( "[CAT ERROR] SORRY, On the plugin <" .. k.uniqueID .. ">'s hooks <" .. hookID .. "> has a critical error ...\n" .. result .. "\n" )
			end
		end
	end

	if ( Schema and Schema[ hookID ] ) then
		local success, result = pcall( Schema[ hookID ], Schema, ... )
		
		if ( success ) then
			result = { result }
			
			if ( #result > 0 ) then
				return unpack( result )
			end
		else
			ErrorNoHalt( "[CAT ERROR] SORRY, Schema hooks <" .. hookID .. "> has a critical error ...\n" .. result .. "\n" )
		end
	end
	
	return hook.CallCatHooks( hookID, gamemode, ... )
end