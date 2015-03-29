function GM:GetGameDescription( )
	return "CAT - ".. ( Schema and Schema.Name or "Unknown" )
end

function GM:PlayerSpray( pl )
	return !hook.Run( "PlayerCanSpray", pl )
end

function GM:PlayerSpawn( pl )
	if ( IsValid( pl.dummy ) ) then
		pl.dummy:Remove( )
	end
	pl:SetNoDraw( false )
	pl:Freeze( false )
	pl:ConCommand( "-duck" )
	pl:SetColor( Color( 255, 255, 255, 255 ) )
	player_manager.SetPlayerClass( pl, "catherine_player" )
	if ( pl:IsCharacterLoaded( ) ) then
		hook.Run( "PlayerSpawnedInCharacter", pl )
	end
end

function GM:PlayerSpawnedInCharacter( pl )
	catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
	hook.Run( "OnSpawnedInCharacter", pl )
	hook.Run( "PostWeaponGive", pl )
end

function GM:PlayerSetHandsModel( pl, ent )
	local model = player_manager.TranslateToPlayerModelName( pl:GetModel( ) )
	local info = player_manager.TranslatePlayerHands( model )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
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
	pl.CAT_healthRecoverBool = true
	pl:EmitSound( hook.Run( "GetPlayerPainSound", pl ) or "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 1, 6 ).. ".wav" )
	hook.Run( "PlayerTakeDamage", pl )
	return true
end

function GM:PlayerDeathSound( pl )
	pl:EmitSound( hook.Run( "GetPlayerDeathSound", pl ) or "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
	return true
end

function GM:DoPlayerDeath( pl )
	pl:SetNoDraw( true )
	pl:Freeze( true )
end

function GM:PlayerDeath( pl )
	// Spaen fake death body.
	pl.dummy = ents.Create( "prop_ragdoll" )
	pl.dummy:SetAngles( pl:GetAngles( ) )
	pl.dummy:SetModel( pl:GetModel( ) )
	pl.dummy:SetPos( pl:GetPos( ) )
	pl.dummy:Spawn( )
	pl.dummy:Activate( )
	pl.dummy:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	pl.dummy.player = self
	catherine.network.SetNetVar( pl.dummy, "player", pl )
	catherine.network.SetNetVar( pl.dummy, "ragdollID", pl.dummy:EntIndex( ) )
	pl.dummy:CallOnRemove( "RecoverPlayer", function( )
		if ( !IsValid( pl ) or !IsValid( pl.dummy ) ) then return end
		pl.dummy:Remove( )
	end )
	
	timer.Create( "catherine.timer.Respawn_" .. pl:SteamID( ), catherine.configs.spawnTime, 1, function( )
		if ( !IsValid( pl ) ) then return end
		pl:Spawn( )
	end )
		
	pl.CAT_healthRecoverBool = false
	catherine.util.ProgressBar( pl, "You are now respawning.", catherine.configs.spawnTime )
	catherine.network.SetNetVar( pl, "nextSpawnTime", CurTime( ) + catherine.configs.spawnTime )
	catherine.network.SetNetVar( pl, "deathTime", CurTime( ) )
	
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
	hook.Run( "DataSave" )
end