catherine.player = catherine.player or { }

local META = FindMetaTable( "Player" )

if ( SERVER ) then
	function catherine.player.Initialize( pl, func )
		if ( !catherine.database.Connected ) then // 데이터베이스가 연결되지 않음?
			netstream.Start( pl, "catherine.LoadingStatus", { false, "데이터베이스 오류 : " .. catherine.database.ErrorMsg, true } ) // 에러 메세지 전송;
			return
		end
		catherine.network.SyncAllVars( pl, function( ) // 현재 네트워킹 된 글로벌, 엔티티 값 전송..^-^
			netstream.Start( pl, "catherine.LoadingStatus", { false, "네트워킹 하는 중 ..." } )
			catherine.character.GetCurrentNetworking( pl, function( ) // 현재 네트워킹된 캐릭터 값 전송..^-^
				netstream.Start( pl, "catherine.LoadingStatus", { false, "캐릭터 네트워킹 중 ..." } )
				catherine.database.GetDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", function( data ) // 플레이어 데이터베이스 값 체크..
					if ( !data or #data == 0 ) then
						netstream.Start( pl, "catherine.LoadingStatus", { false, "플레이어 데이터베이스 초기화 하는 중 ..." } )
						catherine.database.InsertDatas( "catherine_players", { // 플레이어 데이터를 데이터베이스에 삽입..
							_steamName = pl:SteamName( ),
							_steamID = pl:SteamID( ),
							_catData = { }
						}, function( )
							netstream.Start( pl, "catherine.LoadingStatus", { false, "캐릭터 목록을 불러오는 중 ..." } )
							catherine.character.SendCharacterLists( pl, function( ) // 캐릭터 리스트 전송..
								netstream.Start( pl, "catherine.LoadingStatus", { false, "기타 데이터를 불러오는 중 ..." } )
								catherine.catData.Load( pl ) // cat(CAT - Catherine) 데이터 전송;
								netstream.Start( pl, "catherine.LoadingStatus", { false, "재미있게 플레이 하십시오!" } )
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
						netstream.Start( pl, "catherine.LoadingStatus", { false, "캐릭터 목록을 불러오는 중 ..." } )
						catherine.character.SendCharacterLists( pl, function( ) // 캐릭터 리스트 전송..
							netstream.Start( pl, "catherine.LoadingStatus", { false, "기타 데이터를 불러오는 중 ..." } )
							catherine.catData.Load( pl ) // cat(CAT - Catherine) 데이터 전송;
							netstream.Start( pl, "catherine.LoadingStatus", { false, "재미있게 플레이 하십시오!" } )
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
		return v( velo( self ) ) >= ( self:GetRunSpeed( ) - 5 )
	end
	
	function META:IsRagdolled( )
		return IsValid( self.ragdoll )
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
	
	//print(catherine.network.GetNetVar( self, "weaponRaised", false ))
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