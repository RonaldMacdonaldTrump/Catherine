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
--[[ Catherine Anti HaX Version 3.0 : Last Update 2015-07-24 ]]--

if ( !catherine.configs.enable_AntiHaX ) then return end

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
		local playerAll = player.GetAll( )
		local playerAllCount = #playerAll
		local i = 0
		local nextCheck = CurTime( ) + 0.05
		
		for k, v in pairs( playerAll ) do
			if ( !IsValid( v ) or !v:IsPlayer( ) ) then
				playerAllCount = playerAllCount - 1
				continue
			end
			
			receiveData[ v ] = {
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
		netstream.Start( nil, "catherine.antiHaX.CheckRequest" )

		hook.Remove( "Think", "catherine.antiHaX.Work.TimeOutChecker" )
		hook.Add( "Think", "catherine.antiHaX.Work.TimeOutChecker", function( )
			if ( !startTimeOutChecker or !catherine.antiHaX.doing ) then return end
			
			if ( nextCheck <= CurTime( ) ) then
				for k, v in pairs( playerAll ) do
					if ( IsValid( v ) and receiveData[ v ] and receiveData[ v ].fin == true ) then
						local isHack = false
						local steamName, steamID = v:SteamName( ), v:SteamID( )

						if ( receiveData[ v ].sendTime - SysTime( ) >= 15 ) then
							local kickMessage = LANG( v, "AntiHaX_KickMessage_TimeOut" )
							
							MsgC( Color( 255, 255, 0 ), "[CAT AntiHaX] Kicked time out player.[" .. steamName .. "/" .. steamID	.. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked time out player.[" .. steamName .. "/" .. steamID	.. "]", true )
							v:Kick( kickMessage )
							receiveData[ v ] = nil
							continue
						end
						
						if ( serverCheat != receiveData[ v ].clientFetch.cheat ) then
							MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] WARNING !!! : sv_cheats mismatch found !!![" .. steamName .. "/" .. steamID .. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_cheats mismatch found !!![" .. steamName .. "/" .. steamID .. "]", true )
							isHack = true
						end
						
						if ( serverCSLua != receiveData[ v ].clientFetch.csLua ) then
							MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] WARNING !!! : sv_allowcslua mismatch found !!![" .. steamName .. "/" .. steamID .. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_allowcslua mismatch found !!![" .. steamName .. "/" .. steamID .. "]", true )
							isHack = true
						end
						
						if ( isHack ) then
							local kickMessage = LANG( v, "AntiHaX_KickMessage" )
							
							MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] Kicked hack player.[" .. steamName .. "/" .. steamID	.. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked hack player.[" .. steamName .. "/" .. steamID	.. "]", true )
							v:Kick( kickMessage )
							receiveData[ v ] = nil
							continue
						else
							receiveData[ v ] = nil
						end
					end
				end
				
				nextCheck = CurTime( ) + 0.05
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
		if ( !catherine.configs.enable_AntiHaX or catherine.antiHaX.doing ) then return end
		
		if ( catherine.antiHaX.NextCheckTick <= CurTime( ) ) then
			MsgC( Color( 255, 0, 0 ), "[CAT AntiHaX] Checking the players ...\n" )
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