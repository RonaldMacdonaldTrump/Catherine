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
	
	catherine.faction.Include( Schema.FolderName .. "/gamemode/schema" )
	catherine.class.Include( Schema.FolderName .. "/gamemode/schema" )
	catherine.item.Include( Schema.FolderName .. "/gamemode/schema" )
	catherine.language.Include( Schema.FolderName .. "/gamemode/schema" )
	catherine.util.Include( "schema/sh_schema.lua" )
	catherine.util.IncludeInDir( "schema/libs" )
	catherine.util.IncludeInDir( "schema/derma" )
	catherine.plugin.LoadAll( Schema.FolderName )
	//catherine.plugin.LoadAll( catherine.FolderName ) // ;;?
	
	hook.Run( "SchemaInitialized" )
end

function catherine.schema.GetUniqueID( )
	return Schema and Schema.UniqueID or "catherine"
end

hook.NyanHookRun = hook.NyanHookRun or hook.Call

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
	return hook.NyanHookRun( name, gm, ... )
end