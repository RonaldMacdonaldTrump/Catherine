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

catherine.catData = catherine.catData or { networkRegistry = { } }

if ( SERVER ) then
	function catherine.catData.SetVar( pl, key, value, noSync, save )
		local steamID = pl.SteamID( pl )
		
		catherine.catData.networkRegistry[ steamID ] = catherine.catData.networkRegistry[ steamID ] or { }
		catherine.catData.networkRegistry[ steamID ][ key ] = value
		
		if ( !noSync ) then
			catherine.netXync.Send( pl, "catherine.catData.SetVar", { key, value } )
		end
		
		if ( save ) then
			catherine.catData.Save( pl )
		end
	end

	function catherine.catData.GetVar( pl, key, default )
		local steamID = pl.SteamID( pl )
		
		return catherine.catData.networkRegistry[ steamID ] and catherine.catData.networkRegistry[ steamID ][ key ] or default
	end
	
	function catherine.catData.Save( pl )
		local steamID = pl.SteamID( pl )
		if ( !catherine.catData.networkRegistry[ steamID ] ) then return end
		
		catherine.database.UpdateDatas( "catherine_players", "_steamID = '" .. steamID .. "'", {
			_catData = util.TableToJSON( catherine.catData.networkRegistry[ steamID ] )
		} )
	end
	
	function catherine.catData.SyncToPlayer( pl )
		local steamID = pl.SteamID( pl )
		
		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. steamID .. "'", function( data )
			if ( !data ) then return end
			
			catherine.catData.networkRegistry[ steamID ] = util.JSONToTable( data[ 1 ][ "_catData" ] )
			catherine.netXync.Send( pl, "catherine.catData.Sync", catherine.catData.networkRegistry[ steamID ] )
		end )
	end

	function catherine.catData.PlayerDisconnected( pl )
		catherine.catData.Save( pl )
		catherine.catData.networkRegistry[ pl.SteamID( pl ) ] = nil
	end
	
	hook.Add( "PlayerDisconnected", "catherine.catData.PlayerDisconnected", catherine.catData.PlayerDisconnected )
else
	catherine.netXync.Receiver( "catherine.catData.SetVar", function( data )
		catherine.catData.networkRegistry[ data[ 1 ] ] = data[ 2 ]
	end )
	
	catherine.netXync.Receiver( "catherine.catData.Clear", function( data )
		catherine.catData.networkRegistry[ data ] = nil
	end )
	
	catherine.netXync.Receiver( "catherine.catData.Sync", function( data )
		catherine.catData.networkRegistry = data
	end )
	
	function catherine.catData.GetVar( key, default )
		return catherine.catData.networkRegistry[ key ] or default
	end
end