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
]]--

catherine.animation = catherine.animation or { lists = { } }

function catherine.animation.Register( class, mdl )
	catherine.animation.lists[ mdl:lower( ) ] = class
end

function catherine.animation.RegisterDataTable( class, dataTable )
	catherine.animation[ class ] = dataTable
end

function catherine.animation.Get( mdl )
	mdl = mdl:lower( )
	
	return catherine.animation.lists[ mdl ] or ( mdl:find( "female" ) and "citizen_female" or "citizen_male" )
end

function catherine.animation.IsClass( ent, class )
	return catherine.animation.lists[ ent:GetModel( ):lower( ) ] == class
end

catherine.animation.RegisterDataTable( "citizen_male", {
	normal = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_LOW, ACT_COVER_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED }
	},
	pistol = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, ACT_RANGE_ATTACK_PISTOL },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_PISTOL_LOW, ACT_RANGE_AIM_PISTOL_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_SMG1_LOW, ACT_RANGE_AIM_SMG1_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_SMG1_LOW, ACT_RANGE_AIM_SMG1_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, ACT_IDLE_MANNEDGUN },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_LOW, ACT_COVER_PISTOL_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN_RIFLE_STIMULATED },
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SUITCASE, ACT_IDLE_ANGRY_MELEE },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_LOW, ACT_COVER_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_AIM_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN },
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE,
	vehicle = {
		[ "prop_vehicle_prisoner_pod" ] = { "podpose", Vector( -3, 0, 0 ) },
		[ "prop_vehicle_jeep" ] = { "sitchair1", Vector( 14, 0, -14 ) },
		[ "prop_vehicle_airboat" ] = { "sitchair1", Vector( 8, 0, -20 ) },
		chair = { "sitchair1", Vector( 1, 0, -23 ) }
	},
} )

catherine.animation.RegisterDataTable( "citizen_female", {
	normal = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, ACT_IDLE_MANNEDGUN },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_LOW, ACT_COVER_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_RANGE_AIM_SMG1_LOW },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED }
	},
	pistol = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_AIM_PISTOL },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN_AIM_PISTOL },
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, ACT_IDLE_MANNEDGUN },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_AIM_PISTOL },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN_AIM_PISTOL },
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SUITCASE, ACT_IDLE_ANGRY_MELEE },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_LOW, ACT_COVER_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_AIM_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN },
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE,
	vehicle = catherine.animation.citizen_male.vehicle
} )

catherine.animation.RegisterDataTable( "metrocop", {
	normal = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_PISTOL_LOW, ACT_COVER_SMG1_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_AIM_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN }
	},
	pistol = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK_PISTOL, ACT_WALK_AIM_PISTOL },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		[ ACT_MP_RUN ] = { ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL },
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_GESTURE_RELOAD_PISTOL
	},
	smg = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		[ ACT_MP_RUN ] = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE }
	},
	shotgun = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		[ ACT_MP_RUN ] = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE }
	},
	grenade = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, ACT_IDLE_ANGRY_MELEE },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_ANGRY },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN },
		attack = ACT_COMBINE_THROW_GRENADE
	},
	melee = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, ACT_IDLE_ANGRY_MELEE },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW },
		[ ACT_MP_WALK ] = { ACT_WALK, ACT_WALK_ANGRY },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN },
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE,
	vehicle = {
		chair = { ACT_COVER_PISTOL_LOW, Vector( 5, 0, -5 ) },
		[ "prop_vehicle_airboat" ] = { ACT_COVER_PISTOL_LOW, Vector( 10, 0, 0 ) },
		[ "prop_vehicle_jeep" ] = { ACT_COVER_PISTOL_LOW, Vector( 18, -2, 4 ) },
		[ "prop_vehicle_prisoner_pod" ] = { ACT_IDLE, Vector( -4, -0.5, 0 ) }
	}
} )

catherine.animation.RegisterDataTable( "overwatch", {
	normal = {
		[ ACT_MP_STAND_IDLE ] = { "idle_unarmed", ACT_IDLE_ANGRY },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
		[ ACT_MP_WALK ] = { "walkunarmed_all", ACT_WALK_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE }
	},
	pistol = {
		[ ACT_MP_STAND_IDLE ] = { "idle_unarmed", ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
		[ ACT_MP_WALK ] = { "walkunarmed_all", ACT_WALK_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE }
	},
	smg = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
		[ ACT_MP_WALK ] = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE }
	},
	shotgun = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SHOTGUN },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
		[ ACT_MP_WALK ] = { ACT_WALK_RIFLE, ACT_WALK_AIM_SHOTGUN },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_RIFLE, ACT_RUN_AIM_SHOTGUN }
	},
	grenade = {
		[ ACT_MP_STAND_IDLE ] = { "idle_unarmed", ACT_IDLE_ANGRY },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
		[ ACT_MP_WALK ] = { "walkunarmed_all", ACT_WALK_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE }
	},
	melee = {
		[ ACT_MP_STAND_IDLE ] = { "idle_unarmed", ACT_IDLE_ANGRY },
		[ ACT_MP_CROUCH_IDLE ] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
		[ ACT_MP_WALK ] = { "walkunarmed_all", ACT_WALK_RIFLE },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
		[ ACT_MP_RUN ] = { ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE },
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE
} )

