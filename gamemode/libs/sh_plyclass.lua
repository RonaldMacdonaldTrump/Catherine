local PLAYER = { }

PLAYER.DuckSpeed = 0.1
PLAYER.UnDuckSpeed = 0.1

PLAYER.WalkSpeed = catherine.configs.playerDefaultWalkSpeed
PLAYER.RunSpeed	= catherine.configs.playerDefaultRunSpeed

player_manager.RegisterClass( "catherine_player", PLAYER, "player_default" )
