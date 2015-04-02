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

function GM:ShowHelp( pl )
	netstream.Start( pl, "catherine.ShowHelp" )
end

function GM:GetGameDescription( )
	return "CAT - ".. ( Schema and Schema.Name or "Unknown" )
end

function GM:PlayerSpray( pl )
	return !hook.Run( "PlayerCanSpray", pl )
end

function GM:PlayerSpawn( pl )
	pl:SetNoDraw( false )
	pl:Freeze( false )
	pl:ConCommand( "-duck" )
	pl:SetColor( Color( 255, 255, 255, 255 ) )
	player_manager.SetPlayerClass( pl, "catherine_player" )
	if ( pl:IsCharacterLoaded( ) and !pl.CAT_loadingChar ) then
		hook.Run( "PlayerSpawnedInCharacter", pl )
	end
end

function GM:PlayerSpawnedInCharacter( pl )
	catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
	hook.Run( "OnSpawnedInCharacter", pl )
	hook.Run( "PostWeaponGive", pl )
end

function GM:PlayerSetHandsModel( pl, ent )
	local info = player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( pl:GetModel( ) ) )
	if ( !info ) then return end
	ent:SetModel( info.model )
	ent:SetSkin( info.skin )
	ent:SetBodyGroups( info.body )
end

function GM:PlayerDisconnected( pl )
	if ( IsValid( pl.dummy ) ) then
		pl.dummy:Remove( )
	end
end

function GM:PlayerCanHearPlayersVoice( pl, target )
	return catherine.configs.voiceAllow, catherine.configs.voice3D
end

// 철인 RP 방지 시스템
function GM:EntityTakeDamage( pl, dmginfo )
	if ( !pl:IsPlayer( ) or !dmginfo:IsBulletDamage( ) ) then return end
	pl:SetRunSpeed( pl:GetWalkSpeed( ) )
	timer.Remove( "Catherine.timer.RunSpamProtection_" .. pl:SteamID( ) )
	timer.Create( "Catherine.timer.RunSpamProtection_" .. pl:SteamID( ), 2, 1, function( )
		pl:SetRunSpeed( catherine.configs.playerDefaultRunSpeed )
	end )
end

