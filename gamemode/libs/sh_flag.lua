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
	function catherine.flag.Give( pl, target, code )
		if ( !IsValid( pl ) or !IsValid( target ) ) then catherine.util.Notify( pl, "Player is not valid!" ) return end
		local flagData = table.Copy( catherine.character.GetCharData( target, "flags", { } ) )
		local add = { }
		for k, v in pairs( code ) do
			local flagTab = catherine.flag.FindByCode( v )
			if ( !flagTab or catherine.flag.Has( target, v ) ) then continue end
			add[ #add + 1 ] = v
		end
		
		for k, v in pairs( add ) do
			if ( !table.HasValue( flagData, v ) ) then
				flagData[ #flagData + 1 ] = v
				hook.Run( "FlagGive", target, v )
			end
		end
		if ( #add >= 1 ) then
			catherine.character.SetCharData( target, "flags", flagData )
			catherine.util.NotifyAll( pl:Name( ) .. " has set " .. target:Name( ) .. "'s flags to " .. ( type( code ) == "string" and code or table.concat( code, ", " ) ) .. "." )
		else
			catherine.util.Notify( pl, "That player already have that flag!" )
		end
	end
	
	function catherine.flag.Take( pl, target, code )
		if ( !IsValid( pl ) or !IsValid( target ) ) then catherine.util.Notify( pl, "Player is not valid!" ) return end
		local flagData = table.Copy( catherine.character.GetCharData( target, "flags", { } ) )
		local remove = 0
		for k, v in pairs( code ) do
			if ( table.HasValue( flagData, v ) ) then
				local flagTab = catherine.flag.FindByCode( v )
				if ( !flagTab ) then catherine.util.Notify( pl, v .. " is not valid flag!" ) continue end
				remove = remove + 1
				hook.Run( "FlagTake", target, v )
				table.RemoveByValue( flagData, v )
			end
		end
		if ( remove != 0 ) then
			catherine.character.SetCharData( target, "flags", flagData )
			catherine.util.NotifyAll( pl:Name( ) .. " has set " .. target:Name( ) .. "'s flags to " .. ( type( code ) == "string" and code or table.concat( code, ", " ) ) .. "." )
		else
			catherine.util.Notify( pl, "That player not have flag!" )
		end
	end
	
	function META:GiveFlag( code )
		catherine.flag.Give( self, code )
	end
	
	function META:TakeFlag( code )
		catherine.flag.Take( self, code )
	end
	
	hook.Add( "CharacterLoaded", "catherine.flag.CharacterLoaded", function( pl )
		if ( pl:HasFlag( "p" ) ) then
			pl:Give( "weapon_physgun" )
		end
		if ( pl:HasFlag( "t" ) ) then
			pl:Give( "gmod_tool" )
		end
	end )
	
	hook.Add( "PlayerSpawned", "catherine.flag.PlayerSpawned", function( pl )
		if ( pl:HasFlag( "p" ) ) then
			pl:Give( "weapon_physgun" )
		end
		if ( pl:HasFlag( "t" ) ) then
			pl:Give( "gmod_tool" )
		end
	end )
	
	hook.Add( "FlagGive", "catherine.flag.FlagGive", function( pl, code )
		if ( code == "p" ) then
			pl:Give( "weapon_physgun" )
		end
		if ( code == "t" ) then
			pl:Give( "gmod_tool" )
		end
	end )
	
	hook.Add( "FlagTake", "catherine.flag.FlagTake", function( pl, code )
		if ( code == "p" ) then
			pl:StripWeapon( "weapon_physgun" )
		end
		if ( code == "t" ) then
			pl:StripWeapon( "gmod_tool" )
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
		local argsF = string.Explode( ",", args[ 2 ] )
		catherine.flag.Give( pl, player, argsF )
	end
} )

catherine.command.Register( {
	command = "flagtake",
	syntax = "[player]",
	runFunc = function( pl, args )
		local player = catherine.util.FindPlayerByName( args[ 1 ] )
		local argsF = string.Explode( ",", args[ 2 ] )
		catherine.flag.Take( pl, player, argsF )
	end
} )

catherine.flag.Register( "p", "Access to physgun." )
catherine.flag.Register( "t", "Access to tool gun." )
catherine.flag.Register( "ex", "Access to spawn prop." )