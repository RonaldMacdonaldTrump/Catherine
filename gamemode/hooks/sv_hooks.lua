function GM:GetGameDescription( )
	return "Catherine - ".. ( Schema and Schema.Name or "Unknown" )
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
	pl:SetupHands( )
	player_manager.SetPlayerClass( pl, "catherine_player" )
	hook.Run( "PlayerSpawned", pl )
end

function GM:PlayerSpawned( pl )
	if ( !pl:IsCharacterLoaded( ) ) then return end
	hook.Run( "DefaultWeaponGive", pl )
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

function GM:KeyPress( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Create("Catherine_toggleweaponRaised_" .. pl:SteamID( ), 1, 1, function()
			if ( !IsValid( pl ) ) then return end
			pl:ToggleWeaponRaised( )
		end )
	end
end

function GM:DefaultWeaponGive( pl )
	pl:Give( "catherine_fist" )
	pl:Give( "catherine_key" )
end

function GM:PlayerSay( pl, text )
	local class = catherine.chat.FetchClassByText( text )
	local newText = hook.Run( "PostPlayerSay", pl, class, text ) or text
	if ( newText == "" ) then return end
	catherine.chat.Progress( pl, newText )
end

function GM:KeyRelease( pl, key )
	if ( key == IN_RELOAD ) then timer.Destroy( "Catherine_toggleweaponRaised_" .. pl:SteamID( ) ) end
end

function GM:PlayerInitialSpawn( pl )
	timer.Simple( 1, function( )
		pl:SetNoDraw( true )
	end )

<<<<<<< HEAD
	local function init( )
		if ( !catherine.database.Connected ) then
			netstream.Start( pl, "catherine.LoadingStatus", { false, 0, "MySQL Error : " .. catherine.database.ErrorMsg } )
			return
		end
		netstream.Start( pl, "catherine.LoadingStatus", { false, 0.1 } )
		catherine.character.SendCurrentCharacterDatas( pl )
		netstream.Start( pl, "catherine.LoadingStatus", { false, 0.2 } )
		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
			if ( !data or #data == 0 ) then
				catherine.database.InsertDatas( "catherine_players",
				{
					_steamName = pl:SteamName( ),
					_steamID = pl:SteamID( ),
					_catData = "[]"
				}, 
				function( )
					netstream.Start( pl, "catherine.LoadingStatus", { false, 0.7 } )
					catherine.catData.Load( pl )
					netstream.Start( pl, "catherine.LoadingStatus", { false, 1 } )
					timer.Simple( 1, function( )
						netstream.Start( pl, "catherine.LoadingStatus", { true, 1 } )
						catherine.character.SendCharacterLists( pl )
						catherine.character.SendCharacterPanel( pl )
					end )
				end )
			else
				catherine.catData.Load( pl )
				netstream.Start( pl, "catherine.LoadingStatus", { false, 1 } )
				timer.Simple( 1, function( )
					netstream.Start( pl, "catherine.LoadingStatus", { true, 1 } )
					catherine.character.SendCharacterLists( pl )
					catherine.character.SendCharacterPanel( pl )
				end )
			end
		end )
	end

=======
>>>>>>> dev
	timer.Create( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ), 1, 0, function( )
		if ( IsValid( pl ) and pl:IsPlayer( ) ) then
			timer.Destroy( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ) )
			timer.Simple( 3, function( )
				catherine.player.Initialize( pl ) // 초기화 실행 ^-^!
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
			catherine.network.SetNetVar( pl, "nocliping", true )
		else
			pl:SetNoDraw( false )
			pl:DrawShadow( true )
			pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
			catherine.network.SetNetVar( pl, "nocliping", false )
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
		if ( !IsValid( pl ) ) then return end
		pl:Spawn( )
		if ( !IsValid( pl.dummy ) ) then return end
		pl.dummy:Remove( )
	end )
	
	timer.Create( "catherine.timer.Respawn_" .. pl:SteamID( ), catherine.configs.spawnTime, 1, function( )
		if ( !IsValid( pl ) ) then return end
		pl:Spawn( )
	end )
		
	pl.autoHealthrecoverStart = false
	catherine.util.ProgressBar( pl, "You are now respawning.", catherine.configs.spawnTime )
	catherine.network.SetNetVar( pl, "nextSpawnTime", CurTime( ) + catherine.configs.spawnTime )
	catherine.network.SetNetVar( pl, "deathTime", CurTime( ) )
end

function GM:Tick( )
	// Health auto recover system.
	for k, v in pairs( player.GetAll( ) ) do
		if ( !v:IsCharacterLoaded( ) ) then continue end
		if ( !v.autoHealthrecoverStart ) then continue end
		if ( !v.autoHealthrecoverCur ) then v.autoHealthrecoverCur = CurTime( ) + 3 end
		if ( math.Round( v:Health( ) ) >= v:GetMaxHealth( ) ) then v.autoHealthrecoverStart = false hook.Run( "HealthFullRecovered", v ) end
		if ( v.autoHealthrecoverCur <= CurTime( ) ) then
			v:SetHealth( math.Clamp( v:Health( ) + 1, 0, v:GetMaxHealth( ) ) )
			v.autoHealthrecoverCur = CurTime( ) + 3
			hook.Run( "HealthRecovering", v )
		end
	end
end

function GM:Initialize( )
	hook.Run( "GMInitialize" )
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

function GM:PlayerCantSpray( pl ) end