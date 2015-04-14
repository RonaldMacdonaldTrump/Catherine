--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

catherine.player = catherine.player or { }
local META = FindMetaTable( "Player" )

if ( SERVER ) then
	function catherine.player.Initialize( pl, func )
		if ( !IsValid( pl ) ) then return end
		
		local function loading( )
			catherine.network.SyncAllVars( pl )
			catherine.character.SendCurrentNetworking( pl )
			catherine.environment.SyncToPlayer( pl )
			catherine.player.SQLInitialize( pl )
			catherine.character.SendCharacterLists( pl )
			catherine.catData.Load( pl )

			timer.Simple( 2, function( )
				if ( !IsValid( pl ) ) then return end
				netstream.Start( pl, "catherine.loadingFinished" )
				
				timer.Simple( 1, function( )
					if ( !IsValid( pl ) ) then return end
					
					netstream.Start( pl, "catherine.IntroStop" )
					timer.Simple( 1, function( )
						if ( !IsValid( pl ) ) then return end
						
						pl:Freeze( false )
						pl:UnLock( )
						catherine.character.OpenPanel( pl )
					end )
				end )
			end )
		end
		
		netstream.Hook( "catherine.player.CheckLocalPlayer_Receive", function( )
			netstream.Start( pl, "catherine.IntroStart" )
			loading( )
		end )
		
		pl:Freeze( true )
		pl:Lock( )
		
		netstream.Start( pl, "catherine.player.CheckLocalPlayer" )
	end

	function catherine.player.SQLInitialize( pl )
		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
			if ( !data or #data == 0 ) then
				if ( pl:SteamID( ) == catherine.configs.OWNER and pl:GetNWString( "usergroup" ):lower( ) == "user" ) then
					if ( ulx ) then
						RunConsoleCommand( "ulx", "adduserid", pl:SteamID( ), "superadmin" )
						catherine.util.Print( Color( 0, 255, 0 ), "Automatic owner set (using ULX) : " .. pl:SteamName( ) )
					else
						pl:SetUserGroup( "superadmin" )
						catherine.util.Print( Color( 0, 255, 0 ), "Automatic owner set : " .. pl:SteamName( ) )
					end
				end
				
				catherine.database.InsertDatas( "catherine_players", {
					_steamName = pl:SteamName( ),
					_steamID = pl:SteamID( ),
					_catData = { }
				} )
			end
		end )
	end
	
	function catherine.player.HealthRecoverTick( pl )
		if ( !pl.CAT_healthRecover ) then return end
		
		if ( math.Round( pl:Health( ) ) >= pl:GetMaxHealth( ) ) then
			pl.CAT_healthRecover = false
			hook.Run( "HealthFullRecovered", pl )
			return
		end
		
		if ( ( pl.CAT_healthRecoverTick or CurTime( ) + 3 ) <= CurTime( ) ) then
			pl:SetHealth( math.Clamp( pl:Health( ) + 1, 0, pl:GetMaxHealth( ) ) )
			pl.CAT_healthRecoverTick = CurTime( ) + 3
			hook.Run( "HealthRecovering", pl )
		end
	end
	
	function catherine.player.BunnyHopProtection( pl )
		if ( pl:KeyPressed( IN_JUMP ) and ( pl.CAT_nextBunnyCheck or CurTime( ) ) <= CurTime( ) ) then
			if ( !pl.CAT_nextBunnyCheck ) then
				pl.CAT_nextBunnyCheck = CurTime( ) + 0.05
			end
			pl.CAT_bunnyCount = ( pl.CAT_bunnyCount or 0 ) + 1
			if ( pl.CAT_bunnyCount >= 10 ) then
				pl:SetJumpPower( 150 )
				catherine.util.Notify( pl, "Don't Bunny-hop!" )
				pl:Freeze( true )
				pl.CAT_bunnyFreezed = true
				pl.CAT_nextbunnyFreezeDis = CurTime( ) + 5
			end
			pl.CAT_nextBunnyCheck = CurTime( ) + 0.05
		else
			if ( ( pl.CAT_nextBunnyInit or CurTime( ) ) <= CurTime( ) ) then
				pl.CAT_bunnyCount = 0
				pl.CAT_nextBunnyInit = CurTime( ) + 15
			end
		end
		if ( pl.CAT_bunnyFreezed and ( pl.CAT_nextbunnyFreezeDis or CurTime( ) ) <= CurTime( ) ) then
			pl:Freeze( false )
			pl.CAT_bunnyCount = 0
			pl.CAT_bunnyFreezed = false
		end
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
		
		if ( !time ) then catherine.util.TopNotify( pl, LANG( pl, "Player_Message_Ragdolled_01" ) ) end
		
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
			catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_Ragdolled_01" ), time, function( )
				catherine.player.RagdollWork( pl, false )
			end )
		end
	end

	function META:SetWeaponRaised( bool, wep )
		if ( !IsValid( self ) or !self:IsCharacterLoaded( ) ) then return end
		wep = wep or self:GetActiveWeapon( )
		if ( wep.AlwaysLowered ) then self:SetNetVar( "weaponRaised", false ) return end
		self:SetNetVar( "weaponRaised", bool )
		
		if ( IsValid( wep ) ) then
			local time = 99999
			if ( bool or wep.CanFireLowered ) then time = 0.9 end
			wep:SetNextPrimaryFire( CurTime( ) + time )
			wep:SetNextSecondaryFire( CurTime( ) + time )
		end
	end

	function META:ToggleWeaponRaised( )
		if ( self:GetWeaponRaised( ) ) then
			self:SetWeaponRaised( false )
		else
			self:SetWeaponRaised( true )
		end
	end
	
	hook.Add( "PlayerSwitchWeapon", "catherine.player.PlayerSwitchWeapon", function( pl, oldWep, newWep )
		if ( !newWep.AlwaysRaised and !catherine.configs.alwaysRaised[ newWep:GetClass( ) ] ) then
			pl:SetWeaponRaised( false, newWep )
		else
			pl:SetWeaponRaised( true, newWep )
		end
	end )
	
	local velo = FindMetaTable("Entity").GetVelocity
	local v = FindMetaTable("Vector").Length2D
	
	function META:IsRunning( )
		return v( velo( self ) ) >= ( catherine.configs.playerDefaultRunSpeed - 5 )
	end
