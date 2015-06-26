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

function catherine.cash.Has( pl, amount )
	return catherine.cash.Get( pl ) >= math.max( amount or 0, 0 )
end

function catherine.cash.Get( pl )
	return tonumber( catherine.character.GetVar( pl, "_cash", 0 ) )
end

if ( SERVER ) then
	function catherine.cash.Set( pl, amount )
		amount = tonumber( amount )
		
		if ( !amount ) then return false end
		
		catherine.character.SetVar( pl, "_cash", math.max( amount, 0 ) )
		
		return true
	end
	
	function catherine.cash.Give( pl, amount )
		amount = tonumber( amount )
		
		if ( !amount ) then return false end
		
		catherine.character.SetVar( pl, "_cash", math.max( catherine.cash.Get( pl ) + amount, 0 ) )
		
		return true
	end

	function catherine.cash.Take( pl, amount )
		amount = tonumber( amount )
		
		if ( !amount ) then return false end
		
		catherine.character.SetVar( pl, "_cash", math.max( catherine.cash.Get( pl ) - amount, 0 ) )
		
		return true
	end
else
	hook.Add( "AddRPInformation", "catherine.cash.AddRPInformation", function( pnl, data )
		data[ #data + 1 ] = LANG( "Cash_UI_HasStr", catherine.cash.Get( LocalPlayer( ) ) )
	end )
end