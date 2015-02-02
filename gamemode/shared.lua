

DeriveGamemode( "sandbox" )

nexus.Name = "Nexus"
nexus.Author = "L7D, Fristet"

include( "sh_util.lua" )
AddCSLuaFile( "sh_util.lua" )

nexus.util.Include( "sh_config.lua" )
nexus.util.IncludeInDir( "libs", true )
nexus.util.IncludeInDir( "hooks", true )