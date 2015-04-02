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

catherine.date = catherine.date or { }
catherine.date.Tick = CurTime( ) + 0.5
catherine.date.Buffer = catherine.date.Buffer or { }
catherine.date.MonthBuffer = catherine.date.MonthBuffer or {
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

catherine.date.Buffer = {
	year = 2016,
	month = 6,
	day = 1,
	hour = 6,
	minute = 5,
	second = 11
}

function catherine.date.GetDateString( )
	local d = catherine.date.Buffer
	local t = "AM"
	if ( d.hour >= 12 ) then t = "PM" end
	return Format( "%s-%s-%s", d.year, d.month, d.day )
end

function catherine.date.GetTimeString( )
	local d = table.Copy( catherine.date.Buffer )
	local t = "AM"
	if ( d.hour >= 12 ) then t = "PM" end
	if ( #tostring( d.minute ) == 1 ) then
		d.minute = "0" .. d.minute
	end
	return Format( "%s %s:%s", t, d.hour, d.minute )
end

if ( SERVER ) then
	catherine.date.NextSync = catherine.date.NextSync or CurTime( ) + 60
	catherine.date.currentLightFlag = catherine.date.currentLightFlag or nil

	function catherine.date.Work( )
		if ( catherine.date.Tick <= CurTime( ) ) then
			local d = catherine.date.Buffer
			d.second = d.second + 1
			
			if ( d.second >= 60 ) then
				d.minute = d.minute + 1
				d.second = 0
			end
			
			if ( d.minute >= 60 ) then
				d.hour = d.hour + 1
				d.minute = 0
				catherine.date.AutomaticDayNight( )
			end
			
			if ( d.hour >= 25 ) then
				d.day = d.day + 1
				d.hour = 1
			end
			
			if ( d.day >= catherine.date.MonthBuffer[ d.month ] ) then
				d.month = d.month + 1
				d.day = 1
			end
			
			if ( d.month > 12 ) then
				d.year = d.year + 1
				d.month = 1
			end

			catherine.date.Tick = CurTime( ) + 0.5
		end
		
		if ( catherine.date.NextSync <= CurTime( ) ) then
			catherine.date.SyncToAll( )
			catherine.date.NextSync = CurTime( ) + 60
		end
	end

	function catherine.date.GetLightDataByHour( )
		local hour = catherine.date.GetHour( )
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
	
	function catherine.date.GetHour( )
		return catherine.date.Buffer.hour
	end
	
	function catherine.date.AutomaticDayNight( )
		local dayNightData = catherine.date.GetLightDataByHour( )
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

		catherine.date.SetLightFlag( dayNightData.lightStyle )
	end

	function catherine.date.SetLightFlag( flag )
		engine.LightStyle( 0, flag )
		netstream.Start( nil, "catherine.date.SetLightFlag" )
	end

	function catherine.date.SyncToPlayer( pl, func )
		if ( !IsValid( pl ) ) then return end
		netstream.Start( pl, "catherine.date.Sync", catherine.date.Buffer )
		if ( func ) then
			func( )
		end
	end

	function catherine.date.SyncToAll( )
		netstream.Start( player.GetAllByLoaded( ), "catherine.date.Sync", catherine.date.Buffer )
	end

	function catherine.date.DataSave( )
		catherine.data.Set( "date", catherine.date.Buffer )
	end
	
	function catherine.date.DataLoad( )
		local data = catherine.data.Get( "date", catherine.configs.defaultRPdateTime )

		if ( table.Count( data ) == 0 ) then
			catherine.date.Buffer = catherine.configs.defaultRPdateTime
		else
			catherine.date.Buffer = data
		end
		
		catherine.date.AutomaticDayNight( )
	end

	hook.Add( "Think", "catherine.date.Work", catherine.date.Work )
	hook.Add( "DataSave", "catherine.date.DataSave", catherine.date.DataSave )
	hook.Add( "DataLoad", "catherine.date.DataLoad", catherine.date.DataLoad )
else
	netstream.Hook( "catherine.date.Sync", function( data )
		catherine.date.Buffer = data
	end )
	
	netstream.Hook( "catherine.date.SetLightFlag", function( )
		render.RedownloadAllLightmaps( )
	end )

	function catherine.date.WorkClient( )
		if ( table.Count( catherine.date.Buffer ) == 0 ) then return end
		if ( catherine.date.Tick <= CurTime( ) ) then
			local d = catherine.date.Buffer
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
			
			if ( d.day >= catherine.date.MonthBuffer[ d.month ] ) then
				d.month = d.month + 1
				d.day = 1
			end
			
			if ( d.month > 12 ) then
				d.year = d.year + 1
				d.month = 1
			end

			catherine.date.Tick = CurTime( ) + 0.5
		end
	end

	hook.Add( "Tick", "catherine.date.WorkClient", catherine.date.WorkClient )
end