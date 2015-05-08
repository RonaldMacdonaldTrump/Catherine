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

catherine.entity = catherine.entity or { }
local META = FindMetaTable( "Entity" )

function catherine.entity.IsDoor( ent )
	local class = ent:GetClass( )
	
	return class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
end

function catherine.entity.IsProp( ent )
	return ent:GetClass( ):find( "prop_" )
end

if ( SERVER ) then
	catherine.entity.customUse = catherine.entity.customUse or { }

	function catherine.entity.RegisterUseMenu( ent, menuTable )
		local forServer = { }
		local forClient = { }
		
		for k, v in pairs( menuTable ) do
			forServer[ v.uniqueID ] = v.func
			forClient[ v.uniqueID ] = { text = v.text, uniqueID = v.uniqueID }
		end
		
		ent.IsCustomUse = true
		catherine.entity.customUse[ ent:EntIndex( ) ] = forServer

		ent:SetNetVar( "customUseClient", forClient )
	end
	
	function catherine.entity.RunUseMenu( pl, index, uniqueID )
		if ( !catherine.entity.customUse[ index ] or !catherine.entity.customUse[ index ][ uniqueID ] ) then return end
		
		catherine.entity.customUse[ index ][ uniqueID ]( pl, Entity( index ) )
	end
	
	function catherine.entity.EntityRemoved( ent )
		catherine.entity.customUse[ ent:EntIndex( ) ] = nil
	end

	hook.Add( "EntityRemoved", "catherine.entity.EntityRemoved", catherine.entity.EntityRemoved )

	netstream.Hook( "catherine.entity.customUseMenu_Receive", function( pl, data )
		catherine.entity.RunUseMenu( pl, data[ 1 ], data[ 2 ] )
	end )
else
	netstream.Hook( "catherine.entity.CustomUseMenu", function( data )
		local index = data
		local ent = Entity( index )
		local menu = DermaMenu( )
		
		for k, v in pairs( IsValid( ent ) and ent:GetNetVar( "customUseClient" ) or { } ) do
			menu:AddOption( catherine.util.StuffLanguage( v.text ), function( )
				netstream.Start( "catherine.entity.customUseMenu_Receive", {
					index,
					v.uniqueID
				} )
			end )
		end
		
		menu:Open( )
		menu:Center( )
	end )
end