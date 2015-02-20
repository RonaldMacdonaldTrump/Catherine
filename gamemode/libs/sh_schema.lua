catherine.schema = catherine.schema or { }

function catherine.schema.Initialization( )
	Schema = Schema or {
		Name = "Catherine Schema",
		Author = "L7D, Fristet",
		Desc = "A catherine schema.",
		UniqueID = GM.FolderName,
		FolderName = GM.FolderName,
		Title = "A Good Schema",
		Desc = "Good"
	}
	catherine.util.IncludeInDir( "schema/libs" )
	catherine.util.Include( "schema/sh_schema.lua" )
	catherine.faction.Include( Schema.FolderName .. "/gamemode/schema" )
	catherine.item.Include( Schema.FolderName .. "/gamemode/schema" )
	
	hook.Run( "SchemaInit" )
end

function catherine.schema.GetUniqueID( )
	if ( !Schema ) then return "catherine" end
	return Schema.UniqueID or "catherine"
end

hook.catherineHookCall = hook.catherineHookCall or hook.Call

function hook.Call( name, gm, ... )
	if ( Schema and Schema[ name ] ) then
		local func = Schema[ name ]( Schema, ... )
		if ( func != nil ) then
			return func
		end
	end
	return hook.catherineHookCall( name, gm, ... )
end

