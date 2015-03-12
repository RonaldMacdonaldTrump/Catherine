DeriveGamemode( "sandbox" )

catherine.Name = "Catherine"
catherine.Author = "L7D"

AddCSLuaFile( "sh_util.lua" )
include( "sh_util.lua" )

catherine.util.Include( "sh_config.lua" )
catherine.util.IncludeInDir( "libs", true )
catherine.util.IncludeInDir( "hooks", true )
catherine.util.IncludeInDir( "derma", true )
catherine.util.IncludeInDir( "plugins", true )

if ( SERVER ) then
	if ( !Schema ) then
		for i = 1, 10 do
			catherine.util.Print( Color( 255, 255, 0 ), "You are using catherine but this is wrong, you must using catherine schema!" )
		end
	end
	
	catherine.util.AddResourceByFolder( "materials/CAT" )
end