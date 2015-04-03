--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

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
	function catherine.cash.Set( pl, amount )
		amount = tonumber( amount )
		if ( !amount ) then return false end
		catherine.character.SetGlobalVar( pl, "_cash", math.Clamp( tonumber( amount ), 0, CASH_MAX_LIMIT ) )
		
		return true
	end
	
	function catherine.cash.Give( pl, amount )
		amount = tonumber( amount )
		if ( !amount ) then return false end
		catherine.character.SetGlobalVar( pl, "_cash", math.Clamp( catherine.cash.Get( pl ) + tonumber( amount ), 0, CASH_MAX_LIMIT ) )
		
		return true
	end

	function catherine.cash.Take( pl, amount )
		amount = tonumber( amount )
		if ( !amount ) then return false end
		catherine.character.SetGlobalVar( pl, "_cash", math.Clamp( catherine.cash.Get( pl ) - tonumber( amount ), 0, CASH_MAX_LIMIT ) )
		
		return true
	end
end

function catherine.cash.Get( pl )
	return tonumber( catherine.character.GetGlobalVar( pl, "_cash", 0 ) )
end

if ( SERVER ) then return end

hook.Add( "AddRPInformation", "catherine.cash.AddRPInformation", function( pnl, data )
	data[ #data + 1 ] = "You have a " .. catherine.cash.GetName( catherine.cash.Get( LocalPlayer( ) ) ) .. "."
end )