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
		
		local function loadFramework( )
			catherine.player.PlayerInformationInitialize( pl )
			catherine.net.SyncAllVars( pl )
			catherine.character.SyncAllNetworkRegistry( pl )
			catherine.environment.SyncToPlayer( pl )
			catherine.character.SyncCharacterList( pl )
			catherine.catData.SyncToPlayer( pl )

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
						catherine.character.OpenMenu( pl )
					end )
				end )
			end )
		end
		
		netstream.Hook( "catherine.player.CheckLocalPlayer_Receive", function( )
			netstream.Start( pl, "catherine.IntroStart" )
			loadFramework( )
		end )
		
		pl:Freeze( true )
		pl:Lock( )
		
		netstream.Start( pl, "catherine.player.CheckLocalPlayer" )
	end

	function catherine.player.PlayerInformationInitialize( pl )
		local steamID = pl.SteamID( pl )
		
		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. steamID .. "'", function( data )
			if ( !data or #data == 0 ) then
				if ( steamID == catherine.configs.OWNER and pl.GetNWString( pl, "usergroup" ):lower( ) == "user" ) then
					if ( ulx ) then
						RunConsoleCommand( "ulx", "adduserid", steamID, "superadmin" )
						catherine.util.Print( Color( 0, 255, 0 ), "Automatic owner set (using ULX) : " .. pl.SteamName( pl ) )
					else
						pl:SetUserGroup( "superadmin" )
						catherine.util.Print( Color( 0, 255, 0 ), "Automatic owner set : " .. pl.SteamName( pl ) )
					end
				end
				
				catherine.database.InsertDatas( "catherine_players", {
					_steamName = pl.SteamName( pl ),
					_steamID = steamID,
					_catData = { }
				} )
			end
		end )
	end
	
	function catherine.player.HealthRecoverTick( pl )
		if ( !pl.CAT_healthRecover ) then return end

		if ( math.Round( pl.Health( pl ) ) >= pl.GetMaxHealth( pl ) ) then
			pl.CAT_healthRecover = false
			hook.Run( "HealthFullRecovered", pl )
			return
		end
		
		if ( ( pl.CAT_healthRecoverTick or CurTime( ) ) <= CurTime( ) ) then
			pl:SetHealth( math.Clamp( pl.Health( pl ) + 1, 0, pl.GetMaxHealth( pl ) ) )
			pl.CAT_healthRecoverTick = CurTime( ) + 5
			hook.Run( "HealthRecovering", pl )
		end
	end
	
	function catherine.player.SetTie( pl, target, bool, force, removeItem )
		if ( bool ) then
			if ( catherine.player.IsTied( pl ) and !force ) then
				catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
				return
			end
		
			if ( catherine.player.IsTied( target ) ) then
				catherine.util.NotifyLang( pl, "Item_Notify01_ZT" )
				return
			end
			
			if ( !catherine.inventory.HasItem( pl, "zip_tie" ) ) then
				catherine.util.NotifyLang( pl, "Item_Notify02_ZT" )
				return
			end
			
			catherine.util.ProgressBar( pl, LANG( pl, "Item_Message01_ZT" ), 2, function( )
				local tr = { }
				tr.start = pl.GetShootPos( pl )
				tr.endpos = tr.start + pl.GetAimVector( pl ) * 60
				tr.filter = pl
				
				target = util.TraceLine( tr ).Entity
				
				if ( !IsValid( target ) ) then return end
				
				if ( target.GetClass( target ) == "prop_ragdoll" ) then
					target = target.GetNetVar( target, "player" )
				end
				
				if ( IsValid( target ) ) then
					catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, {
						uniqueID = "zip_tie"
					} )
				
					target:SetNetVar( "isTied", true )
					
					return true
				end
			end )
		else
			if ( catherine.player.IsTied( pl ) and !force ) then
				catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
				return
			end
			
			if ( !catherine.player.IsTied( target ) ) then
				catherine.util.NotifyLang( pl, "Item_Notify04_ZT" )
				return
			end
			
			catherine.util.ProgressBar( pl, LANG( pl, "Item_Message02_ZT" ), 2, function( )
				local tr = { }
				tr.start = pl.GetShootPos( pl )
				tr.endpos = tr.start + pl.GetAimVector( pl ) * 60
				tr.filter = pl
				
				target = util.TraceLine( tr ).Entity
				
				if ( !IsValid( target ) ) then return end
				
				if ( target.GetClass( target ) == "prop_ragdoll" ) then
					target = target.GetNetVar( target, "player" )
				end
		
				if ( IsValid( target ) ) then
					target:SetNetVar( "isTied", false )
					
					return true
				end
			end )
		end
	end
	
	function catherine.player.BunnyHopProtection( pl )
		if ( pl.KeyPressed( pl, IN_JUMP ) and ( pl.CAT_nextBunnyCheck or CurTime( ) ) <= CurTime( ) ) then
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
		if ( status ) then
			if ( IsValid( pl.CAT_ragdoll ) ) then
				pl.CAT_ragdoll:Remove( )
			end

			local ent = ents.Create( "prop_ragdoll" )
			ent:SetAngles( pl.GetAngles( pl ) )
			ent:SetModel( pl.GetModel( pl ) )
			ent:SetPos( pl.GetPos( pl ) )
			ent:SetSkin( pl.GetSkin( pl ) )
			ent:Spawn( )
			ent:SetNetVar( "player", pl )
			ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
			ent:Activate( )
			ent:CallOnRemove( "RecoverPlayer", function( )
				if ( !IsValid( pl ) ) then return end
				
				pl:SetNetVar( "ragdollIndex", nil )
				pl:SetNetVar( "isRagdolled", nil )
				
				pl:SetNotSolid( false )
				pl:SetNoDraw( false )
				pl:Freeze( false )
				pl:SetMoveType( MOVETYPE_WALK )
				pl:SetLocalVelocity( vector_origin )
				
				for k, v in ipairs( ent.CAT_weaponsBuffer ) do
					pl.Give( pl, v )
				end
			end )

			pl.CAT_ragdoll = ent

			ent.CAT_weaponsBuffer = { }
			ent.CAT_player = pl

			for k, v in ipairs( pl.GetWeapons( pl ) ) do
				ent.CAT_weaponsBuffer[ #ent.CAT_weaponsBuffer + 1 ] = v.GetClass( v )
			end

			pl:StripWeapons( )
			pl:GodDisable( )
			pl:Freeze( true )
			pl:SetNotSolid( true )
			pl:SetNoDraw( true )

			pl:SetNetVar( "ragdollIndex", ent.EntIndex( ent ) )
			pl:SetNetVar( "isRagdolled", true )
			
			if ( time ) then
				catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_Ragdolled_01" ), time, function( )
					catherine.player.RagdollWork( pl )
				end )
			else
				catherine.util.TopNotify( pl, LANG( pl, "Player_Message_Ragdolled_01" ) )
			end
		elseif ( IsValid( pl.CAT_ragdoll ) ) then
			pl.CAT_ragdoll:Remove( )
		end
	end

	function META:SetWeaponRaised( bool, wep )
		if ( !IsValid( self ) or !self.IsCharacterLoaded( self ) ) then return end
		wep = wep or self.GetActiveWeapon( self )
		
		if ( wep.AlwaysLowered ) then
			self:SetNetVar( "weaponRaised", false )
			return
		end
		
		self:SetNetVar( "weaponRaised", bool )
		
		if ( IsValid( wep ) ) then
			local time = 99999
			
			if ( bool or wep.CanFireLowered ) then
				time = 0.9
			end
			
			wep:SetNextPrimaryFire( CurTime( ) + time )
			wep:SetNextSecondaryFire( CurTime( ) + time )
		end
	end

	function META:ToggleWeaponRaised( )
		if ( self.GetWeaponRaised( self ) ) then
			self:SetWeaponRaised( false )
		else
			self:SetWeaponRaised( true )
		end
	end
	
	local velo = FindMetaTable( "Entity" ).GetVelocity
	local twoD = FindMetaTable( "Vector" ).Length2D
	
	function META:IsRunning( )
		return twoD( velo( self ) ) >= ( catherine.configs.playerDefaultRunSpeed - 5 )
	end

	function catherine.player.PlayerSwitchWeapon( pl, oldWep, newWep )
		if ( !newWep.AlwaysRaised and !catherine.configs.alwaysRaised[ newWep.GetClass( newWep ) ] ) then
			pl:SetWeaponRaised( false, newWep )
		else
			pl:SetWeaponRaised( true, newWep )
		end
	end
	
	hook.Add( "PlayerSwitchWeapon", "catherine.player.PlayerSwitchWeapon", catherine.player.PlayerSwitchWeapon )
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

function META:GetWeaponRaised( )
	return self.GetNetVar( self, "weaponRaised", false )
end

function META:GetGender( )
	local model = self.GetModel( self ):lower( )
	local gender = "male"
	
	if ( model:find( "female" ) or model:find( "alyx" ) or model:find( "mossman" ) ) then
		gender = "female"
	end
	
	return gender
end

function META:IsFemale( )
	local model = self.GetModel( self ):lower( )

	if ( model:find( "female" ) or model:find( "alyx" ) or model:find( "mossman" ) ) then
		return true
	end
end

function META:IsNoclipping( )
	return self.GetNetVar( self, "nocliping", false )
end

function META:IsChatTyping( )
	return self.GetNetVar( self, "isTyping", false )
end

function catherine.player.IsRagdolled( pl )
	return pl.GetNetVar( pl, "isRagdolled", nil )
end

function catherine.player.IsTied( pl )
	return pl.GetNetVar( pl, "isTied", false )
end

function player.GetAllByLoaded( )
	local players = { }
	
	for k, v in pairs( player.GetAll( ) ) do
		if ( !v.IsCharacterLoaded( v ) ) then continue end
		
		players[ #players + 1 ] = v
	end
	
	return players
end