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
			catherine.character.GetCurrentNetworking( pl, function( )
				catherine.database.GetDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
					if ( !data or #data == 0 ) then
						catherine.player.DoQueryInitialize( pl, function( )
							catherine.character.SendCharacterLists( pl, function( )
								catherine.catData.Load( pl )
								netstream.Start( pl, "catherine.LoadingStatus", { false, "Framework loaded!" } )
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
							netstream.Start( pl, "catherine.LoadingStatus", { false, "Framework loaded!" } )
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
	
	function catherine.player.DoQueryInitialize( pl, func )
		if ( !IsValid( pl ) ) then return end
		catherine.database.InsertDatas( "catherine_players", {
			_steamName = pl:SteamName( ),
			_steamID = pl:SteamID( ),
			_catData = { }
		}, function( )
			if ( func ) then func( ) end
		end )
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
		pl:SetWeaponRaised( false, new )
	end )
	
	local velo = FindMetaTable("Entity").GetVelocity
	local v = FindMetaTable("Vector").Length2D
	function META:IsRunning( )
		return v( velo( self ) ) >= ( catherine.configs.playerDefaultRunSpeed - 5 )
	end

	/* // Error;
	
	function META:ForceRagdoll( )
		self.ragdoll = ents.Create( "prop_ragdoll" )
		self.ragdoll:SetAngles( self:GetAngles( ) )
		self.ragdoll:SetModel( self:GetModel( ) )
		self.ragdoll:SetPos( self:GetPos( ) )
		self.ragdoll:Spawn( )
		self.ragdoll:Activate( )
		self.ragdoll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self.ragdoll.player = self
		self.ragdoll:SetNetworkValue( "player", self )
		self.ragdoll:CallOnRemove( "RecoverPlayer", function( )
			if ( IsValid( self ) ) then
				self:Ragdoll( false )
			end
		end )

		local weap = { }
		for k, v in pairs( self:GetWeapons( ) ) do
			weap[#weap + 1] = v:GetClass( )
		end

		self:SetNetworkValue( "weap", weap )
		self:StripWeapons( )
		self:Freeze( true )
		self:SetNoDraw( true )
		self:SetNetworkValue( "ragdollID", self.ragdoll:EntIndex( ) )
		self:SetNotSolid( true )
	end
		
	function META:Ragdoll( bool )
		if ( bool ) then
			self:ForceRagdoll( )
		else
			if ( !self:IsRagdolled( ) ) then return end
			self:SetPos( self.ragdoll:GetPos( ) )
			self:SetMoveType( MOVETYPE_WALK )
			self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
			self:Freeze( false )
			self:SetNoDraw( false )
			self:SetNetworkValue( "ragdollID", 0 )
			self:DropToFloor( )
			self:SetNotSolid( false )
			
			for k, v in pairs( self:GetNetworkValue( "weap", { } ) ) do
				self:Give( v )
			end

			self:SetNetworkValue( "weap", nil )

			if ( IsValid( self.ragdoll ) ) then
				self.ragdoll:Remove( )
			end
		end
	end
	
	*/
else

end

function META:GetWeaponRaised( )
	return catherine.network.GetNetVar( self, "weaponRaised", false )
end

function META:GetGender( )
	local model = self:GetModel( ):lower( )
	if ( model:find( "female" ) ) then
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