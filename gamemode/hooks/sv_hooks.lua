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
	if ( !pl:IsCharacterLoaded( ) ) then return end
	local status = hook.Run( "CanLookF1", pl )
	if ( !status ) then return end
	
	netstream.Start( pl, "catherine.ShowHelp" )
end

function GM:ShowTeam( pl )
	if ( !pl:IsCharacterLoaded( ) ) then return end
	local status = hook.Run( "CanLookF2", pl )
	if ( !status ) then return end
	
	local ent = pl:GetEyeTrace( 70 ).Entity
	
	if ( IsValid( ent ) and catherine.entity.IsDoor( ent ) ) then
		if ( catherine.door.IsDoorOwner( pl, ent, CAT_DOOR_FLAG_MASTER ) ) then
			netstream.Start( pl, "catherine.door.DoorMenu", ent:EntIndex( ) )
		else
			catherine.util.QueryReceiver( pl, "BuyDoor_Question", LANG( pl, "Door_Notify_BuyQ" ), function( _, bool )
				if ( bool ) then
					catherine.door.Buy( pl, ent )
				end
			end )
		end
	else
		netstream.Start( pl, "catherine.recognize.SelectMenu" )
	end
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

function GM:ScalePlayerDamage( pl, hitGroup, dmgInfo )
	if ( !pl:IsPlayer( ) ) then return end
	catherine.util.ScreenColorEffect( pl, Color( 255, 150, 150 ), 0.5, 0.01 )
	
	if ( hitGroup == CAT_BODY_ID_HEAD ) then
		catherine.util.ScreenColorEffect( pl, nil, 2, 0.005 )
	end
end

function GM:PlayerSpawnedInCharacter( pl )
	catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
	hook.Run( "OnSpawnedInCharacter", pl )
	hook.Run( "PostWeaponGive", pl )
end

function GM:PlayerSetHandsModel( pl, ent )
	local info = player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( pl:GetModel( ) ) )
	
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

function GM:PlayerDisconnected( pl )
	// 나중에 추가 -_-
end

function GM:PlayerCanHearPlayersVoice( pl, target )
	return catherine.configs.voiceAllow, catherine.configs.voice3D
end

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
		timer.Create("Catherine.timer.WeaponToggle." .. pl:SteamID( ), 1, 1, function()
			pl:ToggleWeaponRaised( )
		end )
	elseif ( key == IN_USE ) then
		local tr = { }
		tr.start = pl:GetShootPos( )
		tr.endpos = tr.start + pl:GetAimVector( ) * 60
		tr.filter = pl
		
		local ent = util.TraceLine( tr ).Entity
		
		if ( !IsValid( ent ) ) then return end
		
		if ( catherine.entity.IsDoor( ent ) ) then
			if ( pl.canUseDoor == nil ) then
				pl.canUseDoor = true
			end
			
			if ( !pl.doorSpamCount ) then
				pl.doorSpamCount = 0
			end
			
			if ( pl.lookingDoorEntity == nil ) then
				pl.lookingDoorEntity = ent
			end
			
			pl.doorSpamCount = pl.doorSpamCount + 1
			
			if ( pl.lookingDoorEntity == ent and pl.doorSpamCount >= 10 ) then
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
		elseif ( ent.IsCustomUse ) then
			netstream.Start( pl, "catherine.entity.CustomUseMenu", ent:EntIndex( ) )
		end
	end
end

function GM:PlayerUse( pl, ent )
	return catherine.entity.IsDoor( ent ) and pl.canUseDoor or true
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
		timer.Remove( "Catherine.timer.WeaponToggle." .. pl:SteamID( ) )
	end
end

function GM:PlayerInitialSpawn( pl )
	timer.Simple( 1, function( )
		pl:SetNoDraw( true )
	end )
	
	catherine.player.Initialize( pl )
end

local IsAdmin = function( _, pl ) return pl:IsAdmin( ) end

GM.PlayerGiveSWEP = IsAdmin
GM.PlayerSpawnSWEP = IsAdmin
GM.PlayerSpawnEffect = IsAdmin
GM.PlayerSpawnNPC = IsAdmin
GM.PlayerSpawnRagdoll = IsAdmin
GM.PlayerSpawnVehicle = IsAdmin
GM.PlayerSpawnSENT = IsAdmin

function GM:PlayerSpawnObject( pl )
	return pl:HasFlag( "e" )
end

function GM:PlayerSpawnProp( pl )
	return pl:HasFlag( "e" )
end

function GM:PlayerHurt( pl )
	if ( pl:Health( ) <= 0 ) then
		return true
	end
	
	pl.CAT_healthRecover = true
	
	local hitGroup = pl:LastHitGroup( )
	local sound = hook.Run( "GetPlayerPainSound", pl )
	local gender = pl:GetGender( )
	
	if ( !sound ) then
		if ( hitGroup == HITGROUP_HEAD) then
			sound = "vo/npc/" .. gender .. "01/ow0" .. math.random( 1, 2 ) .. ".wav"
		elseif ( hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC ) then
			sound = "vo/npc/" .. gender .. "01/hitingut0" .. math.random( 1, 2 ) .. ".wav"
		elseif ( hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG ) then
			sound = "vo/npc/" .. gender .. "01/myleg0" .. math.random( 1, 2 ) .. ".wav"
		elseif ( hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM ) then
			sound = "vo/npc/" .. gender .. "01/myarm0" .. math.random( 1, 2 ) .. ".wav"
		elseif ( hitGroup == HITGROUP_GEAR ) then
			sound = "vo/npc/" .. gender .. "01/startle0" .. math.random( 1, 2 ) .. ".wav"
		end
	end
	
	pl:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 1, 6 ) .. ".wav" )
	hook.Run( "PlayerTakeDamage", pl )
	
	return true
end

function GM:PlayerDeathSound( pl )
	pl:EmitSound( hook.Run( "GetPlayerDeathSound", pl ) or "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
	
	return true
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
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		catherine.player.BunnyHopProtection( v )
		catherine.player.HealthRecoverTick( v )
	end
end

function GM:GetUnknownTargetName( pl, target )
	return LANG( pl, "Recognize_UI_Unknown" )
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