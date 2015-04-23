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

catherine.entity = catherine.entity or { CustomUse = { } }
local META = FindMetaTable( "Entity" )
local doorClasses = {
	"func_door",
	"func_door_rotating",
	"prop_door_rotating",
	"prop_dynamic"
}

function catherine.entity.IsDoor( ent )
	return table.HasValue( doorClasses, ent:GetClass( ) )
end

function catherine.entity.IsProp( ent )
	return ent:GetClass( ):find( "prop_" )
end

if ( SERVER ) then
	catherine.entity.CustomUse = catherine.entity.CustomUse or { }
	
	function catherine.entity.RegisterUseMenu( ent, menuTable )
		local forServer = { }
		local forClient = { }
		
		for k, v in pairs( menuTable ) do
			forServer[ v.uniqueID ] = v.func
			forClient[ v.uniqueID ] = { text = v.text, uniqueID = v.uniqueID }
		end
		
		ent.IsCustomUse = true
		catherine.entity.CustomUse[ ent:EntIndex( ) ] = forServer

		ent:SetNetVar( "customUseClient", forClient )
	end
	
	function catherine.entity.RunUseMenu( pl, index, uniqueID )
		if ( !catherine.entity.CustomUse[ index ] or !catherine.entity.CustomUse[ index ][ uniqueID ] ) then return end
		
		catherine.entity.CustomUse[ index ][ uniqueID ]( pl, Entity( index ) )
	end
	
	function catherine.entity.EntityRemoved( ent )
		catherine.entity.CustomUse[ ent:EntIndex( ) ] = nil
	end

	hook.Add( "EntityRemoved", "catherine.entity.EntityRemoved", catherine.entity.EntityRemoved )

	catherine.netXync.Receiver( "catherine.entity.CustomUseMenu_Receive", function( pl, data )
		catherine.entity.RunUseMenu( pl, data[ 1 ], data[ 2 ] )
	end )
else
	catherine.netXync.Receiver( "catherine.entity.CustomUseMenu", function( data )
		local index = data
		local ent = Entity( index )
		local menu = DermaMenu( )
		
		for k, v in pairs( IsValid( ent ) and ent:GetNetVar( "customUseClient" ) or { } ) do
			menu:AddOption( catherine.util.StuffLanguage( v.text ), function( )
				catherine.netXync.Send( "catherine.entity.CustomUseMenu_Receive", { index, v.uniqueID } )
			end )
		end
		
		menu:Open( )
		menu:Center( )
	end )
	
	catherine.netXync.Receiver( "catherine.entity.RegisterUseMenu", function( data )
		catherine.entity.CustomUse[ data[ 1 ] ] = data[ 2 ]
	end )
	
	catherine.netXync.Receiver( "catherine.entity.ClearCustomUse", function( data )
		catherine.entity.CustomUse[ data ] = nil
	end )
end