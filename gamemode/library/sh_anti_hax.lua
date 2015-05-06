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

catherine.antiHaX = catherine.antiHaX or { }

if ( SERVER ) then
	catherine.antiHaX.checkingList = catherine.antiHaX.checkingList or { }
	catherine.antiHaX.NextCheckTick = catherine.antiHaX.NextCheckTick or CurTime( ) + catherine.configs.HaXCheckInterval

	function catherine.antiHaX.Check( )
		local serverConVars = {
			cheat = GetConVarString( "sv_cheats" ),
			csLua = GetConVarString( "sv_allowcslua" )
		}
		local checkingPlayers = player.GetAll( )
		
		catherine.antiHaX.checkingList = {
			receive = { },
			data = {
				svConVars = serverConVars,
				players = checkingPlayers,
			}
		}
		
		for k, v in pairs( checkingPlayers ) do
			catherine.antiHaX.checkingList.receive[ v.SteamID( v ) ] = { }
		end

		netstream.Start( nil, "catherine.antiHaX.CheckProgress" )
		
		timer.Simple( 3, function( )
			for k, v in pairs( catherine.antiHaX.checkingList.receive ) do
				local pl = catherine.util.FindPlayerByStuff( "SteamID", k )
				if ( !IsValid( pl ) or pl.IsBot( pl ) ) then continue end
				local hax = false
				
				if ( serverConVars.cheat != v.cheat ) then
					MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] WARNING !!! : sv_cheats mismatch found !!![" .. pl.SteamName( pl ) .. "/" .. pl:SteamID( ) .. "]\n" )
					catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_cheats mismatch found !!![" .. pl.SteamName( pl ) .. "/" .. pl:SteamID( ) .. "]", true )
					hax = true
				end
				
				if ( serverConVars.csLua != v.csLua ) then
					MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] WARNING !!! : sv_allowcslua mismatch found !!![" .. pl.SteamName( pl ) .. "/" .. pl:SteamID( ) .. "]\n" )
					catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_allowcslua mismatch found !!![" .. pl.SteamName( pl ) .. "/" .. pl:SteamID( ) .. "]", true )
					hax = true
				end

				if ( hax ) then
					MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] Kicked hack player.[" .. pl.SteamName( pl ) .. "/" .. pl:SteamID( )	.. "]\n" )
					catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked hack player.[" .. pl.SteamName( pl ) .. "/" .. pl:SteamID( )	.. "]", true )
					pl:Kick( "[Catherine AntiHaX] Hack program used." )
					continue
				end
			end
			
			catherine.antiHaX.checkingList = { }
		end )
	end
	
	function catherine.antiHaX.Think( )
		if ( !catherine.configs.enable_AntiHaX ) then return end
		
		if ( catherine.antiHaX.NextCheckTick <= CurTime( ) ) then
			catherine.antiHaX.Check( )
			MsgC( Color( 0, 255, 0 ), "[CAT AntiHaX] Hack checked.\n" )
			
			catherine.antiHaX.NextCheckTick = CurTime( ) + catherine.configs.HaXCheckInterval
		end
	end

	hook.Add( "Think", "catherine.antiHaX.Think", catherine.antiHaX.Think )
	
	netstream.Hook( "catherine.antiHaX.CheckProgress_Receive", function( pl, data )
		catherine.antiHaX.checkingList.receive[ pl:SteamID( ) ] = data
	end )
else
	netstream.Hook( "catherine.antiHaX.CheckProgress", function( )
		netstream.Start( "catherine.antiHaX.CheckProgress_Receive", {
			cheat = GetConVarString( "sv_cheats" ),
			csLua = GetConVarString( "sv_allowcslua" )
		} )
	end )
end