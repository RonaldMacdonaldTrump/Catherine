DEFINE_BASECLASS( "gamemode_base" )
function GM:LoadCheck( )
	print("Loaded")
end

function GM:GetGameDescription( )
	return "Nexus - ".. ( Schema and Schema.Name or "Error" )
end

function GM:PlayerSpray( pl )
	return true
end

function GM:PlayerSpawn( pl )
	player_manager.SetPlayerClass( pl, "player_nexus" )
	BaseClass.PlayerSpawn( self, pl )
end

function GM:PlayerInitialSpawn( pl )
	nexus.character.SendCharacterPanel( pl )
end

