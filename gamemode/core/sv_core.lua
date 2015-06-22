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
	if ( !pl:IsCharacterLoaded( ) or catherine.character.GetCharVar( pl, "charBanned" ) ) then return end
	local status = hook.Run( "CantLookF1", pl )
	
	if ( !status ) then
		netstream.Start( pl, "catherine.ShowHelp" )
	end
end

function GM:ShowTeam( pl )
	if ( !pl:IsCharacterLoaded( ) or catherine.character.GetCharVar( pl, "charBanned" ) ) then return end
	local status = hook.Run( "CantLookF2", pl )
	if ( status ) then return end

	local data = { }
	data.start = pl:GetShootPos( )
	data.endpos = data.start + pl:GetAimVector( ) * 70
	data.filter = pl
	local ent = util.TraceLine( data ).Entity
	
	if ( IsValid( ent ) and catherine.entity.IsDoor( ent ) and !catherine.door.IsDoorDisabled( ent ) ) then
		local has, flag = catherine.door.IsHasDoorPermission( pl, ent )
		
		if ( has ) then
			if ( flag == CAT_DOOR_FLAG_BASIC ) then return end
			
			netstream.Start( pl, "catherine.door.DoorMenu", {
				ent:EntIndex( ),
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

function GM:PlayerFirstSpawned( pl, id )
	catherine.character.SetCharVar( pl, "originalModel", pl:GetModel( ) )
end

function GM:CharacterVarChanged( pl, key, value )
	if ( key == "_name" ) then
		hook.Run( "CharacterNameChanged", pl, value )
	elseif ( key == "_model" ) then
		pl:SetModel( value )
		pl:SetupHands( )
		catherine.character.SetCharVar( pl, "originalModel", value )
	end
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

function GM:PlayerHealthSet( pl, newHealth, oldHealth )
	local maxHealth = pl:GetMaxHealth( )
	
	if ( newHealth > oldHealth ) then
		catherine.limb.HealBody( pl, ( newHealth - oldHealth ) / 2.2 )
	end
	
	if ( newHealth >= maxHealth ) then
		catherine.limb.HealBody( pl, 100 )
		pl:RemoveAllDecals( )
	end
end

function GM:PlayerCharacterLoaded( pl )
	local factionTable = catherine.faction.FindByIndex( pl:Team( ) )
	
	if ( factionTable and factionTable.salary and factionTable.salary > 0 ) then
		timer.Create( "Catherine.timer.Salary_" .. pl:SteamID( ), factionTable.salaryTime or 350, 0, function( )
			if ( !IsValid( pl ) ) then
				timer.Remove( "Catherine.timer.Salary_" .. pl:SteamID( ) )
				return
			end
			
			local amount = hook.Run( "GetSalaryAmount", pl, factionTable ) or factionTable.salary
			
			catherine.cash.Give( pl, amount )
			catherine.util.NotifyLang( pl, "Cash_Notify_Salary", amount )
		end )
	end
end

function GM:PlayerSpawn( pl )
	if ( IsValid( pl.deathBody ) ) then
		pl.deathBody:Remove( )
		pl.deathBody = nil
	end

	pl.CAT_deathSoundPlayed = nil

	pl:SetNetVar( "noDrawOriginal", nil )
	
	pl:Freeze( false )
	pl:SetNoDraw( false )
	pl:SetNotSolid( false )
	player_manager.SetPlayerClass( pl, "cat_player" )
	pl:ConCommand( "-duck" )
	pl:SetColor( Color( 255, 255, 255, 255 ) )
	pl:SetNetVar( "isTied", false )
	pl:SetCanZoom( false )

	catherine.limb.HealBody( pl, 100 )

	catherine.util.ProgressBar( pl, false )
	catherine.util.TopNotify( pl, false )

	if ( catherine.configs.giveHand ) then
		pl:Give( "cat_fist" )
	end
	
	if ( catherine.configs.giveKey ) then
		pl:Give( "cat_key" )
	end

	if ( pl:IsCharacterLoaded( ) and !pl.CAT_loadingChar ) then
		hook.Run( "PlayerSpawnedInCharacter", pl )
	end
end

function GM:PlayerLimbTakeDamage( pl, hitGroup, amount )
	if ( hitGroup == HITGROUP_HEAD ) then
		local visibility = 1 - ( ( amount / 100 ) / 1 )
		
		catherine.util.StartMotionBlur( pl, math.max( visibility, 0.13 ), 1, 0.02 )
	end
end

function GM:PlayerLimbDamageHealed( pl, hitGroup, amount )
	if ( hitGroup == HITGROUP_HEAD ) then
		local visibility = 1 - ( amount / 100 )
		
		catherine.util.StartMotionBlur( pl, visibility, 1, 0.02 )
		
		if ( visibility == 0 ) then
			catherine.util.StopMotionBlur( pl )
		end
	end
end

function GM:GetLockTime( pl )
	return math.max( 5 * ( math.max( catherine.limb.GetDamage( pl, HITGROUP_LEFTARM ),
	catherine.limb.GetDamage( pl, HITGROUP_RIGHTARM ) ) / 100 ), 1.8 )
end

function GM:GetUnlockTime( pl )
	return math.max( 5 * ( math.max( catherine.limb.GetDamage( pl, HITGROUP_LEFTARM ),
	catherine.limb.GetDamage( pl, HITGROUP_RIGHTARM ) ) / 100 ), 1.8 )
end

function GM:PlayerJump( pl )
	
end

function GM:PlayerInfoTable( pl, infoTable )
	local jumpPower = infoTable.jumpPower
	local runSpeed = infoTable.runSpeed
	local leftLegLimbDmg = catherine.limb.GetDamage( pl, HITGROUP_LEFTLEG )
	local rightLegLimbDmg = catherine.limb.GetDamage( pl, HITGROUP_RIGHTLEG )
	local defJumpPower = catherine.player.GetPlayerDefaultJumpPower( pl )
	local defRunSpeed = catherine.player.GetPlayerDefaultRunSpeed( pl )

	if ( ( leftLegLimbDmg and leftLegLimbDmg != 0 ) or ( rightLegLimbDmg and rightLegLimbDmg != 0 ) ) then
		local per = ( math.max( leftLegLimbDmg, rightLegLimbDmg ) / 100 ) * defJumpPower / defJumpPower
		local per2 = ( math.max( leftLegLimbDmg, rightLegLimbDmg ) / 100 ) * defRunSpeed / defRunSpeed

		return {
			jumpPower = defJumpPower * per,
			runSpeed = defRunSpeed * per2
		}
	else
		return {
			jumpPower = defJumpPower,
			runSpeed = defRunSpeed
		}
	end
end

function GM:ScalePlayerDamage( pl, hitGroup, dmgInfo )
	if ( !pl:IsPlayer( ) ) then return end
	
	if ( !pl.CAT_ignoreScreenColor ) then
		catherine.util.ScreenColorEffect( pl, Color( 255, 150, 150 ), 0.5, 0.01 )
		
		if ( hitGroup == CAT_BODY_ID_HEAD ) then
			catherine.util.ScreenColorEffect( pl, nil, 2, 0.005 )
		end
	end
end

function GM:PlayerSpawnedInCharacter( pl )
	catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )

	hook.Run( "OnSpawnedInCharacter", pl )
end

function GM:PlayerSetHandsModel( pl, ent )
	local info = player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( pl:GetModel( ) ) )
	
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

