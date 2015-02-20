catherine.flag = catherine.flag or { }
catherine.flag.Lists = { }
local META = FindMetaTable( "Player" )

function catherine.flag.Register( code, desc )
	catherine.flag.Lists[ #catherine.flag.Lists + 1 ] = { code = code, desc = desc }
end

function catherine.flag.FindByCode( code )
	if ( !code ) then return nil end
	for k, v in pairs( catherine.flag.Lists ) do
		if ( v.code == code ) then
			return v
		end
	end
	
	return nil
end

function catherine.flag.Has( pl, code )
	local flagData = catherine.character.GetCharData( pl, "flags", { } )
	return table.HasValue( flagData, code )
end

if ( SERVER ) then
	function catherine.flag.Give( pl, code )
		if ( !IsValid( pl ) ) then return "player has not valid!" end
		local flagData = table.Copy( catherine.character.GetCharData( pl, "flags", { } ) )
		if ( type( code ) == "string" ) then
			local flagTab = catherine.flag.FindByCode( code )
			if ( !flagTab or catherine.flag.Has( pl, code ) ) then return "that player already have that flag." end
			flagData[ #flagData + 1 ] = code
		elseif ( type( code ) == "table" ) then
			for k, v in pairs( code ) do
				local flagTab = catherine.flag.FindByCode( v )
				if ( !flagTab or catherine.flag.Has( pl, v ) ) then continue end
				flagData[ #flagData + 1 ] = v
			end
		end
		catherine.character.SetCharData( pl, "flags", flagData )
		return "You are give flag!"
	end
	
	function catherine.flag.Take( pl, code )
		if ( !IsValid( pl ) ) then return "player has not valid!" end
		local flagTab = catherine.flag.FindByCode( code )
		if ( !flagTab or !catherine.flag.Has( pl, code ) ) then return "that player hasn't that flag." end
		local flagData = table.Copy( catherine.character.GetCharData( pl, "flags", { } ) )
		for k, v in pairs( flagData ) do
			if ( v == code ) then
				table.remove( flagData, k )
			end
		end
		catherine.character.SetCharData( pl, "flags", flagData )
		
		return "You are take flag!"
	end
	
	function META:GiveFlag( code )
		catherine.flag.Give( self, code )
	end
	
	function META:TakeFlag( code )
		catherine.flag.Take( self, code )
	end
	
	hook.Add( "PlayerSpawned", "catherine.flag.PlayerSpawned", function( pl )
		if ( pl:HasFlag( "p" ) ) then
			pl:Give( "weapon_physgun" )
		end
		if ( pl:HasFlag( "t" ) ) then
			pl:Give( "gmod_tool" )
		end
	end )
end

function META:HasFlag( code )
	return catherine.flag.Has( self, code )
end

catherine.command.Register( {
	command = "flaggive",
	syntax = "[player]",
	runFunc = function( pl, args )
		local player = catherine.util.FindPlayerByName( args[ 1 ] )
		catherine.util.Notify( catherine.flag.Give( player, args[ 2 ] ))
	end
} )

catherine.flag.Register( "p", "Access to physgun." )
catherine.flag.Register( "t", "Access to tool gun." )