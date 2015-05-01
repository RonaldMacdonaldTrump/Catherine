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
	if ( !pl.IsCharacterLoaded( pl ) ) then return end
	local status = hook.Run( "CanLookF1", pl )
	if ( !status ) then return end
	
	netstream.Start( pl, "catherine.ShowHelp" )
end

function GM:ShowTeam( pl )
	if ( !pl.IsCharacterLoaded( pl ) ) then return end
	local status = hook.Run( "CanLookF2", pl )
	if ( !status ) then return end
	
	local ent = pl.GetEyeTrace( pl, 70 ).Entity
	
	if ( IsValid( ent ) and catherine.entity.IsDoor( ent ) and !catherine.door.IsDoorDisabled( ent ) ) then
		local has, flag = catherine.door.IsHasDoorPermission( pl, ent )
		
		if ( has ) then
			if ( flag == CAT_DOOR_FLAG_BASIC ) then return end
			
			netstream.Start( pl, "catherine.door.DoorMenu", {
				ent.EntIndex( ent ),
				flag
			} )
		else
			local isBuyable = catherine.door.IsBuyableDoor( ent )
			if ( !isBuyable ) then return end
			
			catherine.util.QueryReceiver( pl, "BuyDoor_Question", LANG( pl, "Door_Notify_BuyQ" ), function( _, bool )
				if ( bool ) then
					catherine.command.Run( pl, "doorbuy" )
				end
			end )
		end
	else
		netstream.Start( pl, "catherine.recognize.SelectMenu" )
	end
end

function GM:CanLookF1( pl )
	return true
end

function GM:CanLookF2( pl )
	return true
end

function GM:CanPlayerSuicide( pl )
	return hook.Run( "PlayerCanSuicide", pl ) or false
end

function GM:GetGameDescription( )
	return "CAT - " .. ( Schema and Schema.Name or "Unknown" )
end

function GM:PlayerSpray( pl )
	return !hook.Run( "PlayerCanSpray", pl )
end

function GM:Move( pl, moveData )
	if ( pl.IsCharacterLoaded( pl ) ) then
		if ( pl.GetNetVar( pl, "isActioning" ) ) then
			moveData:SetForwardSpeed( 0 )
			moveData:SetSideSpeed( 0 )
		else
		end
	end
end

function GM:PlayerSpawn( pl )
	if ( IsValid( pl.deathBody ) ) then
		pl.deathBody.Remove( pl.deathBody )
		pl.deathBody = nil
	end
	
	if ( IsValid( pl.CAT_ragdoll ) ) then
		pl.CAT_ragdoll.Remove( pl.CAT_ragdoll )
		pl.CAT_ragdoll = nil
	end
	
	if ( pl.CAT_deathSoundPlayed ) then
		pl.CAT_deathSoundPlayed = nil
	end
	
	pl:SetNetVar( "noDrawOriginal", nil )
	
	pl.SetNoDraw( pl, false )
	pl.Freeze( pl, false )
	pl.ConCommand( pl, "-duck" )
	pl.SetColor( pl, Color( 255, 255, 255, 255 ) )
	pl.SetNetVar( pl, "isTied", false )
	pl.SetupHands( pl )

	local status = hook.Run( "PlayerCanFlashlight", pl ) or false
	pl.AllowFlashlight( pl, status )

	if ( pl.IsCharacterLoaded( pl ) and !pl.CAT_loadingChar ) then
		hook.Run( "PlayerSpawnedInCharacter", pl )
	end
end

function GM:ScalePlayerDamage( pl, hitGroup, dmgInfo )
	if ( !pl.IsPlayer( pl ) ) then return end

	catherine.util.ScreenColorEffect( pl, Color( 255, 150, 150 ), 0.5, 0.01 )
	
	if ( hitGroup == CAT_BODY_ID_HEAD ) then
		catherine.util.ScreenColorEffect( pl, nil, 2, 0.005 )
	end
end

function GM:PlayerSpawnedInCharacter( pl )
	catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
	hook.Run( "OnSpawnedInCharacter", pl )
	
	if ( catherine.configs.giveHand ) then
		pl.Give( pl, "cat_fist" )
	end
	
	if ( catherine.configs.giveKey ) then
		pl.Give( pl, "cat_key" )
	end
end

function GM:PlayerSetHandsModel( pl, ent )
	local info = player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( pl.GetModel( pl ) ) )
	
	if ( info ) then
		ent.SetModel( ent, info.model )
		ent.SetSkin( ent, info.skin )
		ent.SetBodyGroups( ent, info.body )
	end
end

function GM:PlayerAuthed( pl )
	catherine.chat.Send( pl, "connect" )
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, pl.SteamName( pl ) .. ", " .. pl.SteamID( pl ) .. " has connected a server." )
	
	hook.Run( "PlayerInitSpawned", pl )
