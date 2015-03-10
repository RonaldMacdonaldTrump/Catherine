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

function GM:TranslateActivity(pl, act)
	local model = pl:GetModel( ):lower( )
	local class = catherine.anim.getModelClass( model )
	local weapon = pl:GetActiveWeapon( )
	local animTab = catherine.anim[ class ]
	
	if ( class == "player" ) then
		if ( IsValid( weapon ) and pl:OnGround( ) ) then
			if ( model:find("zombie") ) then
				local tree = catherine.anim.zombie

				if ( model:find("fast") ) then
					tree = catherine.anim.fastZombie
				end

				if ( tree[ act ] ) then
					return tree[ act ]
				end
			end

			local holdType = weapon:GetHoldType( )
			local value = PlayerHoldType[ holdType ] or "passive"
			local tree = catherine.anim.player[ value ]

			if ( tree and tree[ act ] ) then
				return tree[ act ]
			end
		end

		return self.BaseClass:TranslateActivity( pl, act )
	end

	if ( animTab ) then
		local subClass = "normal"

		if ( pl:InVehicle( ) and animTab.vehicle ) then
			local vehicle = pl:GetVehicle( )
			if ( vehicle and IsValid( vehicle ) ) then
				local act = animTab.vehicle[ vehicle:GetClass( ) ][ pl:GetWeaponRaised( ) and 2 or 1 ]
				
				if ( type( act ) == "string" ) then
					pl.Calcseq = pl:LookupSequence( act )
					return
				else
					return act
				end
			end
		end
		
		if ( pl:OnGround( ) ) then
			if ( IsValid( weapon ) ) then
				subClass = weapon:GetHoldType( )
				subClass = Weapon_HoldType[subClass] or subClass
			end

			if ( animTab[ subClass ] and animTab[ subClass ][ act ] ) then
				local act2 = animTab[ subClass ][ act ][ pl:GetWeaponRaised( ) and 2 or 1 ]
				if ( type( act2 ) == "string" ) then
					pl.Calcseq = pl:LookupSequence(act2)
					return
				end
				return act2
			end
		elseif ( animTab.glide ) then
			return animTab.glide
		end
	end
end
--[[
function GM:DoAnimationEvent(pl, event, data)
	local model = pl:GetModel():lower()
	local class = catherine.anim.getModelClass(model)

	if (class == "player") then
		return self.BaseClass:DoAnimationEvent(pl, event, data)
	else
		local weapon = pl:GetActiveWeapon()

		if (IsValid(weapon)) then
			local holdType = weapon:GetHoldType()
			holdType = Weapon_HoldType[holdType] or holdType

			local animation = catherine.anim[class][holdType]

			if (event == PLAYERANIMEVENT_ATTACK_PRIMARY) then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

				return ACT_VM_PRIMARYATTACK
			elseif (event == PLAYERANIMEVENT_ATTACK_SECONDARY) then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

				return ACT_VM_SECONDARYATTACK
			elseif (event == PLAYERANIMEVENT_RELOAD) then
				pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.reload or ACT_GESTURE_RELOAD_SMG1, true)

				return ACT_INVALID
			elseif (event == PLAYERANIMEVENT_JUMP) then
				pl.m_bJumping = true
				pl.m_bFistJumpFrame = true
				pl.m_flJumpStartTime = CurTime()

				pl:AnimRestartMainSequence()

				return ACT_INVALID
			elseif (event == PLAYERANIMEVENT_CANCEL_RELOAD) then
				pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)

				return ACT_INVALID
			end
		end
	end

	return ACT_INVALID
end

function GM:CalcMainActivity(pl, velocity)
	local eyeAngles = pl:EyeAngles()
	local yaw = velocity:Angle().yaw
	local normalized = math.NormalizeAngle(yaw - eyeAngles.y)

	pl:SetPoseParameter("move_yaw", normalized)

	if (CLIENT) then
		pl:SetIK(false)
	end

	local oldSeqOverride = pl.CalcSeqOverride
	local seqIdeal, seqOverride = self.BaseClass:CalcMainActivity(pl, velocity)
	--pl.CalcSeqOverride is being -1 after this line.

	return seqIdeal, pl.nutForceSeq or oldSeqOverride or pl.CalcSeqOverride
end
--]]