catherine = catherine or GM

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local function badSchemaGMSyntaxFix( )
	local badGMSyntax = {
		[ "cat_hl2rp" ] = {
			"Catherine-HL2RP-master",
			"Catherine-HL2RP"
		}
	}
	local currGM = GetConVarString( "gamemode" ):lower( )
	
	if ( currGM == "catherine" ) then
		local _, gmDirs = file.Find( "gamemodes/*", "GAME" )
		for k, v in pairs( gmDirs ) do
			if ( !v:lower( ):find( "cat_" ) ) then continue end
			catherine.util.Print( Color( 255, 255, 0 ), "Don't setting gamemode to Catherine, automatic change to " .. v .. "!" )
			RunConsoleCommand( "gamemode", v )
			RunConsoleCommand( "changelevel", game.GetMap( ) )
		end
	else
		for k, v in pairs( badGMSyntax ) do
			for k1, v1 in pairs( v ) do
				if ( currGM == v1:lower( ) ) then
					catherine.util.Print( Color( 255, 255, 0 ), "Bad gamemode setting found, automatic change to " .. k .. "!" )
					RunConsoleCommand( "gamemode", k )
					RunConsoleCommand( "changelevel", game.GetMap( ) )
				end
			end
		end
	end
end

badSchemaGMSyntaxFix( )
catherine.util.AddResourceInFolder( "materials/CAT" )

if ( game.IsDedicated( ) ) then
	concommand.Remove( "gm_save" )
	concommand.Add( "gm_save", function( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.util.Notify( pl, "You are not allowed to do that" )
	end )
end