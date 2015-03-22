--[[
	This code has brought by nutscript.
	https://github.com/Chessnut/NutScript
--]]

Weapon_HoldType = {}
Weapon_HoldType[ "" ] = "normal"
Weapon_HoldType[ "physgun" ] = "smg"
Weapon_HoldType[ "ar2" ] = "smg"
Weapon_HoldType[ "crossbow" ] = "shotgun"
Weapon_HoldType[ "rpg" ] = "shotgun"
Weapon_HoldType[ "slam" ] = "normal"
Weapon_HoldType[ "grenade" ] = "normal"
Weapon_HoldType[ "fist" ] = "normal"
Weapon_HoldType[ "melee2" ] = "melee"
Weapon_HoldType[ "passive" ] = "normal"
Weapon_HoldType[ "knife" ] = "melee"
Weapon_HoldType[ "duel" ] = "pistol"
Weapon_HoldType[ "camera" ] = "smg"
Weapon_HoldType[ "magic" ] = "normal"
Weapon_HoldType[ "revolver" ] = "pistol"

PlayerHoldType = {}
PlayerHoldType[ "" ] = "normal"
PlayerHoldType[ "fist" ] = "normal"
PlayerHoldType[ "pistol" ] = "normal"
PlayerHoldType[ "grenade" ] = "normal"
PlayerHoldType[ "melee" ] = "normal"
PlayerHoldType[ "slam" ] = "normal"
PlayerHoldType[ "melee2" ] = "normal"
PlayerHoldType[ "passive" ] = "normal"
PlayerHoldType[ "knife" ] = "normal"
PlayerHoldType[ "duel" ] = "normal"
PlayerHoldType[ "bugbait" ] = "normal"

local Length2D = FindMetaTable("Vector").Length2D
local NormalHoldTypes = {
	normal = true,
	fist = true,
	melee = true,
	revolver = true,
	pistol = true,
	slam = true,
	knife = true,
	grenade = true
}
WEAPON_LOWERED = 1
WEAPON_RAISED = 2

function GM:CalcMainActivity( pl, velo )
	local mdl = pl:GetModel( ):lower( )
	local class = catherine.anim.GetModelAnimation( mdl )
	local wep = pl:GetActiveWeapon( )
	local holdType = "normal"
	local status = WEAPON_LOWERED
	local act = "idle"

	if ( Length2D( velo ) >= catherine.configs.playerDefaultRunSpeed - 10 ) then
		act = "run"
	elseif ( Length2D( velo ) >= 5 ) then
		act = "walk"
	end

	if ( IsValid( wep ) ) then
		holdType = catherine.util.GetHoldType( wep )

		if ( wep.AlwaysRaised or catherine.configs.alwaysRaised[ wep:GetClass( ) ]) then
			status = WEAPON_RAISED
		end
	end

	if ( pl:GetWeaponRaised( ) ) then
		status = WEAPON_RAISED
	end

	if ( mdl:find( "/player" ) or mdl:find( "/playermodel" ) or class == "player" ) then
		local calcIdle, calcOver = self.BaseClass:CalcMainActivity( pl, velo )

		if ( status == WEAPON_LOWERED ) then
			if ( pl:Crouching( ) ) then
				act = act.."_crouch"
			end

			if ( !pl:OnGround( ) ) then
				act = "jump"
			end

			if ( !NormalHoldTypes[ holdType ] ) then
				calcIdle = _G[ "ACT_HL2MP_" .. act:upper( ) .. "_PASSIVE" ]
			else
				if ( act == "jump" ) then
					calcIdle = ACT_HL2MP_JUMP_PASSIVE
				else
					calcIdle = _G[ "ACT_HL2MP_" .. act:upper( ) ]
				end
			end
		end

		pl.CalcIdle = calcIdle
		pl.CalcOver = calcOver

		return pl.CalcIdle, pl.CalcOver
	end
	
	if ( pl:IsCharacterLoaded( ) and pl:Alive( ) ) then
		pl.CalcOver = -1

		if ( pl:Crouching( ) ) then
			act = act .. "_crouch"
		end

		local aniClass = catherine.anim[ class ]

		if ( !aniClass ) then
			class = "citizen_male"
		end

		if ( !aniClass[ holdType ] ) then
			holdType = "normal"
		end

		if ( !aniClass[ holdType ][ act ] ) then
			act = "idle"
		end

		local ani = aniClass[ holdType ][ act ]
		local val = ACT_IDLE

		if ( !pl:OnGround( ) ) then
			pl.CalcIdle = aniClass.glide or ACT_GLIDE
		elseif ( pl:InVehicle( ) ) then
			pl.CalcIdle = aniClass.normal.idle_crouch[ 1 ]
		elseif ( ani ) then
			val = ani[ status ]
			if ( type( val ) == "string" ) then
				pl.CalcOver = pl:LookupSequence( val )
			else
				pl.CalcIdle = val
			end
		end

		if ( CLIENT ) then
			pl:SetIK( false )
		end

		local norm = math.NormalizeAngle( velo:Angle( ).yaw - pl:EyeAngles( ).y)
		pl:SetPoseParameter( "move_yaw", norm )
		return pl.CalcIdle or ACT_IDLE, pl.CalcOver or -1
	end
end

function GM:PlayerNoClip( pl, bool )
	if ( pl:IsAdmin( ) ) then
		if ( pl:GetMoveType( ) == MOVETYPE_WALK ) then
			pl:SetNoDraw( true )
			pl:DrawShadow( false )
			pl:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			if ( SERVER ) then catherine.network.SetNetVar( pl, "nocliping", true ) end
		else
			pl:SetNoDraw( false )
			pl:DrawShadow( true )
			pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
			if ( SERVER ) then catherine.network.SetNetVar( pl, "nocliping", false ) end
		end
	end
	return pl:IsAdmin( )
end