else
	catherine.player.nextLocalPlayerCheck = catherine.player.nextLocalPlayerCheck or CurTime( ) + 1
	
	netstream.Hook( "catherine.player.CheckLocalPlayer", function( )
		hook.Add( "Tick", "catherine.player.CheckLocalPlayer.Tick", function( )
			if ( catherine.player.nextLocalPlayerCheck <= CurTime( ) ) then
				if ( IsValid( LocalPlayer( ) ) ) then
					netstream.Start( "catherine.player.CheckLocalPlayer_Receive" )
					hook.Remove( "Tick", "catherine.player.CheckLocalPlayer.Tick" )
					catherine.player.nextLocalPlayerCheck = nil
					return
				end
				catherine.player.nextLocalPlayerCheck = CurTime( ) + 1
			end
		end )
	end )
end

function catherine.player.IsRagdolled( pl )
	return pl:GetNetVar( "isRagdolled", nil )
end
	
function META:GetWeaponRaised( )
	return self:GetNetVar( "weaponRaised", false )
end

function META:GetGender( )
	local model = self:GetModel( ):lower( )
	local gender = "male"
	
	if ( model:find( "female" ) or model:find( "alyx" ) or model:find( "mossman" ) ) then
		gender = "female"
	end
	
	return gender
end

function player.GetAllByLoaded( )
	local players = { }
	
	for k, v in pairs( player.GetAll( ) ) do
		if ( !v:IsCharacterLoaded( ) ) then continue end
		players[ #players + 1 ] = v
	end
	
	return players
end