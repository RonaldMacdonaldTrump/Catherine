catherine = catherine or GM

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

if ( GetConVarString( "gamemode" ):lower( ) == "catherine" ) then
	catherine.network.SetNetGlobalVar( "notSetSchema", true )
	for i = 1, 10 do
		catherine.util.Print( Color( 255, 255, 0 ), "WARNING : Please change \"+gamemode\" command to Catherine schema!!! ( Example : cat_hl2rp )" )
	end
end

catherine.util.AddResourceByFolder( "materials/CAT" )