function GM:PlayerAuthed( pl )
	timer.Simple( 2, function( )
		catherine.chat.Send( pl, "connect" )
		catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, pl:SteamName( ) .. ", " .. pl:SteamID( ) .. " has connected a server." )
		
		hook.Run( "PlayerLoadFinished", pl )
	end )
end

function GM:PlayerDisconnected( pl )
	if ( IsValid( pl.deathBody ) ) then
		pl.deathBody:Remove( )
	end
	
	if ( IsValid( pl.CAT_ragdoll ) ) then
		pl.CAT_ragdoll:Remove( )
	end
	
	timer.Remove( "Catherine.timer.Salary_" .. pl:SteamID( ) )
	
	catherine.chat.Send( pl, "disconnect" )
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, pl:SteamName( ) .. ", " .. pl:SteamID( ) .. " has disconnected a server." )
	
	if ( pl:IsCharacterLoaded( ) ) then
		hook.Run( "PlayerDisconnectedInCharacter", pl )
	end
end

function GM:PlayerCanHearPlayersVoice( pl, target )
	return catherine.configs.voiceAllow, catherine.configs.voice3D
end

function GM:EntityTakeDamage( ent, dmgInfo )
	if ( ent:GetClass( ) == "prop_ragdoll" ) then
		local pl = catherine.entity.GetPlayer( ent )
		
		if ( IsValid( pl ) and pl:IsPlayer( ) ) then
			local inflictor = dmgInfo:GetInflictor( )
			local attacker = dmgInfo:GetAttacker( )
			local amount = dmgInfo:GetDamage( )

			if ( !attacker:IsPlayer( ) or attacker:GetClass( ) == "prop_ragdoll" or catherine.entity.IsDoor( attacker ) or amount < 5 ) then
				return
			end
			
			if ( amount >= 20 or dmgInfo:IsBulletDamage( ) ) then
				catherine.player.SetIgnoreHurtSound( pl, true )

				// Uh....
				pl:TakeDamage( amount, attacker, inflictor )
				
				catherine.effect.Create( "BLOOD", {
					ent = ent,
					pos = dmgInfo:GetDamagePosition( ),
					scale = 1,
					decalCount = 1
				} )
				
				catherine.player.SetIgnoreHurtSound( pl, nil )

				if ( pl:Health( ) <= 0 and !pl.CAT_deathSoundPlayed ) then
					hook.Run( "PlayerDeathSound", pl, ent )
				else
					hook.Run( "PlayerTakeDamage", pl, attacker, dmgInfo, ent )
				end
			end
		end
	elseif ( ent:IsPlayer( ) ) then
		hook.Run( "PlayerTakeDamage", ent, dmgInfo:GetAttacker( ), dmgInfo )
	end
	
	if ( catherine.configs.doorBreach ) then
		local pl = dmgInfo:GetAttacker( )

		if ( IsValid( pl ) and ent:GetClass( ) == "prop_door_rotating" and dmgInfo:IsBulletDamage( ) and !pl:IsNoclipping( ) and ( ent.CAT_nextDoorBreach or 0 ) <= CurTime( ) ) then
			local partner = catherine.util.GetDoorPartner( ent )
			
			if ( IsValid( ent.lock ) or ( IsValid( partner ) and IsValid( partner.lock ) ) ) then
				return
			end
			
			local index = ent:LookupBone( "handle" )
			
			if ( index ) then
				local pos = dmgInfo:GetDamagePosition( )

				if ( pl:GetEyeTrace( ).Entity != ent or pl:GetPos( ):Distance( pos ) < 130 and pos:Distance( ent:GetBonePosition( index ) ) <= 5 ) then
					ent:EmitSound( "physics/wood/wood_crate_break" .. math.random( 1, 5 ) .. ".wav", 150 )

					local effect = EffectData( )
					effect:SetStart( pos )
					effect:SetOrigin( pos )
					effect:SetScale( 10 )
					util.Effect( "GlassImpact", effect, true, true )
					
					local dummyName = pl:SteamID( ) .. CurTime( )
					pl:SetName( dummyName )

					ent:Fire( "SetSpeed", 100 )
					ent:Fire( "UnLock" )
					ent:Fire( "OpenAwayFrom", dummyName )
					
					if ( IsValid( partner ) ) then
						partner:Fire( "SetSpeed", 100 )
						partner:Fire( "UnLock" )
						partner:Fire( "OpenAwayFrom", dummyName )
					end
					
					ent:EmitSound( "physics/wood/wood_plank_break" .. math.random( 1, 4 ) .. ".wav", 100, 120 )
					
					ent.CAT_nextDoorBreach = CurTime( ) + 3
				end
			end
		end
	end
	
	if ( ent:IsPlayer( ) and dmgInfo:IsBulletDamage( ) ) then
		local steamID = ent:SteamID( )
		
		ent:SetRunSpeed( ent:GetWalkSpeed( ) )

		timer.Remove( "Catherine.timer.RunSpamProtection_" .. steamID )
		timer.Create( "Catherine.timer.RunSpamProtection_" .. steamID, 2, 1, function( )
			if ( !IsValid( ent ) ) then return end
			
			ent:SetRunSpeed( catherine.player.GetPlayerDefaultRunSpeed( ent ) )
		end )
	end
