

nexus.util = nexus.util or { }

function nexus.util.Include( dir, types )
	if ( !dir ) then return end
	local lowerDir = string.lower( dir )
	if ( SERVER and ( types == "SERVER" or string.find( lowerDir, "sv_" ) ) ) then
		include( dir )
	elseif ( types == "CLIENT" or string.find( lowerDir, "cl_" ) ) then
		if ( SERVER ) then
			AddCSLuaFile( dir )
		else
			include( dir )
		end
	elseif ( types == "SHARED" or string.find( lowerDir, "sh_" ) ) then
		AddCSLuaFile( dir )
		include( dir )
	end
end

function nexus.util.IncludeInDir( dir, isNexus )
	if ( !dir ) then return end
	if ( ( !isNexus or string.find( dir, "schema/" ) ) and !Schema ) then return end
	local dir2 = ( ( isNexus and "nexus" ) or Schema.FolderName ) .. "/gamemode/" .. dir .. "/*.lua"
	for k, v in pairs( file.Find( dir2, "LUA" ) ) do
		nexus.util.Include( dir .. "/" .. v )
	end
	
end

nexus.util.IncludeInDir( "libs/external", true )

