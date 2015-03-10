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

if ( SERVER ) then
	catherine.character.Buffers = catherine.character.Buffers or { }
	catherine.character.Loaded = catherine.character.Loaded or { }
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
						//print(success,reason)
						netstream.Start( pl, "catherine.character.CreateResult", { success, reason } )
						return
					end
				end
			end
			
			characterVars[ v.field ] = var
		end
		
		PrintTable(characterVars)

		catherine.database.InsertDatas( "catherine_characters", characterVars, function( )
			print( "Created - L7D" )
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

	function catherine.character.Use( pl, id )
		if ( !IsValid( pl ) or !id ) then return end
		if ( !catherine.character.Buffers[ pl:SteamID( ) ] ) then return end
		
		if ( pl:GetCharacterID( ) != nil ) then
			catherine.character.SavePlayerCharacter( pl )
			//catherine.character.DisconnectNetworking( pl ) -- 꼭 필요한지 몰르겠즘;; T-T
			catherine.character.SetLoadedCharacterByID( pl, pl:GetCharacterID( ), nil )
			
			// 이전 캐릭터 데이터 클리어..
		end
		
		if ( pl:GetCharacterID( ) == id ) then
			netstream.Start( pl, "catherine.character.UseResult", { false, "You can't use same character!" } )
			return
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

			catherine.network.SetNetVar( pl, "charID", id )
			catherine.network.SetNetVar( pl, "charLoaded", true )
			
			netstream.Start( pl, "catherine.character.UseResult", { true } )
			
			print("Loaded - " .. id )
		end

		local characterData = nil
		
		for k, v in pairs( catherine.character.Buffers[ pl:SteamID( ) ] ) do
			for k1, v1 in pairs( v ) do
				if ( k1 == "_id" and v1 == id ) then
					characterData = v
				end
			end
		end

		if ( !characterData ) then return end

		catherine.character.SetLoadedCharacterByID( pl, id, characterData )
		useCharacter( characterData )
	end
	
	function catherine.character.SetLoadedCharacterByID( pl, id, data )
		if ( !IsValid( pl ) or !id ) then return end
		catherine.character.Loaded[ tostring( id ) ] = data
	end
	
	function catherine.character.TransferJSON( data )
		if ( !data ) then return nil end
		for k, v in pairs( data ) do
			local globalVarTab = catherine.character.FindGlobalVarByField( k )
			if ( globalVarTab and !globalVarTab.needTransfer ) then continue end
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
	
	function catherine.character.GetCurrentNetworking( pl, func )
		if ( !IsValid( pl ) ) then return end
		netstream.Start( nil, "catherine.character.GetCurrentNetworking", catherine.character.networkingVars )
		if ( func ) then
			func( )
		end
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
		local character = catherine.character.GetLoadedCharacterByID( pl, id )
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
	
	function catherine.character.MergeNetworkingVarsByLoaded( pl )
		if ( !IsValid( pl ) ) then return end
		table.Merge( catherine.character.Loaded[ tostring( pl:GetCharacterID( ) ) ], catherine.character.networkingVars[ pl:SteamID( ) ] )
	end
	
	function catherine.character.Think( )
		if ( catherine.character.SaveCurTime <= CurTime( ) ) then
			for k, v in pairs( player.GetAllByLoaded( ) ) do
				catherine.character.SavePlayerCharacter( v )
			end
			catherine.character.SaveCurTime = CurTime( ) + catherine.configs.saveInterval
		end
	end
	
	function catherine.character.PlayerDisconnected( pl )
		catherine.character.SavePlayerCharacter( pl )
		catherine.character.SetLoadedCharacterByID( pl, pl:GetCharacterID( ), nil )
		catherine.character.DisconnectNetworking( pl )
	end
	
	hook.Add( "Think", "catherine.character.Think", catherine.character.Think )
	hook.Add( "PlayerDisconnected", "catherine.character.PlayerDisconnected", catherine.character.PlayerDisconnected )
	
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
	
	netstream.Hook( "catherine.character.Create", function( caller, data )
		catherine.character.Create( caller, data )
		//PrintTable(data)
	end )
	
	netstream.Hook( "catherine.character.Use", function( caller, data )
		catherine.character.Use( caller, data )
	end )
	
	netstream.Hook( "catherine.character.Delete", function( caller, data )
		// 나중에;.
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
	
	netstream.Hook( "catherine.character.GetCurrentNetworking", function( data )
		catherine.character.networkingVars = data
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
end

function catherine.character.GetGlobalVar( pl, key, default )
	if ( !IsValid( pl ) and !key ) then return default end
	if ( !catherine.character.networkingVars[ pl:SteamID( ) ] or catherine.character.networkingVars[ pl:SteamID( ) ][ key ] == nil ) then return default end
	return catherine.character.networkingVars[ pl:SteamID( ) ][ key ] or default
end

local META = FindMetaTable( "Player" )

function META:GetCharacterID( )
	return catherine.network.GetNetVar( self, "charID", 0 )
end

function META:IsCharacterLoaded( )
	return catherine.network.GetNetVar( self, "charLoaded", false )
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
	
	META.Nick = META.Name
	META.GetName = META.Name
end