nexus.character = nexus.character or { }

if ( SERVER ) then
	nexus.character.buffers = nexus.character.buffers or { }
	nexus.character.globals = { }
	
	function nexus.character.GetGlobalListsAll( )
		return nexus.character.globals
	end
	
	function nexus.character.RegisterGlobal( tab )
		nexus.character.globals[ tab.id ] = tab
	end

	function nexus.character.GetGlobalByID( id )
		if ( !id ) then return nil end
		return nexus.character.globals[ id ]
	end
	
	function nexus.character.GetGlobalByField( field )
		if ( !field ) then return nil end
		for k, v in pairs( nexus.character.globals ) do
			for k1, v1 in pairs( nexus.character.globals[ k ] ) do
				if ( v.field == field ) then
					return v
				end
			end
		end
		
		return nil
	end

	nexus.character.RegisterGlobal( {
		id = "id",
		field = "_id",
		static = true
	} )
	
	nexus.character.RegisterGlobal( {
		id = "name",
		field = "_name",
		isNetwork = true,
		default = "Jason",
		replaceFunc = function( data )
			if ( data.name ) then return data.name end
		end
	} )
	
	nexus.character.RegisterGlobal( {
		id = "desc",
		field = "_desc",
		isNetwork = true,
		default = "A desc.",
		replaceFunc = function( data )
			if ( data.desc ) then return data.desc end
		end
	} )
	
	nexus.character.RegisterGlobal( {
		id = "model",
		field = "_model",
		isNetwork = true,
		default = "models/players/breen.mdl",
		replaceFunc = function( data )
			if ( data.model ) then return data.model end
		end
	} )
	
	nexus.character.RegisterGlobal( {
		id = "att",
		field = "_att",
		isNetwork = true,
		replaceFunc = function( data )
			if ( data.att ) then return "[]" end // to do
		end,
		needpon = true
	} )
	
	nexus.character.RegisterGlobal( {
		id = "schema",
		field = "_schema",
		getFunc = function( )
			return nexus.schema.GetUniqueID( )
		end
	} )
	
	nexus.character.RegisterGlobal( {
		id = "steamID",
		field = "_steamID",
		getFunc = function( pl )
			return pl:SteamID( )
		end
	} )
	
	nexus.character.RegisterGlobal( {
		id = "inv",
		field = "_inv",
		isNetwork = true,
		replaceFunc = function( )
			return "[]"
		end,
		needpon = true
	} )
	
	nexus.character.RegisterGlobal( {
		id = "cash",
		field = "_cash",
		isNetwork = true,
		default = nexus.configs.defaultCash
	} )
	
	nexus.character.RegisterGlobal( {
		id = "faction",
		field = "_faction",
		default = "Citizen",
		replaceFunc = function( data )
			if ( data.faction ) then return data.faction end
		end
	} )
	
	nexus.character.RegisterGlobal( {
		id = "charData",
		field = "_charData",
		isNetwork = true,
		replaceFunc = function( )
			return "[]"
		end,
		needpon = true
	} )

	function nexus.character.Register( pl, data )
		if ( !IsValid( pl ) or !data ) then return end
		local canMake = nexus.character.CheckCanMake( data )
		if ( canMake[ 1 ] == false ) then
			return nexus.util.Notify( pl, canMake[ 2 ] )
		end
		nexus.character.buffers[ pl:SteamID( ) ] = nexus.character.buffers[ pl:SteamID( ) ] or { }
		
		local character = { }
	
		for k, v in pairs( nexus.character.GetGlobalListsAll( ) ) do
			if ( v.static ) then continue end
			local value = v.default
			if ( value == nil and v.getFunc ) then value = v.getFunc( pl ) end
			local newvalue = value
			if ( v.replaceFunc ) then newvalue = v.replaceFunc( data ) or value end
			character[ v.field ] = newvalue
		end
		nexus.database.Insert( character, "nexus_characters", function( )
			nexus.database.GetTable( "_steamID = '" .. pl:SteamID( ) .. "' AND _name = '" .. data.name .. "'", "nexus_characters", function( result )
				for k, v in pairs( result[ 1 ] ) do
					local globaldata = nexus.character.GetGlobalByField( k )
					if ( globaldata and globaldata.needpon and type( v ) == "string" ) then
						result[ 1 ][ k ] = pon.decode( v )
					end
				end
				nexus.character.buffers[ pl:SteamID( ) ][ #nexus.character.buffers[ pl:SteamID( ) ] + 1 ] = result[ 1 ]
				nexus.util.Print( Color( 255, 255, 0 ), "Character created! - " .. pl:SteamID( ) )
				nexus.character.SendCharacterLists( pl )
			end )
		end )
	end
	
	function nexus.character.Load( pl, charID )
		hook.Run( "PreCharacterLoaded", pl, pl.characterID )

		pl.characterID = charID
		pl:SetNetworkValue( "characterID", charID )
		pl:SetNetworkValue( "characterLoaded", true )
		
		hook.Run( "CharacterLoaded", pl, charID )
	end

	function nexus.character.SendCharacterLists( pl )
		if ( !IsValid( pl ) or !nexus.character.buffers[ pl:SteamID( ) ] ) then return end
		netstream.Start( pl, "nexus.character.SendCharacterLists", nexus.character.buffers[ pl:SteamID( ) ] )
	end

	function nexus.character.IsValid( charID )
		for k, v in pairs( nexus.character.buffers ) do
			for k1, v1 in pairs( nexus.character.buffers[ k ] ) do
				if ( v1.id == charID ) then
					return true
				end
			end
		end
		
		return false
	end
	
	function nexus.character.CheckCanMake( data )
		if ( data.name ) then
			for k, v in pairs( nexus.character.buffers ) do
				for k1, v1 in pairs( v ) do
					for k2, v2 in pairs( v1 ) do
						if ( type( k2 ) == "string" and ( k2:sub( 2 ) == "name" and v2 == data.name ) ) then
							return { false, "Can't make that!" }
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

	function nexus.character.GetPlayerCharacterLists( pl )
		if ( !IsValid( pl ) or !nexus.character.buffers[ pl:SteamID( ) ] ) then return nil end
		return nexus.character.buffers[ pl:SteamID( ) ]
	end
	

	function nexus.character.SaveAllToDataBases( )
		local characterCount = nexus.character.CountBufferCharacters( )
		if ( characterCount == 0 ) then return end
		nexus.util.Print( Color( 255, 255, 0 ), "Now nexus framework start working saveing characters! - " .. characterCount )
		local progress = 0
		local time = 0
		local buffer = table.Copy( nexus.character.buffers )
		for k, v in pairs( buffer ) do
			local steamID = k
			for k1, v1 in pairs( v ) do
				for k2, v2 in pairs( v1 ) do
					local globaldata = nexus.character.GetGlobalByID( k2:sub( 2 ) )
					local charID = v1._id
					if ( !steamID or !charID ) then
						nexus.util.Print( Color( 255, 0, 0 ), "ERROR - Can't save character! - " .. math.Round( ( progress / characterCount ), 2 ) * 100 .. "%" )
						continue
					end
					if ( globaldata and globaldata.needpon and type( v2 ) == "table" ) then
						//v2 = util.TableToJSON( v2 ) 
					end
					local timerUniqueID = "nexus.character.timer.SaveCharacters_" .. charID
					timer.Create( timerUniqueID, time, 1, function( )
						nexus.database.Update( "_steamID = '" .. steamID .. "' AND _id = '" .. charID .. "'", v1, "nexus_characters", function( )
							progress = progress + 1
							nexus.util.Print( Color( 255, 255, 0 ), "Save complete! - " .. math.Round( ( progress / characterCount ), 2 ) * 100 .. "%" )
						end )
					end )
					time = time + 0.02
				end
			end
		end
	end

	function nexus.character.LoadAllByDataBases( )
		nexus.database.GetTable_All( "nexus_characters", function( data )
			if ( #data == 0 ) then return end
			nexus.character.buffers = { }
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
					local globaldata = nexus.character.GetGlobalByField( k )
					if ( globaldata and globaldata.needpon and type( v ) == "string" ) then
						buffer[ steamID ][ curretCount[ steamID ] ][ k ] = util.JSONToTable( v )
					end
				end
			end
			nexus.character.buffers = buffer
			nexus.util.Print( Color( 255, 255, 0 ), "Nexus framework has loaded " .. nexus.character.CountBufferCharacters( ) .. "'s characters." )
		end )
	end

	function nexus.character.CountBufferCharacters( )
		local count = 0
		for k, v in pairs( nexus.character.buffers ) do
			for k1, v1 in pairs( nexus.character.buffers[ k ] ) do
				if ( !v1._id ) then continue end
				count = count + 1
			end
		end
		return count
	end

	hook.Add( "PlayerInitialSpawn", "nexus.character.PlayerInitialSpawn", function( pl )
		//if ( nexus.character.GetPlayerCharacterLists( pl ) ) then return end
		//nexus.character.buffers[ pl:SteamID( ) ] = { }
	end )
else
	nexus.character.LocalCharacters = nexus.character.LocalCharacters or nil
	
	netstream.Hook( "nexus.character.SendCharacterLists", function( data )
		nexus.character.LocalCharacters = data
		--[[ // for UI
		if ( IsValid( nexus.vgui.character ) ) then
			nexus.vgui.character:RefreshCharacterLists( )
		end
		--]]
	end )
end