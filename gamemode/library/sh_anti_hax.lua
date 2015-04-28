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
	catherine.antiHaX.NextCheckTick = catherine.antiHaX.NextCheckTick or CurTime( ) + 300
	
	
	function catherine.antiHaX.Check( )
		
		local serverConVars = {
			cheat = GetConVarString( "sv_cheats" ),
			csLua = GetConVarString( "sv_allowcslua" )
		}
		local checkingPlayers = player.GetAll( )
		
		catherine.antiHaX.checkingList.data = {
			svConVars = serverConVars,
			players = checkingPlayers,
			startTime = 0
		}
		
		for k, v in pairs( checkingPlayers ) do
			catherine.antiHaX.checkingList[ v.SteamID( v ) ] = { }
		end
		
		catherine.antiHaX.checkingList.data.startTime = CurTime( )
		netstream.Start( nil, "catherine.antiHaX.CheckProgress" )
	end
	
	function catherine.antiHaX.Think( )
		if ( catherine.antiHaX.NextCheckTick <= CurTime( ) ) then
			catherine.antiHaX.Check( )
			catherine.antiHaX.NextCheckTick = CurTime( ) + 300
		end
	end
	
	hook.Add( "Think", "catherine.antiHaX.Think", catherine.antiHaX.Think )
	
	netstream.Hook( "catherine.antiHaX.CheckProgress_Receive", function( pl, data )
		local checkingList = catherine.antiHaX.checkingList
		local svData = checkingList.data
		
		
	end )
else
	netstream.Hook( "catherine.antiHaX.CheckProgress", function( )
	
	end )
end