end

function GM:PlayerSwitchFlashlight( pl, bool )
	return true
end

function GM:AttributeChanged( pl, uniqueID )
	
end

function GM:KeyPress( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Create( "Catherine.timer.WeaponToggle_" .. pl:SteamID( ), 1, 1, function( )
			if ( IsValid( pl ) ) then
				pl:ToggleWeaponRaised( )
			end
		end )
	elseif ( key == IN_USE ) then
		local data = { }
		data.start = pl:GetShootPos( )
		data.endpos = data.start + pl:GetAimVector( ) * 100
		data.filter = pl
		local ent = util.TraceLine( data ).Entity

		if ( !IsValid( ent ) or ent.CAT_ignoreUse ) then
			return
		end
		
		if ( ent:GetClass( ) == "prop_ragdoll" ) then
			ent = catherine.entity.GetPlayer( ent )
		end
		
		if ( !IsValid( ent ) ) then return end

		if ( catherine.entity.IsDoor( ent ) ) then
			catherine.door.DoorSpamProtection( pl, ent )

			hook.Run( "PlayerUse", pl, ent )
		elseif ( ent:IsPlayer( ) ) then
			return hook.Run( "PlayerInteract", pl, ent )
		elseif ( ent.IsCustomUse ) then
			netstream.Start( pl, "catherine.entity.CustomUseMenu", ent:EntIndex( ) )
		end
	end
end

function GM:KeyRelease( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Remove( "Catherine.timer.WeaponToggle_" .. pl:SteamID( ) )
	end
end

function GM:PlayerCanUseDoor( pl, ent )
	return !pl.CAT_cantUseDoor
end

function GM:PlayerUse( pl, ent )
	if ( pl:IsTied( ) ) then
		if ( ( pl.CAT_tiedMSG or 0 ) <= CurTime( ) ) then
			catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
			pl.CAT_tiedMSG = CurTime( ) + 5
		end
		
		return false
	end

	local isDoor = catherine.entity.IsDoor( ent )
	
	if ( isDoor ) then
		local result = hook.Run( "PlayerCanUseDoor", pl, ent )

		if ( result == false or catherine.entity.GetIgnoreUse( ent ) ) then
			return false
		else
			hook.Run( "PlayerUseDoor", pl, ent )
		end
	end
	
	return true
end

function GM:PlayerSay( pl, text )
	catherine.chat.Run( pl, text )
	catherine.log.Add( CAT_LOG_FLAG_BASIC, pl:Name( ) .. ", " .. pl:SteamName( ) .. " typed chat " .. text )
end

function GM:PlayerInitialSpawn( pl )
	timer.Simple( 2, function( )
		pl:SetNoDraw( true )
		pl:SetNotSolid( true )
		pl:GodEnable( )
		pl:SetPos( Vector( 0, 0, 10000 ) )
		
		catherine.player.Initialize( pl )
	end )
end

function GM:PlayerGiveSWEP( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnSWEP( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnEffect( pl )
	return pl:HasFlag( "s" )
end

function GM:PlayerSpawnRagdoll( pl )
	return pl:HasFlag( "R" )
end

function GM:PlayerSpawnNPC( pl )
	return pl:HasFlag( "n" )
end

function GM:PlayerSpawnVehicle( pl )
	return pl:HasFlag( "V" )
end

function GM:PlayerSpawnSENT( pl )
	return pl:HasFlag( "x" )
end

function GM:PlayerSpawnObject( pl )
	return pl:HasFlag( "e" )
end

function GM:PlayerSpawnProp( pl )
	return pl:HasFlag( "e" )
end

function GM:PlayerTakeDamage( pl, attacker, dmgInfo, ragdollEntity )
	if ( pl:Health( ) <= 0 ) then
		return true
	end
	
	pl.CAT_healthRecover = true

	if ( !catherine.player.GetIgnoreScreenColor( pl ) ) then
		catherine.util.ScreenColorEffect( pl, Color( 255, 150, 150 ), 0.5, 0.01 )
	end
	
	local hitGroup = pl:LastHitGroup( )

	if ( dmgInfo:IsDamageType( DMG_FALL ) ) then
		catherine.limb.TakeDamage( pl, HITGROUP_LEFTLEG, dmgInfo:GetDamage( ) )
		catherine.limb.TakeDamage( pl, HITGROUP_RIGHTLEG, dmgInfo:GetDamage( ) )
	else
		catherine.limb.TakeDamage( pl, hitGroup, dmgInfo:GetDamage( ) )
	end

	if ( !catherine.player.GetIgnoreHurtSound( pl ) ) then
		local sound = hook.Run( "GetPlayerPainSound", pl )
		local gender = pl:GetGender( )
	
		if ( !sound ) then
			if ( hitGroup == HITGROUP_HEAD ) then
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

		if ( IsValid( ragdollEntity ) ) then
			ragdollEntity:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 1, 6 ) .. ".wav" )
			
			return true
		end

		pl:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 1, 6 ) .. ".wav" )
	end
	
	return true
