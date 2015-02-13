if ( !catherine.data ) then
	catherine.util.Include( "sv_data.lua" )
end
catherine.door = catherine.door or { }

local META = FindMetaTable( "Player" )
local META2 = FindMetaTable( "Entity" )

function META2:IsDoor( )
	if ( !IsValid( self ) ) then return false end
	local class = self:GetClass( )
	if ( class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating" or class == "prop_dynamic" ) then
		return true
	end
	return false
end

if ( SERVER ) then
	function META:BuyDoor( )
		catherine.door.Buy( self )
	end

	function META:SellDoor( )
		catherine.door.Sell( self )
	end

	function META:SetDoorTitle( title )
		catherine.door.SetDoorTitle( self, title )
	end
	
	function META2:SetDoorOwner( pl )
		catherine.door.SetDoorOwner( self, pl )
	end

	function catherine.door.Buy( pl )
		local ent = pl:GetEyeTrace( 70 ).Entity
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		if ( ent:GetNetworkValue( "owner" ) != nil ) then
			return catherine.util.Notify( pl, "This door has already bought by unknown guy." )
		end
		if ( pl:GetCash( ) >= catherine.configs.doorCost ) then
			ent:SetDoorOwner( pl )
			catherine.util.Notify( pl, "You have purchased this door." )
			pl:TakeCash( catherine.configs.doorCost )
		elseif ( pl:GetCash( ) < catherine.configs.doorCost ) then
			catherine.util.Notify( pl, "You need " .. catherine.cash.GetName( catherine.configs.doorCost - pl:GetCash( ) ) .. "(s) more!" )
		end
	end
	
	function catherine.door.Sell( pl )
		local ent = pl:GetEyeTrace( 70 ).Entity
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		if ( ent:GetNetworkValue( "owner" ) != pl ) then
			return catherine.util.Notify( pl, "You do not have permission!" )
		end
		ent:SetDoorOwner( nil )
		pl:GiveCash( catherine.configs.doorSellCost )
		catherine.util.Notify( pl, "You are sold this door." )
	end
	
	function catherine.door.SetDoorTitle( pl, title )
		if ( !title ) then title = "Door" end
		local ent = pl:GetEyeTrace( 70 ).Entity
		if ( !IsValid( ent ) ) then return catherine.util.Notify( pl, "Please look valid entity!" ) end
		if ( !ent:IsDoor( ) ) then return catherine.util.Notify( pl, "Please look valid door!" ) end
		if ( ent:GetNetworkValue( "owner" ) != pl ) then return catherine.util.Notify( pl, "You do not have permission!" ) end
		ent:SetNetworkValue( "title", title )
		catherine.util.Notify( pl, "You are setting this door title to \"" .. title .. "\"" )
	end
	
	function catherine.door.SetDoorOwner( ent, pl )
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		ent:SetNetworkValue( "owner", pl )
	end

	function catherine.door.SaveData( )
		local data = { }
		for k, v in pairs( ents.GetAll( ) ) do
			if ( !v:IsDoor( ) ) then continue end
			local title = v:GetNetworkValue( "title", "Door" )
			if ( title == "Door" ) then continue end
			data[ #data + 1 ] = {
				title = title,
				index = v:EntIndex( )
			}
		end
		
		catherine.data.Set( "door", data )
	end
	
	
	function catherine.door.LoadData( )
		local data = catherine.data.Get( "door", { } )
		
		for k, v in pairs( data ) do
			for k1, v1 in pairs( ents.GetAll( ) ) do
				if ( IsValid( v1 ) and v1:IsDoor( ) and v1:EntIndex( ) == v.index ) then
					v1:SetNetworkValue( "title", v.title )
				end
			end
		end
	end
	
	hook.Add( "DataSave", "catherine.door.DataSave", function( )
		catherine.door.SaveData( )
	end )
	
	hook.Add( "DataLoad", "catherine.door.DataLoad", function( )
		catherine.door.LoadData( )
	end )
else
	local toscreen = FindMetaTable("Vector").ToScreen
	
	hook.Add( "DrawEntityInformation", "catherine.door.DrawEntityInformation", function( ent, a )
		if ( !ent:IsDoor( ) ) then return end
		local position = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		local title = ent:GetNetworkValue( "title", "A Door." )
		local haveOwner = nil
		if ( ent:GetNetworkValue( "owner" ) == nil ) then haveOwner = false else haveOwner = true end
		local tw, th = surface.GetTextSize( title )
		draw.SimpleText( ( haveOwner and "This door has already been purchased." ) or "This door can purchase.", "catherine_font02_20", position.x, position.y + 20, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( ent:GetNetworkValue( "title", "A Door." ), "catherine_font02_25", position.x, position.y, Color( 255, 255, 255, a ), 1, 1 )
	end )
end

catherine.command.Register( {
	command = "doorbuy",
	syntax = "[none]",
	runFunc = function( pl, args )
		pl:BuyDoor( )
	end
} )

catherine.command.Register( {
	command = "doorsell",
	syntax = "[none]",
	runFunc = function( pl, args )
		pl:SellDoor( )
	end
} )

catherine.command.Register( {
	command = "doorsettitle",
	syntax = "[text]",
	runFunc = function( pl, args )
		pl:SetDoorTitle( args[ 1 ] )
	end
} )