end

function GM:PlayerDisconnected( pl )
	if ( IsValid( pl.deathBody ) ) then
		pl.deathBody:Remove( )
	end
	
	catherine.chat.Send( pl, "disconnect" )
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, pl.SteamName( pl ) .. ", " .. pl.SteamID( pl ) .. " has disconnected a server." )
	
	if ( pl.IsCharacterLoaded( pl ) ) then
		hook.Run( "PlayerDisconnectedInCharacter", pl )
	end
end

function GM:PlayerCanHearPlayersVoice( pl, target )
	return catherine.configs.voiceAllow, catherine.configs.voice3D
end

function GM:EntityTakeDamage( ent, dmginfo )
	local entPlayer = ent
	
	if ( ent.GetClass( ent ) == "prop_ragdoll" ) then
		local pl = ent.GetNetVar( ent, "player" )
		
		if ( IsValid( pl ) and pl.IsPlayer( pl ) ) then
			local inflictor = dmginfo:GetInflictor( )
			local attacker = dmginfo:GetAttacker( )
			local amount = dmginfo:GetDamage( )
			
			pl.CAT_ignore_hurtSound = true
			
			pl:TakeDamage( amount, attacker, inflictor )
			
			pl.CAT_ignore_hurtSound = nil

			if ( pl.Health( pl ) <= 0 ) then
				if ( !pl.CAT_deathSoundPlayed ) then
					hook.Run( "PlayerDeathSound", pl, ent )
				end
			else
				hook.Run( "PlayerTakeDamage", pl, attacker, ent )
			end
		end
	end
	
	if ( ent.IsPlayer( ent ) and dmginfo.IsBulletDamage( dmginfo ) ) then
		ent.SetRunSpeed( ent, ent.GetWalkSpeed( ent ) )
		
		local steamID = ent.SteamID( ent )
		timer.Remove( "Catherine.timer.RunSpamProtection_" .. steamID )
		timer.Create( "Catherine.timer.RunSpamProtection_" .. steamID, 2, 1, function( )
			ent.SetRunSpeed( ent, catherine.configs.playerDefaultRunSpeed )
		end )
	end
end

function GM:PlayerCanFlashlight( pl )
	return true
end

function GM:KeyPress( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Create( "Catherine.timer.WeaponToggle." .. pl.SteamID( pl ), 1, 1, function( )
			pl.ToggleWeaponRaised( pl )
		end )
	elseif ( key == IN_USE ) then
		local data = { }
		data.start = pl.GetShootPos( pl )
		data.endpos = data.start + pl.GetAimVector( pl ) * 60
		data.filter = pl
		local ent = util.TraceLine( data ).Entity
		
		if ( !IsValid( ent ) ) then return end
		
		if ( ent.GetClass( ent ) == "prop_ragdoll" ) then
			ent = ent.GetNetVar( ent, "player" )
		end
		
		if ( IsValid( ent ) and ent.IsPlayer( ent ) ) then
			return hook.Run( "PlayerInteract", pl, ent )
		end

		if ( IsValid( ent ) and catherine.entity.IsDoor( ent ) ) then
			if ( hook.Run( "PlayerCanUseDoor", pl, ent ) == false ) then
				return
			end
			
			catherine.door.DoorSpamProtection( pl, ent )

			return hook.Run( "PlayerUseDoor", pl, ent )
		elseif ( IsValid( ent ) and ent.IsCustomUse ) then
			netstream.Start( pl, "catherine.entity.CustomUseMenu", ent.EntIndex( ent ) )
		end
	end
end

function GM:PlayerUse( pl, ent )
	if ( catherine.player.IsTied( pl ) ) then
		if ( ( pl.CAT_tiedMSG or CurTime( ) ) <= CurTime( ) ) then
			catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
			pl.CAT_tiedMSG = CurTime( ) + 5
		end
		
		return false
	end

	local isDoor = catherine.entity.IsDoor( ent )
	
	return ( isDoor and !pl.CAT_cantUseDoor == true ) and true or !isDoor and true
end

function GM:PlayerSay( pl, text )
	catherine.chat.Run( pl, text )
end

function GM:KeyRelease( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Remove( "Catherine.timer.WeaponToggle." .. pl.SteamID( pl ) )
	end
end

function GM:PlayerInitialSpawn( pl )
	timer.Simple( 1, function( )
		pl.SetNoDraw( pl, true )
	end )
	
	catherine.player.Initialize( pl )
end

local IsAdmin = function( _, pl ) return pl.IsAdmin( pl ) end

GM.PlayerGiveSWEP = IsAdmin
GM.PlayerSpawnSWEP = IsAdmin
GM.PlayerSpawnEffect = IsAdmin

function GM:PlayerSpawnRagdoll( pl )
	return pl.HasFlag( pl, "R" )
end

function GM:PlayerSpawnNPC( pl )
	return pl.HasFlag( pl, "n" )
end

function GM:PlayerSpawnVehicle( pl )
	return pl.HasFlag( pl, "V" )
end

function GM:PlayerSpawnSENT( pl )
	return pl.HasFlag( pl, "x" )
end

function GM:PlayerSpawnObject( pl )
	return pl.HasFlag( pl, "e" )
end

function GM:PlayerSpawnProp( pl )
	return pl.HasFlag( pl, "e" )
end

function GM:PlayerTakeDamage( pl, attacker, ragdollEntity )
	if ( pl.Health( pl ) <= 0 ) then
		return true
	end
	
	pl.CAT_healthRecover = true
	
	local hitGroup = pl.LastHitGroup( pl )
	local sound = hook.Run( "GetPlayerPainSound", pl )
	local gender = pl.GetGender( pl )
	
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
	
	catherine.util.ScreenColorEffect( pl, Color( 255, 150, 150 ), 0.5, 0.01 )

	if ( IsValid( ragdollEntity ) ) then
		ragdollEntity:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 1, 6 ) .. ".wav" )
		
		return true
	end

	pl:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 1, 6 ) .. ".wav" )
	
	return true
