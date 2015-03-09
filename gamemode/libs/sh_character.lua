catherine.character = catherine.character or { }
catherine.character.globalVars = { }

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

--[[

CREATE TABLE IF NOT EXISTS `catherine_characters` (
	`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`_name` varchar(70) NOT NULL,
	`_desc` tinytext NOT NULL,
	`_model` varchar(160) NOT NULL,
	`_att` varchar(180) DEFAULT NULL,
	`_schema` varchar(24) NOT NULL,
	`_registerTime` int(11) unsigned NOT NULL,
	`_steamID` varchar(20) NOT NULL,
	`_charData` text,
	`_inv` text,
	`_gender` varchar(50),
	`_cash` int(11) unsigned DEFAULT NULL,
	`_faction` varchar(50) NOT NULL,
	PRIMARY KEY (`_id`)
);

--]]

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
		return false, "can't make! - name"
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
		return false, "can't make! - desc"
	end
} )

catherine.character.RegisterGlobalVar( "model", {
	field = "_model",
	//doNetwork = true, -- 이거 꼭 필요함..?, 나도 몰려.... ^-^;
	default = "models/breen.mdl",
	checkValid = function( data )
		if ( file.Exists( data, "GAME" ) ) then
			return true
		end
		
		return false, "can't make! - model"
	end
} )

catherine.character.RegisterGlobalVar( "att", {
	field = "_att",
	doNetwork = true,
	default = "[]", // 흠..;
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
	default = function( ) // 이게 꼭 함수로 작성되어야 하나..;
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
	default = "male" // 나중에 추가할것 --;
} )

catherine.character.RegisterGlobalVar( "cash", {
	field = "_cash",
	doNetwork = true,
	default = catherine.configs.defaultCash
} )

catherine.character.RegisterGlobalVar( "faction", {
	field = "_faction",
	default = "citizen"
} )

//PrintTable(catherine.character.globalVars)

if ( SERVER ) then
	catherine.character.Buffers = catherine.character.Buffers or { }
	catherine.character.Loaded = catherine.character.Loaded or { }
	catherine.character.networkingVars = catherine.character.networkingVars or { }
	
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
						print(success,reason)
						//netstream.Start( pl, "catherine.character.CreateResult", { success, reason } )
						return
					end
				end
			end
			
			characterVars[ v.field ] = var
		end
		
		catherine.database.InsertDatas( "catherine_characters", characterVars, function( )
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

	function catherine.character.Use( pl, id )
		if ( !IsValid( pl ) or !id ) then return end
		if ( !catherine.character.Buffers[ pl:SteamID( ) ] ) then return end
		
		if ( pl:GetCharacterID( ) != nil ) then
			catherine.character.SavePlayerCharacter( pl )
			//catherine.character.DisconnectNetworking( pl )
			catherine.character.SetLoadedCharacterByID( pl, pl:GetCharacterID( ), nil )
			
			// 이전 캐릭터 데이터 클리어..
			
		end
		
		if ( pl:GetCharacterID( ) == id ) then
			//netstream.Start( pl, "catherine.character.UseResult", { false, "You can't use same character!" } )
			//return
		end
		
		local function useCharacter( data )
			local factionTab = catherine.faction.FindByID( data._faction )
			if ( !factionTab ) then
				print("Faction error")
				return
			end
			// 초기화;
			pl:KillSilent( )
			pl:Spawn( )
			pl:SetTeam( factionTab.index )
			pl:SetModel( data._model )
			pl:SetWalkSpeed( catherine.configs.playerDefaultWalkSpeed )
			pl:SetRunSpeed( catherine.configs.playerDefaultRunSpeed )
			pl:Give( "catherine_fist" )
			pl:Give( "catherine_key" )
			
			catherine.character.InitializeNetworking( pl, id, data )
			pl:SetNetworkValue( "characterID", id )
			pl:SetNetworkValue( "characterLoaded", true )
			
			print("Loaded - " .. id )
		end
		
		local characterData = nil
		
		for k, v in pairs( catherine.character.Buffers[ pl:SteamID( ) ] ) do
			for k1, v1 in pairs( v ) do
				if ( k1 == "_id" and v1 == id ) then
					characterData = catherine.character.TransferJSON( v )
				end
			end
		end

		if ( !characterData ) then return end
		
		//PrintTable(characterData)

		catherine.character.SetLoadedCharacterByID( pl, id, characterData )
		useCharacter( characterData )

		--[[
		catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
			if ( !data ) then return end
			local foundCharacter = nil

			for k, v in pairs( data ) do
				for k1, v1 in pairs( v ) do
					if ( k1 == "_id" and v1 == id ) then
						foundCharacter = v
						break
					end
				end
			end
			
			if ( !foundCharacter ) then
				netstream.Start( pl, "catherine.character.UseResult", { false, "Can't find character!" } )
				return
			end
			
			for k1, v1 in pairs( foundCharacter ) do
				local globalVarTab =  catherine.character.FindGlobalVarByField( k1 )
				if ( globalVarTab and !globalVarTab.needTransfer ) then continue end
				foundCharacter[ k1 ] = util.JSONToTable( v1 )
			end
			
			//PrintTable(foundCharacter)

			catherine.character.SetLoadedCharacterByID( pl, id, foundCharacter )
			useCharacter( )
		end )--]]
	end
	
	function catherine.character.SetLoadedCharacterByID( pl, id, data )
		if ( !IsValid( pl ) or !id ) then return end
		catherine.character.Loaded[ tostring( id ) ] = data
	end
	
	function catherine.character.TransferJSON( data )
		if ( !data ) then return nil end
		for k, v in pairs( data ) do
			local globalVarTab =  catherine.character.FindGlobalVarByField( k )
			if ( globalVarTab and !globalVarTab.needTransfer ) then continue end
			data[ k ] = util.JSONToTable( v )
		end
		
		return data
	end
	
	function catherine.character.InitializeNetworking( pl, id, data )
		if ( !IsValid( pl ) or !id or !data ) then return end
		catherine.character.networkingVars[ pl:SteamID( ) ] = { }
		
		for k, v in pairs( data ) do
			local globalVarTab =  catherine.character.FindGlobalVarByField( k )
			if ( globalVarTab and !globalVarTab.doNetwork ) then continue end
			catherine.character.networkingVars[ pl:SteamID( ) ][ k ] = v
		end
		
		netstream.Start( nil, "catherine.character.InitializeNetworking", { pl:SteamID( ), catherine.character.networkingVars[ pl:SteamID( ) ] } )
	end
	
	// 이게 꼭 필요한가여... 아닌거가튼데.. --;
	function catherine.character.DisconnectNetworking( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.character.networkingVars[ pl:SteamID( ) ] = nil
	end
	
	function catherine.character.GetLoadedCharacterByID( pl, id )
		if ( !IsValid( pl ) or !id ) then return end
		return catherine.character.Loaded[ tostring( id ) ]
	end

	function catherine.character.SavePlayerCharacter( pl )
		if ( !IsValid( pl ) ) then return end
		local id = pl:GetCharacterID( )
		local character = table.Copy( catherine.character.GetLoadedCharacterByID( pl, id ) )
		if ( !character or !id ) then return end
		
		local characterVars = { }
		for k, v in pairs( catherine.character.GetGlobalVarAll( ) ) do
			for k1, v1 in pairs( character ) do
				characterVars[ k1 ] = v.needTransfer and util.TableToJSON( v1 ) or v1
			end
		end

		catherine.database.UpdateDatas( "catherine_characters", "_id = '" .. tostring( id ) .. "' AND _steamID = '" .. pl:SteamID( ) .. "'", characterVars, function( data )
			catherine.character.SyncCharacterBuffer( pl )
			catherine.util.Print( Color( 0, 255, 0 ), "Saved " .. pl:Name( ) .. "'s [" .. id .. "] character." )
		end )
	end
	
	function catherine.character.SendCharacterLists( pl )
		if ( !IsValid( pl ) ) then return end
		catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. pl:SteamID( ) .. "'", function( data )
			if ( !data ) then return end
			
			for k, v in pairs( catherine.character.GetGlobalVarAll( ) ) do
				for k1, v1 in pairs( data ) do
					if ( !v.needTransfer ) then continue end
					data[ k1 ][ v.field ] = util.JSONToTable( data[ k1 ][ v.field ] )
				end
			end
			
			catherine.character.Buffers[ pl:SteamID( ) ] = data
			
			netstream.Start( pl, "catherine.character.Lists", data )
		end )
	end
	
	function catherine.character.MergeNetworkingVarsByLoaded( pl )
		if ( !IsValid( pl ) ) then return end
		table.Merge( catherine.character.Loaded[ tostring( pl:GetCharacterID( ) ) ], catherine.character.networkingVars[ pl:SteamID( ) ] )
	end
	//catherine.character.Loaded={}
	//PrintTable(catherine.character.Loaded)
	//catherine.character.SavePlayerCharacter( player.GetByID( 1 ) )
	//catherine.character.SavePlayerCharacter(  player.GetByID( 1 ) )
	//catherine.character.SendCharacterLists( player.GetByID( 1 ) )
	//catherine.character.Use( player.GetByID( 1 ), 1 )
	//catherine.character.Create( player.GetByID( 1 ), { name = "Left 7 Dead Character", desc = "zzzzzzzzzzzzzzzzzzzzzzzz" } )

	
	// 나중에 static 예외처리 추가바람... --;
	function catherine.character.SetGlobalVar( pl, key, value, noSync )
		if ( !IsValid( pl ) and !key ) then return default end
		if ( !catherine.character.networkingVars[ pl:SteamID( ) ] or catherine.character.networkingVars[ pl:SteamID( ) ][ key ] == nil ) then return end
		catherine.character.networkingVars[ pl:SteamID( ) ][ key ] = value
		if ( !noSync ) then
			netstream.Start( nil, "catherine.character.SetNetworkingVar", { pl:SteamID( ), key, value } )
		end
		catherine.character.MergeNetworkingVarsByLoaded( pl )
	end

	function catherine.character.SetCharacterVar( pl, key, value, noSync )
		if ( !IsValid( pl ) and !key ) then return default end
		if ( !catherine.character.networkingVars[ pl:SteamID( ) ] or !catherine.character.networkingVars[ pl:SteamID( ) ][ "_charVar" ] ) then return end
		catherine.character.networkingVars[ pl:SteamID( ) ][ "_charVar" ][ key ] = value
		if ( !noSync ) then
			netstream.Start( nil, "catherine.character.SetNetworkingCharVar", { pl:SteamID( ), key, value } )
		end
		catherine.character.MergeNetworkingVarsByLoaded( pl )
	end
	
	//catherine.character.SetGlobalVar( player.GetByID( 1 ), "_name", "L7D!" )
	
	
	//catherine.character.MergeNetworkingVarsByLoaded( player.GetByID( 1 ) )
else
	catherine.character.localCharacters = catherine.character.localCharacters or { }
	catherine.character.networkingVars = catherine.character.networkingVars or { }
	
	
	
	netstream.Hook( "catherine.character.CreateResult", function( data )
	
		if ( data[ 1 ] == true ) then
			if ( IsValid( catherine.vgui.character ) ) then
				print("Fin!")
			end
		else
			Derma_Message( data[ 2 ], "Character Create Error", "OK" )
		end
	end )
	
	netstream.Hook( "catherine.character.InitializeNetworking", function( data )
		catherine.character.networkingVars[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.character.SetNetworkingVar", function( data )
		catherine.character.networkingVars[ data[ 1 ] ][ data[ 2 ] ] = data[ 3 ]
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
			Derma_Message( data[ 2 ], "Character Use Error", "OK" )
		end
	end )
	
	netstream.Hook( "catherine.character.Lists", function( data )
		catherine.character.localCharacters = data
	end )
	
	//PrintTable(catherine.character.networkingVars)
end

//PrintTable(catherine.character.networkingVars)

function catherine.character.GetGlobalVar( pl, key, default )
	if ( !IsValid( pl ) and !key ) then return default end
	if ( !catherine.character.networkingVars[ pl:SteamID( ) ] or catherine.character.networkingVars[ pl:SteamID( ) ][ key ] == nil ) then return default end
	return catherine.character.networkingVars[ pl:SteamID( ) ][ key ] or default
end

/*
do
	local playerMeta = FindMetaTable( "Player" )
	playerMeta.RealName = playerMeta.RealName or playerMeta.Name
	playerMeta.SteamName = playerMeta.RealName

	function playerMeta:Name( )
		if ( self:IsCharacterLoaded( ) ) then
			return self:GetCharacterGlobalData( "_name", "Jason" )
		end

		return self:SteamName( )
	end
	
	function playerMeta:Desc( )
		if ( self:IsCharacterLoaded( ) ) then
			return self:GetCharacterGlobalData( "_desc", "Error" )
		end

		return "Error Desc"
	end
	
	function playerMeta:ID( )
		if ( self:IsCharacterLoaded( ) ) then
			return self:GetCharacterGlobalData( "_id", 0 )
		end

		return "Error ID"
	end

	playerMeta.Nick = playerMeta.Name
	playerMeta.GetName = playerMeta.Name
end

if ( SERVER ) then
	catherine.character.buffers = catherine.character.buffers or { }
	catherine.character.globals = { }
	catherine.character.SaveCurTime = catherine.character.SaveCurTime or CurTime( ) + catherine.configs.saveInterval
	
	
	
	function catherine.character.GetGlobalListsAll( )
		return catherine.character.globals
	end
	
	function catherine.character.RegisterGlobal( tab )
		catherine.character.globals[ tab.id ] = tab
	end

	function catherine.character.GetGlobalByID( id )
		if ( !id ) then return nil end
		return catherine.character.globals[ id ]
	end
	
	function catherine.character.GetGlobalByField( field )
		if ( !field ) then return nil end
		for k, v in pairs( catherine.character.globals ) do
			for k1, v1 in pairs( catherine.character.globals[ k ] ) do
				if ( v.field == field ) then
					return v
				end
			end
		end
		
		return nil
	end

	catherine.character.RegisterGlobal( {
		id = "id",
		field = "_id",
		static = true,
		isNetwork = true
	} )
	
	catherine.character.RegisterGlobal( {
		id = "name",
		field = "_name",
		isNetwork = true,
		default = "Jason",
		replaceFunc = function( data )
			if ( data.name ) then return data.name end
		end
	} )
	
	catherine.character.RegisterGlobal( {
		id = "desc",
		field = "_desc",
		isNetwork = true,
		default = "A desc.",
		replaceFunc = function( data )
			if ( data.desc ) then return data.desc end
		end
	} )
	
	catherine.character.RegisterGlobal( {
		id = "model",
		field = "_model",
		isNetwork = true,
		default = "models/player/breen.mdl",
		replaceFunc = function( data )
			if ( data.model ) then return data.model end
		end
	} )
	
	catherine.character.RegisterGlobal( {
		id = "att",
		field = "_att",
		isNetwork = true,
		replaceFunc = function( data )
			if ( data.att ) then return "[]" else return "[]" end // to do
		end,
		needpon = true
	} )
	
	catherine.character.RegisterGlobal( {
		id = "schema",
		field = "_schema",
		getFunc = function( )
			return catherine.schema.GetUniqueID( )
		end
	} )
	
	catherine.character.RegisterGlobal( {
		id = "steamID",
		field = "_steamID",
		getFunc = function( pl )
			return pl:SteamID( )
		end
	} )
	
	catherine.character.RegisterGlobal( {
		id = "inv",
		field = "_inv",
		isNetwork = true,
		replaceFunc = function( )
			return "[]"
		end,
		needpon = true
	} )
	
	catherine.character.RegisterGlobal( {
		id = "cash",
		field = "_cash",
		isNetwork = true,
		default = catherine.configs.defaultCash
	} )
	
	catherine.character.RegisterGlobal( {
		id = "registerTime",
		field = "_registerTime",
		default = os.time( )
	} )
	
	catherine.character.RegisterGlobal( {
		id = "faction",
		field = "_faction",
		default = "citizen",
		replaceFunc = function( data )
			if ( data.faction ) then return data.faction end
		end
	} )
	
	catherine.character.RegisterGlobal( {
		id = "charData",
		field = "_charData",
		isNetwork = true,
		replaceFunc = function( )
			return "[]"
		end,
		needpon = true
	} )

	function catherine.character.Register( pl, data )
		if ( !IsValid( pl ) or !data ) then return end
		local canMake = catherine.character.CheckCanMake( data )
		if ( canMake[ 1 ] == false ) then
			local message = canMake[ 2 ]
			netstream.Start( pl, "catherine.character.RegisterCharacterResult", message )
			//catherine.util.Notify( pl, canMake[ 2 ] )
			return
		end
		catherine.character.buffers[ pl:SteamID( ) ] = catherine.character.buffers[ pl:SteamID( ) ] or { }
		
		local character = { }
	
		for k, v in pairs( catherine.character.GetGlobalListsAll( ) ) do
			if ( v.static ) then continue end
			local value = v.default
			if ( value == nil and v.getFunc ) then value = v.getFunc( pl ) end
			local newvalue = value
			if ( v.replaceFunc ) then newvalue = v.replaceFunc( data ) or value end
			character[ v.field ] = newvalue
		end
		catherine.database.InsertDatas( "catherine_characters", character, function( )
			catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. pl:SteamID( ) .. "' AND _name = '" .. data.name .. "'", function( result )
				for k, v in pairs( result[ 1 ] ) do
					local globaldata = catherine.character.GetGlobalByField( k )
					if ( globaldata and globaldata.needpon and type( v ) == "string" ) then
						result[ 1 ][ k ] = util.JSONToTable( v )
					end
				end
				catherine.character.buffers[ pl:SteamID( ) ][ #catherine.character.buffers[ pl:SteamID( ) ] + 1 ] = result[ 1 ]
				catherine.util.Print( Color( 255, 255, 0 ), "Character created! - " .. pl:SteamID( ) )
				catherine.character.SendCharacterLists( pl )
				netstream.Start( pl, "catherine.character.RegisterCharacterResult", true )
			end )
		end )
	end
	
	function catherine.character.Load( pl, charID )
		local characterTab = catherine.character.GetCharacterTableByID( charID )
		if ( charID == pl.characterID ) then
			print("You are already using that")
			return
		end
		if ( !characterTab ) then
			print("Not valid character!")
			return
		end
		if ( characterTab._steamID != pl:SteamID( ) ) then
			print("You can't use that character!")
			return
		end
		hook.Run( "PreCharacterLoadStart", pl, pl.characterID )
		
		local faction = catherine.faction.FindByID( characterTab._faction )
		if ( !faction ) then
			print("Faction error")
			return
		end
		
		pl.isCharacterLoading = true

		pl:KillSilent( )
		pl:Spawn( )
		
		pl:SetTeam( faction.index )
		pl:SetModel( characterTab._model )
		
		hook.Run( "DefaultWeaponGive", pl )

		if ( !pl.characterID ) then
			netstream.Start( pl, "catherine.hud.CinematicIntro_Init" )
		end
		
		pl.characterID = charID
		pl:SetNetworkValue( "characterID", charID )
		pl:SetNetworkValue( "characterLoaded", true )
		
		catherine.character.RegisterCharacterDatas( pl, charID )
		
		hook.Run( "CharacterLoaded", pl, charID )
		
		pl.isCharacterLoading = nil
	end

	hook.Add( "PlayerSpawned", "catherine.character.PlayerSpawned", function( pl )
		if ( !pl:IsCharacterLoaded( ) ) then return end
		local characterTab = catherine.character.GetCharacterTableByID( pl.characterID )
		if ( !characterTab ) then return end
		pl:SetModel( characterTab._model )
	end )

	function catherine.character.Delete( pl, charID )
		if ( pl.characterID == charID ) then
			print( "You can't delete using character!" )
			return
		end
		catherine.database.Query( "DELETE FROM `catherine_characters` WHERE _steamID = '" .. pl:SteamID( ) .. "' AND _id = '" .. charID .. "'", function( )
			catherine.util.Print( Color( 255, 0, 0 ), "Character delete! - " .. pl:SteamID( ) .. " / " .. charID )
			for k, v in pairs( catherine.character.buffers[ pl:SteamID( ) ] ) do
				if ( v._id == charID ) then
					table.remove( catherine.character.buffers[ pl:SteamID( ) ], k )
				end
			end
			
			catherine.character.SaveAllToDataBases( )
			catherine.character.SendCharacterLists( pl )
		end )
	end

	function catherine.character.SendCharacterLists( pl )
		if ( !IsValid( pl ) or !catherine.character.buffers[ pl:SteamID( ) ] ) then return end
		netstream.Start( pl, "catherine.character.SendCharacterLists", catherine.character.buffers[ pl:SteamID( ) ] )
	end
	
	function catherine.character.SendCharacterPanel( pl )
		if ( !IsValid( pl ) ) then return end
		netstream.Start( pl, "catherine.character.SendCharacterPanel" )
	end

	function catherine.character.IsValid( charID )
		for k, v in pairs( catherine.character.buffers ) do
			for k1, v1 in pairs( catherine.character.buffers[ k ] ) do
				if ( v1.id == charID ) then
					return true
				end
			end
		end
		
		return false
	end
	
	function catherine.character.CheckCanMake( data )
		if ( data.name ) then
			for k, v in pairs( catherine.character.buffers ) do
				for k1, v1 in pairs( v ) do
					for k2, v2 in pairs( v1 ) do
						if ( type( k2 ) == "string" and ( k2:sub( 2 ) == "name" and v2 == data.name ) ) then
							return { false, "name lol" }
						end
					end
				end
			end
			
			return { true }
		else
			return { false, "Please input name!" }
		end
		
		return { false, "Error" }
	end

	function catherine.character.GetPlayerCharacterLists( pl )
		if ( !IsValid( pl ) or !catherine.character.buffers[ pl:SteamID( ) ] ) then return nil end
		return catherine.character.buffers[ pl:SteamID( ) ]
	end
	
	function catherine.character.GetCharacterTableByID( id )
		if ( !id ) then return nil end
		for k, v in pairs( catherine.character.buffers ) do
			for k1, v1 in pairs( v ) do
				for k2, v2 in pairs( v1 ) do
					if ( k2 == "_id" and v2 == id ) then
						return v1
					end
				end
			end
		end
		
		return nil
	end

	function catherine.character.SaveAllToDataBases( )
		local characterCount = catherine.character.CountBufferCharacters( )
		if ( characterCount == 0 ) then return end
		local progress = 0
		local time = 0
		local buffer = table.Copy( catherine.character.buffers )
		for k, v in pairs( buffer ) do
			local steamID = k
			for k1, v1 in pairs( v ) do
				for k2, v2 in pairs( v1 ) do
					local charID = v1._id
					if ( !steamID or !charID ) then
						catherine.util.Print( Color( 255, 0, 0 ), "ERROR - Can't save character! - " .. math.Round( ( progress / characterCount ), 2 ) * 100 .. "%" )
						continue
					end
					catherine.database.UpdateDatas( "catherine_characters", "_steamID = '" .. steamID .. "' AND _id = '" .. charID .. "'", v1 )
					break
				end
			end
		end
		
		catherine.util.Print( Color( 0, 255, 0 ), "Catherine framework has saved characters to MySQL! [" .. characterCount .. "'s character]" )
	end

	function catherine.character.LoadAllByDataBases( func )
		catherine.database.GetDatas( "catherine_characters", nil, function( data )
			if ( !data or #data == 0 ) then catherine.character.buffers = { } return end
			catherine.character.buffers = { }
			local buffer = { }
			local curretCount = { }
			for i = 1, #data do
				local steamID = data[ i ][ "_steamID" ]
				if ( !buffer[ steamID ] or !curretCount[ steamID ] ) then
					buffer[ steamID ] = { }
					curretCount[ steamID ] = 0
				end
				buffer[ steamID ][ #buffer[ steamID ] + 1 ] = data[ i ]
				curretCount[ steamID ] = curretCount[ steamID ] + 1
				for k, v in pairs( data[ i ] ) do
					local globaldata = catherine.character.GetGlobalByField( k )
					if ( globaldata and globaldata.needpon and type( v ) == "string" ) then
						buffer[ steamID ][ curretCount[ steamID ] ][ k ] = util.JSONToTable( v )
					end
				end
			end
			catherine.character.buffers = buffer
			if ( func ) then
				func( )
			end
			catherine.util.Print( Color( 0, 255, 0 ), "Catherine framework has loaded characters to MySQL! [" .. catherine.character.CountBufferCharacters( ) .. "'s character]" )
		end )
	end

	hook.Add( "Think", "catherine.character.Think", function( )
		if ( catherine.character.SaveCurTime <= CurTime( ) ) then
			catherine.character.SaveAllToDataBases( )
			catherine.character.SaveCurTime = CurTime( ) + catherine.configs.saveInterval
		end
	end )

	hook.Add( "DatabaseConnected", "catherine.character.DatabaseConnected", function( )
		catherine.character.LoadAllByDataBases( )
	end )

	hook.Add( "DataSave", "catherine.character.DataSave", function( )
		for k, v in pairs( player.GetAll( ) ) do
			catherine.character.TransferToCharacterTable( v, v.characterID )
		end
		
		catherine.character.SaveAllToDataBases( )
	end )

	function catherine.character.CountBufferCharacters( )
		local count = 0
		for k, v in pairs( catherine.character.buffers ) do
			for k1, v1 in pairs( catherine.character.buffers[ k ] ) do
				if ( !v1._id ) then continue end
				count = count + 1
			end
		end
		return count
	end
	
	netstream.Hook( "catherine.character.RegisterCharacter", function( pl, data )
		catherine.character.Register( pl, data )
	end )
	
	netstream.Hook( "catherine.character.LoadCharacter", function( pl, data )
		catherine.character.Load( pl, data )
	end )
	
	netstream.Hook( "catherine.character.DeleteCharacter", function( pl, data )
		catherine.character.Delete( pl, data )
	end )
else
	catherine.character.LocalCharacters = catherine.character.LocalCharacters or nil
	
	netstream.Hook( "catherine.character.SendCharacterPanel", function( data )
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:Close( )
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		else
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		end
	end )
	
	netstream.Hook( "catherine.character.RegisterCharacterResult", function( data )
		if ( IsValid( catherine.vgui.character ) ) then
			if ( type( data ) == "boolean" ) then
				catherine.vgui.character:CancelStage( )
			else
				Derma_Message( data, "Character create failed", "Okay" )
			end
		end
	end )

	netstream.Hook( "catherine.character.SendCharacterLists", function( data )
		catherine.character.LocalCharacters = data
		
		if ( IsValid( catherine.vgui.character ) ) then
			if ( catherine.vgui.character.loadCharacter ) then
				catherine.vgui.character:LoadCharacter_Refresh( )
				catherine.vgui.character:LoadCharacter_Init( )
			end
		end
	end )
end
*/