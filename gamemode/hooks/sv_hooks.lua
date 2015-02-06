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

function GM:PlayerInitialSpawn( pl )
	//catherine.character.SendCharacterPanel( pl )
	pl:SetNoDraw( true )
	pl:KillSilent( )
		local function stap01( )
		netstream.Start( pl, "catherine.LoadingStatus", "Character networking ..." )
		
		catherine.character.SendCurrentCharacterDatas( pl )
		
		catherine.database.GetTable( "_steamID = '" .. pl:SteamID( ) .. "'", "catherine_players", function( data )
			if ( #data == 0 ) then
				netstream.Start( pl, "catherine.LoadingStatus", "Makeing player tables ..." )
				print("Makeing player tables ..." )
				catherine.database.Insert( {
					_steamName = pl:Name( ),
					_steamID = pl:SteamID( ),
					_catherineData = "[]"
				}, "catherine_players", function( )
					netstream.Start( pl, "catherine.LoadingStatus", "Maked player tables ..." )
					catherine.catherine_data.RegisterByMySQL( pl, true )
					print("Register catherine data ..." )
					timer.Simple( 3, function( )
						netstream.Start( pl, "catherine.LoadingStatus", "Loaded!" )
						netstream.Start( pl, "catherine.LoadingStatus", false )
					end )
					print("Maked player tables ..." )
				end )
			else
				catherine.catherine_data.RegisterByMySQL( pl, true )
				print("Register catherine data ..." )
				timer.Simple( 3, function( )
					netstream.Start( pl, "catherine.LoadingStatus", "Loaded!" )
					netstream.Start( pl, "catherine.LoadingStatus", false )
				end )
			end
		end )
	end
	
	timer.Create( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ), 1, 0, function( )
		//netstream.Start( pl, "catherine.LoadingStatus", "Waiting local player ..." )
		
		if ( IsValid( pl ) ) then
			print("Start")
			timer.Destroy( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ) )
			netstream.Start( pl, "catherine.LoadingStatus", true )
			
			netstream.Start( pl, "catherine.LoadingStatus", "Waiting local player ..." )
			timer.Simple( 3, function( )
				stap01( )
			end )
		end
	end )
	
end

concommand.Add( "panelTest", function( pl )

	catherine.character.SendCharacterPanel( pl )
end )

concommand.Add( "loadingTest", function( pl )
	
	local function stap01( )
		netstream.Start( pl, "catherine.LoadingStatus", "Character networking ..." )
		
		catherine.character.SendCurrentCharacterDatas( pl )
		
		catherine.database.GetTable( "_steamID = '" .. pl:SteamID( ) .. "'", "catherine_players", function( data )
			if ( #data == 0 ) then
				netstream.Start( pl, "catherine.LoadingStatus", "Makeing player tables ..." )
				print("Makeing player tables ..." )
				catherine.database.Insert( {
					_steamName = pl:Name( ),
					_steamID = pl:SteamID( ),
					_catherineData = "[]"
				}, "catherine_players", function( )
					netstream.Start( pl, "catherine.LoadingStatus", "Maked player tables ..." )
					catherine.catherine_data.RegisterByMySQL( pl, true )
					print("Register catherine data ..." )
					timer.Simple( 3, function( )
						netstream.Start( pl, "catherine.LoadingStatus", "Loaded!" )
						netstream.Start( pl, "catherine.LoadingStatus", false )
					end )
					print("Maked player tables ..." )
				end )
			else
				catherine.catherine_data.RegisterByMySQL( pl, true )
				print("Register catherine data ..." )
				timer.Simple( 3, function( )
					netstream.Start( pl, "catherine.LoadingStatus", "Loaded!" )
					netstream.Start( pl, "catherine.LoadingStatus", false )
				end )
			end
		end )
	end
	
	timer.Create( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ), 1, 0, function( )
		//netstream.Start( pl, "catherine.LoadingStatus", "Waiting local player ..." )
		
		if ( IsValid( pl ) ) then
			print("Start")
			timer.Destroy( "catherine.loading.WaitLocalPlayer_" .. pl:SteamID( ) )
			netstream.Start( pl, "catherine.LoadingStatus", true )
			
			netstream.Start( pl, "catherine.LoadingStatus", "Waiting local player ..." )
			timer.Simple( 3, function( )
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