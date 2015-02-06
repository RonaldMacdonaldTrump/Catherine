catherine.plugin = catherine.plugin or { }
catherine.plugin.buffer = catherine.plugin.buffer or { }

function catherine.plugin.IncludeEntities( directory )
	local entFiles, entFolders = file.Find( directory .. "/entities/entities/*", "LUA" )
	
	for k, v in pairs( entFolders ) do
		ENT = { }
			ENT.Type = "anim"
			ENT.ClassName = v

			local dir2 = directory .. "/entities/entities/" .. ENT.ClassName .. "/"

			if ( file.Exists( dir2 .. "cl_init.lua", "LUA" ) ) then
				catherine.util.Include( dir2 .. "init.lua", "server" )
				catherine.util.Include( dir2 .. "cl_init.lua" )
			else
				catherine.util.Include( dir2 .. "shared.lua", "shared" )
			end

			scripted_ents.Register( ENT, ENT.ClassName )
		ENT = nil
	end
	
	for k, v in pairs( entFiles ) do
		ENT = { }
			ENT.ClassName = string.sub( v, 1, -5 )
			catherine.util.Include( directory .. "/entities/entities/" .. ENT.ClassName .. ".lua", "shared" )
			scripted_ents.Register( ENT, ENT.ClassName )
		ENT = nil
	end
end

function catherine.plugin.IncludeWeapons( directory )
	local wepFiles, wepFolders = file.Find( directory .. "/entities/weapons/*", "LUA" )

	for k, v in pairs( wepFolders ) do
		SWEP = { }
			SWEP.Folder = v
			SWEP.Base = "weapon_base"
			SWEP.Primary = { }
			SWEP.Secondary = { }

			local dir2 = directory .. "/entities/weapons/" .. SWEP.Folder .. "/"

			if ( file.Exists( dir2 .. "cl_init.lua", "LUA" ) ) then
				catherine.util.Include( dir2 .. "init.lua", "server" )
				catherine.util.Include( dir2 .. "cl_init.lua")
			else
				catherine.util.Include( dir2 .. "shared.lua", "shared" )
			end

			weapons.Register( SWEP, SWEP.Folder )
		SWEP = nil
	end

	for k, v in pairs( wepFiles ) do
		SWEP = {
			Primary = { },
			Secondary = { }
		}
			SWEP.Folder = string.sub( v, 1, -5 )
			SWEP.Base = "weapon_base"

			catherine.util.Include( directory .. "/entities/weapons/" .. v, "shared" )
			weapons.Register( SWEP, SWEP.Folder )
		SWEP = nil
	end
end

function catherine.plugin.IncludeEffects( directory )
	local effectFiles, effectFolders = file.Find( directory .. "/entities/effects/*", "LUA" )

	for k, v in pairs( effectFolders ) do
		EFFECT = { }
			EFFECT.ClassName = v

			local dir2 = directory .. "/entities/effects/" .. EFFECT.ClassName .. "/"

			if ( file.Exists( dir2 .. "cl_init.lua", "LUA" ) ) then
				catherine.util.Include( dir2 .. "init.lua", "server" )
				catherine.util.Include( dir2 .. "cl_init.lua" )
			elseif ( file.Exists( dir2 .. "shared.lua", "LUA" ) ) then
				catherine.util.Include( dir2 .. "shared.lua", "shared" )
			end

			if ( CLIENT ) then
				effects.Register( EFFECT, EFFECT.ClassName )
			end
		EFFECT = nil
	end

	for k, v in pairs( effectFiles ) do
		EFFECT = { }
			EFFECT.ClassName = string.sub( v, 1, -4 )
			catherine.util.Include( directory .. "/entities/effects/" .. EFFECT.ClassName .. ".lua", "client" )

			if ( CLIENT ) then
				effects.Register( EFFECT, EFFECT.ClassName )
			end
		EFFECT = nil
	end
end

function catherine.plugin.Load( directory )
	local _, folders = file.Find( "gamemode/plugins/*", "LUA" )
	
	for k, v in pairs(folders) do

			PLUGIN = catherine.plugin.Get( v ) or { }

				local pluginDir = "gamemode/plugins/" .. v

				if ( file.Exists( pluginDir .. "/sh_plugin.lua", "LUA" ) ) then
					catherine.util.Include( pluginDir .. "/sh_plugin.lua" )

					catherine.plugin.IncludeEntities( pluginDir )
					catherine.plugin.IncludeWeapons( pluginDir )
					catherine.plugin.IncludeEffects( pluginDir )

					catherine.item.Load( pluginDir )
					catherine.plugin.buffer[ v ] = PLUGIN
				end
			PLUGIN = nil
		end

	local files = file.Find( "gamemode/plugins/*.lua", "LUA" )

	for k, v in pairs( files ) do
		local Name = string.sub( v, 1, -5 )

		if ( Name:sub( 1, 3 ) == "sh_" ) then
			Name = Name:sub(4)
		end

				catherine.util.Include( "gamemode/plugins/"..v, "shared")
				catherine.plugin.buffer[Name] = PLUGIN
			PLUGIN = nil
		end
	end
end