catherine.character = catherine.character or { }

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
		static = true
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
		id = "faction",
		field = "_faction",
		default = "Citizen",
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
			return catherine.util.Notify( pl, canMake[ 2 ] )
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
		catherine.database.Insert( character, "catherine_characters", function( )
			catherine.database.GetTable( "_steamID = '" .. pl:SteamID( ) .. "' AND _name = '" .. data.name .. "'", "catherine_characters", function( result )
				for k, v in pairs( result[ 1 ] ) do
					local globaldata = catherine.character.GetGlobalByField( k )
					if ( globaldata and globaldata.needpon and type( v ) == "string" ) then
						result[ 1 ][ k ] = util.JSONToTable( v )
					end
				end
				catherine.character.buffers[ pl:SteamID( ) ][ #catherine.character.buffers[ pl:SteamID( ) ] + 1 ] = result[ 1 ]
				catherine.util.Print( Color( 255, 255, 0 ), "Character created! - " .. pl:SteamID( ) )
				catherine.character.SendCharacterLists( pl )
			end )
		end )
	end
	
	//catherine.character.Register( catherine.util.FindPlayerByName( "MOKAKI"	), { name = "MOKAKI2" } )
	//catherine.character.Register( player.GetByID( 3 ), { name = "LOL!" } )

	//PrintTable(catherine.character.buffers)
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
		
		
		pl:KillSilent( )
		pl:Spawn( )
		pl:StripWeapons( )
		//pl:SetTeam( 1 )
		pl:SetModel( characterTab._model )
		
		pl.characterID = charID
		pl:SetNetworkValue( "characterID", charID )
		pl:SetNetworkValue( "characterLoaded", true )
		
		hook.Run( "CharacterLoaded", pl, charID )
	end
	
	concommand.Add( "characterLoad", function( pl, cmd, args )
	
		catherine.character.Load( pl, tonumber( args[ 1 ] ) )
	end )
	

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
		catherine.util.Print( Color( 255, 255, 0 ), "Now catherine framework start working saveing characters! - " .. characterCount )
		local progress = 0
		local time = 0
		local buffer = table.Copy( catherine.character.buffers )
		for k, v in pairs( buffer ) do
			local steamID = k
			for k1, v1 in pairs( v ) do
				for k2, v2 in pairs( v1 ) do
					local globaldata = catherine.character.GetGlobalByID( k2:sub( 2 ) )
					local charID = v1._id
					if ( !steamID or !charID ) then
						catherine.util.Print( Color( 255, 0, 0 ), "ERROR - Can't save character! - " .. math.Round( ( progress / characterCount ), 2 ) * 100 .. "%" )
						continue
					end
					if ( globaldata and globaldata.needpon and type( v2 ) == "table" ) then
						//v2 = util.TableToJSON( v2 ) 
					end
					local timerUniqueID = "catherine.character.timer.SaveCharacters_" .. charID
					timer.Create( timerUniqueID, time, 1, function( )
						catherine.database.Update( "_steamID = '" .. steamID .. "' AND _id = '" .. charID .. "'", v1, "catherine_characters", function( )
							progress = progress + 1
							catherine.util.Print( Color( 255, 255, 0 ), "Save complete! - " .. math.Round( ( progress / characterCount ), 2 ) * 100 .. "%" )
						end )
					end )
					time = time + 0.02
				end
			end
		end
	end

	function catherine.character.LoadAllByDataBases( )
		catherine.database.GetTable_All( "catherine_characters", function( data )
			if ( #data == 0 ) then catherine.character.buffers = { } return end
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
			catherine.util.Print( Color( 255, 255, 0 ), "catherine framework has loaded " .. catherine.character.CountBufferCharacters( ) .. "'s characters." )
		end )
	end
	
	hook.Add( "Tick", "catherine.character.Tick", function( )
		if ( catherine.character.SaveCurTime <= CurTime( ) ) then
			catherine.character.SaveAllToDataBases( )
			catherine.character.SaveCurTime = CurTime( ) + catherine.configs.saveInterval
		end
	end )

	//catherine.character.Register( player.GetByID( 1 ), { name = "L7D3", model = "models/player/alyx.mdl" } )
	//PrintTable(catherine.character.buffers)

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

	hook.Add( "PlayerInitialSpawn", "catherine.character.PlayerInitialSpawn", function( pl )
		//if ( catherine.character.GetPlayerCharacterLists( pl ) ) then return end
		//catherine.character.buffers[ pl:SteamID( ) ] = { }
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
	
	netstream.Hook( "catherine.character.SendCharacterLists", function( data )
		catherine.character.LocalCharacters = data
		--[[ // for UI
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:RefreshCharacterLists( )
		end
		--]]
	end )
end