end

function GM:PlayerHurt( pl, attacker )
	return true
end

function GM:PlayerDeathSound( pl, ragdollEntity )
	local sound = hook.Run( "GetPlayerDeathSound", pl )
	local gender = pl:GetGender( )
	
	if ( IsValid( ragdollEntity ) ) then
		ragdollEntity:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
		pl.CAT_deathSoundPlayed = true
		
		return true
	end
	
	pl:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
	pl.CAT_deathSoundPlayed = true
	
	return true
end

function GM:PlayerDeathThink( pl )

end

function GM:DoPlayerDeath( pl )
	pl:SetNoDraw( true )
	pl:Freeze( true )

	if ( !pl.CAT_ragdoll ) then
		local ent = ents.Create( "prop_ragdoll" )
		ent:SetAngles( pl:GetAngles( ) )
		ent:SetModel( pl:GetModel( ) )
		ent:SetPos( pl:GetPos( ) )
		ent:Spawn( )
		ent:Activate( )
		ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		ent.player = self
		ent:SetNetVar( "player", pl )
		
		pl:SetNetVar( "ragdollIndex", ent:EntIndex( ) )
		pl.deathBody = ent
	end
	
	pl:SetNetVar( "noDrawOriginal", true )
	pl:SetNetVar( "isRagdolled", nil )
