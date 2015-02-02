--[[DEFINE_BASECLASS( "player_default" )

local PLY = { }
PLY.DisplayName = "Nexus Player"

PLY.WalkSpeed = 1000
PLY.RunSpeed = 2000

function PLY:Spawn()

	self:SetModel( "models/breen.mdl" )
end

function PLY:Loadout( )
	print("Loadout")
end

local META = FindMetaTable( "Player" )

do
	local GetVelocity = FindMetaTable( "Entity" ).GetVelocity
	local Length2D = FindMetaTable( "Vector" ).Length2D

	function META:IsRunning( )
		return Length2D( GetVelocity( self ) ) >= ( nexus.configs.playerDefaultRunSpeed - 10 )
	end
end


player_manager.RegisterClass( "player_nexus", PLY, "player_default" )--]]

local PLAYER = {}

PLAYER.DuckSpeed = 0.1
PLAYER.UnDuckSpeed = 0.1

PLAYER.WalkSpeed = nexus.configs.playerDefaultWalkSpeed
PLAYER.RunSpeed	= nexus.configs.playerDefaultRunSpeed
PLAYER.JumpPower	= nexus.configs.playerJumpPower


function PLAYER:Loadout()

end

local META = FindMetaTable( "Player" )

do
	local GetVelocity = FindMetaTable( "Entity" ).GetVelocity
	local Length2D = FindMetaTable( "Vector" ).Length2D

	function META:IsRunning( )
		return Length2D( GetVelocity( self ) ) >= ( nexus.configs.playerDefaultRunSpeed - 10 )
	end
end

player_manager.RegisterClass( "player_nexus", PLAYER, "player_default" )
