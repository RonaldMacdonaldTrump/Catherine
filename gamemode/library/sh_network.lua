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

catherine.network = catherine.network or { globalRegistry = { }, entityRegistry = { } }
local META = FindMetaTable( "Entity" )
local META2 = FindMetaTable( "Player" )
// 네트워킹 시스템; ^-^; 2015-03-10 학교 컴실에서.. // 이전
// 새로운 네트워킹 시스템; ^-^; 2015-04-09 집에서..

if ( SERVER ) then
	catherine.network.NextOptimizeTick = catherine.network.NextOptimizeTick or CurTime( ) + catherine.configs.netRegistryOptimizeInterval

	function catherine.network.SetNetVar( ent, key, value, noSync )
		catherine.network.entityRegistry[ ent ] = catherine.network.entityRegistry[ ent ] or { }
		catherine.network.entityRegistry[ ent ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.network.SetNetVar", { ent:IsPlayer( ) and ent:SteamID( ) or ent:EntIndex( ), key, value } )
		end
	end
	
	function catherine.network.GetNetVar( ent, key, default )
		return catherine.network.entityRegistry[ ent ] and catherine.network.entityRegistry[ ent ][ key ] or default
	end
	
	function catherine.network.SetNetGlobalVar( key, value, noSync )
		catherine.network.globalRegistry[ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.network.SetNetGlobalVar", { key, value } )
		end
	end

	function catherine.network.SyncAllVars( pl )
		local convert = { }
		
		for k, v in pairs( catherine.network.entityRegistry ) do
			if ( !IsValid( k ) ) then continue end
			
			convert[ k:IsPlayer( ) and k:SteamID( ) or k:EntIndex( ) ] = v
		end

		netstream.Start( pl, "catherine.network.SyncAllVars", { convert, catherine.network.globalRegistry } )
	end
	
	function catherine.network.NetworkRegistryOptimize( )
		for k, v in pairs( catherine.network.entityRegistry ) do
			if ( IsValid( k ) ) then continue end
			
			catherine.network.entityRegistry[ k ] = nil
		end
		
		catherine.network.SyncAllVars( )
	end

	function META:SetNetVar( key, value, noSync )
		catherine.network.SetNetVar( self, key, value, noSync )
	end
	
	META2.SetNetVar = META.SetNetVar
	
	function catherine.network.Think( )
		if ( catherine.network.NextOptimizeTick <= CurTime( ) ) then
			catherine.network.NetworkRegistryOptimize( )
			
			catherine.network.NextOptimizeTick = CurTime( ) + catherine.configs.netRegistryOptimizeInterval
		end
	end
	
	function catherine.network.EntityRemoved( ent )
		catherine.network.entityRegistry[ ent ] = nil
		netstream.Start( nil, "catherine.network.ClearNetVar", ent:EntIndex( ) )
	end
	
	function catherine.network.PlayerDisconnected( pl )
		catherine.network.entityRegistry[ pl ] = nil
		netstream.Start( nil, "catherine.network.ClearNetVar", pl:SteamID( ) )
	end

	hook.Add( "Think", "catherine.network.Think", catherine.network.Think )
	hook.Add( "EntityRemoved", "catherine.network.EntityRemoved", catherine.network.EntityRemoved )
	hook.Add( "PlayerDisconnected", "catherine.network.PlayerDisconnected", catherine.network.PlayerDisconnected )
else
	netstream.Hook( "catherine.network.SetNetVar", function( data )
		local steamID = data[ 1 ]
		
		catherine.network.entityRegistry[ steamID ] = catherine.network.entityRegistry[ steamID ] or { }
		catherine.network.entityRegistry[ steamID ][ data[ 2 ] ] = data[ 3 ]
	end )
	
	netstream.Hook( "catherine.network.SetNetGlobalVar", function( data )
		catherine.network.globalRegistry[ data[ 1 ] ] = data[ 2 ]
	end )

	netstream.Hook( "catherine.network.ClearNetVar", function( data )
		catherine.network.entityRegistry[ data ] = nil
	end )
	
	netstream.Hook( "catherine.network.ClearNetGlobalVar", function( data )
		catherine.network.globalRegistry[ data ] = nil
	end )
	
	netstream.Hook( "catherine.network.SyncAllVars", function( data )
		catherine.network.entityRegistry = data[ 1 ]
		catherine.network.globalRegistry = data[ 2 ]
	end )
	
	function catherine.network.GetNetVar( ent, key, default )
		local data = ent:IsPlayer( ) and ent:SteamID( ) or ent:EntIndex( )
		
		return catherine.network.entityRegistry[ data ] and catherine.network.entityRegistry[ data ][ key ] or default
	end
end

function catherine.network.GetNetGlobalVar( key, default )
	return catherine.network.globalRegistry[ key ] or default
end

function META:GetNetVar( key, default )
	return catherine.network.GetNetVar( self, key, default )
end