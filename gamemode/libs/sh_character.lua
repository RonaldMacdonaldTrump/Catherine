nexus.character = nexus.character or { }
nexus.character.characterDataList = { }

local encodePon = pon.encode( { } )

function nexus.character.RegisterCharacterData( tab )
	nexus.character.characterDataList[ #nexus.character.characterDataList + 1 ] = tab
end

function nexus.character.DataListFindByField( field )
	for k, v in pairs( nexus.character.characterDataList ) do
		if ( v.Field == field ) then
			return v
		end
	end
	
	return nil
end

nexus.character.RegisterCharacterData( {
	Field = "_Name",
	Name = "Name",
	CantDefault = true,
	ReceiveIndex = 1,
	Default = "Jason",
	IsNetwork = true,
	ErrorFetch = function( data )
		if ( data == "" ) then
			return "Please input name!"
		end
	end
} )

nexus.character.RegisterCharacterData( {
	Field = "_Desc",
	Name = "Desc",
	ReceiveIndex = 2,
	Default = "A sample desc.",
	IsNetwork = true
} )

nexus.character.RegisterCharacterData( {
	Field = "_Faction",
	Name = "Faction",
	CantDefault = true,
	IgnoreSet = true,
	ReceiveIndex = 3,
	Default = "Citizen",
	ErrorFetch = function( data )
		if ( data == "" ) then
			return "Please input faction!"
		end
	end
} )

nexus.character.RegisterCharacterData( {
	Field = "_Model",
	Name = "Model",
	CantDefault = true,
	ReceiveIndex = 4,
	Default = "models/breen.mdl",
	IsNetwork = true,
	ErrorFetch = function( data )
		if ( data == "" ) then
			return "Please input model!"
		end
	end
} )

nexus.character.RegisterCharacterData( {
	Field = "_Att",
	Name = "Att",
	ReceiveIndex = 5,
	Default = encodePon
} )

nexus.character.RegisterCharacterData( {
	Field = "_Cash",
	Name = "Cash",
	Default = nexus.configs.defaultCash,
	Fetch = function( )
		return nexus.configs.defaultCash
	end
} )

nexus.character.RegisterCharacterData( {
	Field = "_RegisterTime",
	Name = "RegisterTime",
	Default = 0,
	Fetch = function( )
		return math.floor( os.time( ) )
	end
} )

nexus.character.RegisterCharacterData( {
	Field = "_NexusData",
	Name = "NexusData",
	Default = encodePon
} )

nexus.character.RegisterCharacterData( {
	Field = "_SteamID",
	Name = "SteamID",
	Default = "STEAM",
	IgnoreSet = true,
	Fetch = function( pl )
		return pl:SteamID( )
	end
} )

nexus.character.RegisterCharacterData( {
	Field = "_Schema",
	Name = "Schema",
	Default = "nexus",
	Fetch = function( )
		return Schema and Schema.FolderName
	end
} )

	
if ( SERVER ) then
	nexus.character.Lists = nexus.character.Lists or { }
	nexus.character.Registering = nexus.character.Registering or false
	nexus.character.SaveCurTime = nexus.character.SaveCurTime or CurTime( ) + nexus.configs.saveInterval
	
	function nexus.character.Register( pl, data )
		nexus.character.Registering = true
		
		local buffer = { }
		local buffer2 = { }
		for k, v in pairs( nexus.character.characterDataList ) do
			local value = v.Default
			if ( v.Fetch ) then
				value = v.Fetch( pl ) or value
			else
				value = data[ v.ReceiveIndex ] or value
			end
			if ( v.CantDefault and v.ErrorFetch ) then
				local errorMsg = v.ErrorFetch( value )
				if ( errorMsg ) then
					MsgN( errorMsg )
					return
				end
				
			end
				
			buffer[ v.Field ] = value
			buffer2[ v.Name ] = value
		end
	
		//PrintTable( buffer )
		nexus.database.Insert( buffer, "characters", function( )
			nexus.database.GetTable( "_SteamID = '" .. pl:SteamID( ) .. "'", "characters", function( data )
				nexus.character.SendCharacterLists( pl, data )
			end )
		end )
	
		print("Character created!")
		
		nexus.character.Registering = false
		
		hook.Run( "CharacterCreated", pl, data )
	end
	
	function nexus.character.Load( pl, id )
		nexus.database.GetTable( "_ID = '" .. id .. "'", "characters", function( data )
			local data = data[ 1 ]
			pl.characterID = data[ "_ID" ]
			pl.characterTab = data[ 1 ]
			pl:SetNetworkValue( "characterID", data[ "_ID" ] )
			pl:SetNetworkValue( "characterLoaded", true )
			
			for k, v in pairs( data ) do
				if ( k == "_ID" or k == "_NexusData" ) then continue end
				local field = nexus.character.DataListFindByField( k )
				if ( field.IgnoreSet ) then continue end
				pl:SetCharacterData( k, v )
			end
			
			// pl:SetTeam( )
			// pl:SetHealth( )
			// pl:SetArmor( )
			
			pl:Spawn( )
			pl:SetModel( pl:GetCharacterData( "_Model" ) )
			pl:SetColor( Color( 255, 255, 255, 255 ) )
			
			print("Character Loaded! - " .. id)
			
			hook.Run( "CharacterLoaded", pl, id )
		end )
	end
	
	function nexus.character.SaveTargetPlayer( pl )
		if ( nexus.character.Registering ) then return end
		local datas = { }
		for k, v in pairs( nexus.character.characterDataList ) do
			if ( v.IgnoreSet ) then continue end
			datas[ v.Field ] = pl:GetCharacterData( v.Field )
		end
		nexus.database.Update( "_ID = '" .. pl:GetCharacterID( ) .. "'", datas, "characters" )
		
		hook.Run( "CharacterSaved" )
	end

	function nexus.character.SendCharacterLists( pl, data )
		netstream.Start( pl, "nexus.character.ReceiveCharacterLists", data )
	end
	
	function nexus.character.SendCharacterPanel( pl )
		netstream.Start( pl, "nexus.character.ReceiveCharacterPanel" )
	end
	
	hook.Add( "PlayerDisconnected", "nexus.character.PlayerDisconnected", function( pl )
		nexus.character.SaveTargetPlayer( pl )
	end )
	
	hook.Add( "Think", "nexus.character.Think", function( )
		if ( nexus.character.SaveCurTime <= CurTime( ) ) then
			local start = 1
			for k, v in pairs( player.GetAll( ) ) do
				if ( !v:IsCharacterLoaded( ) ) then continue end
				timer.Simple( start, function( )
					nexus.character.SaveTargetPlayer( v )
				end )
				start = start + math.max( v:Ping( ) / 75, 0.75 )
			end
			nexus.character.SaveCurTime = CurTime( ) + nexus.configs.saveInterval
		end
	end )
	
	function nexus.character.NewNexusData( )
	
	end
	
--[[ -- For Development
	nexus.character.Register( player.GetByID( 2 ), {
		"Bot",
		"A Sample",
		"Citizen",
		"models/alyx.mdl"
	} )

	print(player.GetByID( 1 ):GetCharacterData( "_Model"))
	nexus.character.SaveTargetPlayer( player.GetByID( 1 ) )
	player.GetByID( 1 ):SetCharacterData( "_Model", "models/player/alyx.mdl" )
	nexus.character.Load( player.GetByID( 1 ), 10 )
	player.GetByID( 1 ):SetCharacterData( "_Faction", "Fristet" )
	nexus.character.Save( player.GetByID( 1 ), 10 )
--]]	
else
	nexus.character.Lists = nexus.character.Lists or nil
	nexus.character.characterDatas = nexus.character.characterDatas or { }
	
	netstream.Hook( "nexus.character.ReceiveCharacterLists", function( data )
		nexus.character.Lists = data
		
		PrintTable( data )
	end )
	
	netstream.Hook( "nexus.character.SendCharacterDatas", function( data )
		local uniqueID = data[ 1 ]
		local key = data[ 2 ]
		local value = data[ 3 ]
		nexus.character.characterDatas[ uniqueID ] = nexus.character.characterDatas[ uniqueID ] or { }
		if ( nexus.character.characterDatas[ uniqueID ][ key ] != value ) then
			nexus.character.characterDatas[ uniqueID ][ key ] = value
		end
	end )
	
	netstream.Hook( "nexus.character.ClearCharacterDatas", function( data )
		local uniqueID = data[ 1 ]
		if ( !nexus.character.characterDatas[ uniqueID ] ) then return end
		nexus.character.characterDatas[ uniqueID ] = nil
	end )
	
	netstream.Hook( "nexus.character.ReceiveCharacterPanel", function( )
		// nexus.vgui.character = vgui.Create( "nexus.vgui.character" ) TO DO
	end )
end

--[[
nexus.database.Insert( {
	_Name = "L7D",
	_SteamID = "STEAM_0:1:25704824",
	_Desc = "127.0.0.1",
	_Model = "breen.mdl",
	_Att = "{}",
	_Schema = "nexus_hl2rp",
	_RegisterTime = 111111,
	_NexusData = "{}",
	_Cash = 0,
	_Faction = "Citizen"
}, "characters" )
--]]