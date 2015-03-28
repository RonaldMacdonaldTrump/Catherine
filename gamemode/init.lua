catherine = catherine or GM

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local function badSchemaSettingFix( )
	local currGM = GetConVarString( "gamemode" ):lower( )
	if ( currGM == "catherine" ) then
		local _, gmDirs = file.Find( "gamemodes/*", "GAME" )
		for k, v in pairs( gmDirs ) do
			if ( !v:lower( ):find( "cat_" ) ) then continue end
			catherine.util.Print( Color( 255, 255, 0 ), "Don't setting gamemode to Catherine, automatic change to " .. v .. "!" )
			RunConsoleCommand( "gamemode", v )
			RunConsoleCommand( "changelevel", game.GetMap( ) )
		end
	end
end

badSchemaSettingFix( )
catherine.util.AddResourceInFolder( "materials/CAT" )
catherine.util.AddResourceInFolder( "sound/CAT" )

if ( game.IsDedicated( ) ) then
	concommand.Remove( "gm_save" )
	concommand.Add( "gm_save", function( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.util.Notify( pl, "You are not allowed to do that" )
	end )
end