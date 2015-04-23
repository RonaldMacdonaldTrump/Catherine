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
// 버그가 많음;
catherine.environment = catherine.environment or { buffer = catherine.configs.defaultRPInformation }
catherine.environment.TimeTick = CurTime( ) + 0.2
local monthLen = {
	31,
	28,
	31,
	30,
	31,
	30,
	31,
	31,
	30,
	31,
	30,
	31
}

function catherine.environment.GetDateString( )
	local d = catherine.environment.buffer
	local t = "AM"
	
	if ( d.hour >= 12 ) then
		t = "PM"
	end
	
	return Format( "%s-%s-%s", d.year, d.month, d.day )
end

function catherine.environment.GetTemperatureString( )
	return catherine.environment.buffer.temperature .. " ℃"
end

function catherine.environment.GetTimeString( )
	local d = table.Copy( catherine.environment.buffer )
	local t = "AM"
	
	if ( d.hour >= 12 ) then
		t = "PM"
	end
	
	if ( #tostring( d.minute ) == 1 ) then
		d.minute = "0" .. d.minute
	end
	
	return Format( "%s %s:%s", t, d.hour, d.minute )
end

if ( SERVER ) then
	catherine.environment.SyncTick = catherine.environment.SyncTick or CurTime( ) + 60
	catherine.environment.TemperatureTick = catherine.environment.TemperatureTick or CurTime( )
	catherine.environment.currentLightFlag = catherine.environment.currentLightFlag or nil

	function catherine.environment.Work( )
		if ( catherine.environment.TimeTick <= CurTime( ) ) then
			local d = catherine.environment.buffer
			if ( !d.second ) then
				catherine.util.ErrorPrint( "catherine.environment.Work has error!" )
				return
			end
			
			d.second = d.second + 1
			
			if ( d.second >= 60 ) then
				d.minute = d.minute + 1
				d.second = 0
			end
			
			if ( d.minute >= 60 ) then
				d.hour = d.hour + 1
				d.minute = 0
				catherine.environment.AutomaticDayNight( )
			end
			
			if ( d.hour >= 25 ) then
				d.day = d.day + 1
				d.hour = 1
			end
			
			if ( d.day >= monthLen[ d.month ] ) then
				d.month = d.month + 1
				d.day = 1
			end
			
			if ( d.month > 12 ) then
				d.year = d.year + 1
				d.month = 1
			end

			catherine.environment.TimeTick = CurTime( ) + 0.2
		end
		
		if ( catherine.environment.TemperatureTick <= CurTime( ) ) then
			local nextTick = math.random( 60, 200 )
			
			catherine.environment.buffer.temperature = catherine.environment.CalcTemperature( )

			catherine.environment.SendTemperatureToAll( )
			catherine.environment.TemperatureTick = CurTime( ) + nextTick
		end
		
		if ( catherine.environment.SyncTick <= CurTime( ) ) then
			catherine.environment.SyncToAll( )
			catherine.environment.SyncTick = CurTime( ) + 60
		end
	end

	function catherine.environment.GetLightDataByHour( )
		local hour = catherine.environment.GetHour( )
		local lightDatas = {
			[ 1 ] = { // AM 1
				lightStyle = "b",
				skyColors = {
					top = Vector( 0, 0, 0 ),
					bottom = Vector( 0, 0, 0 )
				}
			},
			[ 2 ] = { // AM 2
				lightStyle = "b",
				skyColors = {
					top = Vector( 0, 0.001, 0.001 ),
					bottom = Vector( 0, 0, 0 )
				}
			},
			[ 3 ] = { // AM 3
				lightStyle = "b",
				skyColors = {
					top = Vector( 0, 0.005, 0.005 ),
					bottom = Vector( 0, 0, 0 )
				}
			},
			[ 4 ] = { // AM 4
				lightStyle = "c",
				skyColors = {
					top = Vector( 0, 0.005, 0.005 ),
					bottom = Vector( 0, 0, 0 )
				}
			},
			[ 5 ] = { // AM 5
				sun = true,
				lightStyle = "d",
				skyColors = {
					top = Vector( 0.45, 0.55, 1 ),
					bottom = Vector( 0.91, 0.64, 0.05 )
				}
			},
			[ 6 ] = { // AM 6
				sun = true,
				lightStyle = "f",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 7 ] = { // AM 7
				sun = true,
				lightStyle = "g",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 8 ] = { // AM 8
				sun = true,
				lightStyle = "h",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 9 ] = { // AM 9
				sun = true,
				lightStyle = "i",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 10 ] = { // AM 10
				sun = true,
				lightStyle = "j",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 11 ] = { // AM 11
				sun = true,
				lightStyle = "k",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 12 ] = { // AM 12
				sun = true,
				lightStyle = "l",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 13 ] = { // PM 1
				sun = true,
				lightStyle = "m",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 14 ] = { // PM 2
				sun = true,
				lightStyle = "n",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 15 ] = { // PM 3
				sun = true,
				lightStyle = "o",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 16 ] = { // PM 4
				sun = true,
				lightStyle = "p",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 17 ] = { // PM 5
				sun = true,
				lightStyle = "n",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 18 ] = { // PM 6
				sun = true,
				lightStyle = "j",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 19 ] = { // PM 7
				sun = true,
				lightStyle = "f",
				skyColors = {
					top = Vector( 0.24, 0.61, 1 ),
					bottom = Vector( 0.4, 0.8, 1 )
				}
			},
			[ 20 ] = { // PM 8
				lightStyle = "c",
				skyColors = {
					top = Vector( 0, 0.01, 0.02 ),
					bottom = Vector( 0, 0, 0 )
				}
			},
			[ 21 ] = { // PM 9
				lightStyle = "c",
				skyColors = {
					top = Vector( 0, 0.01, 0.02 ),
					bottom = Vector( 0, 0, 0 )
				}
			},
			[ 22 ] = { // PM 10
				lightStyle = "c",
				skyColors = {
					top = Vector( 0, 0.01, 0.02 ),
					bottom = Vector( 0, 0, 0 )
				}
			},
			[ 23 ] = { // PM 11
				lightStyle = "b",
				skyColors = {
					top = Vector( 0, 0.01, 0.02 ),
					bottom = Vector( 0, 0, 0 )
				}
			},
			[ 24 ] = { // PM 12
				lightStyle = "b",
				skyColors = {
					top = Vector( 0, 0.01, 0.02 ),
					bottom = Vector( 0, 0, 0 )
				}
			},
			[ 25 ] = { // AM 1
				lightStyle = "b",
				skyColors = {
					top = Vector( 0, 0.01, 0.02 ),
					bottom = Vector( 0, 0, 0 )
				}
			}
		}
		
		return lightDatas[ hour ]
	end
	
	function catherine.environment.GetHour( )
		return catherine.environment.buffer.hour or 1
	end
	
	function catherine.environment.GetTemperature( )
		return catherine.environment.buffer.temperature or 30
	end

	function catherine.environment.AutomaticDayNight( )
		local dayNightData = catherine.environment.GetLightDataByHour( )
		if ( !dayNightData ) then return end
		
		local Sun = ents.FindByClass( "env_sun" )[ 1 ]
		local SkyPaint = ents.FindByClass( "env_skypaint" )[ 1 ]
		
		if ( IsValid( Sun ) ) then
			Sun:Fire( dayNightData.sun == true and "TurnOn" or "TurnOff" )
		end
		
		if ( !IsValid( SkyPaint ) ) then
			SkyPaint = ents.Create( "env_skypaint" )
			SkyPaint:Spawn( )
			SkyPaint:Activate( )
		end

		SkyPaint:SetTopColor( dayNightData.skyColors.top )
		SkyPaint:SetBottomColor( dayNightData.skyColors.bottom )

		catherine.environment.SetLightFlag( dayNightData.lightStyle )
	end

	function catherine.environment.SetLightFlag( flag )
		engine.LightStyle( 0, flag )
		catherine.netXync.Send( nil, "catherine.environment.SetLightFlag" )
	end
	
	function catherine.environment.CalcTemperature( )
		local temp = catherine.environment.GetTemperature( )
		local bomb = math.random( 1, 100 )
		
		if ( bomb > 95 ) then
			temp = temp + math.random( -10, 10 )
		else
			temp = temp + math.random( -5, 5 )
		end

		return math.Clamp( temp, 0, 35 )
	end

	function catherine.environment.SyncToPlayer( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.netXync.Send( pl, "catherine.environment.Sync", catherine.environment.buffer )
	end
	
	function catherine.environment.SendTemperatureToAll( )
		catherine.netXync.Send( nil, "catherine.environment.SendTemperatureToAll", catherine.environment.buffer.temperature )
	end
	
	function catherine.environment.SyncToAll( )
		catherine.netXync.Send( nil, "catherine.environment.Sync", catherine.environment.buffer )
	end

	function catherine.environment.DataSave( )
		catherine.data.Set( "environment", catherine.environment.buffer )
	end
	
	function catherine.environment.DataLoad( )
		local data = catherine.data.Get( "environment", { } )

		if ( table.Count( data ) != 7 ) then
			catherine.environment.buffer = catherine.configs.defaultRPInformation
		else
			catherine.environment.buffer = data
		end
		
		catherine.environment.AutomaticDayNight( )
	end

	hook.Add( "Think", "catherine.environment.Think", catherine.environment.Work )
	hook.Add( "DataSave", "catherine.environment.DataSave", catherine.environment.DataSave )
	hook.Add( "DataLoad", "catherine.environment.DataLoad", catherine.environment.DataLoad )
else
	catherine.netXync.Receiver( "catherine.environment.Sync", function( data )
		catherine.environment.buffer = data
	end )
	
	catherine.netXync.Receiver( "catherine.environment.SendTemperatureToAll", function( data )
		catherine.environment.buffer.temperature = data
	end )

	catherine.netXync.Receiver( "catherine.environment.SetLightFlag", function( )
		render.RedownloadAllLightmaps( )
	end )

	function catherine.environment.WorkClient( )
		if ( table.Count( catherine.environment.buffer ) != 7 ) then return end
		if ( catherine.environment.TimeTick <= CurTime( ) ) then
			local d = catherine.environment.buffer
			if ( !d.second ) then
				catherine.util.ErrorPrint( "catherine.environment.Work has error!" )
				return
			end
			
			d.second = d.second + 1
			
			if ( d.second >= 60 ) then
				d.minute = d.minute + 1
				d.second = 0
			end
			
			if ( d.minute >= 60 ) then
				d.hour = d.hour + 1
				d.minute = 0
			end
			
			if ( d.hour >= 25 ) then
				d.day = d.day + 1
				d.hour = 1
			end
			
			if ( d.day >= monthLen[ d.month ] ) then
				d.month = d.month + 1
				d.day = 1
			end
			
			if ( d.month > 12 ) then
				d.year = d.year + 1
				d.month = 1
			end

			catherine.environment.TimeTick = CurTime( ) + 0.2
		end
	end

	hook.Add( "Tick", "catherine.environment.WorkClient", catherine.environment.WorkClient )
end