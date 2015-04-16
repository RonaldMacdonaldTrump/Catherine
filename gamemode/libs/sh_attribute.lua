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

if ( !catherine.character ) then
	catherine.util.Include( "sh_character.lua" )
end
catherine.attribute = catherine.attribute or { }
catherine.attribute.Lists = { }

function catherine.attribute.Register( uniqueID, name, desc, image, default, max )
	local index = #catherine.attribute.Lists + 1
	
	catherine.attribute.Lists[ index ] = {
		uniqueID = uniqueID,
		name = name,
		desc = desc,
		image = image,
		default = default or 0,
		max = max or 100
	}
	
	return catherine.attribute.Lists[ index ]
end

function catherine.attribute.GetAll( )
	return catherine.attribute.Lists
end

function catherine.attribute.FindByID( id )
	for k, v in pairs( catherine.attribute.GetAll( ) ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
end

if ( SERVER ) then
	function catherine.attribute.SetProgress( pl, attributeTable, progress )
		if ( !attributeTable or !progress ) then return end
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		local uniqueID = attributeTable.uniqueID
		
		attribute[ uniqueID ] = attribute[ uniqueID ] or {
			per = 0,
			progress = attributeTable.default
		}
		attribute[ uniqueID ].progress = math.Clamp( progress, 0, attributeTable.max )
		
		catherine.character.SetVar( pl, "_att", attribute )
	end
	
	function catherine.attribute.AddProgress( pl, attributeTable, progress )
		if ( !attributeTable or !progress ) then return end
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		local uniqueID = attributeTable.uniqueID
		
		attribute[ uniqueID ] = attribute[ uniqueID ] or {
			per = 0,
			progress = attributeTable.default
		}
		attribute[ uniqueID ].progress = math.Clamp( attribute[ uniqueID ].progress + progress, 0, attributeTable.max )
		
		catherine.character.SetVar( pl, "_att", attribute )
	end
	
	function catherine.attribute.RemoveProgress( pl, attributeTable, progress )
		if ( !attributeTable or !progress ) then return end
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		local uniqueID = attributeTable.uniqueID
		
		attribute[ uniqueID ] = attribute[ uniqueID ] or {
			per = 0,
			progress = attributeTable.default
		}
		attribute[ uniqueID ].progress = math.Clamp( attribute[ uniqueID ].progress - progress, 0, attributeTable.max )
		
		catherine.character.SetVar( pl, "_att", attribute )
	end

	function catherine.attribute.GetProgress( pl, attributeTable )
		local attribute = catherine.character.GetVar( pl, "_att", { } )
		local uniqueID = attributeTable.uniqueID
		
		return attribute[ uniqueID ] and attribute[ uniqueID ].progress or 0
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

		if ( count != #attributeAll ) then
			for k, v in pairs( attributeAll ) do
				if ( attribute[ v.uniqueID ] ) then continue end
				attribute[ v.uniqueID ] = { per = 0, progress = v.default }
				changed = true
			end
		end
		
		if ( changed ) then
			catherine.character.SetVar( pl, "_att", attribute )
		end
	end

	hook.Add( "CreateNetworkRegistry", "catherine.attribute.CreateNetworkRegistry", catherine.attribute.CreateNetworkRegistry )
else
	function catherine.attribute.GetProgress( attributeTable )
		local attribute = catherine.character.GetVar( LocalPlayer( ), "_att", { } )
		local uniqueID = attributeTable.uniqueID
		
		return attribute[ uniqueID ] and attribute[ uniqueID ].progress or 0
	end
end