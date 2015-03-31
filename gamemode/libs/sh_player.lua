catherine.player = catherine.player or { }

local META = FindMetaTable( "Player" )

if ( SERVER ) then
	function catherine.player.Initialize( pl, func )
		if ( !catherine.database.Connected ) then
			netstream.Start( pl, "catherine.LoadingStatus", { false, "DataBase ERROR : " .. catherine.database.ErrorMsg, true } )
			return
		end
		if ( !Schema and catherine.network.GetNetGlobalVar( "notSetSchema", false ) == true ) then
			netstream.Start( pl, "catherine.LoadingStatus", { false, "Can't load Schema table!!! please check your '+gamemode' command!", true } )
			return
		end
		catherine.network.SyncAllVars( pl, function( )
			catherine.character.SendCurrentNetworking( pl, function( )
				catherine.database.GetDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
					if ( !data or #data == 0 ) then
						catherine.language.SyncByGMod( pl )
						catherine.player.QueryInitialize( pl, function( )
							if ( pl:SteamID( ) == catherine.configs.OWNER and pl:GetNWString( "usergroup" ):lower( ) == "user" ) then
								if ( ulx ) then
									RunConsoleCommand( "ulx", "adduserid", pl:SteamID( ), "superadmin" )
									catherine.util.Print( Color( 0, 255, 0 ), "Automatic owner set (using ULX) : " .. pl:SteamName( ) )
								else
									pl:SetUserGroup( "superadmin" )
									catherine.util.Print( Color( 0, 255, 0 ), "Automatic owner set : " .. pl:SteamName( ) )
								end
							end
							catherine.character.SendCharacterLists( pl, function( )
								catherine.catData.Load( pl )
								netstream.Start( pl, "catherine.LoadingStatus", { false, "Welcome." } )
								timer.Simple( 1, function( )
									netstream.Start( pl, "catherine.LoadingStatus", { true, "" } )
									catherine.character.OpenPanel( pl )
									if ( func ) then
										func( )
									end
								end )
							end )
						end )
					else
						catherine.character.SendCharacterLists( pl, function( )
							catherine.catData.Load( pl )
							netstream.Start( pl, "catherine.LoadingStatus", { false, "Welcome." } )
							timer.Simple( 1, function( )
								netstream.Start( pl, "catherine.LoadingStatus", { true, "" } )
								catherine.character.OpenPanel( pl )
								if ( func ) then
									func( )
								end
							end )
						end )
					end
				end )
			end )
		end )
	end

	function catherine.player.QueryInitialize( pl, func )
		if ( !IsValid( pl ) ) then return end
		catherine.database.InsertDatas( "catherine_players", {
			_steamName = pl:SteamName( ),
			_steamID = pl:SteamID( ),
			_catData = { }
		}, function( )
			if ( func ) then func( ) end
		end )
	end

	function catherine.player.RagdollWork( pl, status, time )
		if ( !IsValid( pl ) ) then return end
		
		if ( !status ) then
			pl:SetNoDraw( false )
			pl:SetNotSolid( false )
			pl:Freeze( false )
			pl:SetPos( IsValid( pl.ragdoll ) and pl.ragdoll:GetPos( ) or pl:GetPos( ) )
			pl:SetMoveType( MOVETYPE_WALK )
			pl:SetLocalVelocity( vector_origin )
			pl:DropToFloor( )
			if ( IsValid( pl.ragdoll ) ) then pl.ragdoll:SetNetVar( "player", nil ) end
			
			for k, v in pairs( pl:GetNetVar( "weps", { } ) ) do
				pl:Give( v )
			end
			
			pl:SetNetVar( "weps", nil )
			pl:SetNetVar( "isRagdolled", nil )
			pl:SetNetVar( "ragdollEnt", nil )
			
			if ( IsValid( pl.ragdoll ) ) then
				pl.ragdoll:Remove( )
				pl.ragdoll = nil
			end
			return
		end
		
		if ( IsValid( pl.ragdoll ) ) then
			pl.ragdoll:Remove( )
			pl.ragdoll = nil
		end
		
		if ( !time ) then catherine.util.TopNotify( pl, "You are regaining consciousness ..." ) end
		
		pl.ragdoll = ents.Create( "prop_ragdoll" )
		pl.ragdoll:SetAngles( pl:GetAngles( ) )
		pl.ragdoll:SetModel( pl:GetModel( ) )
		pl.ragdoll:SetPos( pl:GetPos( ) )
		pl.ragdoll:Spawn( )
		pl.ragdoll:Activate( )
		pl.ragdoll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		pl.ragdoll.player = self
		pl.ragdoll:SetNetVar( "player", pl )
		pl.ragdoll:CallOnRemove( "RecoverPlayer", function( )
			if ( !IsValid( pl ) ) then return end
			pl:SetNoDraw( false )
			pl:SetNotSolid( false )
			pl:Freeze( false )
			pl:SetMoveType( MOVETYPE_WALK )
			pl:SetLocalVelocity( vector_origin )
			catherine.util.TopNotify( pl, false )
			pl:SetNetVar( "isRagdolled", nil )
			pl:SetNetVar( "ragdollEnt", nil )
		end )
		
		local weps, wepsBuffer = pl:GetWeapons( ), { }
		for k, v in pairs( weps ) do
			wepsBuffer[ #wepsBuffer + 1 ] = v:GetClass( )
		end
		
		pl:SetNetVar( "weps", wepsBuffer )
		pl:StripWeapons( )
		pl:GodDisable( )
		pl:Freeze( true )
		pl:SetNoDraw( true )
		
		pl:SetNetVar( "ragdollEnt", pl.ragdoll:EntIndex( ) )
		pl:SetNetVar( "isRagdolled", true )
		
		if ( time ) then
			catherine.util.ProgressBar( pl, "You are regaining consciousness ...", time, function( )
				catherine.player.RagdollWork( pl, false )
			end )
		end
	end

	function META:SetWeaponRaised( bool, weapon )
		if ( !IsValid( self ) or !self:IsCharacterLoaded( ) ) then return end
		weapon = weapon or self:GetActiveWeapon( )
		if ( weapon.AlwaysLowered ) then catherine.network.SetNetVar( self, "weaponRaised", false ) return end
		catherine.network.SetNetVar( self, "weaponRaised", bool )
		if ( IsValid( weapon ) ) then
			local time = 9999999
			if ( bool or weapon.CanFireLowered ) then time = 0.9 end
			weapon:SetNextPrimaryFire( CurTime( ) + time )
			weapon:SetNextSecondaryFire( CurTime( ) + time )
		end
	end

	function META:ToggleWeaponRaised( )
		if ( self:GetWeaponRaised( ) ) then
			self:SetWeaponRaised( false )
		else
			self:SetWeaponRaised( true )
		end
	end
	
	hook.Add("PlayerSwitchWeapon", "player_PlayerSwitchWeapon", function( pl, old, new )
		if ( !new.AlwaysRaised and !catherine.configs.alwaysRaised[ new:GetClass( ) ] ) then
			pl:SetWeaponRaised( false, new )
		else
			pl:SetWeaponRaised( true, new )
		end
	end )
	
	local velo = FindMetaTable("Entity").GetVelocity
	local v = FindMetaTable("Vector").Length2D
	function META:IsRunning( )
		return v( velo( self ) ) >= ( catherine.configs.playerDefaultRunSpeed - 5 )
	end
end

function catherine.player.IsRagdolled( pl )
	return pl:GetNetVar( "isRagdolled", nil )
end
	
function META:GetWeaponRaised( )
	return self:GetNetVar( "weaponRaised", false )
end

function META:GetGender( )
	local model = self:GetModel( ):lower( )
	if ( model:find( "female" ) or model:find( "alyx" ) or model:find( "mossman" ) ) then
		return "female"
	else
		return "male"
	end
end

function player.GetAllByLoaded( )
	local players = { }
	for k, v in pairs( player.GetAll( ) ) do
		if ( !v:IsCharacterLoaded( ) ) then continue end
		players[ #players + 1 ] = v
	end
	return players
end