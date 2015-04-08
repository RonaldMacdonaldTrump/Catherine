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
local doorClasses = {
	"func_door",
	"func_door_rotating",
	"prop_door_rotating",
	"prop_dynamic"
}

function catherine.entity.IsDoor( ent )
	if ( !IsValid( ent ) ) then return end
	return table.HasValue( doorClasses, ent:GetClass( ) ) // need lower?, idk ;)
end

function catherine.entity.IsProp( ent )
	if ( !IsValid( ent ) ) then return end
	return ent:GetClass( ):find( "prop_" )
end

if ( SERVER ) then

end