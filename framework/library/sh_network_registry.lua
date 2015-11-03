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

if ( SERVER ) then
	function catherine.net.SetNetVar( ent, key, value, noSync )
		catherine.net.entityRegistry[ ent ] = catherine.net.entityRegistry[ ent ] or { }
		catherine.net.entityRegistry[ ent ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetVar", {
				ent:IsPlayer( ) and ent:SteamID( ) or ent:EntIndex( ),
				key,
				value
			} )
		end
	end
	
	function catherine.net.SetNetGlobalVar( key, value, noSync )
		catherine.net.globalRegistry[ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetGlobalVar", {
				key,
				value
			} )
		end
	end
	
	function META:SetNetVar( key, value, noSync )
		catherine.net.entityRegistry[ self ] = catherine.net.entityRegistry[ self ] or { }
		catherine.net.entityRegistry[ self ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetVar", {
				self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( ),
				key,
				value
			} )
		end
	end
	
	function META2:SetNetVar( key, value, noSync )
		catherine.net.entityRegistry[ self ] = catherine.net.entityRegistry[ self ] or { }
		catherine.net.entityRegistry[ self ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetVar", {
				self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( ),
				key,
				value
			} )
		end
	end
	
	function catherine.net.GetNetVar( ent, key, default )
		return catherine.net.entityRegistry[ ent ] and catherine.net.entityRegistry[ ent ][ key ] or default
	end
	
	function catherine.net.GetNetGlobalVar( key, default )
		return catherine.net.globalRegistry[ key ] or default
	end
	
	function META:GetNetVar( key, default )
		return catherine.net.entityRegistry[ self ] and catherine.net.entityRegistry[ self ][ key ] or default
	end
	
	function META2:GetNetVar( key, default )
		return catherine.net.entityRegistry[ self ] and catherine.net.entityRegistry[ self ][ key ] or default
	end
	
	function catherine.net.SendAllNetworkRegistries( pl )
		local convert = { }
		
		for k, v in pairs( catherine.net.entityRegistry ) do
			if ( !IsValid( k ) ) then continue end
			
			convert[ k:IsPlayer( ) and k:SteamID( ) or k:EntIndex( ) ] = v
		end
		
		netstream.Start( pl, "catherine.net.SendAllNetworkRegistries", {
			convert,
			catherine.net.globalRegistry
		} )
	end
	
	local function removeDummyInTable( tab )
		for k, v in pairs( tab ) do
			local keyType, valueType = type( k ), type( v )
			
			if ( ( keyType == "Entity" or keyType == "Player" ) and !IsValid( k ) ) then
				tab[ k ] = nil
			end
			
			if ( valueType == "table" ) then
				removeDummyInTable( v )
			else
				if ( ( valueType == "Entity" or valueType == "Player" ) and !IsValid( v ) ) then
					tab[ k ] = nil
				end
			end
		end
	end
	
	function catherine.net.RemoveDummy( send, pl )
		for k, v in pairs( catherine.net.entityRegistry ) do
			local keyType = type( k )
			
			if ( ( keyType == "Entity" or keyType == "Player" ) and !IsValid( k ) ) then
				catherine.net.entityRegistry[ k ] = nil
			end
			
			if ( type( v ) == "table" ) then
				removeDummyInTable( v )
			end
		end
		
		if ( send ) then
			catherine.net.SendAllNetworkRegistries( pl )
		end
	end
	
	timer.Remove( "Catherine.timer.net.AutoRemoveDummy" )
	timer.Create( "Catherine.timer.net.AutoRemoveDummy", catherine.configs.netRegistryOptimizeInterval, 0, function( )
		if ( table.Count( catherine.net.entityRegistry ) == 0 ) then return end
		
		catherine.net.RemoveDummy( true )
	end )
	
	function catherine.net.EntityRemoved( ent )
		catherine.net.entityRegistry[ ent ] = nil
		netstream.Start( nil, "catherine.net.ClearNetVar", ent:EntIndex( ) )
	end
	
	function catherine.net.PlayerDisconnected( pl )
		catherine.net.entityRegistry[ pl ] = nil
		netstream.Start( nil, "catherine.net.ClearNetVar", pl:SteamID( ) )
	end
	
	hook.Add( "EntityRemoved", "catherine.net.EntityRemoved", catherine.net.EntityRemoved )
	hook.Add( "PlayerDisconnected", "catherine.net.PlayerDisconnected", catherine.net.PlayerDisconnected )
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
	
	netstream.Hook( "catherine.net.SendAllNetworkRegistries", function( data )
		catherine.net.entityRegistry = data[ 1 ]
		catherine.net.globalRegistry = data[ 2 ]
	end )
	
	function catherine.net.GetNetVar( ent, key, default )
		local id = ent:IsPlayer( ) and ent:SteamID( ) or ent:EntIndex( )
		
		return catherine.net.entityRegistry[ id ] and catherine.net.entityRegistry[ id ][ key ] or default
	end
	
	function catherine.net.GetNetGlobalVar( key, default )
		return catherine.net.globalRegistry[ key ] or default
	end
	
	function META:GetNetVar( key, default )
		local id = self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( )
		
		return catherine.net.entityRegistry[ id ] and catherine.net.entityRegistry[ id ][ key ] or default
	end
	
	function META2:GetNetVar( key, default )
		local id = self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( )
		
		return catherine.net.entityRegistry[ id ] and catherine.net.entityRegistry[ id ][ key ] or default
	end
end