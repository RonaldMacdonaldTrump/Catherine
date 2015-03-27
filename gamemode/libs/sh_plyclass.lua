local PLAYER = { }
PLAYER.DisplayName = "Catherine Player"

function PLAYER:Loadout( )
	self.Player:SetupHands( )
end

function PLAYER:GetHandsModel( )
	return player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( self.Player:GetModel( ) ) )
end

player_manager.RegisterClass( "catherine_player", PLAYER, "player_default" )
