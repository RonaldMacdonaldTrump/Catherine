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

if ( SERVER and game.IsDedicated( ) ) then
	concommand.Remove( "gm_save" )
	
	concommand.Add( "gm_save", function( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.util.Notify( pl, "You are not allowed to do that" )
	end )
end
