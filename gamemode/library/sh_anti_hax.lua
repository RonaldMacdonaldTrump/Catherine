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
	catherine.antiHaX.masterData = catherine.antiHaX.masterData or { }
	catherine.antiHaX.doing = catherine.antiHaX.doing or false
	catherine.antiHaX.NextCheckTick = catherine.antiHaX.NextCheckTick or CurTime( ) + catherine.configs.HaXCheckInterval
	
	function catherine.antiHaX.Work( )
		if ( catherine.antiHaX.doing ) then return end
		
		local masterData = {
			serverConfig = {
				cheat = GetConVarString( "sv_cheats" ),
				csLua = GetConVarString( "sv_allowcslua" )
			},
			receiveData = { },
			startTime = SysTime( )
		}
		local serverCheat = masterData.serverConfig.cheat
		local serverCSLua = masterData.serverConfig.csLua
		local receiveData = masterData.receiveData
		local startTimeOutChecker = false
		local playerAll = player.GetAllByLoaded( )
		local playerAllCount = #playerAll
		local i = 0
		
		for k, v in pairs( playerAll ) do
			if ( !IsValid( v ) or !v:IsPlayer( ) ) then
				playerAllCount = playerAllCount - 1
				continue
			end
			
			receiveData[ v ] = {
				serverFetch = {
					cheat = v:GetInfo( "sv_cheats" ),
					csLua = v:GetInfo( "sv_allowcslua" )
				},
				clientFetch = { },
				sendTime = SysTime( ),
				fin = false
			}

			i = i + 1
			
			if ( i >= playerAllCount ) then
				startTimeOutChecker = true
			end
		end
		
		catherine.antiHaX.masterData = masterData
		catherine.antiHaX.doing = true
		netstream.Start( playerAll, "catherine.antiHaX.CheckRequest" )
		
		hook.Remove( "Think", "catherine.antiHaX.Work.TimeOutChecker" )
		hook.Add( "Think", "catherine.antiHaX.Work.TimeOutChecker", function( )
			if ( !startTimeOutChecker or !catherine.antiHaX.doing ) then return end
			
			for k, v in pairs( playerAll ) do
				if ( receiveData[ v ] and receiveData[ v ].fin == true ) then
					local isHack = false
					
					if ( receiveData[ v ].sendTime - SysTime( ) >= 15 ) then
						local kickMessage = LANG( v, "AntiHaX_KickMessage_TimeOut" )
						
						MsgC( Color( 255, 255, 0 ), "[CAT AntiHaX] Kicked time out player.[" .. pl:SteamName( ) .. "/" .. pl:SteamID( )	.. "]\n" )
						catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked time out player.[" .. pl:SteamName( ) .. "/" .. pl:SteamID( )	.. "]", true )
						pl:Kick( kickMessage )
						receiveData[ v ] = nil
						continue
					end
					
					if ( serverCheat != receiveData[ v ].serverFetch.cheat or serverCheat != receiveData[ v ].clientFetch.cheat ) then
						MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] WARNING !!! : sv_cheats mismatch found !!![" .. pl:SteamName( ) .. "/" .. pl:SteamID( ) .. "]\n" )
						catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_cheats mismatch found !!![" .. pl:SteamName( ) .. "/" .. pl:SteamID( ) .. "]", true )
						isHack = true
					end
					
					if ( serverCSLua != receiveData[ v ].serverFetch.csLua or serverCSLua != receiveData[ v ].clientFetch.csLua ) then
						MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] WARNING !!! : sv_allowcslua mismatch found !!![" .. pl:SteamName( ) .. "/" .. pl:SteamID( ) .. "]\n" )
						catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_allowcslua mismatch found !!![" .. pl:SteamName( ) .. "/" .. pl:SteamID( ) .. "]", true )
						isHack = true
					end
					
					if ( isHack ) then
						local kickMessage = LANG( v, "AntiHaX_KickMessage" )
						
						MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] Kicked hack player.[" .. pl:SteamName( ) .. "/" .. pl:SteamID( )	.. "]\n" )
						catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked hack player.[" .. pl:SteamName( ) .. "/" .. pl:SteamID( )	.. "]", true )
						pl:Kick( kickMessage )
						receiveData[ v ] = nil
						continue
					else
						receiveData[ v ] = nil
					end
				end
			end
			
			if ( table.Count( receiveData ) == 0 ) then
				MsgC( Color( 0, 255, 0 ), "[CAT AntiHaX] Finished progress.\n" )
				hook.Remove( "Think", "catherine.antiHaX.Work.TimeOutChecker" )
				catherine.antiHaX.masterData = { }
				catherine.antiHaX.doing = false
			elseif ( masterData.startTime - SysTime( ) >= 50 ) then
				MsgC( Color( 255, 255, 0 ), "[CAT AntiHaX] Checking progress has timed out.\n" )
				hook.Remove( "Think", "catherine.antiHaX.Work.TimeOutChecker" )
				catherine.antiHaX.masterData = { }
				catherine.antiHaX.doing = false
			end
		end )
	end
	
	function catherine.antiHaX.Think( )
		if ( !catherine.configs.enable_AntiHaX ) then return end
		
		if ( !catherine.antiHaX.doing and catherine.antiHaX.NextCheckTick <= CurTime( ) ) then
			catherine.antiHaX.Work( )
			
			catherine.antiHaX.NextCheckTick = CurTime( ) + catherine.configs.HaXCheckInterval
		end
	end
	
	hook.Add( "Think", "catherine.antiHaX.Think", catherine.antiHaX.Think )
	
	netstream.Hook( "catherine.antiHaX.CheckRequest_Receive", function( pl, data )
		if ( !catherine.antiHaX.doing ) then return end
		local masterData = catherine.antiHaX.masterData
		
		masterData.receiveData[ pl ].clientFetch = {
			cheat = data[ 1 ],
			csLua = data[ 2 ]
		}
		masterData.receiveData[ pl ].fin = true
		
		catherine.antiHaX.masterData = masterData
	end )
else
	netstream.Hook( "catherine.antiHaX.CheckRequest", function( )
		netstream.Start( "catherine.antiHaX.CheckRequest_Receive", {
			GetConVarString( "sv_cheats" ),
			GetConVarString( "sv_allowcslua" )
		} )
	end )
end

/* // Old Version :)
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
					MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] WARNING !!! : sv_cheats mismatch found !!![" .. pl:SteamName( ) .. "/" .. pl:SteamID( ) .. "]\n" )
					catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_cheats mismatch found !!![" .. pl:SteamName( ) .. "/" .. pl:SteamID( ) .. "]", true )
					hax = true
				end
				
				if ( serverConVars.csLua != v.csLua ) then
					MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] WARNING !!! : sv_allowcslua mismatch found !!![" .. pl:SteamName( ) .. "/" .. pl:SteamID( ) .. "]\n" )
					catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_allowcslua mismatch found !!![" .. pl:SteamName( ) .. "/" .. pl:SteamID( ) .. "]", true )
					hax = true
				end

				if ( hax ) then
					MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] Kicked hack player.[" .. pl:SteamName( ) .. "/" .. pl:SteamID( )	.. "]\n" )
					catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked hack player.[" .. pl:SteamName( ) .. "/" .. pl:SteamID( )	.. "]", true )
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
*/