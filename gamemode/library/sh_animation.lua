--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

--[[
	This code has brought from NutScript.
	https://github.com/Chessnut/NutScript
--]]
catherine.animation = catherine.animation or { lists = { } }

function catherine.animation.Register( class, mdl )
	catherine.animation.lists[ mdl:lower( ) ] = class
end

function catherine.animation.Get( mdl )
	mdl = mdl:lower( )
	
	return catherine.animation.lists[ mdl ] or ( mdl:find( "female" ) and "citizen_female" or "citizen_male" )
end

local function RegisterCitizen( gender )
	for k, v in pairs( file.Find("models/humans/group01/" .. gender .. "_*.mdl", "GAME" ) ) do
		catherine.animation.Register( "citizen_" .. gender, "models/humans/group01/" .. v )
	end

	for k, v in pairs( file.Find("models/humans/group02/" .. gender .. "_*.mdl", "GAME" ) ) do
		catherine.animation.Register( "citizen_" .. gender, "models/humans/group02/" .. v )
	end

	for k, v in pairs( file.Find("models/humans/group03/" .. gender .. "_*.mdl", "GAME" ) ) do
		catherine.animation.Register( "citizen_" .. gender, "models/humans/group03/" .. v )
	end

	for k, v in pairs( file.Find("models/humans/group04/" .. gender .. "_*.mdl", "GAME" ) ) do
		catherine.animation.Register( "citizen_" .. gender, "models/humans/group04/" .. v )
	end
end

RegisterCitizen( "male" )
RegisterCitizen( "female" )
catherine.animation.Register( "citizen_female", "models/mossman.mdl" )
catherine.animation.Register( "citizen_female", "models/alyx.mdl" )
catherine.animation.Register( "metrocop", "models/police.mdl" )
catherine.animation.Register( "overwatch", "models/combine_super_soldier.mdl" )
catherine.animation.Register( "overwatch", "models/combine_soldier_prisonguard.mdl" )
catherine.animation.Register( "overwatch", "models/combine_soldier.mdl" )
catherine.animation.Register( "vort", "models/vortigaunt.mdl" )
catherine.animation.Register( "vort", "models/vortigaunt_slave.mdl" )
catherine.animation.Register( "metrocop", "models/dpfilms/metropolice/playermodels/pm_skull_police.mdl" )

catherine.animation.citizen_male = {
	normal = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED}
	},
	pistol = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		idle = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		run = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		idle = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		run = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		idle = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		idle = {ACT_IDLE_SUITCASE, ACT_IDLE_ANGRY_MELEE},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		run = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE
}

catherine.animation.citizen_female = {
	normal = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED}
	},
	pistol = {
		idle = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_PISTOL},
		run = {ACT_RUN, ACT_RUN_AIM_PISTOL},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		idle = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		run = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		idle = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		run = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		idle = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		run = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE
}

catherine.animation.metrocop = {
	normal = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_PISTOL_LOW, ACT_COVER_SMG1_LOW},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		run = {ACT_RUN, ACT_RUN}
	},
	pistol = {
		idle = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		idle_crouch = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		walk = {ACT_WALK_PISTOL, ACT_WALK_AIM_PISTOL},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		run = {ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL},
		attack = ACT_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		idle = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		walk = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		run = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	shotgun = {
		idle = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		walk = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		run = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE_STIMULATED}
	},
	grenade = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		idle_crouch = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		walk = {ACT_WALK, ACT_WALK_ANGRY},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		run = {ACT_RUN, ACT_RUN},
		attack = ACT_COMBINE_THROW_GRENADE
	},
	melee = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		idle_crouch = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		walk = {ACT_WALK, ACT_WALK_ANGRY},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		run = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE
}

