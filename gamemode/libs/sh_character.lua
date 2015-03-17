catherine.character = catherine.character or { }
catherine.character.globalVars = { }
catherine.character.networkingVars = catherine.character.networkingVars or { }

function catherine.character.RegisterGlobalVar( id, tab )
	table.Merge( tab, { id = id } )
	catherine.character.globalVars[ #catherine.character.globalVars + 1 ] = tab
end

function catherine.character.GetGlobalVarAll( )
	return catherine.character.globalVars
end

function catherine.character.FindGlobalVarByID( id )
	if ( !id ) then return nil end
	
	for k, v in pairs( catherine.character.GetGlobalVarAll( ) ) do
		if ( v.id == id ) then
			return v
		end
	end
	
	return nil
end

function catherine.character.FindGlobalVarByField( field )
	if ( !field ) then return nil end
	
	for k, v in pairs( catherine.character.GetGlobalVarAll( ) ) do
		if ( v.field == field ) then
			return v
		end
	end
	
	return nil
end

catherine.character.RegisterGlobalVar( "id", {
	field = "_id",
	doNetwork = true,
	static = true
} )

catherine.character.RegisterGlobalVar( "name", {
	field = "_name",
	doNetwork = true,
	default = "Johnson",
	checkValid = function( data )
		if ( data:len( ) >= catherine.configs.characterNameMinLen and data:len( ) < catherine.configs.characterNameMaxLen ) then
			return true
		end
		return false, "The character name must be at least " .. catherine.configs.characterNameMinLen .." characters long and up to " .. catherine.configs.characterNameMaxLen .. " characters!"
	end
} )

catherine.character.RegisterGlobalVar( "desc", {
	field = "_desc",
	doNetwork = true,
	default = "No desc.",
	checkValid = function( data )
		if ( data:len( ) >= catherine.configs.characterDescMinLen and data:len( ) < catherine.configs.characterDescMaxLen ) then
			return true
		end
		return false, "The character description must be at least " .. catherine.configs.characterDescMinLen .." characters long and up to " .. catherine.configs.characterDescMaxLen .. " characters!"
	end
} )

catherine.character.RegisterGlobalVar( "model", {
	field = "_model",
	default = "models/breen.mdl",
	checkValid = function( data )
		if ( data == "" ) then
			return false, "Please select character model!"
		end
		return true
	end
} )

catherine.character.RegisterGlobalVar( "att", {
	field = "_att",
	doNetwork = true,
	default = "[]",
	checkValid = function( data )
		// to do;
	end,
	needTransfer = true
} )

catherine.character.RegisterGlobalVar( "schema", {
	field = "_schema",
	static = true,
	default = function( )
		return catherine.schema.GetUniqueID( )
	end
} )

catherine.character.RegisterGlobalVar( "registerTime", {
	field = "_registerTime",
	static = true,
	default = function( )
		return os.time( )
	end
} )

catherine.character.RegisterGlobalVar( "steamID", {
	field = "_steamID",
	static = true,
	default = function( pl )
		return pl:SteamID( )
	end
} )

catherine.character.RegisterGlobalVar( "charVar", {
	field = "_charVar",
	doNetwork = true,
	default = "[]",
	needTransfer = true
} )

catherine.character.RegisterGlobalVar( "inventory", {
	field = "_inv",
	doNetwork = true,
	default = "[]",
	needTransfer = true
} )

catherine.character.RegisterGlobalVar( "gender", {
	field = "_gender",
	doNetwork = true,
	default = "",
	checkValid = function( data )
		if ( data == "" ) then
			return false, "Please select character gender!"
		end
		return true
	end
} )

catherine.character.RegisterGlobalVar( "cash", {
	field = "_cash",
	doNetwork = true,
	default = catherine.configs.defaultCash
} )

catherine.character.RegisterGlobalVar( "faction", {
	field = "_faction",
	doNetwork = true,
	default = "citizen"
} )

if ( SERVER ) then
	catherine.character.Buffers = catherine.character.Buffers or { }
	catherine.character.SaveCurTime = catherine.character.SaveCurTime or CurTime( ) + catherine.configs.saveInterval

	function catherine.character.Create( pl, data )
		if ( !IsValid( pl ) or !data ) then return end
		
		local characterVars = { }
		for k, v in pairs( catherine.character.GetGlobalVarAll( ) ) do
			local var = nil
			
			if ( type( v.default ) == "function" ) then
				var = v.default( pl )
			else
				var = v.default
			end

			if ( data[ v.id ] ) then
				var = data[ v.id ]
				if ( v.checkValid ) then
					local success, reason = v.checkValid( var )
					
					if ( success == false ) then
						netstream.Start( pl, "catherine.character.CreateResult", { success, reason } )
						return
					end
				end
			end
			
			characterVars[ v.field ] = var
		end

		catherine.database.InsertDatas( "catherine_characters", characterVars, function( )
			catherine.util.Print( Color( 0, 255, 0 ), "Character created! [" .. pl:SteamName( ) .. "]" )
			netstream.Start( pl, "catherine.character.CreateResult", { true } )
			catherine.character.SendCharacterLists( pl )
		end )
	end
	
	function catherine.character.SyncCharacterBuffer( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
			if ( !data ) then return end
			catherine.character.Buffers[ pl:SteamID( ) ] = data
		end )
	end
	
	function catherine.character.Delete( pl, id )
		if ( !IsValid( pl ) ) then return end
		if ( pl:GetCharacterID( ) == id ) then
			netstream.Start( pl, "catherine.character.DeleteResult", { false, "You can't delete using character!" } )
			return
		end
		catherine.database.Query( "DELETE FROM `catherine_characters` WHERE _steamID = '" .. pl:SteamID( ) .. "' AND _id = '" .. id .. "'", function( data )
			catherine.character.SendCharacterLists( pl, function( )
				netstream.Start( pl, "catherine.character.DeleteResult", { true } )
			end )
		end )
	end

	function catherine.character.Use( pl, id )
		if ( !IsValid( pl ) or !id ) then return end
		if ( !catherine.character.Buffers[ pl:SteamID( ) ] ) then return end
		local prevID = pl:GetCharacterID( )
		
		if ( prevID == id ) then
			netstream.Start( pl, "catherine.character.UseResult", { false, "You can't use same character!" } )
			return
		end

		if ( prevID != nil ) then
			catherine.character.SavePlayerCharacter( pl )
			catherine.character.DisconnectNetworking( pl )
		end

		local characterData = catherine.character.GetTargetCharacterByID( pl, id )
		if ( !characterData ) then
			netstream.Start( pl, "catherine.character.UseResult", { false, "Character is not valid!" } )
			return
		end

		local factionTab = catherine.faction.FindByID( characterData._faction )
		if ( !factionTab ) then
			netstream.Start( pl, "catherine.character.UseResult", { false, "Faction is not valid!" } )
			return
		end
		
		pl:KillSilent( )
		pl:Spawn( )
		pl:SetTeam( factionTab.index )
		pl:SetModel( characterData._model )
		pl:SetWalkSpeed( catherine.configs.playerDefaultWalkSpeed )
		pl:SetRunSpeed( catherine.configs.playerDefaultRunSpeed )
		
		hook.Run( "PostWeaponGive", pl )

		catherine.character.InitializeNetworking( pl, id, characterData )
		
		if ( prevID == nil ) then
			netstream.Start( pl, "catherine.hud.CinematicIntro_Init" )
		end

		pl:SetNetVar( "charID", id )
		pl:SetNetVar( "charLoaded", true )
		
		hook.Run( "PlayerSpawnedInCharacter", pl, id )
		
		netstream.Start( pl, "catherine.character.UseResult", { true } )
		
		catherine.util.Print( Color( 0, 255, 0 ), "Character loaded! [ " .. pl:SteamName( ) .. " ]" .. ( prevID or "None" ) .. " -> " .. id )
	end

	function catherine.character.GetTargetCharacterByID( pl, id )
		if ( !IsValid( pl ) or !id ) then return nil end
		for k, v in pairs( catherine.character.Buffers[ pl:SteamID( ) ] ) do
			for k1, v1 in pairs( v ) do
				if ( k1 == "_id" and v1 == id ) then
					return catherine.character.TransferJSON( v )
				end
			end
		end
		
		return nil
	end
	
	function catherine.character.TransferJSON( data )
		if ( !data ) then return nil end
		for k, v in pairs( data ) do
			local globalVarTab = catherine.character.FindGlobalVarByField( k )
			if ( globalVarTab and !globalVarTab.needTransfer ) then continue end
			if ( type( v ) == "table" ) then continue end
			data[ k ] = util.JSONToTable( v )
		end
		
		return data
	end
	
	function catherine.character.InitializeNetworking( pl, id, data )
		if ( !IsValid( pl ) or !id or !data ) then return end
		catherine.character.networkingVars[ pl:SteamID( ) ] = { }
		
		for k, v in pairs( data ) do
			local globalVarTab = catherine.character.FindGlobalVarByField( k )
			if ( globalVarTab and !globalVarTab.doNetwork ) then continue end
			catherine.character.networkingVars[ pl:SteamID( ) ][ k ] = v
		end
		
		netstream.Start( nil, "catherine.character.InitializeNetworking", { pl:SteamID( ), catherine.character.networkingVars[ pl:SteamID( ) ] } )
	end

	function catherine.character.SendCurrentNetworking( pl, func )
		if ( !IsValid( pl ) ) then return end
		netstream.Start( pl, "catherine.character.SendCurrentNetworking", catherine.character.networkingVars )
		if ( func ) then
			func( )
		end
	end
	
	function catherine.character.GetPlayerNetworking( pl )
		if ( !IsValid( pl ) ) then return end
		return catherine.character.networkingVars[ pl:SteamID( ) ]
	end

	function catherine.character.DisconnectNetworking( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.character.networkingVars[ pl:SteamID( ) ] = nil
		netstream.Start( nil, "catherine.character.DisconnectNetworking", pl:SteamID( ) )
	end

	function catherine.character.SavePlayerCharacter( pl )
		if ( !IsValid( pl ) ) then return end
		hook.Run( "PostCharacterSave", pl )
		local id = pl:GetCharacterID( )
		local character = catherine.character.GetPlayerNetworking( pl )
		if ( !character ) then return end
		catherine.database.UpdateDatas( "catherine_characters", "_id = '" .. tostring( id ) .. "' AND _steamID = '" .. pl:SteamID( ) .. "'", character, function( data )
			catherine.character.SyncCharacterBuffer( pl )
			catherine.util.Print( Color( 0, 255, 0 ), "Saved " .. pl:Name( ) .. "'s [" .. id .. "] character." )
		end )
	end
	
	function catherine.character.OpenPanel( pl )
		if ( !IsValid( pl ) ) then return end
		netstream.Start( pl, "catherine.character.OpenPanel" )
	end
	
	function catherine.character.SendCharacterLists( pl, func )
		if ( !IsValid( pl ) ) then return end
		catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
			if ( !data ) then
				catherine.character.Buffers[ pl:SteamID( ) ] = { }
				netstream.Start( pl, "catherine.character.Lists", { } )
				if ( func ) then
					func( )
				end
				return
			end
			
			for k, v in pairs( catherine.character.GetGlobalVarAll( ) ) do
				for k1, v1 in pairs( data ) do
					if ( !v.needTransfer ) then continue end
					data[ k1 ][ v.field ] = util.JSONToTable( data[ k1 ][ v.field ] )
				end
			end
			
			catherine.character.Buffers[ pl:SteamID( ) ] = data
			netstream.Start( pl, "catherine.character.Lists", data )
			if ( func ) then
				func( )
			end
		end )
	end
	
	function catherine.character.Think( )
		if ( catherine.character.SaveCurTime <= CurTime( ) ) then
			for k, v in pairs( player.GetAllByLoaded( ) ) do
				catherine.character.SavePlayerCharacter( v )
			end
			catherine.character.SaveCurTime = CurTime( ) + catherine.configs.saveInterval
		end
	end

	function catherine.character.DataSave( )
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			catherine.character.SavePlayerCharacter( v )
		end
	end
	
	function catherine.character.PlayerDisconnected( pl )
		catherine.character.SavePlayerCharacter( pl )
		catherine.character.DisconnectNetworking( pl )
	end
	
	hook.Add( "Think", "catherine.character.Think", catherine.character.Think )
	hook.Add( "PlayerDisconnected", "catherine.character.PlayerDisconnected", catherine.character.PlayerDisconnected )
	hook.Add( "DataSave", "catherine.character.DataSave", catherine.character.DataSave )

	// static 예외 처리 추가바람;;
	function catherine.character.SetGlobalVar( pl, key, value, noSync )
		if ( !IsValid( pl ) and !key ) then return default end
		if ( !catherine.character.networkingVars[ pl:SteamID( ) ] or catherine.character.networkingVars[ pl:SteamID( ) ][ key ] == nil ) then return end
		catherine.character.networkingVars[ pl:SteamID( ) ][ key ] = value
		if ( !noSync ) then
			netstream.Start( nil, "catherine.character.SetNetworkingVar", { pl:SteamID( ), key, value } )
		end
	end

	function catherine.character.SetCharacterVar( pl, key, value, noSync )
		if ( !IsValid( pl ) and !key ) then return default end
		if ( !catherine.character.networkingVars[ pl:SteamID( ) ] or !catherine.character.networkingVars[ pl:SteamID( ) ][ "_charVar" ] ) then return end
		catherine.character.networkingVars[ pl:SteamID( ) ][ "_charVar" ][ key ] = value
		if ( !noSync ) then
			netstream.Start( nil, "catherine.character.SetNetworkingCharVar", { pl:SteamID( ), key, value } )
		end
	end

	netstream.Hook( "catherine.character.Create", function( caller, data )
		catherine.character.Create( caller, data )
	end )
	
	netstream.Hook( "catherine.character.Use", function( caller, data )
		catherine.character.Use( caller, data )
	end )
	
	netstream.Hook( "catherine.character.Delete", function( caller, data )
		catherine.character.Delete( caller, data )
	end )
else
	catherine.character.localCharacters = catherine.character.localCharacters or { }
	
	netstream.Hook( "catherine.character.CreateResult", function( data )
		if ( data[ 1 ] == true ) then
			if ( IsValid( catherine.vgui.character ) and IsValid( catherine.vgui.character.createData.currentStage ) ) then
				catherine.vgui.character.createData.currentStage:AlphaTo( 0, 0.2, 0, function( _, pnl )
					pnl:Remove( )
					pnl = nil
					catherine.vgui.character:BackToMainMenu( )
				end )
			end
		else
			Derma_Message( data[ 2 ], "Character Create Error", "OK" )
		end
	end )
	
	netstream.Hook( "catherine.character.OpenPanel", function( data )
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:Close( )
		end
		catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
	end )
	
	netstream.Hook( "catherine.character.InitializeNetworking", function( data )
		catherine.character.networkingVars[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.character.DisconnectNetworking", function( data )
		catherine.character.networkingVars[ data ] = nil
	end )

	netstream.Hook( "catherine.character.SendCurrentNetworking", function( data )
		catherine.character.networkingVars = data
	end )
	
	netstream.Hook( "catherine.character.SetNetworkingVar", function( data )
		catherine.character.networkingVars[ data[ 1 ] ][ data[ 2 ] ] = data[ 3 ]
		
		if ( IsValid( catherine.vgui.inventory ) ) then
			catherine.vgui.inventory:InitializeInv( )
		end
	end )
	
	netstream.Hook( "catherine.character.SetNetworkingCharVar", function( data )
		catherine.character.networkingVars[ data[ 1 ] ][ "_charVar" ][ data[ 2 ] ] = data[ 3 ]
	end )

	netstream.Hook( "catherine.character.UseResult", function( data )
		if ( data[ 1 ] == true ) then
			if ( IsValid( catherine.vgui.character ) ) then
				catherine.vgui.character:Close( )
			end
		else
			Derma_Message( data[ 2 ], "Error", "OK" )
		end
	end )
	
	netstream.Hook( "catherine.character.DeleteResult", function( data )
		if ( data[ 1 ] == true ) then
			if ( IsValid( catherine.vgui.character ) and IsValid( catherine.vgui.character.CharacterPanel ) ) then
				catherine.vgui.character.CharacterPanel:Remove( )
				catherine.vgui.character:UseCharacterPanel( )
			end
		else
			Derma_Message( data[ 2 ], "Error", "OK" )
		end
	end )
	
	netstream.Hook( "catherine.character.Lists", function( data )
		catherine.character.localCharacters = data
	end )
end

function catherine.character.GetGlobalVar( pl, key, default )
	if ( !IsValid( pl ) and !key ) then return default end
	if ( !catherine.character.networkingVars[ pl:SteamID( ) ] or catherine.character.networkingVars[ pl:SteamID( ) ][ key ] == nil ) then return default end
	return catherine.character.networkingVars[ pl:SteamID( ) ][ key ] or default
end

function catherine.character.GetCharacterVar( pl, key, default )
	if ( !IsValid( pl ) and !key ) then return default end
	if ( !catherine.character.networkingVars[ pl:SteamID( ) ] or !catherine.character.networkingVars[ pl:SteamID( ) ][ "_charVar" ] or catherine.character.networkingVars[ pl:SteamID( ) ][ "_charVar" ][ key ] == nil ) then return default end
	return catherine.character.networkingVars[ pl:SteamID( ) ][ "_charVar" ][ key ] or default
end

local META = FindMetaTable( "Player" )

function META:GetCharacterID( )
	return self:GetNetVar( "charID", nil )
end

function META:IsCharacterLoaded( )
	return self:GetNetVar( "charLoaded", false )
end

function META:GetCharacterGlobalVar( key, default )
	return catherine.character.GetGlobalVar( self, key, default )
end

function META:GetCharacterVar( key, default )
	return catherine.character.GetCharacterVar( self, key, default )
end

do
	META.RealName = META.RealName or META.Name
	META.SteamName = META.RealName

	function META:Name( )
		return catherine.character.GetGlobalVar( self, "_name", self:SteamName( ) )
	end
	
	function META:Desc( )
		return catherine.character.GetGlobalVar( self, "_desc", "....." )
	end
	
	function META:Faction( )
		return catherine.character.GetGlobalVar( self, "_faction", "citizen" )
	end
	
	function META:FactionName( )
		return team.GetName( self:Team( ) )
	end
	
	META.Nick = META.Name
	META.GetName = META.Name
end