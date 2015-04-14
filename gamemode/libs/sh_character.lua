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

catherine.character = catherine.character or { networkRegistry = { } }
catherine.character.vars = { }
local META = FindMetaTable( "Player" )

function catherine.character.NewVar( id, varTable )
	if ( !varTable ) then varTable = { } end
	table.Merge( varTable, { id = id } )
	catherine.character.vars[ #catherine.character.vars + 1 ] = varTable
end

function catherine.character.GetVarAll( )
	return catherine.character.vars
end

function catherine.character.FindVarByID( id )
	if ( !id ) then return end
	
	for k, v in pairs( catherine.character.GetVarAll( ) ) do
		if ( v.id == id ) then
			return v
		end
	end
end

function catherine.character.FindVarByField( field )
	if ( !field ) then return end
	
	for k, v in pairs( catherine.character.GetVarAll( ) ) do
		if ( v.field == field ) then
			return v
		end
	end
end

catherine.character.NewVar( "id", {
	field = "_id",
	doNetworking = true,
	static = true
} )

catherine.character.NewVar( "name", {
	field = "_name",
	doNetworking = true,
	default = "Johnson",
	checkValid = function( data )
		if ( data:len( ) >= catherine.configs.characterNameMinLen and data:len( ) < catherine.configs.characterNameMaxLen ) then
			return true
		end
		return false, "The character name must be at least " .. catherine.configs.characterNameMinLen .." characters long and up to " .. catherine.configs.characterNameMaxLen .. " characters!"
	end
} )

catherine.character.NewVar( "desc", {
	field = "_desc",
	doNetworking = true,
	default = "No desc.",
	checkValid = function( data )
		if ( data:len( ) >= catherine.configs.characterDescMinLen and data:len( ) < catherine.configs.characterDescMaxLen ) then
			return true
		end
		return false, "The character description must be at least " .. catherine.configs.characterDescMinLen .." characters long and up to " .. catherine.configs.characterDescMaxLen .. " characters!"
	end
} )

catherine.character.NewVar( "model", {
	field = "_model",
	default = "models/breen.mdl",
	checkValid = function( data )
		if ( data == "" ) then
			return false, "Please select character model!"
		end
		return true
	end
} )

catherine.character.NewVar( "att", {
	field = "_att",
	doNetworking = true,
	default = "[]",
	doConversion = true,
	doLocal = true
} )

catherine.character.NewVar( "schema", {
	field = "_schema",
	static = true,
	default = function( )
		return catherine.schema.GetUniqueID( )
	end
} )

catherine.character.NewVar( "registerTime", {
	field = "_registerTime",
	static = true,
	default = function( )
		return os.time( )
	end
} )

catherine.character.NewVar( "steamID", {
	field = "_steamID",
	static = true,
	default = function( pl )
		return pl:SteamID( )
	end
} )

catherine.character.NewVar( "charVar", {
	field = "_charVar",
	doNetworking = true,
	default = "[]",
	doConversion = true,
	doLocal = true
} )

catherine.character.NewVar( "inventory", {
	field = "_inv",
	doNetworking = true,
	default = "[]",
	doConversion = true,
	doLocal = true
} )

catherine.character.NewVar( "cash", {
	field = "_cash",
	doNetworking = true,
	default = catherine.configs.defaultCash
} )

catherine.character.NewVar( "faction", {
	field = "_faction",
	doNetworking = true,
	default = "citizen"
} )

if ( SERVER ) then
	catherine.character.buffers = catherine.character.buffers or { }
	catherine.character.SaveTick = catherine.character.SaveTick or CurTime( ) + catherine.configs.saveInterval
	
	function catherine.character.New( pl, id )
		if ( catherine.player.IsRagdolled( pl ) ) then
			return false, "Character_Notify_CantSwitchRagdolled"
		end
		
		local character = catherine.character.GetTargetCharacterByID( pl, id )
		
		if ( !character ) then
			return false, "Character_Notify_IsNotValid"
		end
		
		local factionTable = catherine.faction.FindByID( character._faction )
		
		if ( !factionTable ) then
			return false, "Character_Notify_IsNotValidFaction"
		end

		local prevID = pl:GetCharacterID( )
		
		if ( prevID == id ) then
			return false, "Character_Notify_CantSwitchUsing"
		end
		
		hook.Run( "CharacterLoadingStart", pl, prevID, id )

		if ( prevID != nil ) then
			catherine.character.Save( pl )
			catherine.character.DeleteNetworkRegistry( pl )
		end
		
		// Go!
		pl.CAT_loadingChar = true
		
		pl:KillSilent( )
		pl:Spawn( )
		pl:SetTeam( factionTable.index )
		pl:SetModel( character._model )
		pl:SetWalkSpeed( catherine.configs.playerDefaultWalkSpeed )
		pl:SetRunSpeed( catherine.configs.playerDefaultRunSpeed )
		
		hook.Run( "PostWeaponGive", pl )

		catherine.character.CreateNetworkRegistry( pl, id, character )
		catherine.character.SetCharVar( pl, "class", nil )
		
		if ( prevID == nil ) then
			netstream.Start( pl, "catherine.hud.WelcomeIntroStart" )
		end
		
		hook.Run( "PlayerSpawnedInCharacter", pl )

		pl:SetNetVar( "charID", id )
		pl:SetNetVar( "charLoaded", true )

		if ( catherine.character.GetCharVar( pl, "isFirst", true ) == true ) then
			catherine.character.SetCharVar( pl, "isFirst", false )
			hook.Run( "PlayerFirstSpawned", pl, id )
		end
		
		pl.CAT_loadingChar = nil

		return true
		// Fin!
	end

	function catherine.character.Create( pl, data )
		local charVars = { }
		
		for k, v in pairs( catherine.character.GetVarAll( ) ) do
			local var = v.default or nil
			
			if ( type( v.default ) == "function" ) then
				var = v.default( pl )
			end

			if ( data[ v.id ] ) then
				var = data[ v.id ]
				if ( v.checkValid ) then
					local success, reason = v.checkValid( var )
					
					if ( success == false ) then
						netstream.Start( pl, "catherine.character.CreateResult", reason ) // need language;
						return
					end
				end
			end
			
			charVars[ v.field ] = var
		end

		catherine.database.InsertDatas( "catherine_characters", charVars, function( )
			catherine.util.Print( Color( 0, 255, 0 ), "Character created! [" .. pl:SteamName( ) .. "]" )
			netstream.Start( pl, "catherine.character.CreateResult", true )
			catherine.character.SyncCharacterList( pl )
		end )
	end
	
	function catherine.character.Use( pl, id )
		local success, reason = catherine.character.New( pl, id )
		
		if ( success ) then
			netstream.Start( pl, "catherine.character.UseResult", true )
			catherine.util.Print( Color( 0, 255, 0 ), "Character loaded! [" .. pl:SteamName( ) .. "] " .. ( prevID or "None" ) .. " -> " .. id )
		else
			netstream.Start( pl, "catherine.character.UseResult", LANG( pl, reason ) )
		end
	end
	
	function catherine.character.Delete( pl, id )
		if ( pl:GetCharacterID( ) == id ) then
			netstream.Start( pl, "catherine.character.DeleteResult", LANG( pl, "Character_Notify_CantDeleteUsing" ) )
			return
		end
		
		catherine.database.Query( "DELETE FROM `catherine_characters` WHERE _steamID = '" .. pl:SteamID( ) .. "' AND _id = '" .. id .. "'", function( data )
			catherine.character.SyncCharacterList( pl, function( )
				netstream.Start( pl, "catherine.character.DeleteResult", true )
			end )
		end )
	end
	
	function catherine.character.SetVar( pl, key, value, noSync )
		if ( !IsValid( pl ) or !key ) then return end
		local steamID = pl:SteamID( )
		local varTable = catherine.character.FindVarByField( key )
		if ( ( varTable and varTable.static ) or !catherine.character.networkRegistry[ steamID ] ) then return end
		
		catherine.character.networkRegistry[ steamID ][ key ] = value
		
		if ( !noSync ) then
			local target = nil
			if ( globalVar and globalVar.doLocal ) then target = pl end
			
			netstream.Start( target, "catherine.character.SetVar", { steamID, key, value } )
		end
		
		hook.Run( "CharacterVarChanged", pl, key, value )
	end

	function catherine.character.SetCharVar( pl, key, value, noSync )
		if ( !IsValid( pl ) or !key ) then return end
		local steamID = pl:SteamID( )
		if ( !catherine.character.networkRegistry[ steamID ] or !catherine.character.networkRegistry[ steamID ][ "_charVar" ] ) then return end
		
		catherine.character.networkRegistry[ steamID ][ "_charVar" ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( pl, "catherine.character.SetCharVar", { steamID, key, value } )
		end
		
		hook.Run( "CharacterCharVarChanged", pl, key, value )
	end
	
	function META:SetVar( key, value, noSync )
		catherine.character.SetVar( self, key, value, noSync )
	end

	function META:SetCharVar( key, value, noSync )
		catherine.character.SetCharVar( self, key, value, noSync )
	end
	
	function catherine.character.OpenMenu( pl )
		netstream.Start( pl, "catherine.character.OpenMenu" )
	end
	
	function catherine.character.SyncCharacterList( pl, func )
		local steamID = pl:SteamID( )
		
		catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. steamID .. "'", function( data )
			if ( !data ) then
				catherine.character.buffers[ steamID ] = { }
				netstream.Start( pl, "catherine.character.SyncCharacterList", { } )
				
				if ( func ) then
					func( )
				end
				return
			end

			for k, v in pairs( catherine.character.GetVarAll( ) ) do
				for k1, v1 in pairs( data ) do
					if ( !v.doConversion ) then continue end
					
					data[ k1 ][ v.field ] = util.JSONToTable( data[ k1 ][ v.field ] )
				end
			end
			
			catherine.character.buffers[ steamID ] = data
			netstream.Start( pl, "catherine.character.SyncCharacterList", data )
			
			if ( func ) then
				func( )
			end
		end )
	end
	
	function catherine.character.RefreshCharacterBuffer( pl )
		local steamID = pl:SteamID( )
		
		catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. steamID .. "'", function( data )
			if ( !data ) then return end
			catherine.character.buffers[ steamID ] = data
		end )
	end

	function catherine.character.GetTargetCharacterByID( pl, id )
		for k, v in pairs( catherine.character.buffers[ pl:SteamID( ) ] or { } ) do
			for k1, v1 in pairs( v ) do
				if ( k1 == "_id" and v1 == id ) then
					return catherine.character.ConvertDataTable( v )
				end
			end
		end
	end
	
	function catherine.character.ConvertDataTable( data )
		for k, v in pairs( data ) do
			local varTable = catherine.character.FindVarByField( k )
			if ( ( varTable and !varTable.doConversion ) or type( v ) == "table" ) then continue end
			data[ k ] = util.JSONToTable( v )
		end
		
		return data
	end

	function catherine.character.CreateNetworkRegistry( pl, id, data )
		local steamID = pl:SteamID( )
		
		catherine.character.networkRegistry[ steamID ] = { }
		for k, v in pairs( data ) do
			local varTable = catherine.character.FindVarByField( k )
			if ( varTable and !varTable.doNetworking ) then continue end
			catherine.character.networkRegistry[ steamID ][ k ] = v
		end
		
		hook.Run( "CreateNetworkRegistry", pl, catherine.character.networkRegistry[ steamID ] )
		netstream.Start( nil, "catherine.character.CreateNetworkRegistry", { steamID, catherine.character.networkRegistry[ steamID ] } )
	end

	function catherine.character.SyncAllNetworkRegistry( pl )
		netstream.Start( pl, "catherine.character.SyncAllNetworkRegistry", catherine.character.networkRegistry )
	end

	function catherine.character.GetNetworkRegistry( pl )
		return catherine.character.networkRegistry[ pl:SteamID( ) ]
	end

	function catherine.character.DeleteNetworkRegistry( pl )
		local steamID = pl:SteamID( )
		
		catherine.character.networkRegistry[ steamID ] = nil
		netstream.Start( nil, "catherine.character.DeleteNetworkRegistry", steamID )
	end

	function catherine.character.Save( pl )
		hook.Run( "PostCharacterSave", pl )
		
		local networkRegistry = catherine.character.GetNetworkRegistry( pl )
		if ( !networkRegistry ) then return end
		local id = pl:GetCharacterID( )
		
		catherine.database.UpdateDatas( "catherine_characters", "_id = '" .. tostring( id ) .. "' AND _steamID = '" .. pl:SteamID( ) .. "'", networkRegistry, function( )
			catherine.character.RefreshCharacterBuffer( pl )
			catherine.util.Print( Color( 0, 255, 0 ), "Saved " .. pl:Name( ) .. "'s [" .. id .. "] character." )
		end )
	end

	function catherine.character.Think( )
		if ( catherine.character.SaveTick <= CurTime( ) ) then
			for k, v in pairs( player.GetAllByLoaded( ) ) do
				catherine.character.Save( v )
			end
			
			catherine.character.SaveTick = CurTime( ) + catherine.configs.saveInterval
		end
	end

	function catherine.character.DataSave( )
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			catherine.character.Save( v )
		end
	end
	
	function catherine.character.PlayerDisconnected( pl )
		catherine.character.Save( pl )
		catherine.character.DeleteNetworkRegistry( pl )
	end
	
	function catherine.character.CharacterVarChanged( pl, key, value )
		if ( key == "_model" ) then
			pl:SetModel( value )
		elseif ( key == "_name" ) then
			hook.Run( "CharacterNameChanged", pl, value )
		end
	end
	
	hook.Add( "CharacterVarChanged", "catherine.character.CharacterVarChanged", catherine.character.CharacterVarChanged )
	hook.Add( "Think", "catherine.character.Think", catherine.character.Think )
	hook.Add( "PlayerDisconnected", "catherine.character.PlayerDisconnected", catherine.character.PlayerDisconnected )
	hook.Add( "DataSave", "catherine.character.DataSave", catherine.character.DataSave )

	netstream.Hook( "catherine.character.Create", function( pl, data )
		catherine.character.Create( pl, data )
	end )
	
	netstream.Hook( "catherine.character.Use", function( pl, data )
		catherine.character.Use( pl, data )
	end )
	
	netstream.Hook( "catherine.character.Delete", function( pl, data )
		catherine.character.Delete( pl, data )
	end )
