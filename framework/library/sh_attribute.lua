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

catherine.attribute = catherine.attribute or { lists = { } }

function catherine.attribute.Register( attributeTable )
	if ( !attributeTable or !attributeTable.index ) then
		return
	end
	
	attributeTable.default = attributeTable.default or 0
	attributeTable.max = attributeTable.max or 100

	if ( SERVER and attributeTable.image ) then
		resource.AddFile( attributeTable.image )
	end

	catherine.attribute.lists[ attributeTable.uniqueID ] = attributeTable
	
	return attributeTable.uniqueID
end

function catherine.attribute.New( uniqueID )
	return { uniqueID = uniqueID, index = table.Count( catherine.attribute.lists ) + 1 }
end

function catherine.attribute.GetAll( )
	return catherine.attribute.lists
end

function catherine.attribute.FindByID( id )
	return catherine.attribute.lists[ id ]
end

function catherine.attribute.FindByIndex( index )
	for k, v in pairs( catherine.attribute.GetAll( ) ) do
		if ( v.index == index ) then
			return v
		end
	end
end

function catherine.attribute.Include( dir )
	for k, v in pairs( file.Find( dir .. "/attribute/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/attribute/" .. v, "SHARED" )
	end
end

catherine.attribute.Include( catherine.FolderName .. "/framework" )

if ( SERVER ) then
	function catherine.attribute.AddTemporaryIncreaseProgress( pl, uniqueID, amount, removeTime )
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		removeTime = removeTime or 5
		
		if ( attribute[ uniqueID ] ) then
			local progress = attribute[ uniqueID ].progress
			
			if ( attributeTable.max < progress + amount ) then
				return
			end

			attribute[ uniqueID ].boost = math.Clamp( amount, 0, attributeTable.max )
			attribute[ uniqueID ].removeTime = removeTime
			
			local charID = pl:GetCharacterID( )
			local timerID = "Catherine.timer.attribute.TemporaryIncreaseRemove." .. pl:SteamID( ) .. "." .. uniqueID .. "." .. charID
			local removeTime2 = removeTime
			
			timer.Remove( timerID )
			timer.Create( timerID, 3, 0, function( )
				if ( !IsValid( pl ) or charID != pl:GetCharacterID( ) ) then
					timer.Remove( timerID )
					return
				end
				
				if ( removeTime2 - 3 <= 0 ) then
					catherine.attribute.RemoveTemporaryIncreaseProgress( pl, uniqueID )
					timer.Remove( timerID )
					return
				end
				
				local attributeTable = catherine.attribute.FindByID( uniqueID )
				
				if ( !attributeTable ) then
					timer.Remove( timerID )
					return
				end
				
				local attribute = catherine.character.GetVar( pl, "_att", { } )
				
				if ( attribute[ uniqueID ] ) then
					if ( !attribute[ uniqueID ].removeTime or !attribute[ uniqueID ].boost ) then
						timer.Remove( timerID )
						return
					end
						
					attribute[ uniqueID ].removeTime = removeTime2 - 3
					removeTime2 = removeTime2 - 3
					
					catherine.character.SetVar( pl, "_att", attribute )
				else
					timer.Remove( timerID )
				end
			end )
		else
			attribute[ uniqueID ] = {
				per = 0,
				progress = 0,
				boost = math.Clamp( amount, 0, attributeTable.max ),
				removeTime = removeTime
			}
		end
		
		catherine.character.SetVar( pl, "_att", attribute )
		
		hook.Run( "AttributeBoosted", pl, uniqueID )
	end
	
	function catherine.attribute.AddTemporaryDecreaseProgress( pl, uniqueID, amount, removeTime )
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		local decreaseTable = catherine.character.GetCharVar( pl, "attribute_temporary", { } )
		
		removeTime = removeTime or 5
		
		if ( attribute[ uniqueID ] ) then
			local progress = attribute[ uniqueID ].progress
			
			if ( attributeTable.max < progress + amount ) then
				return
			end

			attribute[ uniqueID ].boost = math.Clamp( amount, 0, attributeTable.max )
			attribute[ uniqueID ].removeTime = removeTime
			
			local charID = pl:GetCharacterID( )
			local timerID = "Catherine.timer.attribute.TemporaryDecreaseRemove." .. pl:SteamID( ) .. "." .. uniqueID .. "." .. charID
			local removeTime2 = removeTime
			
			timer.Remove( timerID )
			timer.Create( timerID, 3, 0, function( )
				if ( !IsValid( pl ) or charID != pl:GetCharacterID( ) ) then
					timer.Remove( timerID )
					return
				end
				
				if ( removeTime2 - 3 <= 0 ) then
					catherine.attribute.RemoveTemporaryIncreaseProgress( pl, uniqueID )
					timer.Remove( timerID )
					return
				end
				
				local attributeTable = catherine.attribute.FindByID( uniqueID )
				
				if ( !attributeTable ) then
					timer.Remove( timerID )
					return
				end
				
				local attribute = catherine.character.GetVar( pl, "_att", { } )
				
				if ( attribute[ uniqueID ] ) then
					if ( !attribute[ uniqueID ].removeTime or !attribute[ uniqueID ].boost ) then
						timer.Remove( timerID )
						return
					end
						
					attribute[ uniqueID ].removeTime = removeTime2 - 3
					removeTime2 = removeTime2 - 3
					
					catherine.character.SetVar( pl, "_att", attribute )
				else
					timer.Remove( timerID )
				end
			end )
		else
			attribute[ uniqueID ] = {
				per = 0,
				progress = 0,
				boost = math.Clamp( amount, 0, attributeTable.max ),
				removeTime = removeTime
			}
		end
		
		catherine.character.SetVar( pl, "_att", attribute )
		
		hook.Run( "AttributeBoosted", pl, uniqueID )
	end
	
	function catherine.attribute.RemoveBoost( pl, uniqueID )
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		if ( attribute[ uniqueID ] ) then
			if ( !attribute[ uniqueID ].boost or !attribute[ uniqueID ].removeTime ) then return end
			
			attribute[ uniqueID ].boost = nil
			attribute[ uniqueID ].removeTime = nil
			
			catherine.character.SetVar( pl, "_att", attribute )
			hook.Run( "AttributeUnBoosted", pl, uniqueID )
		end
	end
	
	function catherine.attribute.ClearBoost( pl )
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		local changed = false
		
		for k, v in pairs( attribute ) do
			local attributeTable = catherine.attribute.FindByID( k )
			
			if ( !attributeTable ) then continue end

			attribute[ k ].boost = nil
			attribute[ k ].removeTime = nil
			
			changed = true
		end
		
		if ( changed ) then
			catherine.character.SetVar( pl, "_att", attribute )
		end
	end
	
	function catherine.attribute.SetProgress( pl, uniqueID, progress )
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		if ( attribute[ uniqueID ] ) then
			attribute[ uniqueID ].progress = math.Clamp( progress, 0, attributeTable.max )
		else
			attribute[ uniqueID ] = {
				per = 0,
				progress = math.Clamp( progress, 0, attributeTable.max )
			}
		end
		
		catherine.character.SetVar( pl, "_att", attribute )
		
		hook.Run( "AttributeChanged", pl, uniqueID )
	end

	function catherine.attribute.AddProgress( pl, uniqueID, progress )
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable or attribute[ uniqueID ].progress >= attributeTable.max ) then return end
		
		if ( attribute[ uniqueID ] ) then
			attribute[ uniqueID ].progress = math.Clamp( attribute[ uniqueID ].progress + progress, 0, attributeTable.max )
		else
			attribute[ uniqueID ] = {
				per = 0,
				progress = attributeTable.default
			}
		end

		catherine.character.SetVar( pl, "_att", attribute )
		
		hook.Run( "AttributeChanged", pl, uniqueID )
	end
	
	function catherine.attribute.RemoveProgress( pl, uniqueID, progress )
		local attributeTable = catherine.attribute.FindByID( uniqueID )
		
		if ( !attributeTable ) then return end
		
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		
		if ( attribute[ uniqueID ] ) then
			attribute[ uniqueID ].progress = math.Clamp( attribute[ uniqueID ].progress - progress, 0, attributeTable.max )
			
			catherine.character.SetVar( pl, "_att", attribute )
		
			hook.Run( "AttributeChanged", pl, uniqueID )
		end
	end

	function catherine.attribute.GetProgress( pl, uniqueID )
		local attribute = catherine.character.GetVar( pl, "_att", { } )

		if ( attribute[ uniqueID ] ) then
			return attribute[ uniqueID ].progress + ( attribute[ uniqueID ].boost or 0 )
		else
			return 0
		end
	end

	function catherine.attribute.CreateNetworkRegistry( pl, charVars )
		if ( !charVars._att ) then return end
		local attribute = charVars._att
		local changed = false
		local count = table.Count( attribute )
		local attributeAll = catherine.attribute.GetAll( )
		
		for k, v in pairs( attribute ) do
			if ( catherine.attribute.FindByID( k ) ) then continue end
			
			attribute[ k ] = nil
			changed = true
		end

		if ( count != table.Count( attributeAll ) ) then
			for k, v in pairs( attributeAll ) do
				if ( attribute[ k ] ) then continue end
				
				attribute[ k ] = {
					per = 0,
					progress = v.default
				}
				changed = true
			end
		end

		if ( changed ) then
			catherine.character.SetVar( pl, "_att", attribute )
		end
		
		timer.Simple( 1, function( )
			local charID = pl:GetCharacterID( )
			local steamID = pl:SteamID( )

			for k, v in pairs( catherine.character.GetVar( pl, "_att", { } ) ) do
				if ( !v.boost or !v.removeTime ) then continue end
				
				local timerID = "Catherine.timer.attribute.AutoBoostRemove." .. steamID .. "." .. k .. "." .. charID
				local removeTime = v.removeTime
				
				timer.Remove( timerID )
				timer.Create( timerID, 3, 0, function( )
					if ( !IsValid( pl ) or charID != pl:GetCharacterID( ) ) then
						timer.Remove( timerID )
						return
					end

					if ( removeTime - 3 <= 0 ) then
						catherine.attribute.RemoveBoost( pl, k )
						timer.Remove( timerID )
						return
					end
					
					local attributeTable = catherine.attribute.FindByID( k )
					
					if ( !attributeTable ) then
						timer.Remove( timerID )
						return
					end

					local attribute = catherine.character.GetVar( pl, "_att", { } )
					
					if ( attributeTable.max < attribute[ k ].progress + v.boost ) then
						catherine.attribute.RemoveBoost( pl, k )
						timer.Remove( timerID )
						return
					end
					
					if ( attribute[ k ] ) then
						if ( !attribute[ k ].removeTime or !attribute[ k ].boost ) then
							timer.Remove( timerID )
							return
						end
						
						attribute[ k ].removeTime = removeTime - 3
						removeTime = removeTime - 3
						
						catherine.character.SetVar( pl, "_att", attribute )
					else
						timer.Remove( timerID )
					end
				end )
			end
		end )
	end

	hook.Add( "CreateNetworkRegistry", "catherine.attribute.CreateNetworkRegistry", catherine.attribute.CreateNetworkRegistry )
else
	function catherine.attribute.GetProgress( uniqueID )
		local attribute = catherine.character.GetVar( catherine.pl, "_att", { } )

		return attribute[ uniqueID ] and attribute[ uniqueID ].progress or 0
	end
	
	function catherine.attribute.GetBoostProgress( uniqueID )
		local attribute = catherine.character.GetVar( catherine.pl, "_att", { } )

		return attribute[ uniqueID ] and attribute[ uniqueID ].boost or 0
	end
end