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

catherine.catData = catherine.catData or { networkingVars = { } }

if ( SERVER ) then
	function catherine.catData.Set( pl, key, value, nosync, save )
		if ( !IsValid( pl ) or !key ) then return end
		catherine.catData.networkingVars[ pl:SteamID( ) ] = catherine.catData.networkingVars[ pl:SteamID( ) ] or { }
		catherine.catData.networkingVars[ pl:SteamID( ) ][ key ] = value
		if ( !nosync ) then netstream.Start( pl, "catherine.catData.Set", { key, value } ) end
		if ( save ) then catherine.catData.Save( pl ) end
	end

	function catherine.catData.Get( pl, key, default )
		if ( !IsValid( pl ) or !key or !catherine.catData.networkingVars[ pl:SteamID( ) ] ) then return default end
		return catherine.catData.networkingVars[ pl:SteamID( ) ][ key ] or default
	end
	
	function catherine.catData.Save( pl )
		if ( !IsValid( pl ) or !catherine.catData.networkingVars[ pl:SteamID( ) ] ) then return end
		catherine.database.UpdateDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", {
			_catData = util.TableToJSON( catherine.catData.networkingVars[ pl:SteamID( ) ] )
		} )
	end
	
	function catherine.catData.Load( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
			if ( #data == 0 ) then return end
			catherine.catData.networkingVars[ pl:SteamID( ) ] = util.JSONToTable( data[ 1 ][ "_catData" ] )
			catherine.catData.Sync( pl )
		end )
	end
	
	function catherine.catData.Sync( pl )
		if ( !IsValid( pl ) or !catherine.catData.networkingVars[ pl:SteamID( ) ] ) then return end
		netstream.Start( pl, "catherine.catData.Sync", catherine.catData.networkingVars[ pl:SteamID( ) ] )
	end

	function catherine.catData.PlayerDisconnected( pl )
		catherine.catData.Save( pl )
		catherine.catData.networkingVars[ pl:SteamID( ) ] = nil
	end
	
	hook.Add( "PlayerDisconnected", "catherine.catData.PlayerDisconnected", catherine.catData.PlayerDisconnected )
else
	function catherine.catData.Get( key, default )
		return catherine.catData.networkingVars[ key ] or default
	end

	netstream.Hook( "catherine.catData.Set", function( data )
		catherine.catData.networkingVars[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.catData.Sync", function( data )
		catherine.catData.networkingVars = data
	end )
end