if ( !catherine.command ) then
	catherine.util.Include( "sh_command.lua" )
end

catherine.cash = catherine.cash or { }

function catherine.cash.GetOnlyName( )
	return catherine.configs.cashName
end

function catherine.cash.GetName( amount )
	return amount .. " " .. catherine.configs.cashName
end

catherine.command.Register( {
	command = "chargivecash",
	syntax = "[name] [amount]",
	runFunc = function( pl, args )
		if ( !args[ 1 ] or !args[ 2 ] ) then
			return
		end
		local foundTarget = catherine.util.FindPlayerByName( args[ 1 ] )
		foundTarget:GiveCash( args[ 2 ] )
	end
} )