catherine.animation.RegisterDataTable( "vort", {
	normal = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, "actionidle" },
		[ ACT_MP_CROUCH_IDLE ] = { "crouchidle", "crouchidle" },
		[ ACT_MP_WALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_RUN ] = { ACT_RUN, ACT_RUN }
	},
	pistol = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, "tcidle" },
		[ ACT_MP_CROUCH_IDLE ] = { "crouchidle", "crouchidle" },
		[ ACT_MP_WALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_RUN ] = { ACT_RUN, "run_all_tc" }
	},
	smg = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, "tcidle" },
		[ ACT_MP_CROUCH_IDLE ] = { "crouchidle", "crouchidle" },
		[ ACT_MP_WALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_RUN ] = { ACT_RUN, "run_all_tc" }
	},
	shotgun = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, "tcidle" },
		[ ACT_MP_CROUCH_IDLE ] = { "crouchidle", "crouchidle" },
		[ ACT_MP_WALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_RUN ] = { ACT_RUN, "run_all_tc" }
	},
	grenade = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, "tcidle" },
		[ ACT_MP_CROUCH_IDLE ] = { "crouchidle", "crouchidle" },
		[ ACT_MP_WALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_RUN ] = { ACT_RUN, "run_all_tc" }
	},
	melee = {
		[ ACT_MP_STAND_IDLE ] = { ACT_IDLE, "tcidle" },
		[ ACT_MP_CROUCH_IDLE ] = { "crouchidle", "crouchidle" },
		[ ACT_MP_WALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_CROUCHWALK ] = { ACT_WALK, "walk_all_holdgun" },
		[ ACT_MP_RUN ] = { ACT_RUN, "run_all_tc" }
	},
	glide = ACT_GLIDE
} )

catherine.animation.RegisterDataTable( "player", {
	normal = {
		[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_IDLE,
		[ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_IDLE_CROUCH,
		[ ACT_MP_WALK ] = ACT_HL2MP_WALK,
		[ ACT_MP_RUN ] = ACT_HL2MP_RUN
	 },
	passive = {
		[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_IDLE_PASSIVE,
		[ ACT_MP_WALK ] = ACT_HL2MP_WALK_PASSIVE,
		[ ACT_MP_CROUCHWALK ] = ACT_HL2MP_WALK_CROUCH_PASSIVE,
		[ ACT_MP_RUN ] = ACT_HL2MP_RUN_PASSIVE
	}
} )

catherine.animation.RegisterDataTable( "zombie", {
	[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_IDLE_ZOMBIE,
	[ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE,
	[ ACT_MP_CROUCHWALK ] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01,
	[ ACT_MP_WALK ] = ACT_HL2MP_WALK_ZOMBIE_02,
	[ ACT_MP_RUN ] = ACT_HL2MP_RUN_ZOMBIE
} )

catherine.animation.RegisterDataTable( "fastZombie", {
	[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_WALK_ZOMBIE,
	[ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE,
	[ ACT_MP_CROUCHWALK ] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_05,
	[ ACT_MP_WALK ] = ACT_HL2MP_WALK_ZOMBIE_06,
	[ ACT_MP_RUN ] = ACT_HL2MP_RUN_ZOMBIE_FAST
} )

for i = 1, 4 do
	for k, v in pairs( file.Find( "models/humans/group0" .. i .. "/male_*.mdl", "GAME" ) ) do
		catherine.animation.Register( "citizen_male", "models/humans/group0" .. i .. "/" .. v )
	end
	
	for k, v in pairs( file.Find( "models/humans/group0" .. i .. "/female_*.mdl", "GAME" ) ) do
		catherine.animation.Register( "citizen_female", "models/humans/group0" .. i .. "/" .. v )
	end
end

catherine.animation.Register( "citizen_female", "models/mossman.mdl" )
catherine.animation.Register( "citizen_female", "models/alyx.mdl" )
catherine.animation.Register( "metrocop", "models/police.mdl" )
catherine.animation.Register( "overwatch", "models/combine_super_soldier.mdl" )
catherine.animation.Register( "overwatch", "models/combine_soldier_prisonguard.mdl" )
catherine.animation.Register( "overwatch", "models/combine_soldier.mdl" )
catherine.animation.Register( "vort", "models/vortigaunt.mdl" )
catherine.animation.Register( "vort", "models/vortigaunt_slave.mdl" )
catherine.animation.Register( "metrocop", "models/dpfilms/metropolice/playermodels/pm_skull_police.mdl" )
catherine.animation.Register( "metrocop", "models/dpfilms/metropolice/hl2concept.mdl" )

if ( SERVER ) then
	function catherine.animation.SetSeqAnimation( pl, seqID, time, doFunc, func )
		local rightSeq, len = pl:LookupSequence( seqID )
		time = time or len

		if ( !rightSeq or rightSeq == -1 ) then
			return
		end
		
		pl:SetNetVar( "seqAni", seqID )

		if ( doFunc ) then
			doFunc( )
		end

		if ( time > 0 ) then
			timer.Create( "Catherine.timer.animation.SequenceAnimation." .. pl:SteamID( ), time, 1, function( )
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
	return pl:GetNetVar( "seqAni", false )
end