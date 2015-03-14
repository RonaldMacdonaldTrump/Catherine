if ( !catherine.command ) then
	catherine.util.Include( "sh_command.lua" )
end

catherine.cash = catherine.cash or { }

function catherine.cash.GetOnlyName( )
	return catherine.configs.cashName
end

function catherine.cash.GetName( int )
	return int .. " " .. catherine.configs.cashName
end

catherine.command.Register( {
	command = "chargivecash",
	syntax = "[name] [int]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success = catherine.cash.Give( target, args[ 2 ] )
					if ( success ) then
						catherine.util.Notify( pl, catherine.language.GetValue( pl, "Cash_GiveMessage01", target:Name( ), catherine.cash.GetName( args[ 2 ] ) ) )
					else
						catherine.util.Notify( pl, catherine.language.GetValue( pl, "UnknownError" ) )
					end
				else
					catherine.util.Notify( pl, catherine.language.GetValue( pl, "UnknownPlayerError" ) )
				end
			else
				catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 2 ) )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
		end
	end
} )

local CASH_MAX_LIMIT = 9999999999

if ( SERVER ) then
	function catherine.cash.Set( pl, int )
		int = tonumber( int )
		if ( !int ) then return false end
		catherine.character.SetGlobalVar( pl, "_cash", math.Clamp( tonumber( int ), 0, CASH_MAX_LIMIT ) )
		
		return true
	end
	
	function catherine.cash.Give( pl, int )
		int = tonumber( int )
		if ( !int ) then return false end
		catherine.character.SetGlobalVar( pl, "_cash", math.Clamp( catherine.cash.Get( pl ) + tonumber( int ), 0, CASH_MAX_LIMIT ) )
		
		return true
	end
	
	function catherine.cash.Take( pl, int )
		int = tonumber( int )
		if ( !int ) then return false end
		catherine.character.SetGlobalVar( pl, "_cash", math.Clamp( catherine.cash.Get( pl ) - tonumber( int ), 0, CASH_MAX_LIMIT ) )
		
		return true
	end
end

function catherine.cash.Get( pl )
	return tonumber( catherine.character.GetGlobalVar( pl, "_cash", 0 ) )
end