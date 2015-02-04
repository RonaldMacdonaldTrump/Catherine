nexus.schema = nexus.schema or { }

function nexus.schema.Initialization( )
	Schema = Schema or {
		Name = "Nexus Schema",
		Author = "L7D, Fristet",
		Desc = "A Nexus schema.",
		UniqueID = GM.FolderName,
		FolderName = GM.FolderName
	}
	nexus.util.IncludeInDir( "schema/libs" )
	nexus.util.Include( "schema/sh_schema.lua" )
	
	hook.Run( "SchemaInit" )
end

function nexus.schema.GetUniqueID( )
	if ( !Schema ) then return "nexus" end
	return Schema.UniqueID or "nexus"
end

hook.NexusHookCall = hook.NexusHookCall or hook.Call

function hook.Call( name, gm, ... )
	if ( Schema and Schema[ name ] ) then
		local func = Schema[ name ]( Schema, ... )
		if ( func != nil ) then
			return func
		end
	end
	return hook.NexusHookCall( name, gm, ... )
end