else
	catherine.character.localCharacters = catherine.character.localCharacters or { }
	
	netstream.Hook( "catherine.character.CreateResult", function( data )
		if ( data == true ) then
			if ( IsValid( catherine.vgui.character ) and IsValid( catherine.vgui.character.createData.currentStage ) ) then
				catherine.vgui.character.createData.currentStage:AlphaTo( 0, 0.2, 0, function( _, pnl )
					pnl:Remove( )
					pnl = nil
					catherine.vgui.character:BackToMainMenu( )
				end )
			end
		else
			Derma_Message( data, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		end
	end )
	
	netstream.Hook( "catherine.character.UseResult", function( data )
		if ( data == true ) then
			if ( IsValid( catherine.vgui.character ) ) then
				catherine.vgui.character:Close( )
			end
		else
			Derma_Message( data, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		end
	end )
	
	netstream.Hook( "catherine.character.DeleteResult", function( data )
		if ( data == true ) then
			if ( IsValid( catherine.vgui.character ) and IsValid( catherine.vgui.character.CharacterPanel ) ) then
				catherine.vgui.character.CharacterPanel:Remove( )
				catherine.vgui.character:UseCharacterPanel( )
			end
		else
			Derma_Message( data, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		end
	end )
	
	netstream.Hook( "catherine.character.OpenMenu", function( data )
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:Close( )
		end
		catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
	end )
	
	netstream.Hook( "catherine.character.CreateNetworkRegistry", function( data )
		local steamID = data[ 1 ]
		local registry = data[ 2 ]
		
		catherine.character.networkRegistry[ steamID ] = registry
		hook.Run( "CreateNetworkRegistry", catherine.util.FindPlayerByStuff( "SteamID", steamID ), registry )
	end )

	netstream.Hook( "catherine.character.DeleteNetworkRegistry", function( data )
		catherine.character.networkRegistry[ data ] = nil
	end )

	netstream.Hook( "catherine.character.SyncAllNetworkRegistry", function( data )
		catherine.character.networkRegistry = data
	end )
	
	netstream.Hook( "catherine.character.SetVar", function( data )
		local steamID = data[ 1 ]
		local key = data[ 2 ]
		local value = data[ 3 ]
		
		if ( !catherine.character.networkRegistry[ steamID ] ) then return end
		catherine.character.networkRegistry[ steamID ][ key ] = value
		
		hook.Run( "CharacterVarChanged", catherine.util.FindPlayerByStuff( "SteamID", steamID ), key, value )
	end )

	netstream.Hook( "catherine.character.SetCharVar", function( data )
		local steamID = data[ 1 ]
		local key = data[ 2 ]
		local value = data[ 3 ]
		
		if ( !catherine.character.networkRegistry[ steamID ] or !catherine.character.networkRegistry[ steamID ][ "_charVar" ] ) then return end
		catherine.character.networkRegistry[ steamID ][ "_charVar" ][ key ] = value
		
		hook.Run( "CharacterCharVarChanged", catherine.util.FindPlayerByStuff( "SteamID", steamID ), key, value )
	end )

	netstream.Hook( "catherine.character.SyncCharacterList", function( data )
		catherine.character.localCharacters = data
	end )
end

function catherine.character.GetVar( pl, key, default )
	local steamID = pl:SteamID( )
	if ( !catherine.character.networkRegistry[ steamID ] ) then return default end
	return catherine.character.networkRegistry[ steamID ][ key ] or default // 버그발생?
end

function catherine.character.GetCharVar( pl, key, default )
	local steamID = pl:SteamID( )
	if ( !catherine.character.networkRegistry[ steamID ] or !catherine.character.networkRegistry[ steamID ][ "_charVar" ] ) then return default end
	return catherine.character.networkRegistry[ steamID ][ "_charVar" ][ key ] or default // 버그발생?
end

function META:GetVar( key, default )
	return catherine.character.GetVar( self, key, default )
end

function META:GetCharVar( key, default )
	return catherine.character.GetVar( self, key, default )
end

function META:GetCharacterID( )
	return self:GetNetVar( "charID", nil )
end

function META:IsCharacterLoaded( )
	return self:GetNetVar( "charLoaded", false )
end

do
	META.RealName = META.RealName or META.Name
	META.SteamName = META.RealName

	function META:Name( )
		return catherine.character.GetVar( self, "_name", self:SteamName( ) )
	end
	
	function META:Desc( )
		return catherine.character.GetVar( self, "_desc", "....." )
	end
	
	function META:Faction( )
		return catherine.character.GetVar( self, "_faction", "citizen" )
	end
	
	function META:FactionName( )
		return team.GetName( self:Team( ) )
	end
	
	META.Nick = META.Name
	META.GetName = META.Name
end