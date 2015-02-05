DEFINE_BASECLASS( "gamemode_base" )
function GM:LoadCheck( )
	print("Loaded")
end

function GM:GetGameDescription( )
	return "Nexus - ".. ( Schema and Schema.Name or "Error" )
end

function GM:PlayerSpray( pl )
	return true
end

function GM:PlayerSpawn( pl )
	player_manager.SetPlayerClass( pl, "player_nexus" )
	BaseClass.PlayerSpawn( self, pl )
	if ( nexus.configs.giveHand ) then
		pl:Give( "nexus_hands" )
	end
		
	if ( nexus.configs.giveKey ) then
		pl:Give( "nexus_key" )
	end
	
	hook.Run( "CharacterSpawned", pl )
end

function GM:PlayerInitialSpawn( pl )
	//nexus.character.SendCharacterPanel( pl )
	pl:SetNoDraw( true )
	pl:KillSilent( )
		local function stap01( )
		netstream.Start( pl, "nexus.LoadingStatus", "Character networking ..." )
		
		nexus.character.SendCurrentCharacterDatas( pl )
		
		nexus.database.GetTable( "_steamID = '" .. pl:SteamID( ) .. "'", "nexus_players", function( data )
			if ( #data == 0 ) then
				netstream.Start( pl, "nexus.LoadingStatus", "Makeing player tables ..." )
				print("Makeing player tables ..." )
				nexus.database.Insert( {
					_steamName = pl:Name( ),
					_steamID = pl:SteamID( ),
					_nexusData = "[]"
				}, "nexus_players", function( )
					netstream.Start( pl, "nexus.LoadingStatus", "Maked player tables ..." )
					nexus.nexus_data.RegisterByMySQL( pl, true )
					print("Register nexus data ..." )
					timer.Simple( 3, function( )
						netstream.Start( pl, "nexus.LoadingStatus", "Loaded!" )
						netstream.Start( pl, "nexus.LoadingStatus", false )
					end )
					print("Maked player tables ..." )
				end )
			else
				nexus.nexus_data.RegisterByMySQL( pl, true )
				print("Register nexus data ..." )
				timer.Simple( 3, function( )
					netstream.Start( pl, "nexus.LoadingStatus", "Loaded!" )
					netstream.Start( pl, "nexus.LoadingStatus", false )
				end )
			end
		end )
	end
	
	timer.Create( "nexus.loading.WaitLocalPlayer_" .. pl:SteamID( ), 1, 0, function( )
		//netstream.Start( pl, "nexus.LoadingStatus", "Waiting local player ..." )
		
		if ( IsValid( pl ) ) then
			print("Start")
			timer.Destroy( "nexus.loading.WaitLocalPlayer_" .. pl:SteamID( ) )
			netstream.Start( pl, "nexus.LoadingStatus", true )
			
			netstream.Start( pl, "nexus.LoadingStatus", "Waiting local player ..." )
			timer.Simple( 3, function( )
				stap01( )
			end )
		end
	end )
	
end

concommand.Add( "panelTest", function( pl )

	nexus.character.SendCharacterPanel( pl )
end )

concommand.Add( "loadingTest", function( pl )
	
	local function stap01( )
		netstream.Start( pl, "nexus.LoadingStatus", "Character networking ..." )
		
		nexus.character.SendCurrentCharacterDatas( pl )
		
		nexus.database.GetTable( "_steamID = '" .. pl:SteamID( ) .. "'", "nexus_players", function( data )
			if ( #data == 0 ) then
				netstream.Start( pl, "nexus.LoadingStatus", "Makeing player tables ..." )
				print("Makeing player tables ..." )
				nexus.database.Insert( {
					_steamName = pl:Name( ),
					_steamID = pl:SteamID( ),
					_nexusData = "[]"
				}, "nexus_players", function( )
					netstream.Start( pl, "nexus.LoadingStatus", "Maked player tables ..." )
					nexus.nexus_data.RegisterByMySQL( pl, true )
					print("Register nexus data ..." )
					timer.Simple( 3, function( )
						netstream.Start( pl, "nexus.LoadingStatus", "Loaded!" )
						netstream.Start( pl, "nexus.LoadingStatus", false )
					end )
					print("Maked player tables ..." )
				end )
			else
				nexus.nexus_data.RegisterByMySQL( pl, true )
				print("Register nexus data ..." )
				timer.Simple( 3, function( )
					netstream.Start( pl, "nexus.LoadingStatus", "Loaded!" )
					netstream.Start( pl, "nexus.LoadingStatus", false )
				end )
			end
		end )
	end
	
	timer.Create( "nexus.loading.WaitLocalPlayer_" .. pl:SteamID( ), 1, 0, function( )
		//netstream.Start( pl, "nexus.LoadingStatus", "Waiting local player ..." )
		
		if ( IsValid( pl ) ) then
			print("Start")
			timer.Destroy( "nexus.loading.WaitLocalPlayer_" .. pl:SteamID( ) )
			netstream.Start( pl, "nexus.LoadingStatus", true )
			
			netstream.Start( pl, "nexus.LoadingStatus", "Waiting local player ..." )
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