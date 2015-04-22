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

catherine.schema = catherine.schema or { }

function catherine.schema.Initialization( )
	Schema = Schema or {
		Name = "Example Schema",
		Author = "L7D",
		UniqueID = GM.FolderName,
		FolderName = GM.FolderName,
		Title = "Example",
		Desc = "A schema.",
		IntroTitle = "A Schema",
		IntroDesc = "Welcome..."
	}
	
	local schemaFolderName = Schema.FolderName
	
	catherine.faction.Include( schemaFolderName .. "/gamemode/schema" )
	catherine.class.Include( schemaFolderName .. "/gamemode/schema" )
	catherine.item.Include( schemaFolderName .. "/gamemode/schema" )
	catherine.attribute.Include( schemaFolderName .. "/gamemode/schema" )
	catherine.util.Include( "schema/sh_schema.lua" )
	catherine.language.Include( schemaFolderName .. "/gamemode/schema" )
	catherine.util.IncludeInDir( "schema/library", schemaFolderName .. "/gamemode/" )
	catherine.util.IncludeInDir( "schema/derma", schemaFolderName .. "/gamemode/" )
	catherine.plugin.Include( schemaFolderName )
	catherine.plugin.Include( catherine.FolderName )

	hook.Run( "SchemaInitialized" )
end

function catherine.schema.GetUniqueID( )
	return Schema and Schema.UniqueID or "catherine"
end

hook.OriginalHookRun = hook.OriginalHookRun or hook.Call

function hook.Call( name, gm, ... )
	if ( catherine.plugin ) then
		for k, v in pairs( catherine.plugin.GetAll( ) ) do
			if ( !v[ name ] ) then continue end
			local func = v[ name ]( v, ... )
			if ( func == nil ) then continue end
			
			return func
		end
	end
	
	if ( Schema and Schema[ name ] ) then
		local func = Schema[ name ]( Schema, ... )
		if ( func == nil ) then return end
		
		return func
	end
	
	return hook.OriginalHookRun( name, gm, ... )
end