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

hook.CallBackup = hook.CallBackup or hook.Call

function hook.Call( name, gm, ... )
	local cacheData = catherine.hook.caches[ name ]
	
	if ( cacheData ) then
		for k, v in pairs( cacheData ) do
			local result = { v( k, ... ) }

			if ( #result > 0 ) then
				return unpack( result )
			end
		end
	end

	if ( Schema and Schema[ name ] ) then
		local result = { Schema[ name ]( Schema, ... ) }

		if ( #result > 0 ) then
			return unpack( result )
		end
	end
	
	return hook.CallBackup( name, gm, ... )
end

--[[ // Old :<
	for k, v in pairs( catherine.plugin.GetAll( ) ) do
		if ( !v[ name ] ) then continue end
		local success, result = pcall( v[ name ], v, ... )
		
		if ( success ) then
			if ( result == nil ) then continue end

			return result
		else
			catherine.bugX.Work( CAT_BUG_X_FLAG_PLUGIN, {
				pluginID = k,
				hookID = name
			} )
			ErrorNoHalt( "[CAT ERROR] SORRY, On the plugin <" .. k .. ">'s hooks <" .. name .. "> has a critical error ...\n" .. result .. "\n" )
		end
	end
	
	if ( Schema and Schema[ name ] ) then
		local success, result = pcall( Schema[ name ], Schema, ... )

		if ( success ) then
			if ( result != nil ) then
				return result
			end
		else
			ErrorNoHalt( "[CAT ERROR] SORRY, Schema hooks <" .. name .. "> has a critical error ...\n" .. result .. "\n" )
		end
	end
	
	return hook.CallBackup( name, gm, ... )--]]