end

function GM:PlayerDeath( pl )
	pl.CAT_healthRecover = nil
	
	local respawnTime = hook.Run( "GetRespawnTime", pl ) or catherine.configs.spawnTime
	
	catherine.util.ProgressBar( pl, false )
	
	pl:SetViewEntity( NULL )
	pl:UnSpectate( )
	
	pl.CAT_isDeadFunc = true

	catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_Dead_01" ), respawnTime, function( )
		if ( IsValid( pl.CAT_ragdoll ) ) then
			pl.CAT_ragdoll:Remove( )
			pl.CAT_ragdoll = nil
		end
		
		pl:Spawn( )

		timer.Simple( 0, function( )
			pl.CAT_isDeadFunc = nil
		end )
	end )

	catherine.util.TopNotify( pl, false )
	
	pl:SetNetVar( "nextSpawnTime", CurTime( ) + respawnTime )
	pl:SetNetVar( "deathTime", CurTime( ) )
	
	catherine.log.Add( nil, pl:SteamName( ) .. ", " .. pl:SteamID( ) .. " has a died [Character Name : " .. pl:Name( ) .. "]", true )
end

function GM:PlayerThink( pl )
	if ( ( pl.CAT_playerInfoTableTick or 0 ) <= CurTime( ) ) then
		local infoOverride = hook.Run( "PlayerInfoTable", pl, {
			jumpPower = pl:GetJumpPower( ),
			runSpeed = pl:GetRunSpeed( ),
			walkSpeed = pl:GetWalkSpeed( )
		} ) or { }
		
		if ( infoOverride.jumpPower and infoOverride.jumpPower != pl:GetJumpPower( ) ) then
			pl:SetJumpPower( infoOverride.jumpPower )
		end
		
		if ( infoOverride.runSpeed and infoOverride.runSpeed != pl:GetRunSpeed( ) ) then
			pl:SetRunSpeed( infoOverride.runSpeed )
		end
		
		if ( infoOverride.walkSpeed and infoOverride.walkSpeed != pl:GetWalkSpeed( ) ) then
			pl:SetWalkSpeed( infoOverride.walkSpeed )
		end
		
		pl.CAT_playerInfoTableTick = CurTime( ) + 0.1
	end