end

function GM:PlayerHurt( pl, attacker )
	return !pl.CAT_ignore_hurtSound and hook.Run( "PlayerTakeDamage", pl, attacker ) or true
end

function GM:PlayerDeathSound( pl, ragdollEntity )
	if ( IsValid( ragdollEntity ) ) then
		ragdollEntity:EmitSound( hook.Run( "GetPlayerDeathSound", pl ) or "vo/npc/" .. pl.GetGender( pl ) .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
		
		pl.CAT_deathSoundPlayed = true
		
		return true
	end
	
	pl:EmitSound( hook.Run( "GetPlayerDeathSound", pl ) or "vo/npc/" .. pl.GetGender( pl ) .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
	
	pl.CAT_deathSoundPlayed = true
	
	return true
end

function GM:PlayerDeathThink( pl )

end

function GM:DoPlayerDeath( pl )
	pl:SetNoDraw( true )

	if ( !pl.CAT_ragdoll ) then
		pl.deathBody = ents.Create( "prop_ragdoll" )
		pl.deathBody:SetAngles( pl.GetAngles( pl ) )
		pl.deathBody:SetModel( pl.GetModel( pl ) )
		pl.deathBody:SetPos( pl.GetPos( pl ) )
		pl.deathBody:Spawn( )
		pl.deathBody:Activate( )
		pl.deathBody:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		pl.deathBody.player = self
		pl.deathBody:SetNetVar( "player", pl )
		pl.deathBody:SetNetVar( "isDeathBody", true ) // 제거 필요.
		
		pl:SetNetVar( "ragdollIndex", pl.deathBody.EntIndex( pl.deathBody ) )
	end
	
	pl:SetNetVar( "noDrawOriginal", true )
	pl:SetNetVar( "isRagdolled", nil )
end

function GM:PlayerDeath( pl )
	pl.CAT_healthRecover = nil
	
	catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_Dead_01" ), catherine.configs.spawnTime, function( )
		pl.Spawn( pl )
	end )

	pl.SetNetVar( pl, "nextSpawnTime", CurTime( ) + catherine.configs.spawnTime )
	pl.SetNetVar( pl, "deathTime", CurTime( ) )
	
	catherine.log.Add( nil, pl.SteamName( pl ) .. ", " .. pl.SteamID( pl ) .. " has a died [Character Name : " .. pl.Name( pl ) .. "]", true )
	
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

function GM:PlayerShouldTakeDamage( )
	return true
end

function GM:GetFallDamage( pl, spd )
	local custom = hook.Run( "GetCustomFallDamage", pl, spd )
	
	return custom or ( spd - 580 ) * 0.8
end

function GM:InitPostEntity( )
	hook.Run( "DataLoad" )
	hook.Run( "SchemaDataLoad" )
	
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Catherine (Framework, Schema, Plugin) data has loaded." )
end

function GM:ShutDown( )
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Shutting down ... :)" )
	
	hook.Run( "PostDataSave" )
	hook.Run( "DataSave" )
	hook.Run( "SchemaDataSave" )
end

netstream.Hook( "catherine.IsTyping", function( pl, data )
	pl.SetNetVar( pl, "isTyping", data )
	
	hook.Run( "ChatTypingChanged", pl, data )
end )