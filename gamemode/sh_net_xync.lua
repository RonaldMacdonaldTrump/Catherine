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

catherine.netXync = catherine.netXync or { buffer = { } }
catherine.netXync.usingJSON = false
local type, pcall, MsgC, pairs, player = type, pcall, MsgC, pairs, player

if ( !pon ) then
	catherine.netXync.usingJSON = true
	MsgC( Color( 255, 255, 0 ), "[NetXync Notify] Can't found 'pON' library so using 'Json' library!\n" )
end

function catherine.netXync.Receiver( uniqueID, func )
	catherine.netXync.buffer[ uniqueID ] = func
end

function catherine.netXync.Encode( val )
	return catherine.netXync.usingJSON and util.TableToJSON( val ) or pon.encode( val )
end

function catherine.netXync.Decode( val )
	return catherine.netXync.usingJSON and util.JSONToTable( val ) or pon.decode( val )
end

if ( SERVER ) then
	util.AddNetworkString( "Catherine.netXync.Core" )
	
	function catherine.netXync.Send( receivers, uniqueID, ... )
		if ( type( receivers ) != "table" ) then
			receivers = receivers and { receivers } or player.GetAll( )
		end
		
		local dataTable = { ... }
		
		if ( table.Count( dataTable ) == 0 ) then
			net.Start( "Catherine.netXync.Core" )
				net.WriteString( uniqueID )
				net.WriteBit( false )
			net.Send( receivers )
		else
			local encode = catherine.netXync.Encode( dataTable )
			local len = #encode
			
			if ( !encode or len <= 0 ) then return end
			
			net.Start( "Catherine.netXync.Core" )
				net.WriteString( uniqueID )
				net.WriteBit( true )
				net.WriteUInt( len, 32 )
				net.WriteData( encode, len )
			net.Send( receivers )
		end
	end
	
	net.Receive( "Catherine.netXync.Core", function( len, pl )
		local NetXync_UniqueID = net.ReadString( )
		local NetXync_Status = net.ReadBit( )

		if ( NetXync_Status == true ) then
			local NetXync_Length = net.ReadUInt( 32 )
			local NetXync_DataTable = net.ReadData( NetXync_Length )
			local success, val = pcall( catherine.netXync.Decode, NetXync_DataTable )
			local func = catherine.netXync.buffer[ NetXync_UniqueID ]
			
			if ( func ) then
				if ( success ) then
					func( pl, unpack( val ) )
				else
					MsgC( Color( 0, 255, 255 ), "[NetXync ERROR] Catherine NetXync '" .. NetXync_UniqueID .. "' has failed to run.\n'" .. val .. "'\n" )
				end
			else
				MsgC( Color( 0, 255, 255 ), "[NetXync ERROR] Catherine NetXync '" .. NetXync_UniqueID .. "' has failed to run.\n'Callback not found.\n" )
			end
		else
			local func = catherine.netXync.buffer[ NetXync_UniqueID ]
			
			if ( func ) then
				func( pl )
			else
				MsgC( Color( 0, 255, 255 ), "[NetXync ERROR] Catherine NetXync '" .. NetXync_UniqueID .. "' has failed to run.\n'Callback not found.\n" )
			end
		end
	end )
else
	net.Receive( "Catherine.netXync.Core", function( len )
		local NetXync_UniqueID = net.ReadString( )
		local NetXync_Status = net.ReadBit( )
		
		if ( NetXync_Status == true ) then
			local NetXync_Length = net.ReadUInt( 32 )
			local NetXync_DataTable = net.ReadData( NetXync_Length )
			local success, val = pcall( catherine.netXync.Decode, NetXync_DataTable )
			local func = catherine.netXync.buffer[ NetXync_UniqueID ]
			
			if ( func ) then
				if ( success ) then
					func( pl, unpack( val ) )
				else
					MsgC( Color( 0, 255, 255 ), "[NetXync ERROR] Catherine NetXync '" .. NetXync_UniqueID .. "' has failed to run.\n'" .. val .. "'\n" )
				end
			else
				MsgC( Color( 0, 255, 255 ), "[NetXync ERROR] Catherine NetXync '" .. NetXync_UniqueID .. "' has failed to run.\n'Callback not found.\n" )
			end
		else
			local func = catherine.netXync.buffer[ NetXync_UniqueID ]
			
			if ( func ) then
				func( pl )
			else
				MsgC( Color( 0, 255, 255 ), "[NetXync ERROR] Catherine NetXync '" .. NetXync_UniqueID .. "' has failed to run.\n'Callback not found.\n" )
			end
		end
	end )
	
	function catherine.netXync.Send( uniqueID, ... )
		local dataTable = { ... }
		
		if ( table.Count( dataTable ) == 0 ) then
			net.Start( "Catherine.netXync.Core" )
				net.WriteString( uniqueID )
				net.WriteBit( false )
			net.SendToServer( )
		else
			local encode = catherine.netXync.Encode( dataTable )
			local len = #encode
			
			if ( !encode or len <= 0 ) then return end
			
			net.Start( "Catherine.netXync.Core" )
				net.WriteString( uniqueID )
				net.WriteBit( true )
				net.WriteUInt( len, 32 )
				net.WriteData( encode, len )
			net.SendToServer( )
		end
	end
end