end

function GM:Tick( )
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		catherine.player.BunnyHopProtection( v )
		catherine.player.HealthRecoverTick( v )
		
		if ( ( v.CAT_nextJumpUpdate or 0 ) <= CurTime( ) and v:Alive( ) and !v:IsRagdolled( ) and !v:InVehicle( ) and v:GetMoveType( ) == MOVETYPE_WALK and v:IsInWorld( ) and !v:IsOnGround( ) ) then
			hook.Run( "PlayerJump", v )
			v.CAT_nextJumpUpdate = CurTime( ) + 1
		end
		
		hook.Run( "PlayerThink", v )
	end
end

function GM:PlayerGiveWeapon( pl, uniqueID )

end

function GM:PlayerStripWeapon( pl, uniqueID )

end

function GM:GetUnknownTargetName( pl, target )
	return LANG( pl, "Recognize_UI_Unknown" )
end

function GM:PlayerShouldTakeDamage( )
	return true
end

function GM:GetFallDamage( pl, speed )
	return hook.Run( "GetOverrideFallDamage", pl, speed ) or ( speed - 580 ) * 0.8
end

function GM:InitPostEntity( )
	hook.Run( "DataLoad" )
	hook.Run( "SchemaDataLoad" )
	
	if ( catherine.configs.clearMap ) then
		catherine.util.RemoveEntityByClass( "item_healthcharger" )
		catherine.util.RemoveEntityByClass( "item_suitcharger" )
		catherine.util.RemoveEntityByClass( "prop_vehicle*" )
		catherine.util.RemoveEntityByClass( "weapon_*" )
	end
	
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Catherine (Framework, Schema, Plugin) data has loaded." )
end

function GM:ShutDown( )
	catherine.shuttingDown = true
	
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Shutting down ... :)" )
	
	hook.Run( "PostDataSave" )
	hook.Run( "DataSave" )
	hook.Run( "SchemaDataSave" )
end

function GM:Initialize( )
	MsgC( Color( 255, 255, 0 ), "[CAT] Catherine is currently in developing. Reset the database after update, we are very sorry!\n" )
	MsgC( Color( 0, 255, 0 ), "[CAT] You are using Catherine '" .. catherine.version.Ver .. "' date Version, Thanks.\n" )
end

netstream.Hook( "catherine.IsTyping", function( pl, data )
	pl:SetNetVar( "isTyping", data )
	
	hook.Run( "ChatTypingChanged", pl, data )
end )