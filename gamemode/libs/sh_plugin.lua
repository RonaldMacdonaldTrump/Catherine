catherine.plugin = catherine.plugin or { List = { } }

function catherine.plugin.LoadAll( dir )
	local _, folders = file.Find( dir .. "/gamemode/plugins/*", "LUA" )

	for k, v in pairs( folders ) do
		PLUGIN = catherine.plugin.Get( v ) or { }
		
		local Pdir = dir .. "/gamemode/plugins/" .. v
		
		if ( file.Exists( Pdir .. "/sh_plugin.lua", "LUA" ) ) then
			local findDermas = file.Find( Pdir .. "/derma/*.lua", "LUA" )
			local findLibs = file.Find( Pdir .. "/libs/*.lua", "LUA" )
			
			catherine.util.Include( Pdir .. "/sh_plugin.lua" )
			catherine.item.Include( Pdir )
			
			for k1, v1 in pairs( findDermas ) do
				catherine.util.Include( Pdir .. "/derma/" .. v1 )
			end
			
			for k1, v1 in pairs( findLibs ) do
				catherine.util.Include( Pdir .. "/libs/" .. v1 )
			end
			
			catherine.plugin.List[ v ] = PLUGIN
		end
		
		PLUGIN = nil
	end
end

function catherine.plugin.Get( id )
	return catherine.plugin.List[ id ]
end

function catherine.plugin.GetAlls( )
	return catherine.plugin.List
end

catherine.plugin.LoadAll( catherine.FolderName )