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
/*
catherine.system = catherine.system or { libVersion = "2015-08-28" }
CAT_SYSTEM_DATATYPE_NUMBER = 0
CAT_SYSTEM_DATATYPE_STRING = 1
CAT_SYSTEM_DATATYPE_BOOL = 2

if ( SERVER ) then
	function catherine.system.RegisterTick( uniqueID, name, desc, max, time, status )
		SetGlobalInt( "catherine.system.globalInt.tickSystem." .. uniqueID .. ".time", time )
		SetGlobalInt( "catherine.system.globalInt.tickSystem." .. uniqueID .. ".status", status )
		
		local globalVar = catherine.net.GetNetGlobalVar( "cat_timeSystem", { } )
		
		globalVar[ uniqueID ] = {
			name = name,
			desc = desc,
			max = max,
			uniqueID = uniqueID
		}
		
		catherine.net.SetNetGlobalVar( "cat_timeSystem", globalVar )
	end
	
	function catherine.system.SetTickData( uniqueID, dataType, dataID, newData )
		if ( dataType == CAT_SYSTEM_DATATYPE_NUMBER ) then
			SetGlobalInt( "catherine.system.globalInt.tickSystem." .. uniqueID .. "." .. dataID, newData )
		elseif ( dataType == CAT_SYSTEM_DATATYPE_STRING ) then
			SetGlobalString( "catherine.system.globalInt.tickSystem." .. uniqueID .. "." .. dataID, newData )
		elseif ( dataType == CAT_SYSTEM_DATATYPE_BOOL ) then
			SetGlobalBool( "catherine.system.globalInt.tickSystem." .. uniqueID .. "." .. dataID, newData )
		end
	end
else

end

function catherine.system.GetAllTick( )
	return catherine.net.GetNetGlobalVar( "cat_timeSystem", { } )
end

function catherine.system.TickFindByID( uniqueID )
	return catherine.net.GetNetGlobalVar( "cat_timeSystem", { } )[ uniqueID ]
end

function catherine.system.GetTickData( uniqueID, dataType, dataID, default )
	if ( dataType == CAT_SYSTEM_DATATYPE_NUMBER ) then
		return GetGlobalInt( "catherine.system.globalInt.tickSystem." .. uniqueID .. "." .. dataID, default )
	elseif ( dataType == CAT_SYSTEM_DATATYPE_STRING ) then
		return GetGlobalString( "catherine.system.globalInt.tickSystem." .. uniqueID .. "." .. dataID, default )
	elseif ( dataType == CAT_SYSTEM_DATATYPE_BOOL ) then
		return GetGlobalBool( "catherine.system.globalInt.tickSystem." .. uniqueID .. "." .. dataID, default )
	end
	
	return default
end
*/