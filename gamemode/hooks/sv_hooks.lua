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
	if ( nexus.configs.giveHand ) then
		pl:Give( "nexus_hands" )
	end
		
	if ( nexus.configs.giveKey ) then
		pl:Give( "nexus_key" )
	end
	
	hook.Run( "CharacterSpawned", pl )
end

function GM:PlayerInitialSpawn( pl )
	//nexus.character.SendCharacterPanel( pl )
end

function GM:PlayerHealthChanged( pl )
	return GAMEMODE:PlayerHurt( pl )
end

function GM:PlayerHurt( pl )
	return true
end

function GM:PlayerDeathSound( ply )
	return true
end