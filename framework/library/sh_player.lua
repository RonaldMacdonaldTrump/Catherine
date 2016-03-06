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
local velo = META2.GetVelocity
local twoD = FindMetaTable( "Vector" ).Length2D

if ( SERVER ) then
	local initFunctions = {
		{ "player", "UpdateInformation" },
		{ "net", "SendAllNetworkRegistries" },
		{ "character", "SendAllNetworkRegistries" },
		{ "environment", "SendAllEnvironmentConfig" },
		{ "character", "SendPlayerCharacterList" },
		{ "catData", "SendAllNetworkRegistries" }
	}
	
	function catherine.player.Initialize( pl, isRetry )
		if ( !IsValid( pl ) ) then return end
		
		local function Initializing( )
			if ( !IsValid( pl ) ) then return end
			
			if ( !Schema ) then
				timer.Remove( "Catherine.timer.player.Initialize.Reload" )
				netstream.Start( pl, "catherine.loadingError", LANG( pl, "Basic_Error_NoSchema" ) )
				return
			end
			
			if ( !catherine.database.connected ) then
				timer.Remove( "Catherine.timer.player.Initialize.Reload" )
				netstream.Start( pl, "catherine.loadingError", LANG( pl, "Basic_Error_NoDatabase", catherine.database.errorMsg ) )
				return
			end
			
			catherine.character.RemoveDummy( )
			catherine.player.UpdateLanguageSetting( pl )
			
			for i = 1, #initFunctions do
				local libName, funcName = initFunctions[ i ][ 1 ], initFunctions[ i ][ 2 ]
				local success, result = pcall( catherine[ libName ][ funcName ], pl )
				
				if ( !success ) then
					netstream.Start( pl, "catherine.loadingError", LANG( pl, "Basic_Error_LibraryLoad", "catherine." .. libName .. "." .. funcName ) )
					MsgC( Color( 255, 0, 0 ), "[CAT ERROR] Failed to initialize Catherine! ( Player : " .. pl:Name( ) .. "/" .. pl:SteamID( ) .. " ) ( Function : catherine." .. libName .. "." .. funcName .. " )\n" .. result .. "\n" )
					return
				end
			end
			
			timer.Remove( "Catherine.timer.player.Initialize.Reload" )
			
			hook.Run( "PlayerLoadFinished", pl )
			
			timer.Simple( 1, function( )
				if ( !IsValid( pl ) ) then return end
				
				netstream.Start( pl, "catherine.loadingFinished" )
			end )
		end
		
		if ( !isRetry ) then
			netstream.Hook( "catherine.player.CheckLocalPlayer.Receive", function( )
				if ( !IsValid( pl ) ) then return end
				
				Initializing( )
			end )
			
			netstream.Start( pl, "catherine.player.CheckLocalPlayer" )
		else
			Initializing( )
		end
	end
	
	function catherine.player.UpdateLanguageSetting( pl )
		if ( catherine.catData.GetVar( pl, "language" ) ) then return end
		
		if ( catherine.configs.defaultLanguage == "" ) then
			catherine.util.GetForceClientConVar( pl, "gmod_language", function( langID )
				local languageTable = catherine.language.FindByGmodLangID( langID )
				
				pl:ConCommand( "cat_convar_language " .. ( languageTable and languageTable.uniqueID or "english" ) )
				catherine.catData.SetVar( pl, "language", true, nil, true )
			end )
		else
			local languageTable = catherine.language.FindByID( catherine.configs.defaultLanguage )
			
			pl:ConCommand( "cat_convar_language " .. ( languageTable and languageTable.uniqueID or "english" ) )
			catherine.catData.SetVar( pl, "language", true, nil, true )
		end
	end
	
	local adminModule_func = {
		ulx = function( pl, steamID ) // https://github.com/Nayruden/Ulysses/tree/master/ulx
			RunConsoleCommand( "ulx", "adduserid", steamID, "superadmin" )
		end,
		moderator = function( pl, steamID ) // https://github.com/Chessnut/moderator
			moderator.SetGroup( pl, "owner" )
		end,
		exsto = function( pl, steamID ) // http://exsto.googlecode.com/svn/trunk
			pl:SetRank( "srv_owner" )
		end,
		evolve = function( pl, steamID ) // http://evolvemod.googlecode.com/svn/trunk/beta
			pl:EV_SetRank( "owner" )
		end,
		serverguard = function( pl, steamID ) // https://www.gmodserverguard.com/
			serverguard.player:SetRank( pl, "founder" )
		end
	}
	
	function catherine.player.UpdateInformation( pl )
		local steamID = pl:SteamID( )
		
		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. steamID .. "'", function( data )
			if ( !IsValid( pl ) ) then return end
			
			if ( catherine.configs.OWNER != "" and steamID == catherine.configs.OWNER ) then
				if ( table.HasValue( { "user", "guest" }, pl:GetNWString( "usergroup" ):lower( ) ) ) then
					local doDef = true
					
					for k, v in pairs( adminModule_func ) do
						if ( _G[ k ] ) then
							v( pl, steamID )
							doDef = false
							break
						end
					end
					
					if ( doDef ) then
						pl:SetUserGroup( "superadmin" )
					end
				end
			end
			
			if ( !data or #data == 0 ) then
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
		if ( !catherine.character.GetCharVar( pl, "isHealthRecover" ) ) then return end
		
		if ( ( pl.CAT_healthRecoverTick or 0 ) <= CurTime( ) ) then
			if ( hook.Run( "PlayerShouldRecoverHealth", pl ) == false ) then return end
			
			if ( pl:Health( ) >= pl:GetMaxHealth( ) ) then
				catherine.character.SetCharVar( pl, "isHealthRecover", nil )
				hook.Run( "HealthFullRecovered", pl )
				return
			end
			
			pl:SetHealth( math.Clamp( pl:Health( ) + ( hook.Run( "GetHealthRecoverAmount", pl ) or 1 ), 0, pl:GetMaxHealth( ) ) )
			pl.CAT_healthRecoverTick = CurTime( ) + ( hook.Run( "GetHealthRecoverInterval", pl ) or 5 )
			hook.Run( "HealthRecovering", pl )
		end
	end
	
	function catherine.player.SetTie( pl, target, bool, force, removeItem, time )
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
			
			if ( hook.Run( "PlayerShouldTie", pl, target, time ) == false ) then return end
			
			catherine.util.ProgressBar( pl, LANG( pl, "Item_Message01_ZT" ), hook.Run( "GetTieingTime", pl, target, bool ) or time or 2, function( )
				local tr = { }
				tr.start = pl:GetShootPos( )
				tr.endpos = tr.start + pl:GetAimVector( ) * 160
				tr.filter = pl
				
				local newTarget = util.TraceLine( tr ).Entity
				
				if ( !IsValid( target ) or !IsValid( newTarget ) ) then return end
				
				if ( newTarget:GetClass( ) == "prop_ragdoll" ) then
					newTarget = catherine.entity.GetPlayer( newTarget )
				end
				
				if ( IsValid( newTarget ) and newTarget:IsPlayer( ) ) then
					if ( pl:IsTied( ) and !force ) then
						catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
						return
					end
					
					if ( newTarget:IsTied( ) ) then
						catherine.util.NotifyLang( pl, "Item_Notify01_ZT" )
						return
					end
					
					if ( !catherine.inventory.HasItem( pl, "zip_tie" ) ) then
						catherine.util.NotifyLang( pl, "Item_Notify02_ZT" )
						return
					end
					
					if ( hook.Run( "PlayerShouldTie", pl, target, time ) == false ) then return end
					
					if ( removeItem ) then
						catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, {
							uniqueID = "zip_tie"
						} )
					end
					
					newTarget:SetWeaponRaised( false )
					newTarget:SetNetVar( "isTied", true )
					
					hook.Run( "PlayerTied", pl, newTarget )
					
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
			
			if ( hook.Run( "PlayerShouldUnTie", pl, target, time ) == false ) then return end
			
			catherine.util.ProgressBar( pl, LANG( pl, "Item_Message02_ZT" ), hook.Run( "GetTieingTime", pl, target, bool ) or time or 2, function( )
				local tr = { }
				tr.start = pl:GetShootPos( )
				tr.endpos = tr.start + pl:GetAimVector( ) * 160
				tr.filter = pl
				
				local newTarget = util.TraceLine( tr ).Entity
				
				if ( !IsValid( target ) or !IsValid( newTarget ) ) then return end
				
				if ( newTarget:GetClass( ) == "prop_ragdoll" ) then
					newTarget = catherine.entity.GetPlayer( newTarget )
				end
				
				if ( IsValid( newTarget ) and newTarget:IsPlayer( ) ) then
					if ( pl:IsTied( ) and !force ) then
						catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
						return
					end
					
					if ( !newTarget:IsTied( ) ) then
						catherine.util.NotifyLang( pl, "Item_Notify04_ZT" )
						return
					end
					
					if ( hook.Run( "PlayerShouldUnTie", pl, target, time ) == false ) then return end
					
					newTarget:SetNetVar( "isTied", nil )
					
					hook.Run( "PlayerUnTied", pl, newTarget )
					
					return true
				end
			end )
		end
	end
	
	function catherine.player.SetCharacterBan( pl, status, func )
		if ( hook.Run( "PlayerShouldCharacterBan", pl, status, func ) == false ) then
			return false, "Character_Notify_CantCharBan_UnBan"
		end
		
		if ( status ) then
			catherine.character.SetCharVar( pl, "charBanned", true )
			
			if ( func ) then
				func( )
			end
			
			hook.Run( "CharacterBanned", pl, func )
			
			return true
		else
			catherine.character.SetCharVar( pl, "charBanned", nil )
			
			if ( func ) then
				func( )
			end
			
			hook.Run( "CharacterUnBanned", pl, func )
			
			return true
		end
	end
	
	function catherine.player.IsCharacterBanned( pl )
		return catherine.character.GetCharVar( pl, "charBanned" )
	end
	
	function catherine.player.BunnyHopProtection( pl )
		if ( pl:KeyPressed( IN_JUMP ) and ( pl.CAT_nextBunnyCheck or CurTime( ) ) <= CurTime( ) ) then
			if ( hook.Run( "PlayerShouldCheckBunnyHop", pl ) == false ) then return end
			
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
	
	function catherine.player.IsIgnoreHurtSound( pl )
		return pl.CAT_ignore_hurtSound
	end
	
	function catherine.player.IsIgnoreGiveFlagWeapon( pl )
		return pl.CAT_ignoreGiveFlagWeapon
	end
	
	function catherine.player.IsIgnoreScreenColor( pl )
		return pl.CAT_ignoreScreenColor
	end
	
	function catherine.player.GetPlayerDefaultRunSpeed( pl )
		return hook.Run( "GetCustomPlayerDefaultRunSpeed", pl ) or catherine.configs.playerDefaultRunSpeed
	end
	
	function catherine.player.GetPlayerDefaultJumpPower( pl )
		return hook.Run( "GetCustomPlayerDefaultJumpPower", pl ) or catherine.configs.playerDefaultJumpPower
	end
	
	function catherine.player.RagdollWork( pl, status, time )
		if ( hook.Run( "PlayerShouldWorkRagdoll", pl, status, time ) == false ) then return end
		
		if ( status ) then
			if ( IsValid( pl.CAT_ragdoll ) ) then
				pl.CAT_ragdoll:Remove( )
			end
			
			local ent = ents.Create( "prop_ragdoll" )
			ent:SetAngles( pl:GetAngles( ) )
			ent:SetModel( pl:GetModel( ) )
			ent:SetPos( pl:GetPos( ) )
			ent:SetSkin( pl:GetSkin( ) )
			ent:SetMaterial( pl:GetMaterial( ) )
			ent:SetColor( pl:GetColor( ) )
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
					
					for k, v in pairs( ent.CAT_weaponsBuffer ) do
						pl:Give( v, true )
					end
					
					catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
					hook.Run( "PlayerRagdollExited", pl )
				end
			end )
			
			for k, v in pairs( pl:GetBodyGroups( ) ) do
				ent:SetBodygroup( v.id, pl:GetBodygroup( v.id ) )
			end
			
			pl.CAT_ragdoll = ent
			ent.CAT_player = pl
			
			local equippedWeapons = { }
			
			for k, v in pairs( pl:GetWeapons( ) ) do
				equippedWeapons[ #equippedWeapons + 1 ] = v:GetClass( )
			end
			
			ent.CAT_weaponsBuffer = equippedWeapons
			
			pl:StripWeapons( )
			pl:GodDisable( )
			pl:Freeze( true )
			pl:SetNotSolid( true )
			pl:SetNoDraw( true )
			
			pl:SetNetVar( "ragdollIndex", ent:EntIndex( ) )
			pl:SetNetVar( "isRagdolled", true )
			
			local timerID1 = "Catherine.timer.player.RagdollWork2." .. ent:EntIndex( )
			
			timer.Create( timerID1, 1, 0, function( )
				if ( !IsValid( pl ) or !IsValid( ent ) ) then
					timer.Remove( timerID1 )
					return
				end
				
				pl:SetPos( ent:GetPos( ) )
			end )
			
			if ( time ) then
				local time2 = time
				
				pl:SetNetVar( "isForceRagdolled", true )
				
				local timerID2 = "Catherine.timer.player.RagdollWork." .. ent:EntIndex( )
				
				catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_Ragdolled_01" ), time, function( )
					catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
					catherine.player.RagdollWork( pl )
					pl:SetNetVar( "isForceRagdolled", nil )
					timer.Remove( timerID1 )
					timer.Remove( timerID2 )
				end )
				
				timer.Create( timerID2, 1, 0, function( )
					if ( !IsValid( pl ) ) then return end
					
					if ( !pl:Alive( ) ) then
						timer.Remove( timerID1 )
						timer.Remove( timerID2 )
						pl:SetNetVar( "isForceRagdolled", nil )
						return
					end
					
					local ragdoll = pl.CAT_ragdoll
					
					if ( IsValid( ragdoll ) ) then
						time2 = time2 - 1
						
						if ( ragdoll:GetVelocity( ):Length2D( ) >= 4 ) then
							if ( !ragdoll.CAT_paused ) then
								ragdoll.CAT_paused = true
								catherine.util.ProgressBar( pl, false )
							end
							
							return
						elseif ( ragdoll.CAT_paused ) then
							if ( time2 > 0 ) then
								catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_Ragdolled_01" ), time2, function( )
									catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
									catherine.player.RagdollWork( pl )
									pl:SetNetVar( "isForceRagdolled", nil )
									timer.Remove( timerID1 )
									timer.Remove( timerID2 )
								end )
								
								ragdoll.CAT_paused = nil
							else
								ragdoll.CAT_paused = nil
								
								catherine.util.ProgressBar( pl, false )
								catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.01 )
								catherine.player.RagdollWork( pl )
								pl:SetNetVar( "isForceRagdolled", nil )
								timer.Remove( timerID1 )
								timer.Remove( timerID2 )
							end
						end
					else
						timer.Remove( timerID1 )
						timer.Remove( timerID2 )
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
			if ( bool and wep.OnRaised ) then
				wep:OnRaised( )
			elseif ( !bool and wep.OnLowered ) then
				wep:OnLowered( )
			end
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
	META.CATSetUserGroup = META.CATSetUserGroup or META.SetUserGroup
	META.CATLastHitGroup = META.CATLastHitGroup or META.LastHitGroup
	
	function META:LastHitGroup( )
		return pl.CAT_lastHitGroup or self:CATLastHitGroup( )
	end
	
	function META:SetUserGroup( userGroup )
		local oldGroup = self:GetUserGroup( )
		
		self:CATSetUserGroup( userGroup )
		
		hook.Run( "PlayerUserGroupChanged", self, oldGroup, userGroup )
	end
	
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
	
	local ammoTypes = {
		"ar2",
		"alyxgun",
		"pistol",
		"smg1",
		"357",
		"xbowbolt",
		"buckshot",
		"rpg_round",
		"smg1_grenade",
		"sniperround",
		"sniperpenetratedround",
		"grenade",
		"thumper",
		"gravity",
		"battery",
		"gaussenergy",
		"combinecannon",
		"airboatgun",
		"striderminigun",
		"helicoptergun",
		"ar2altfire",
		"slam"
	}
	
	function META:Give( uniqueID, noGiveDefaultAmmo )
		if ( hook.Run( "PlayerShouldGiveWeapon", self, uniqueID ) == false ) then return end
		local ammoStack = nil
		
		self.CAT_isForceGiveWeapon = true
		
		if ( noGiveDefaultAmmo ) then
			ammoStack = { }
			
			for k, v in pairs( ammoTypes ) do
				ammoStack[ #ammoStack + 1 ] = { v, self:GetAmmoCount( v ) }
			end
		end
		
		local wep = self:CATGiveWeapon( uniqueID )
		
		if ( noGiveDefaultAmmo ) then
			for k, v in pairs( ammoStack ) do
				if ( v[ 2 ] != self:GetAmmoCount( v[ 1 ] ) ) then
					self:RemoveAmmo( self:GetAmmoCount( v[ 1 ] ) - v[ 2 ], v[ 1 ] )
				end
			end
		end
		
		self.CAT_isForceGiveWeapon = nil
		
		hook.Run( "PlayerGiveWeapon", self, uniqueID )
		
		return wep
	end
	
	function META:StripWeapon( uniqueID )
		if ( hook.Run( "PlayerShouldStripWeapon", self, uniqueID ) == false ) then return end
		
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
	
	netstream.Hook( "catherine.player.Initialize.IsRetry", function( pl )
		catherine.player.Initialize( pl, true )
	end )
else
	netstream.Hook( "catherine.player.CheckLocalPlayer", function( )
		timer.Remove( "Catherine.timer.player.CheckLocalPlayer" )
		timer.Create( "Catherine.timer.player.CheckLocalPlayer", 0.1, 0, function( )
			if ( IsValid( catherine.pl ) ) then
				netstream.Start( "catherine.player.CheckLocalPlayer.Receive" )
				timer.Remove( "Catherine.timer.player.CheckLocalPlayer" )
			end
		end )
	end )
end

function catherine.player.GetHitGroup( pl, pos )
	local lastDis = nil
	local hitGroup = HITGROUP_GENERIC
	
	for k, v in pairs( catherine.limb.bones ) do
		local bone = pl:LookupBone( k )
		
		if ( bone ) then
			local bonePos = pl:GetBonePosition( bone )
			
			if ( bonePos ) then
				local distance = bonePos:Distance( pos )
				
				if ( !lastDis or distance < lastDis ) then
					lastDis = distance
					hitGroup = v
				end
			end
		end
	end
	
	return hitGroup
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

function META:IsStuck( )
	return util.TraceEntity( {
		start = self:GetPos( ),
		endpos = self:GetPos( ),
		filter = self
	}, self ).StartSolid
end

function player.GetAllByLoaded( )
	local players = { }
	
	for k, v in pairs( player.GetAll( ) ) do
		if ( !v:IsCharacterLoaded( ) ) then continue end
		
		players[ #players + 1 ] = v
	end
	
	return players
end