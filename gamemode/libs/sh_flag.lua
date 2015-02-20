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
		if ( type( code ) == "string" ) then
			local flagTab = catherine.flag.FindByCode( code )
			if ( !flagTab or catherine.flag.Has( target, code ) ) then catherine.util.Notify( pl, "That player already have that flag!" ) return end
			flagData[ #flagData + 1 ] = code
		elseif ( type( code ) == "table" ) then
			for k, v in pairs( code ) do
				local flagTab = catherine.flag.FindByCode( v )
				if ( !flagTab or catherine.flag.Has( target, v ) ) then continue end
				flagData[ #flagData + 1 ] = v
			end
		end
		catherine.character.SetCharData( target, "flags", flagData )
		hook.Run( "FlagGived", target, code )
		catherine.util.NotifyAll( pl:Name( ) .. " 님이 " .. target:Name( ) .. " 님에게 " .. code .. " 플레그를 주셨습니다." )
	end
	
	function catherine.flag.Take( pl, target, code )
		if ( !IsValid( pl ) or !IsValid( target ) ) then catherine.util.Notify( pl, "Player is not valid!" ) return end
		local flagTab = catherine.flag.FindByCode( code )
		if ( !flagTab or !catherine.flag.Has( target, code ) ) then catherine.util.Notify( pl, "That player hasen't have flag." ) return end
		local flagData = table.Copy( catherine.character.GetCharData( target, "flags", { } ) )
		for k, v in pairs( flagData ) do
			if ( v == code ) then
				table.remove( flagData, k )
			end
		end
		catherine.character.SetCharData( target, "flags", flagData )
		
		catherine.util.NotifyAll( pl:Name( ) .. " 님이 " .. target:Name( ) .. " 님의 " .. code .. " 플레그를 뺏으셨습니다." )
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
	
	hook.Add( "FlagGived", "catherine.flag.FlagGived", function( pl, code )
		if ( code == "p" ) then
			pl:Give( "weapon_physgun" )
		end
		if ( code == "t" ) then
			pl:Give( "gmod_tool" )
		end
	end )
	
	hook.Add( "FlagTaked", "catherine.flag.FlagTaked", function( pl, code )
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
		catherine.flag.Give( pl, player, args[ 2 ] )
	end
} )

catherine.command.Register( {
	command = "flagtake",
	syntax = "[player]",
	runFunc = function( pl, args )
		local player = catherine.util.FindPlayerByName( args[ 1 ] )
		catherine.flag.Take( pl, player, args[ 2 ] )
	end
} )

catherine.flag.Register( "p", "Access to physgun." )
catherine.flag.Register( "t", "Access to tool gun." )
catherine.flag.Register( "ex", "Access to spawn prop." )