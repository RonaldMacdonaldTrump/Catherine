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

catherine.log = catherine.log or { }
catherine.log.logString = { }
//CAT_LOG_FLAG_CHAT

function catherine.log.RegisterLogString( key, str )
	catherine.log.logString[ key ] = str
end
	
function catherine.log.FindLogStringByKey( key )
	return catherine.log.logString[ key ]
end

if ( SERVER ) then
	function catherine.log.Add( flag, id, ... )
	
		
	end
	
	function catherine.log.Initialize( )
		file.CreateDir( "catherine" )
		file.CreateDir( "catherine/log" )
		
		local date = os.date( "*t" )
		file.CreateDir( "catherine/log/" .. ( date.year .. "-" .. date.month .. "-" .. date.day ) )
	end

	hook.Add( "Initialize", "catherine.log.Initialize", catherine.log.Initialize )

else
	netstream.Hook( "catherine.log.Send", function( data )
	
		MsgC( Color( 50, 200, 50 ), "[CAT LOG] " .. 
	end )
end