--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

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

if ( !catherine.data ) then
	catherine.util.Include( "sv_data.lua" )
end
catherine.door = catherine.door or { }

local META = FindMetaTable( "Entity" )

function META:IsDoor( )
	if ( !IsValid( self ) ) then return false end
	local class = self:GetClass( )
	if ( class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" or class == "prop_dynamic" ) then
		return true
	end
	return false
end

if ( SERVER ) then
	function catherine.door.Buy( pl )
		local ent = pl:GetEyeTrace( 70 ).Entity
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		if ( catherine.network.GetNetVar( ent, "owner", nil ) != nil ) then
			return catherine.util.Notify( pl, "This door has already bought by unknown guy." )
		end
		if ( catherine.cash.Get( pl ) >= catherine.configs.doorCost ) then
			catherine.door.SetDoorOwner( ent, pl )
			catherine.util.Notify( pl, "You have purchased this door." )
			catherine.cash.Take( pl, catherine.configs.doorCost )
		elseif ( catherine.cash.Get( pl ) < catherine.configs.doorCost ) then
			catherine.util.Notify( pl, "You need " .. catherine.cash.GetName( catherine.configs.doorCost - pl:GetCash( ) ) .. "(s) more!" )
		end
	end
	
	function catherine.door.Sell( pl )
		local ent = pl:GetEyeTrace( 70 ).Entity
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		if ( catherine.network.GetNetVar( ent, "owner", nil ) != pl ) then
			return catherine.util.Notify( pl, "You do not have permission!" )
		end
		catherine.door.SetDoorOwner( ent, nil )
		catherine.cash.Give( pl, catherine.configs.doorSellCost )
		catherine.util.Notify( pl, "You are sold this door." )
	end
	
	function catherine.door.SetDoorTitle( pl, title )
		if ( !title ) then title = "Door" end
		local ent = pl:GetEyeTrace( 70 ).Entity
		if ( !IsValid( ent ) ) then return catherine.util.Notify( pl, "Please look valid entity!" ) end
		if ( !ent:IsDoor( ) ) then return catherine.util.Notify( pl, "Please look valid door!" ) end
		if ( catherine.network.GetNetVar( ent, "owner", nil ) != pl ) then return catherine.util.Notify( pl, "You do not have permission!" ) end
		catherine.network.SetNetVar( ent, "title", title )
		catherine.util.Notify( pl, "You are setting this door title to \"" .. title .. "\"" )
	end
	
	function catherine.door.SetDoorOwner( ent, pl )
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		catherine.network.SetNetVar( ent, "owner", pl )
	end
	
	function catherine.door.GetDoorOwner( ent )
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		return catherine.network.GetNetVar( ent, "owner", nil )
	end

	function catherine.door.SaveData( )
		local data = { }
		for k, v in pairs( ents.GetAll( ) ) do
			if ( !v:IsDoor( ) ) then continue end
			local title = catherine.network.GetNetVar( v, "title", "Door" )
			if ( title == "Door" ) then continue end
			data[ #data + 1 ] = {
				title = title,
				index = v:EntIndex( )
			}
		end
		
		catherine.data.Set( "door", data )
	end
	
	
	function catherine.door.LoadData( )
		local data = catherine.data.Get( "door", { } )
		
		for k, v in pairs( data ) do
			for k1, v1 in pairs( ents.GetAll( ) ) do
				if ( IsValid( v1 ) and v1:IsDoor( ) and v1:EntIndex( ) == v.index ) then
					catherine.network.SetNetVar( v1, "title", v.title )
				end
			end
		end
	end
	
	hook.Add( "DataSave", "catherine.door.DataSave", function( )
		catherine.door.SaveData( )
	end )
	
	hook.Add( "DataLoad", "catherine.door.DataLoad", function( )
		catherine.door.LoadData( )
	end )
else
	local toscreen = FindMetaTable("Vector").ToScreen
	
	hook.Add( "DrawEntityTargetID", "catherine.door.DrawEntityTargetID", function( pl, ent, a )
		if ( !ent:IsDoor( ) ) then return end
		local position = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		draw.SimpleText( catherine.network.GetNetVar( ent, "owner", nil ) == nil and "This door can purchase." or "This door has already been purchased.", "catherine_outline15", position.x, position.y + 20, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( catherine.network.GetNetVar( ent, "title", "Door" ), "catherine_outline20", position.x, position.y, Color( 255, 255, 255, a ), 1, 1 )
	end )
end

catherine.command.Register( {
	command = "doorbuy",
	syntax = "[none]",
	runFunc = function( pl, args )
		catherine.door.Buy( pl )
	end
} )

catherine.command.Register( {
	command = "doorsell",
	syntax = "[none]",
	runFunc = function( pl, args )
		catherine.door.Sell( pl )
	end
} )

catherine.command.Register( {
	command = "doorsettitle",
	syntax = "[text]",
	runFunc = function( pl, args )
		catherine.door.SetDoorTitle( pl, args[ 1 ] )
	end
} )