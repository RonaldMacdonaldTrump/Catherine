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

catherine.network = catherine.network or { globalVars = { }, entityVars = { } }
local META = FindMetaTable( "Entity" )
local META2 = FindMetaTable( "Player" )
// 네트워킹 시스템; ^-^; 2015-03-10 학교 컴실에서.. // 이전
// 새로운 네트워킹 시스템; ^-^; 2015-04-09 집에서..

if ( SERVER ) then
	function catherine.network.SetNetVar( ent, key, value, noSync )
		catherine.network.entityVars[ ent ] = catherine.network.entityVars[ ent ] or { }
		catherine.network.entityVars[ ent ][ key ] = value
		
		if ( !noSync ) then
			local data = ent:EntIndex( )
			
			if ( ent:IsPlayer( ) ) then
				data = ent:SteamID( )
			end
			
			if ( value == nil ) then
				netstream.Start( nil, "catherine.network.ClearNetVar", data )
				return
			end
			
			netstream.Start( nil, "catherine.network.SetNetVar", { data, key, value } )
		end
	end
	
	function catherine.network.GetNetVar( ent, key, default )
		return catherine.network.entityVars[ ent ] and catherine.network.entityVars[ ent ][ key ] or default
	end
	
	function catherine.network.SetNetGlobalVar( key, value, noSync )
		catherine.network.globalVars[ key ] = value
		
		if ( !noSync ) then
			if ( value == nil ) then
				netstream.Start( nil, "catherine.network.ClearNetGlobalVar", key )
				return
			end
			
			netstream.Start( nil, "catherine.network.SetNetGlobalVar", { key, value } )
		end
	end

	function catherine.network.SyncAllVars( pl )
		local conVert = { }
		
		for k, v in pairs( catherine.network.entityVars ) do
			if ( k:IsPlayer( ) ) then
				conVert[ k:SteamID( ) ] = v
			else
				conVert[ k:EntIndex( ) ] = v
			end
		end

		netstream.Start( pl, "catherine.network.SyncAllVars", { conVert, catherine.network.globalVars } )
	end

	function META:SetNetVar( key, value, noSync )
		catherine.network.SetNetVar( self, key, value, noSync )
	end
	
	META2.SetNetVar = META.SetNetVar
	
	function catherine.network.EntityRemoved( ent )
		catherine.network.entityVars[ ent ] = nil
		netstream.Start( nil, "catherine.network.ClearNetVar", ent:EntIndex( ) )
	end
	
	function catherine.network.PlayerDisconnected( pl )
		catherine.network.entityVars[ pl ] = nil
		netstream.Start( nil, "catherine.network.ClearNetVar", pl:SteamID( ) )
	end

	hook.Add( "EntityRemoved", "catherine.network.EntityRemoved", catherine.network.EntityRemoved )
	hook.Add( "PlayerDisconnected", "catherine.network.PlayerDisconnected", catherine.network.PlayerDisconnected )
else
	netstream.Hook( "catherine.network.SetNetVar", function( data )
		catherine.network.entityVars[ data[ 1 ] ] = catherine.network.entityVars[ data[ 1 ] ] or { }
		catherine.network.entityVars[ data[ 1 ] ][ data[ 2 ] ] = data[ 3 ]
	end )
	
	netstream.Hook( "catherine.network.SetNetGlobalVar", function( data )
		catherine.network.globalVars[ data[ 1 ] ] = data[ 2 ]
	end )

	netstream.Hook( "catherine.network.ClearNetVar", function( data )
		catherine.network.entityVars[ data ] = nil
	end )
	
	netstream.Hook( "catherine.network.ClearNetGlobalVar", function( data )
		catherine.network.globalVars[ data ] = nil
	end )
	
	netstream.Hook( "catherine.network.SyncAllVars", function( data )
		catherine.network.entityVars = data[ 1 ]
		catherine.network.globalVars = data[ 2 ]
	end )
	
	function catherine.network.GetNetVar( ent, key, default )
		local data = ent:EntIndex( )
		
		if ( ent:IsPlayer( ) ) then
			data = ent:SteamID( )
		end
		
		return catherine.network.entityVars[ data ] and catherine.network.entityVars[ data ][ key ] or default
	end
end

function catherine.network.GetNetGlobalVar( key, default )
	return catherine.network.globalVars[ key ] or default
end

function META:GetNetVar( key, default )
	return catherine.network.GetNetVar( self, key, default )
end