catherine.animation.overwatch = {
	normal = {
		idle = {"idle_unarmed", "man_gun"},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {ACT_WALK_RIFLE, ACT_WALK_RIFLE},
		walk_crouch = {"crouch_walkall", "crouch_walkall"},
		run = {"runall", ACT_RUN_AIM_RIFLE}
	},
	pistol = {
		idle = {"idle_unarmed", ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {"walkunarmed_all", ACT_WALK_RIFLE},
		walk_crouch = {"crouch_walkall", "crouch_walkall"},
		run = {"runall", ACT_RUN_AIM_RIFLE}
	},
	smg = {
		idle = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		walk_crouch = {"crouch_walkall", "crouch_walkall"},
		run = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	shotgun = {
		idle = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SHOTGUN},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {ACT_WALK_RIFLE, ACT_WALK_AIM_SHOTGUN},
		walk_crouch = {"crouch_walkall", "crouch_walkall"},
		run = {ACT_RUN_RIFLE, ACT_RUN_AIM_SHOTGUN}
	},
	grenade = {
		idle = {"idle_unarmed", "man_gun"},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {"walkunarmed_all", ACT_WALK_RIFLE},
		walk_crouch = {"crouch_walkall", "crouch_walkall"},
		run = {"runall", ACT_RUN_AIM_RIFLE}
	},
	melee = {
		idle = {"idle_unarmed", "man_gun"},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {"walkunarmed_all", ACT_WALK_RIFLE},
		walk_crouch = {"crouch_walkall", "crouch_walkall"},
		run = {"runall", ACT_RUN_AIM_RIFLE},
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE
}

catherine.animation.vort = {
	normal = {
		idle = {ACT_IDLE, "actionidle"},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {ACT_WALK, "walk_all_holdgun"},
		walk_crouch = {ACT_WALK, "walk_all_holdgun"},
		run = {ACT_RUN, ACT_RUN}
	},
	pistol = {
		idle = {ACT_IDLE, "tcidle"},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {ACT_WALK, "walk_all_holdgun"},
		walk_crouch = {ACT_WALK, "walk_all_holdgun"},
		run = {ACT_RUN, "run_all_tc"}
	},
	smg = {
		idle = {ACT_IDLE, "tcidle"},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {ACT_WALK, "walk_all_holdgun"},
		walk_crouch = {ACT_WALK, "walk_all_holdgun"},
		run = {ACT_RUN, "run_all_tc"}
	},
	shotgun = {
		idle = {ACT_IDLE, "tcidle"},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {ACT_WALK, "walk_all_holdgun"},
		walk_crouch = {ACT_WALK, "walk_all_holdgun"},
		run = {ACT_RUN, "run_all_tc"}
	},
	grenade = {
		idle = {ACT_IDLE, "tcidle"},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {ACT_WALK, "walk_all_holdgun"},
		walk_crouch = {ACT_WALK, "walk_all_holdgun"},
		run = {ACT_RUN, "run_all_tc"}
	},
	melee = {
		idle = {ACT_IDLE, "tcidle"},
		idle_crouch = {"crouchidle", "crouchidle"},
		walk = {ACT_WALK, "walk_all_holdgun"},
		walk_crouch = {ACT_WALK, "walk_all_holdgun"},
		run = {ACT_RUN, "run_all_tc"}
	},
	glide = ACT_GLIDE
}

if ( SERVER ) then
	function catherine.animation.SetSeqAnimation( pl, seq, time, doFunc, func )
		local rightSeq, len = pl:LookupSequence( seq )
		time = time or len

		if ( !rightSeq or rightSeq == -1 ) then
			return
		end
		
		pl:SetNetVar( "seqAni", seq )

		if ( doFunc ) then
			doFunc( )
		end

		if ( time > 0 ) then
			timer.Create( "Catherine.timer.SeqAnimation_" .. pl.SteamID( pl ), time, 1, function( )
				if ( !IsValid( pl ) ) then return end
				
				catherine.animation.ResetSeqAnimation( pl )

				if ( func ) then
					func( )
				end
			end )
		end

		return time, rightSeq
	end

	function catherine.animation.ResetSeqAnimation( pl )
		pl:SetNetVar( "seqAni", false )
	end
end

function catherine.animation.GetSeqAnimation( pl )
	return pl.GetNetVar( pl, "seqAni", false )
end