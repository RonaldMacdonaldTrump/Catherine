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

catherine.net = catherine.net or { globalRegistry = { }, entityRegistry = { } }
local META = FindMetaTable( "Entity" )
local META2 = FindMetaTable( "Player" )
// 네트워킹 시스템; ^-^; 2015-03-10 학교 컴실에서.. // 이전
// 새로운 네트워킹 시스템; ^-^; 2015-04-09 집에서..

if ( SERVER ) then
	catherine.net.NextOptimizeTick = catherine.net.NextOptimizeTick or CurTime( ) + catherine.configs.netRegistryOptimizeInterval

	function catherine.net.SetNetVar( ent, key, value, noSync )
		catherine.net.entityRegistry[ ent ] = catherine.net.entityRegistry[ ent ] or { }
		catherine.net.entityRegistry[ ent ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetVar", { ent:IsPlayer( ) and ent:SteamID( ) or ent:EntIndex( ), key, value } )
		end
	end
	
	function catherine.net.GetNetVar( ent, key, default )
		return catherine.net.entityRegistry[ ent ] and catherine.net.entityRegistry[ ent ][ key ] or default
	end
	
	function catherine.net.SetNetGlobalVar( key, value, noSync )
		catherine.net.globalRegistry[ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetGlobalVar", { key, value } )
		end
	end

	function catherine.net.SyncAllVars( pl )
		local convert = { }
		
		for k, v in pairs( catherine.net.entityRegistry ) do
			if ( !IsValid( k ) ) then continue end
			
			convert[ k:IsPlayer( ) and k:SteamID( ) or k:EntIndex( ) ] = v
		end

		netstream.Start( pl, "catherine.net.SyncAllVars", { convert, catherine.net.globalRegistry } )
	end
	
	function catherine.net.NetworkRegistryOptimize( )
		for k, v in pairs( catherine.net.entityRegistry ) do
			if ( IsValid( k ) ) then continue end
			
			catherine.net.entityRegistry[ k ] = nil
		end
		
		catherine.net.SyncAllVars( )
	end

	function META:SetNetVar( key, value, noSync )
		catherine.net.SetNetVar( self, key, value, noSync )
	end
	
	META2.SetNetVar = META.SetNetVar
	
	function catherine.net.Think( )
		if ( catherine.net.NextOptimizeTick <= CurTime( ) ) then
			catherine.net.NetworkRegistryOptimize( )
			
			catherine.net.NextOptimizeTick = CurTime( ) + catherine.configs.netRegistryOptimizeInterval
		end
	end
	
	function catherine.net.EntityRemoved( ent )
		catherine.net.entityRegistry[ ent ] = nil
		netstream.Start( nil, "catherine.net.ClearNetVar", ent:EntIndex( ) )
	end
	
	function catherine.net.PlayerDisconnectedInCharacter( pl )
		catherine.net.entityRegistry[ pl ] = nil
		netstream.Start( nil, "catherine.net.ClearNetVar", pl.SteamID( pl ) )
	end

	hook.Add( "Think", "catherine.net.Think", catherine.net.Think )
	hook.Add( "EntityRemoved", "catherine.net.EntityRemoved", catherine.net.EntityRemoved )
	hook.Add( "PlayerDisconnectedInCharacter", "catherine.net.PlayerDisconnectedInCharacter", catherine.net.PlayerDisconnectedInCharacter )
else
	netstream.Hook( "catherine.net.SetNetVar", function( data )
		local steamID = data[ 1 ]
		
		catherine.net.entityRegistry[ steamID ] = catherine.net.entityRegistry[ steamID ] or { }
		catherine.net.entityRegistry[ steamID ][ data[ 2 ] ] = data[ 3 ]
	end )
	
	netstream.Hook( "catherine.net.SetNetGlobalVar", function( data )
		catherine.net.globalRegistry[ data[ 1 ] ] = data[ 2 ]
	end )

	netstream.Hook( "catherine.net.ClearNetVar", function( data )
		catherine.net.entityRegistry[ data ] = nil
	end )
	
	netstream.Hook( "catherine.net.ClearNetGlobalVar", function( data )
		catherine.net.globalRegistry[ data ] = nil
	end )
	
	netstream.Hook( "catherine.net.SyncAllVars", function( data )
		catherine.net.entityRegistry = data[ 1 ]
		catherine.net.globalRegistry = data[ 2 ]
	end )
	
	function catherine.net.GetNetVar( ent, key, default )
		local data = ent.IsPlayer( ent ) and ent.SteamID( ent ) or ent.EntIndex( ent )
		
		return catherine.net.entityRegistry[ data ] and catherine.net.entityRegistry[ data ][ key ] or default
	end
end

function catherine.net.GetNetGlobalVar( key, default )
	return catherine.net.globalRegistry[ key ] or default
end

function META:GetNetVar( key, default )
	return catherine.net.GetNetVar( self, key, default )
end