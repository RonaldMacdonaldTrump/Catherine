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

local PLUGIN = PLUGIN
PLUGIN.name = "^SP_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^SP_Plugin_Desc"

catherine.util.Include( "sh_language.lua" )

catherine.command.Register( {
	command = "staticprop",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl.GetEyeTraceNoCursor( pl ).Entity

		if ( IsValid( ent ) ) then
			if ( catherine.entity.IsProp( ent ) and !catherine.entity.IsDoor( ent ) ) then
				ent:SetNetVar( "isStatic", !ent.GetNetVar( ent, "isStatic", false ) )
				
				if ( ent.GetNetVar( ent, "isStatic" ) ) then
					catherine.util.NotifyLang( pl, "Staticprop_Notify_Add" )
				else
					catherine.util.NotifyLang( pl, "Staticprop_Notify_Remove" )
				end
				
				PLUGIN:DataSave( )
			else
				catherine.util.NotifyLang( pl, "Staticprop_Notify_IsNotProp" )
			end
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotValid" )
		end
	end
} )

if ( CLIENT ) then return end

function PLUGIN:DataSave( )
	local data = { }
	
	for k, v in pairs( ents.GetAll( ) ) do
		if ( !v.GetNetVar( v, "isStatic" ) ) then continue end
		
		data[ #data + 1 ] = v
	end
	
	if ( #data == 0 ) then return end
	local persistentData = duplicator.CopyEnts( data )
	if ( !persistentData ) then return end
	
	catherine.data.Set( "staticprops", persistentData )
end

function PLUGIN:DataLoad( )
	local data = catherine.data.Get( "staticprops" )
	if ( !data ) then return end
	
	local ents, consts = duplicator.Paste( nil, data.Entities or { }, data.Contraints or { } )
	
	for k, v in pairs( ents ) do
		v:SetNetVar( "isStatic", true )
	end
end