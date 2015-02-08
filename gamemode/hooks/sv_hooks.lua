DEFINE_BASECLASS( "gamemode_base" )

function GM:LoadCheck( )
	print("Loaded")
end

function GM:GetGameDescription( )
	return "Catherine - ".. ( Schema and Schema.Name or "Error" )
end

function GM:PlayerSpray( pl )
	return true
end

function GM:PlayerSpawn( pl )
	player_manager.SetPlayerClass( pl, "catherine_player" )
	BaseClass.PlayerSpawn( self, pl )
end
--[[
netstream.Hook( "catherine.LoadingStatus", function( data )
	if ( data[ 2 ] == true ) then
		if ( data[ 1 ] == true ) then
			catherine.loading = true
			catherine.loadingStarting = false
			catherine.progressBar = 0
		elseif ( data[ 1 ] == false ) then
			catherine.loading = true
			catherine.loadingStarting = true
			catherine.progressBar = 0
		end
	elseif ( data[ 2 ] == false ) then
		catherine.loading = true
		catherine.progressBar = 0
		catherine.errorText = data[ 3 ] or ""
	end
	catherine.percent = data[ 4 ]
	if ( data[ 5 ] == true ) then
		catherine.loading = false
		catherine.loadingStarting = false
	end
end )
--]]

function GM:PlayerInitialSpawn( pl )
	pl:SetNoDraw( true )
	pl:KillSilent( )
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
					_steamName = pl:Name( ),
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
		//netstream.Start( pl, "catherine.LoadingStatus", "Waiting local player ..." )
		
		if ( IsValid( pl ) ) then
			print("Start")
			timer.Destroy( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ) )
			netstream.Start( pl, "catherine.LoadingStatus", { false, true, 1, 0.1 } )
			timer.Simple( 7, function( )
				stap01( )
			end )
		end
	end )
end

concommand.Add( "loadingTest", function( pl )
	pl:SetNoDraw( true )
	pl:KillSilent( )
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
					_steamName = pl:Name( ),
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
		//netstream.Start( pl, "catherine.LoadingStatus", "Waiting local player ..." )
		
		if ( IsValid( pl ) ) then
			print("Start")
			timer.Destroy( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ) )
			netstream.Start( pl, "catherine.LoadingStatus", { false, true, 1, 0.1 } )
			timer.Simple( 7, function( )
				stap01( )
			end )
		end
	end )
end )

function GM:PlayerHealthChanged( pl )
	return GAMEMODE:PlayerHurt( pl )
end

function GM:PlayerHurt( pl )
	return true
end

function GM:PlayerDeathSound( ply )
	return true
end