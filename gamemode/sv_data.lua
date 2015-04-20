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

catherine.data = catherine.data or { buffer = { } }

function catherine.data.DataLoad( )
	file.CreateDir( "catherine" )
	file.CreateDir( "catherine/globals" )
	file.CreateDir( "catherine/" .. catherine.schema.GetUniqueID( ) )
end

hook.Add( "DataLoad", "catherine.data.DataLoad", catherine.data.DataLoad )

function catherine.data.Set( key, value, ignoreMap, isGlobal )
	local dir = "catherine/" .. ( isGlobal and "globals/" or catherine.schema.GetUniqueID( ) .. "/" ) .. key .. "/"
	local data = util.TableToJSON( value )
	
	if ( !ignoreMap ) then
		dir = dir .. game.GetMap( )
		file.CreateDir( dir )
	end
	
	file.Write( dir .. "/data.txt", data )
	catherine.data.buffer[ key ] = value
end

function catherine.data.Get( key, default, ignoreMap, isGlobal, isBuffer )
	local dir = "catherine/" .. ( isGlobal and "globals/" or catherine.schema.GetUniqueID( ) .. "/" ) .. key .. "/" .. ( !ignoreMap and game.GetMap( ) or "" ) .. "/data.txt"
	local data = file.Read( dir, "DATA" ) or nil
	if ( !data ) then return default end

	return isBuffer and catherine.data.buffer[ key ] or util.JSONToTable( data )
end