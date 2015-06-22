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
local META2 = FindMetaTable( "Entity" )
local velo = FindMetaTable( "Entity" ).GetVelocity
local twoD = FindMetaTable( "Vector" ).Length2D

if ( SERVER ) then
	function catherine.player.Initialize( pl, func )
		if ( !IsValid( pl ) ) then return end
		
		local function Initializing( )
			if ( !IsValid( pl ) ) then return end
			--[[ Initializing a Catherine ... :> ]]--
			
			catherine.net.ScanErrorNetworkRegistry( ) // Just.
			
			catherine.player.PlayerInformationUpdate( pl )
			catherine.net.SendAllNetworkRegistries( pl ) // Send ALL entity, player network registries.
			catherine.character.SendAllNetworkRegistries( pl ) // Send ALL character network registries.
			catherine.environment.SendAllEnvironmentConfig( pl ) // Send ALL enviroment configs.
			catherine.character.SendPlayerCharacterList( pl )
			catherine.catData.SendAllNetworkRegistries( pl ) // Send ALL CAT DATA network registries.
			
			if ( !catherine.catData.GetVar( pl, "language" ) ) then
				catherine.player.UpdateLanguageSetting( pl )
			end

			timer.Simple( 1, function( )
				netstream.Start( pl, "catherine.loadingFinished" )
				pl:Freeze( false )
				
				--[[ Finish! ]]--
			end )
		end
		
		netstream.Hook( "catherine.player.CheckLocalPlayer_Receive", function( )
			if ( !IsValid( pl ) ) then return end
			
			netstream.Start( pl, "catherine.introStart" )
			
			timer.Simple( 1, function( )
				Initializing( )
			end )
		end )
		
		pl:Freeze( true )
		
		netstream.Start( pl, "catherine.player.CheckLocalPlayer" )
	end
	
	function catherine.player.UpdateLanguageSetting( pl )
		pl:ConCommand( "cat_convar_language " .. catherine.configs.defaultLanguage )
		catherine.catData.SetVar( pl, "language", true, nil, true )
	end

	function catherine.player.PlayerInformationUpdate( pl )
		local steamID = pl:SteamID( )

		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. steamID .. "'", function( data )
			if ( !data or #data == 0 ) then
				if ( steamID == catherine.configs.OWNER and pl:GetNWString( "usergroup" ):lower( ) == "user" ) then
					if ( ulx ) then
						RunConsoleCommand( "ulx", "adduserid", steamID, "superadmin" )
						catherine.util.Print( Color( 0, 255, 0 ), "Automatic owner set (using ULX) : " .. pl:SteamName( ) )
					else
						pl:SetUserGroup( "superadmin" )
						catherine.util.Print( Color( 0, 255, 0 ), "Automatic owner set : " .. pl:SteamName( ) )
					end
				end
				
				catherine.database.InsertDatas( "catherine_players", {
					_steamName = pl:SteamName( ),
					_steamID = steamID,
					_steamID64 = pl:SteamID64( ),
					_catData = { },
					_ipAddress = pl:IPAddress( ),
					_lastConnect = catherine.util.GetRealTime( )
				} )
			else
				catherine.database.UpdateDatas( "catherine_players", "_steamID = '" .. steamID .. "'", {
					_steamName = pl:SteamName( ),
					_ipAddress = pl:IPAddress( ),
					_lastConnect = catherine.util.GetRealTime( )
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
		
		if ( ( pl.CAT_healthRecoverTick or CurTime( ) ) <= CurTime( ) ) then
			pl:SetHealth( math.Clamp( pl:Health( ) + 1, 0, pl:GetMaxHealth( ) ) )
			pl.CAT_healthRecoverTick = CurTime( ) + 5
			hook.Run( "HealthRecovering", pl )
		end
	end
	
	function catherine.player.SetTie( pl, target, bool, force, removeItem )
		if ( bool ) then
			if ( pl:IsTied( ) and !force ) then
				catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
				return
			end
		
			if ( target:IsTied( ) ) then
				catherine.util.NotifyLang( pl, "Item_Notify01_ZT" )
				return
			end
			
			if ( !catherine.inventory.HasItem( pl, "zip_tie" ) ) then
				catherine.util.NotifyLang( pl, "Item_Notify02_ZT" )
				return
			end
			
			catherine.util.ProgressBar( pl, LANG( pl, "Item_Message01_ZT" ), 2, function( )
				local tr = { }
				tr.start = pl:GetShootPos( )
				tr.endpos = tr.start + pl:GetAimVector( ) * 60
				tr.filter = pl
				
				target = util.TraceLine( tr ).Entity
				
				if ( !IsValid( target ) ) then return end
				
				if ( target:GetClass( ) == "prop_ragdoll" ) then
					target = catherine.entity.GetPlayer( target )
				end
				
				if ( IsValid( target ) ) then
					catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, {
						uniqueID = "zip_tie"
					} )
				
					target:SetWeaponRaised( false )
					target:SetNetVar( "isTied", true )
					
					return true
				end
			end )
		else
			if ( pl:IsTied( ) and !force ) then
				catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
				return
			end
			
			if ( !target:IsTied( ) ) then
				catherine.util.NotifyLang( pl, "Item_Notify04_ZT" )
				return
			end
			
			catherine.util.ProgressBar( pl, LANG( pl, "Item_Message02_ZT" ), 2, function( )
				local tr = { }
				tr.start = pl:GetShootPos( )
				tr.endpos = tr.start + pl:GetAimVector( ) * 60
				tr.filter = pl
				
				target = util.TraceLine( tr ).Entity
				
				if ( !IsValid( target ) ) then return end
				
				if ( target:GetClass( ) == "prop_ragdoll" ) then
					target = catherine.entity.GetPlayer( target )
				end
		
				if ( IsValid( target ) ) then
					target:SetNetVar( "isTied", false )
					
					return true
				end
			end )
		end
	end
	
	function catherine.player.SetCharacterBan( pl, status, func )
		if ( status ) then
			catherine.character.SetCharVar( pl, "charBanned", true )
			
			if ( func ) then
				func( )
			end
		else
			catherine.character.SetCharVar( pl, "charBanned", nil )
			
			if ( func ) then
				func( )
			end
		end
	end
	
	function catherine.player.IsCharacterBanned( pl )
		return catherine.character.GetCharVar( pl, "charBanned" )
	end

	function catherine.player.BunnyHopProtection( pl )
		if ( pl:KeyPressed( IN_JUMP ) and ( pl.CAT_nextBunnyCheck or CurTime( ) ) <= CurTime( ) ) then
			if ( !pl.CAT_nextBunnyCheck ) then
				pl.CAT_nextBunnyCheck = CurTime( ) + 0.05
			end
			
			pl.CAT_bunnyCount = ( pl.CAT_bunnyCount or 0 ) + 1
			
			if ( pl.CAT_bunnyCount >= 10 ) then
				catherine.util.NotifyLang( pl, "Basic_Notify_BunnyHop" )
				pl:Freeze( true )
				pl.CAT_bunnyFreezed = true
				pl.CAT_nextbunnyFreezeDis = CurTime( ) + 5
				
				hook.Run( "PlayerBunnyHopped", pl )
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
	
	function catherine.player.SetIgnoreHurtSound( pl, bool )
		pl.CAT_ignore_hurtSound = bool
	end
	
	function catherine.player.SetIgnoreGiveFlagWeapon( pl, bool )
		pl.CAT_ignoreGiveFlagWeapon = bool
	end
	
	function catherine.player.SetIgnoreScreenColor( pl, bool )
		pl.CAT_ignoreScreenColor = bool
	end
	
	function catherine.player.GetIgnoreHurtSound( pl )
		return pl.CAT_ignore_hurtSound
	end
	
	function catherine.player.GetIgnoreGiveFlagWeapon( pl )
		return pl.CAT_ignoreGiveFlagWeapon
	end

	function catherine.player.GetIgnoreScreenColor( pl )
		return pl.CAT_ignoreScreenColor
	end
	
	function catherine.player.GetPlayerDefaultRunSpeed( pl )
		return hook.Run( "GetCustomPlayerDefaultRunSpeed", pl ) or catherine.configs.playerDefaultRunSpeed
	end

	function catherine.player.GetPlayerDefaultJumpPower( pl )
		return hook.Run( "GetCustomPlayerDefaultJumpPower", pl ) or catherine.configs.playerDefaultJumpPower
	end

	function catherine.player.RagdollWork( pl, status, time )
		if ( status ) then
			if ( IsValid( pl.CAT_ragdoll ) ) then
				pl.CAT_ragdoll:Remove( )
			end

			local ent = ents.Create( "prop_ragdoll" )
			ent:SetAngles( pl:GetAngles( ) )
			ent:SetModel( pl:GetModel( ) )
			ent:SetPos( pl:GetPos( ) )
			ent:SetSkin( pl:GetSkin( ) )
			ent:Spawn( )
			ent:SetNetVar( "player", pl )
			ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
			ent:Activate( )
			ent:CallOnRemove( "RecoverPlayer", function( )
				if ( !IsValid( pl ) ) then return end
				
				pl:SetNetVar( "ragdollIndex", nil )
				pl:SetNetVar( "isRagdolled", nil )

				if ( !pl.CAT_isDeadFunc ) then
					pl:SetPos( ent:GetPos( ) )
					pl:SetNotSolid( false )
					pl:SetNoDraw( false )
					pl:Freeze( false )
					pl:SetMoveType( MOVETYPE_WALK )
					pl:SetLocalVelocity( vector_origin )

					for k, v in ipairs( ent.CAT_weaponsBuffer ) do
						pl:Give( v )
					end
					
					catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
					hook.Run( "PlayerRagdollExited", pl )
				end
			end )

			pl.CAT_ragdoll = ent

			ent.CAT_weaponsBuffer = { }
			ent.CAT_player = pl

			for k, v in ipairs( pl:GetWeapons( ) ) do
				ent.CAT_weaponsBuffer[ #ent.CAT_weaponsBuffer + 1 ] = v:GetClass( )
			end

			pl:StripWeapons( )
			pl:GodDisable( )
			pl:Freeze( true )
			pl:SetNotSolid( true )
			pl:SetNoDraw( true )

			pl:SetNetVar( "ragdollIndex", ent:EntIndex( ) )
			pl:SetNetVar( "isRagdolled", true )
			
			if ( time ) then
				pl:SetNetVar( "isForceRagdolled", true )
				
				local uniqueID = "Catherine.timer.RagdollWork_" .. ent:EntIndex( )
				
				catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_Ragdolled_01" ), time, function( )
					catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
					catherine.player.RagdollWork( pl )
					pl:SetNetVar( "isForceRagdolled", nil )
					timer.Remove( uniqueID )
				end )

				timer.Create( uniqueID, 1, 0, function( )
					if ( !IsValid( pl ) ) then return end

					if ( !pl:Alive( ) ) then
						timer.Remove( uniqueID )
						return
					end
					
					local ragdoll = pl.CAT_ragdoll

					if ( IsValid( ragdoll ) ) then
						if ( ragdoll:GetVelocity( ):Length2D( ) >= 4 ) then
							if ( !ragdoll.CAT_paused ) then
								ragdoll.CAT_paused = true
								catherine.util.ProgressBar( pl, false )
							end

							return
						elseif ( ragdoll.CAT_paused ) then
							catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_Ragdolled_01" ), time, function( )
								catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
								catherine.player.RagdollWork( pl )
								timer.Remove( uniqueID )
							end )
							
							ragdoll.CAT_paused = nil
						end
					else
						//catherine.player.RagdollWork( pl )
						timer.Remove( uniqueID )
					end
				end )
			else
				catherine.util.TopNotify( pl, LANG( pl, "Player_Message_Ragdolled_01" ) )
			end
			
			hook.Run( "PlayerRagdollJoined", pl )
		elseif ( IsValid( pl.CAT_ragdoll ) ) then
			pl.CAT_ragdoll:Remove( )
		end
	end

	function META:SetWeaponRaised( bool, wep )
		if ( self:IsTied( ) ) then
			if ( self:GetWeaponRaised( ) ) then
				self:SetNetVar( "weaponRaised", false )
			end
			
			return
		end
		
		wep = wep or self:GetActiveWeapon( )
		
		self:SetNetVar( "weaponRaised", bool )
		
		if ( IsValid( wep ) ) then
			wep:SetNextPrimaryFire( CurTime( ) + 1 )
			wep:SetNextSecondaryFire( CurTime( ) + 1 )
		end
	end

	function META:ToggleWeaponRaised( )
		local bool = self:GetWeaponRaised( )
		
		self:SetWeaponRaised( !bool )
		
		local wep = self:GetActiveWeapon( )
		
		if ( IsValid( wep ) ) then
			if ( bool and wep.OnRaised ) then
				wep:OnRaised( )
			elseif ( !bool and wep.OnLowered ) then
				wep:OnLowered( )
			end
		end
	end
	
	META.CATGiveWeapon = META.CATGiveWeapon or META.Give
	META.CATTakeWeapon = META.CATTakeWeapon or META.StripWeapon
	META.CATGodEnable = META.CATGodEnable or META.GodEnable
	META.CATGodDisable = META.CATGodDisable or META.GodDisable
	META2.CATSetHealth = META2.CATSetHealth or META2.SetHealth
	META.CATSetArmor = META.CATSetArmor or META.SetArmor

	function META:SetHealth( health )
		local oldHealth = self:Health( )
		
		self:CATSetHealth( health )
		
		hook.Run( "PlayerHealthSet", self, health, oldHealth )
	end
	
	function META:SetArmor( armor )
		local oldArmor = self:Armor( )
		
		self:CATSetArmor( armor )
		
		hook.Run( "PlayerArmorSet", self, armor, oldArmor )
	end

	function META:Give( uniqueID )
		local wep = self:CATGiveWeapon( uniqueID )
		
		hook.Run( "PlayerGiveWeapon", self, uniqueID )
		
		return wep
	end
	
	function META:StripWeapon( uniqueID )
		hook.Run( "PlayerStripWeapon", self, uniqueID )
		
		self:CATTakeWeapon( uniqueID )
	end
	
	function META:GodEnable( )
		hook.Run( "PlayerGodMode", self, true )
		
		self.CAT_godMode = true
		
		self:CATGodEnable( )
	end
	
	function META:GodDisable( )
		hook.Run( "PlayerGodMode", self, false )
		
		self.CAT_godMode = nil
		
		self:CATGodDisable( )
	end
	
	function META:IsInGod( )
		return self.CAT_godMode
	end

	function catherine.player.PlayerSwitchWeapon( pl, oldWep, newWep )
		if ( !newWep.AlwaysRaised and !catherine.configs.alwaysRaised[ newWep:GetClass( ) ] ) then
			pl:SetWeaponRaised( false, newWep )
		else
			pl:SetWeaponRaised( true, newWep )
		end
	end
	
	hook.Add( "PlayerSwitchWeapon", "catherine.player.PlayerSwitchWeapon", catherine.player.PlayerSwitchWeapon )
else
	catherine.player.nextLocalPlayerCheck = catherine.player.nextLocalPlayerCheck or CurTime( ) + 0.05
	
	netstream.Hook( "catherine.player.CheckLocalPlayer", function( )
		hook.Add( "Tick", "catherine.player.CheckLocalPlayer.Tick", function( )
			if ( catherine.player.nextLocalPlayerCheck <= CurTime( ) ) then
				if ( IsValid( LocalPlayer( ) ) ) then
					netstream.Start( "catherine.player.CheckLocalPlayer_Receive" )
					hook.Remove( "Tick", "catherine.player.CheckLocalPlayer.Tick" )
					catherine.player.nextLocalPlayerCheck = nil
					return
				end
				catherine.player.nextLocalPlayerCheck = CurTime( ) + 0.05
			end
		end )
	end )
end

function META:GetWeaponRaised( )
	local wep = self:GetActiveWeapon( )
	
	if ( IsValid( wep ) ) then
		if ( wep.IsAlwaysRaised or catherine.configs.alwaysRaised[ wep:GetClass( ) ] ) then
			return true
		elseif ( wep.IsAlwaysLowered ) then
			return false
		end
	end
	
	if ( self:IsTied( ) ) then
		return false
	end
	
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

function META:IsFemale( )
	local model = self:GetModel( ):lower( )

	if ( model:find( "female" ) or model:find( "alyx" ) or model:find( "mossman" ) ) then
		return true
	end
end

function META:IsNoclipping( )
	return self:GetNetVar( "nocliping", false )
end

function META:IsRagdolled( )
	return self:GetNetVar( "isRagdolled", false )
end

function META:IsTied( )
	return self:GetNetVar( "isTied", false )
end

function META:IsChatTyping( )
	return self:GetNetVar( "isTyping", false )
end

function META:IsRunning( )
	return twoD( velo( self ) ) >= ( catherine.configs.playerDefaultRunSpeed - 5 )
end

function player.GetAllByLoaded( )
	local players = { }
	
	for k, v in pairs( player.GetAll( ) ) do
		if ( !v:IsCharacterLoaded( ) ) then continue end
		
		players[ #players + 1 ] = v
	end
	
	return players
end