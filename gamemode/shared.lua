DeriveGamemode( "sandbox" )

catherine.Name = "Catherine"
catherine.Desc = "A free role-playing framework for Garry's Mod."
catherine.Author = "L7D"

AddCSLuaFile( "sh_util.lua" )
include( "sh_util.lua" )
catherine.util.Include( "sh_config.lua" )
catherine.util.IncludeInDir( "libs", true )
catherine.util.IncludeInDir( "hooks", true )
catherine.util.IncludeInDir( "derma", true )
catherine.util.IncludeInDir( "plugins", true )