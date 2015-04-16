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
	return catherine.cash.Get( pl ) >= amount
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
end

function catherine.cash.Get( pl )
	return tonumber( catherine.character.GetVar( pl, "_cash", 0 ) )
end

catherine.command.Register( {
	command = "charsetcash",
	syntax = "[name] [amount]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success = catherine.cash.Set( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Cash_Notify_Set", pl:Name( ), catherine.cash.GetName( args[ 2 ] ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

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
						catherine.util.NotifyAllLang( "Cash_Notify_Give", pl:Name( ), catherine.cash.GetName( args[ 2 ] ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	command = "chartakecash",
	syntax = "[name] [amount]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success = catherine.cash.Take( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Cash_Notify_Take", pl:Name( ), catherine.cash.GetName( args[ 2 ] ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

if ( SERVER ) then return end

hook.Add( "AddRPInformation", "catherine.cash.AddRPInformation", function( pnl, data )
	data[ #data + 1 ] = LANG( "Cash_UI_HasStr", catherine.cash.GetName( catherine.cash.Get( LocalPlayer( ) ) ) )
end )