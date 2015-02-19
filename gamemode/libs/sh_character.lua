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
	
	function playerMeta:Desc( )
		if ( self:IsCharacterLoaded( ) ) then
			return self:GetCharacterGlobalData( "_desc", "Error" )
		end

		return "Error Desc"
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
		pl:StripWeapons( )
		
		pl:SetTeam( faction.index )
		pl:SetModel( characterTab._model )
		
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
			catherine.character.LoadAllByDataBases( function( )
				catherine.character.SendCharacterLists( pl )
			end )
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
		catherine.util.Print( Color( 255, 255, 0 ), "Now catherine framework start working saveing characters! - " .. characterCount )
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
					--[[ // Timer has deleted.
					local timerUniqueID = "catherine.character.timer.SaveCharacters_" .. charID
					timer.Create( timerUniqueID, time, 1, function( )
						catherine.database.Update( "_steamID = '" .. steamID .. "' AND _id = '" .. charID .. "'", v1, "catherine_characters", function( )
							progress = progress + 1
							catherine.util.Print( Color( 255, 255, 0 ), "Save complete! - " .. math.Round( ( progress / characterCount ), 2 ) * 100 .. "%" )
						end )
					end )--]]
					catherine.database.Update( "_steamID = '" .. steamID .. "' AND _id = '" .. charID .. "'", v1, "catherine_characters", function( )
						catherine.util.Print( Color( 255, 255, 0 ), "Save complete! - " .. charID )
					end )
					
					break
				end
			end
		end
	end

	function catherine.character.LoadAllByDataBases( func )
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
			if ( func ) then
				func( )
			end
			catherine.util.Print( Color( 255, 255, 0 ), "catherine framework has loaded " .. catherine.character.CountBufferCharacters( ) .. "'s characters." )
		end )
	end
	
	hook.Add( "Tick", "catherine.character.Tick", function( )
		if ( catherine.character.SaveCurTime <= CurTime( ) ) then
			catherine.character.SaveAllToDataBases( )
			catherine.character.SaveCurTime = CurTime( ) + catherine.configs.saveInterval
		end
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
				catherine.vgui.character:LoadCharacter_Init( )
			end
		end
	end )
end