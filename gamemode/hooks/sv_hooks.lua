function GM:GetGameDescription( )
	return "Catherine - ".. ( Schema and Schema.Name or "Error" )
end

function GM:PlayerSpray( pl )
	return hook.Run( "PlayerCantSpray", pl )
end

function GM:PlayerSpawn( pl )
	if ( IsValid( pl.dummy ) ) then
		pl.dummy:Remove( )
	end
	pl:SetNoDraw( false )
	pl:Freeze( false )
	pl:ConCommand( "-duck" )
	pl:SetColor( Color( 255, 255, 255, 255 ) )
	player_manager.SetPlayerClass( pl, "player_sandbox" )
	hook.Run( "PlayerSpawned", pl )
end

function GM:PlayerDisconnected( pl )
	if ( IsValid( pl.dummy ) ) then
		pl.dummy:Remove( )
	end
end

function GM:KeyPress( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Create("Catherine_toggleweaponRaised_" .. pl:SteamID( ), 1, 1, function()
			if ( !IsValid( pl ) ) then return end
			pl:ToggleWeaponRaised( )
		end )
	end
end

function GM:PlayerSay( pl, text )
	local newText = hook.Run( "PostPlayerSay", pl, text ) or text
	if ( newText == "" ) then return end
	catherine.chat.Progress( pl, newText )
end

function GM:KeyRelease( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Destroy( "Catherine_toggleweaponRaised_" .. pl:SteamID( ) )
	end
end

function GM:PlayerInitialSpawn( pl )
	timer.Simple( 1, function( )
		pl:SetNoDraw( true )
	end )

	local function stap01( )
		if ( !catherine.database.Connected ) then
			netstream.Start( pl, "catherine.LoadingStatus", { false, false, "Catherine has not connected by MySQL!", 0 } )
			return
		end
		netstream.Start( pl, "catherine.LoadingStatus", { true, true, 1, 0.15 } )
		
		catherine.character.SendCurrentCharacterDatas( pl )
		
		netstream.Start( pl, "catherine.LoadingStatus", { true, true, 1, 0.3 } )
		
		catherine.database.GetTable( "_steamID = '" .. pl:SteamID( ) .. "'", "catherine_players", function( data )
			if ( #data == 0 ) then
				netstream.Start( pl, "catherine.LoadingStatus", { true, true, 1, 0.4 } )
				catherine.database.Insert( {
					_steamName = pl:SteamName( ),
					_steamID = pl:SteamID( ),
					_catherineData = "[]"
				}, "catherine_players", function( )
					netstream.Start( pl, "catherine.LoadingStatus", { true, true, 1, 0.5 } )
					catherine.catherine_data.RegisterByMySQL( pl )
					netstream.Start( pl, "catherine.LoadingStatus", { true, true, 1, 1 } )
					timer.Simple( 3, function( )
						catherine.character.SendCharacterLists( pl )
						catherine.character.SendCharacterPanel( pl )
						netstream.Start( pl, "catherine.LoadingStatus", { 1, 1, 1, 1, true } )
					end )
				end )
			else
				catherine.catherine_data.RegisterByMySQL( pl )
				netstream.Start( pl, "catherine.LoadingStatus", { true, true, 1, 1 } )
				timer.Simple( 3, function( )
					catherine.character.SendCharacterLists( pl )
					catherine.character.SendCharacterPanel( pl )
					netstream.Start( pl, "catherine.LoadingStatus", { 1, 1, 1, 1, true } )
				end )
			end
		end )
	end

	timer.Create( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ), 1, 0, function( )
		if ( IsValid( pl ) ) then
			timer.Destroy( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ) )
			netstream.Start( pl, "catherine.LoadingStatus", { false, true, 1, 0.1 } )
			timer.Simple( 4, function( )
				stap01( )
				pl:SetNoDraw( true )
			end )
		end
	end )
end

function GM:PlayerNoClip( pl, bool )
	if ( pl:IsAdmin( ) ) then
		if ( pl:GetMoveType( ) == MOVETYPE_WALK ) then
			pl:SetNoDraw( true )
			pl:DrawShadow( false )
			pl:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			pl:SetNetworkValue( "nocliping", true )
		else
			pl:SetNoDraw( false )
			pl:DrawShadow( true )
			pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
			pl:SetNetworkValue( "nocliping", false )
		end
	end
	return pl:IsAdmin( )
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
	return pl:HasFlag( "ex" )
end

function GM:PlayerSpawnProp( pl )
	return pl:HasFlag( "ex" )
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
	pl.autoHealthrecoverStart = true
	pl:EmitSound( "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 1, 6 ).. ".wav" )
	return true
end

function GM:PlayerDeathSound( pl )
	pl:EmitSound( "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
	return true
end

function GM:DoPlayerDeath( pl )
	pl:SetNoDraw( true )
	pl:Freeze( true )
end

function GM:PlayerDeath( pl )
	pl.dummy = ents.Create( "prop_ragdoll" )
	pl.dummy:SetAngles( pl:GetAngles( ) )
	pl.dummy:SetModel( pl:GetModel( ) )
	pl.dummy:SetPos( pl:GetPos( ) )
	pl.dummy:Spawn( )
	pl.dummy:Activate( )
	pl.dummy:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	pl.dummy.player = self
	pl.dummy:SetNetworkValue( "player", pl )
	pl.dummy:SetNetworkValue( "ragdollID", pl.dummy:EntIndex( ) )
	pl.dummy:CallOnRemove( "RecoverPlayer", function( )
		if ( !IsValid( pl ) ) then return end
		pl:Spawn( )
		pl.dummy:Remove( )
	end )
	
	timer.Create( "catherine.timer.Respawn_" .. pl:SteamID( ), catherine.configs.spawnTime, 1, function( )
		if ( !IsValid( pl ) ) then return end
		pl:Spawn( )
	end )
		
	pl.autoHealthrecoverStart = false
	catherine.util.ProgressBar( pl, "You are now respawning.", catherine.configs.spawnTime )
	pl:SetNetworkValue( "nextSpawnTime", CurTime( ) + catherine.configs.spawnTime )
	pl:SetNetworkValue( "deathTime", CurTime( ) )
end

function GM:Tick( )
	// Health auto recover system.
	for k, v in pairs( player.GetAll( ) ) do
		if ( !v:IsCharacterLoaded( ) ) then continue end
		if ( !v.autoHealthrecoverStart ) then continue end
		if ( !v.autoHealthrecoverCur ) then v.autoHealthrecoverCur = CurTime( ) + 3 end
		if ( math.Round( v:Health( ) ) >= v:GetMaxHealth( ) ) then v.autoHealthrecoverStart = false end
		if ( v.autoHealthrecoverCur <= CurTime( ) ) then
			v:SetHealth( math.Clamp( v:Health( ) + 1, 0, v:GetMaxHealth( ) ) )
			v.autoHealthrecoverCur = CurTime( ) + 3
		end
	end
end

function GM:Initialize( )
	hook.Run( "GMInit" )
end

function GM:PlayerShouldTakeDamage( )
	return true
end

function GM:GetFallDamage( pl, speed )
	speed = speed - 580
	return speed * 0.8
end

function GM:InitPostEntity( )
	hook.Run( "DataLoad" )
end

function GM:ShutDown( )
	hook.Run( "DataSave" )
end

function GM:PlayerCantSpray( pl ) end