function GM:KeyPress( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Create("Catherine.timer.weapontoggle." .. pl:SteamID( ), 1, 1, function()
			if ( !IsValid( pl ) ) then return end
			pl:ToggleWeaponRaised( )
		end )
	elseif ( key == IN_USE ) then
		local tr = { }
		tr.start = pl:GetShootPos( )
		tr.endpos = tr.start + pl:GetAimVector( ) * 60
		tr.filter = pl
		local ent = util.TraceLine( tr ).Entity
		if ( IsValid( ent ) and ent:IsDoor( ) ) then
			if ( pl.canUseDoor == nil ) then pl.canUseDoor = true end
			if ( !pl.doorSpamCount ) then pl.doorSpamCount = 0 end
			if ( pl.lookingDoorEntity == nil ) then pl.lookingDoorEntity = ent end
			pl.doorSpamCount = pl.doorSpamCount + 1
			
			if ( ( pl.lookingDoorEntity == ent ) and pl.doorSpamCount >= 10 ) then
				pl.lookingDoorEntity = nil
				pl.doorSpamCount = 0
				pl.canUseDoor = false
				catherine.util.Notify( pl, "Do not door-spam!" )
				timer.Create( "Catherine.timer.doorSpamDelay", 1, 1, function( )
					pl.canUseDoor = true
				end )
				timer.Remove( "Catherine.timer.doorSpamInit" )
			elseif ( pl.lookingDoorEntity != ent ) then
				pl.lookingDoorEntity = ent
				pl.doorSpamCount = 1
			end
			timer.Remove( "Catherine.timer.doorSpamInit" )
			timer.Create( "Catherine.timer.doorSpamInit", 1, 1, function( )
				pl.canUseDoor = true
				pl.doorSpamCount = 0
			end )
			
			return hook.Run( "PlayerUseDoor", pl, ent )
		elseif ( IsValid( ent ) and ent.isCustomUse and type( ent.customUseFunction ) == "function" ) then
			ent.customUseFunction( pl, ent )
		end
	elseif ( key == IN_SPEED ) then
		pl.CAT_runStart = true
	end
end

function GM:PlayerUse( pl, ent )
	if ( ent:IsDoor( ) ) then
		return pl.canUseDoor
	end
	return true
end

function GM:PostWeaponGive( pl )
	if ( catherine.configs.giveHand ) then
		pl:Give( "cat_fist" )
	end
	if ( catherine.configs.giveKey ) then
		pl:Give( "cat_key" )
	end
end

function GM:PlayerSay( pl, text )
	catherine.chat.Work( pl, text )
end

function GM:KeyRelease( pl, key )
	if ( key == IN_RELOAD ) then 
		timer.Remove( "Catherine.timer.weapontoggle." .. pl:SteamID( ) )
	elseif ( key == IN_SPEED ) then
		pl.CAT_runStart = false
	end
end

function GM:PlayerInitialSpawn( pl )
	timer.Simple( 1, function( )
		pl:SetNoDraw( true )
	end )

	timer.Create( "Catherine.timer.waitPlayer." .. pl:SteamID( ), 1, 0, function( )
		if ( IsValid( pl ) and pl:IsPlayer( ) ) then
			timer.Remove( "Catherine.timer.waitPlayer." .. pl:SteamID( ) )
			timer.Simple( 4, function( )
				catherine.player.Initialize( pl )
				pl:SetNoDraw( true )
			end )
		end
	end )
end

function GM:PlayerGiveSWEP( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnSWEP( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnEffect( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnNPC( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnObject( pl )
	return pl:HasFlag( "e" )
end

function GM:PlayerSpawnProp( pl )
	return pl:HasFlag( "e" )
end

function GM:PlayerSpawnRagdoll( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnVehicle( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnSENT( pl )
	return pl:IsAdmin( )
end

function GM:PlayerHurt( pl )
	if ( pl:Health( ) <= 0 ) then
		return true
	end
	catherine.util.ScreenColorEffect( pl, Color( 255, 150, 150 ), 0.5, 0.01 )
	pl.CAT_healthRecoverBool = true
	pl:EmitSound( hook.Run( "GetPlayerPainSound", pl ) or "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 1, 6 ).. ".wav" )
	hook.Run( "PlayerTakeDamage", pl )
	return true
end

function GM:PlayerDeathSound( pl )
	pl:EmitSound( hook.Run( "GetPlayerDeathSound", pl ) or "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
	return true
end

function GM:PlayerDeathThink( pl )
	// do nothing :)
end

function GM:PlayerDeath( pl )
	if ( IsValid( pl.ragdoll ) ) then
		pl.ragdoll:Remove( )
		pl.ragdoll = nil
	end
		
	pl.CAT_healthRecoverBool = false
	catherine.util.ProgressBar( pl, "You are now respawning.", catherine.configs.spawnTime, function( )
		pl:Spawn( )
	end )
	pl:SetNetVar( "nextSpawnTime", CurTime( ) + catherine.configs.spawnTime )
	pl:SetNetVar( "deathTime", CurTime( ) )
	hook.Run( "PlayerGone", pl )
end

function GM:Tick( )
	// Health auto recover system.
	// Bunny hop protection.
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( v:KeyPressed( IN_JUMP ) and ( v.CAT_nextBunnyCheck or CurTime( ) ) <= CurTime( ) ) then
			if ( !v.CAT_nextBunnyCheck ) then
				v.CAT_nextBunnyCheck = CurTime( ) + 0.05
			end
			v.CAT_bunnyCount = ( v.CAT_bunnyCount or 0 ) + 1
			if ( v.CAT_bunnyCount >= 10 ) then
				v:SetJumpPower( 150 )
				catherine.util.Notify( v, "Don't Bunny-hop!" )
				v:Freeze( true )
				v.CAT_bunnyFreezed = true
				v.CAT_nextbunnyFreezeDis = CurTime( ) + 5
			end
			v.CAT_nextBunnyCheck = CurTime( ) + 0.05
		else
			if ( ( v.CAT_nextBunnyInit or CurTime( ) ) <= CurTime( ) ) then
				v.CAT_bunnyCount = 0
				v.CAT_nextBunnyInit = CurTime( ) + 15
			end
		end
		if ( v.CAT_bunnyFreezed and ( v.CAT_nextbunnyFreezeDis or CurTime( ) ) <= CurTime( ) ) then
			v:Freeze( false )
			v.CAT_bunnyCount = 0
			v.CAT_bunnyFreezed = false
		end
		--[[ // ^-^;
		if ( v.CAT_runStart ) then
			if ( !v.CAT_runAnimation ) then
				v.CAT_runAnimation = 0
			end
			v.CAT_runAnimation = Lerp( 0.03, v.CAT_runAnimation, catherine.configs.playerDefaultRunSpeed )
			if ( catherine.character.GetCharacterVar( v, "stamina", 100 ) >= 11 ) then
				v:SetRunSpeed( v.CAT_runAnimation )
			end
		else
			v.CAT_runAnimation = 0
		end
		--]]
		if ( !v.CAT_healthRecoverBool ) then continue end
		if ( !v.CAT_healthRecoverTime ) then v.CAT_healthRecoverTime = CurTime( ) + 3 end
		if ( math.Round( v:Health( ) ) >= v:GetMaxHealth( ) ) then
			v.CAT_healthRecoverBool = false
			hook.Run( "HealthFullRecovered", v )
			continue
		end
		if ( v.CAT_healthRecoverTime <= CurTime( ) ) then
			v:SetHealth( math.Clamp( v:Health( ) + 1, 0, v:GetMaxHealth( ) ) )
			v.CAT_healthRecoverTime = CurTime( ) + 3
			hook.Run( "HealthRecovering", v )
		end
	end
end

function GM:Initialize( )
	hook.Run( "GamemodeInitialized" )
end

function GM:PlayerShouldTakeDamage( )
	return true
end

function GM:GetFallDamage( pl, spd )
	local custom = hook.Run( "GetCustomFallDamage", pl, spd )
	return custom or ( spd - 580 ) * 0.8
end

function GM:InitPostEntity( )
	hook.Run( "DataLoad" )
end

function GM:ShutDown( )
	hook.Run( "PostDataSave" )
	hook.Run( "DataSave" )
end