DEFINE_BASECLASS( "gamemode_base" )

function GM:GetGameDescription( )
	return "Catherine - ".. ( Schema and Schema.Name or "Error" )
end

function GM:PlayerSpray( pl )
	return hook.Run( "PlayerCantSpray", pl )
end

function GM:PlayerSpawn( pl )
	pl:SetNoDraw( false )
	player_manager.SetPlayerClass( pl, "catherine_player" )
	BaseClass.PlayerSpawn( self, pl )
	hook.Run( "PlayerSpawned", pl )
end

function GM:KeyPress( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Create("Catherine_toggleweaponRaised_" .. pl:SteamID( ), 1, 1, function()
			if ( !IsValid( pl ) ) then return end
			pl:ToggleWeaponRaised( )
		end )
	end
end

function GM:KeyRelease( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Destroy( "Catherine_toggleweaponRaised_" .. pl:SteamID( ) )
	end
end

function GM:PlayerSpawned( pl )
	if ( pl:IsCharacterLoaded( ) or pl.isCharacterLoading ) then return end
	pl:SetNoDraw( true )
	pl:KillSilent( )
end

function GM:PlayerInitialSpawn( pl )
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
			end )
		end
	end )
end

function GM:PlayerHurt( pl )
	pl:EmitSound( "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 1, 6 ).. ".wav" )
	return true
end

function GM:PlayerDeathSound( pl )
	pl:EmitSound( "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
	return true
end

function GM:PlayerDeath( pl )
	catherine.util.ProgressBar( pl, "You are dead...", catherine.configs.spawnTime )
	pl.catherine_nextSpawn = CurTime( ) + catherine.configs.spawnTime
	pl:SetNetworkValue( "nextSpawnTime", pl.catherine_nextSpawn )
	pl:SetNetworkValue( "deathTime", CurTime( ) )
end

function GM:PlayerDeathThink( pl )
	if ( !pl.catherine_nextSpawn ) then return end
	if ( pl.catherine_nextSpawn <= CurTime( ) ) then
		pl:Spawn( )
	end
end

function GM:Initialize( )
	hook.Run( "GMInit" )
end

function GM:PlayerShouldTakeDamage( )
	return true
end

function GM:GetFallDamage( _, speed )
	return ( speed / 8 )
end

function GM:InitPostEntity( )
	hook.Run( "DataLoad" )
end

function GM:ShutDown( )
	hook.Run( "DataSave" )
end

function GM:PlayerCantSpray( pl ) end