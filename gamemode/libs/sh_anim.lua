--[[
	This code has brought by Nutscript.
	https://github.com/Chessnut/NutScript
--]]
catherine.anim = catherine.anim or { }
catherine.anim.Classes = catherine.anim.Classes or { }

function catherine.anim.SetModelAnimation( class, mdl )
	catherine.anim.Classes[ mdl:lower( ) ] = class
end

function catherine.anim.GetModelAnimation( mdl )
	mdl = mdl:lower( )
	return catherine.anim.Classes[ mdl ] or ( mdl:find( "female" ) and "citizen_female" or "citizen_male" )
end

local pre = {
	"male", "female"
}

for i = 1, 2 do
	for k, v in pairs( file.Find("models/humans/group01/" .. pre[ i ] .. "_*.mdl", "GAME" ) ) do
		catherine.anim.SetModelAnimation( "citizen_" .. pre[ i ], "models/humans/group01/" .. v )
	end

	for k, v in pairs( file.Find("models/humans/group02/" .. pre[ i ] .. "_*.mdl", "GAME" ) ) do
		catherine.anim.SetModelAnimation( "citizen_" .. pre[ i ], "models/humans/group02/" .. v )
	end

	for k, v in pairs( file.Find("models/humans/group03/" .. pre[ i ] .. "_*.mdl", "GAME" ) ) do
		catherine.anim.SetModelAnimation( "citizen_" .. pre[ i ], "models/humans/group03/" .. v )
	end

	for k, v in pairs( file.Find("models/humans/group04/" .. pre[ i ] .. "_*.mdl", "GAME" ) ) do
		catherine.anim.SetModelAnimation( "citizen_" .. pre[ i ], "models/humans/group04/" .. v )
	end
end

catherine.anim.SetModelAnimation( "citizen_female", "models/mossman.mdl" )
catherine.anim.SetModelAnimation( "citizen_female", "models/alyx.mdl" )
catherine.anim.SetModelAnimation( "metrocop", "models/police.mdl" )
catherine.anim.SetModelAnimation( "overwatch", "models/combine_super_soldier.mdl" )
catherine.anim.SetModelAnimation( "overwatch", "models/combine_soldier_prisonguard.mdl" )
catherine.anim.SetModelAnimation( "overwatch", "models/combine_soldier.mdl" )
catherine.anim.SetModelAnimation( "vort", "models/vortigaunt.mdl" )
catherine.anim.SetModelAnimation( "vort", "models/vortigaunt_slave.mdl" )
catherine.anim.SetModelAnimation( "metrocop", "models/dpfilms/metropolice/playermodels/pm_skull_police.mdl" )

catherine.anim.citizen_male = {
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

catherine.anim.citizen_female = {
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

catherine.anim.metrocop = {
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

catherine.anim.overwatch = {
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

catherine.anim.vort = {
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