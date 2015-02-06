

DeriveGamemode( "sandbox" )

catherine.Name = "Catherine"
catherine.Author = "L7D, Fristet"

include( "sh_util.lua" )
AddCSLuaFile( "sh_util.lua" )

catherine.util.Include( "sh_config.lua" )
catherine.util.IncludeInDir( "libs", true )
catherine.util.IncludeInDir( "hooks", true )
catherine.util.IncludeInDir( "derma", true )