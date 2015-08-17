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

--[[ Catherine Lime 4.0 : Last Update 2015-08-17 ]]--

if ( !catherine.configs.enable_Lime ) then return end

local xC = [[
if ( timer.Exists( "Catherine.lime.timer.CheckSystem" ) ) then
	timer.Pause( "Catherine.lime.timer.CheckSystem" )
end

catherine.lime = catherine.lime or { libVersion = "2015-08-17" }

if ( SERVER ) then
	catherine.lime.masterData = catherine.lime.masterData or { }
	catherine.lime.doing = catherine.lime.doing or false
	catherine.lime.NextCheckTick = catherine.lime.NextCheckTick or CurTime( ) + catherine.configs.limeCheckInterval

	function catherine.lime.Work( )
		if ( catherine.lime.doing ) then return end
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
		
		if ( playerAllCount == 0 ) then
			MsgC( Color( 0, 255, 0 ), "[CAT Lime] No players.\n" )
			return
		end
		
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

		catherine.lime.masterData = masterData
		catherine.lime.doing = true
		netstream.Start( nil, "catherine.lime.CheckRequest" )

		hook.Remove( "Think", "catherine.lime.Work.TimeOutChecker" )
		hook.Add( "Think", "catherine.lime.Work.TimeOutChecker", function( )
			if ( !startTimeOutChecker or !catherine.lime.doing ) then return end
			
			if ( nextCheck <= CurTime( ) ) then
				for k, v in pairs( playerAll ) do
					if ( IsValid( v ) and receiveData[ v ] and receiveData[ v ].fin == true ) then
						local isHack = false
						local steamName, steamID = v:SteamName( ), v:SteamID( )

						if ( receiveData[ v ].sendTime - SysTime( ) >= 15 ) then
							local kickMessage = LANG( v, "AntiHaX_KickMessage_TimeOut" )
							
							MsgC( Color( 255, 255, 0 ), "[CAT Lime] Kicked time out player.[" .. steamName .. "/" .. steamID	.. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked time out player.[" .. steamName .. "/" .. steamID .. "]", true )
							v:Kick( kickMessage )
							receiveData[ v ] = nil
							continue
						end
						
						if ( serverCheat != receiveData[ v ].clientFetch.cheat ) then
							MsgC( Color( 255, 0, 0 ), "[CAT Lime] WARNING !!! : sv_cheats mismatch found !!![" .. steamName .. "/" .. steamID .. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_cheats mismatch found !!![" .. steamName .. "/" .. steamID .. "]", true )
							isHack = true
						end
						
						if ( serverCSLua != receiveData[ v ].clientFetch.csLua ) then
							MsgC( Color( 255, 0, 0 ), "[CAT Lime] WARNING !!! : sv_allowcslua mismatch found !!![" .. steamName .. "/" .. steamID .. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_allowcslua mismatch found !!![" .. steamName .. "/" .. steamID .. "]", true )
							isHack = true
						end
						
						if ( isHack ) then
							local kickMessage = LANG( v, "AntiHaX_KickMessage" )
							
							MsgC( Color( 255, 0, 0 ), "[CAT Lime] Kicked hack player.[" .. steamName .. "/" .. steamID .. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked hack player.[" .. steamName .. "/" .. steamID .. "]", true )
							
							for k, v in pairs( catherine.util.GetAdmins( ) ) do
								catherine.util.NotifyLang( v, "AntiHaX_KickMessageNotifyAdmin", steamName, steamID )
								v:ChatPrint( LANG( v, "AntiHaX_KickMessageNotifyAdmin", steamName, steamID ) )
							end
							
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
				MsgC( Color( 0, 255, 0 ), "[CAT Lime] Finished progress.\n" )
				hook.Remove( "Think", "catherine.lime.Work.TimeOutChecker" )
				catherine.lime.masterData = { }
				catherine.lime.doing = false
			elseif ( masterData.startTime - SysTime( ) >= 50 ) then
				MsgC( Color( 255, 255, 0 ), "[CAT Lime] Checking progress has timed out.\n" )
				hook.Remove( "Think", "catherine.lime.Work.TimeOutChecker" )
				catherine.lime.masterData = { }
				catherine.lime.doing = false
			end
		end )
	end

	function catherine.lime.Think( )
		if ( !catherine.configs.enable_Lime or catherine.lime.doing ) then return end
		
		if ( catherine.lime.NextCheckTick <= CurTime( ) ) then
			MsgC( Color( 255, 255, 0 ), "[CAT Lime] Checking the players ...\n" )
			catherine.lime.Work( )
			
			catherine.lime.NextCheckTick = CurTime( ) + catherine.configs.limeCheckInterval
		end
	end
	
	hook.Add( "Think", "catherine.lime.Think", catherine.lime.Think )

	netstream.Hook( "catherine.lime.CheckRequest_Receive", function( pl, data )
		if ( !catherine.lime.doing ) then return end
		local masterData = catherine.lime.masterData
		
		masterData.receiveData[ pl ].clientFetch = {
			cheat = data[ 1 ],
			csLua = data[ 2 ]
		}
		masterData.receiveData[ pl ].fin = true

		catherine.lime.masterData = masterData
	end )
else
	netstream.Hook( "catherine.lime.CheckRequest", function( )
		netstream.Start( "catherine.lime.CheckRequest_Receive", {
			GetConVarString( "sv_cheats" ),
			GetConVarString( "sv_allowcslua" )
		} )
	end )
end

if ( timer.Exists( "Catherine.lime.timer.CheckSystem" ) ) then
	timer.Start( "Catherine.lime.timer.CheckSystem" )
end
]]

do
	RunString( xC )
	RunString( [[
	catherine.lime.XCode = catherine.lime.XCode or "CVX" .. math.random( 10000, 99999 )
	_G[ catherine.lime.XCode ] = _G[ catherine.lime.XCode ] or GetConVarString
	
	function GetConVarString( cv )
		return _G[ catherine.lime.XCode ]( cv )
	end

	local g = {
		"libVersion",
		"masterData",
		"doing",
		"NextCheckTick",
		"Work",
		"Think"
	}
	
	timer.Remove( "Catherine.lime.timer.CheckSystem" )
	timer.Create( "Catherine.lime.timer.CheckSystem", 10, 0, function( )
		if ( catherine.configs.enable_Lime ) then
			if ( !catherine.lime ) then
				RunString( xC )
				return
			end
			
			if ( SERVER ) then
				for k, v in pairs( g ) do
					if ( catherine.lime[ v ] == nil ) then
						RunString( xC )
						return
					end
				end
			end
		end
	end )
	]] )
end