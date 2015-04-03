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

catherine.command = catherine.command or { Lists = { } }

function catherine.command.Register( tab )
	tab.syntax = tab.syntax or "[none]"
	catherine.command.Lists[ tab.command ] = tab
end

function catherine.command.FindByCMD( id )
	if ( !id ) then return nil end
	
	for k, v in pairs( catherine.command.Lists ) do
		if ( v.command == id ) then
			return v
		end
	end
	
	return nil
end

function catherine.command.IsCommand( text )
	if ( text:sub( 1, 1 ) != "/" ) then return end
	
	local toArgs = catherine.command.TransferToArgsTab( text )
	local id = toArgs[ 1 ]:sub( 2, #toArgs[ 1 ] )
	
	return catherine.command.Lists[ id ]
end

function catherine.command.TransferToArgsTab( text )
	local skip, args, curstr = 0, { }, ""
	
	for i = 1, #text do
		if ( i <= skip ) then continue end
		local k = text:sub( i, i )

		if ( k == "\"" or k == "'" ) then
			local match = text:sub( i ):match( "%b" .. k .. k )
			if ( match ) then
				curstr = ""
				skip = i + #match
				args[ #args + 1 ] = match:sub( 2, -2 )
			else
				curstr = curstr .. k
			end
		elseif ( k == " " and curstr != "" ) then
			args[ #args + 1 ] = curstr
			curstr = ""
		else
			if ( k == " " and curstr == "" ) then continue end
			curstr = curstr .. k
		end 
	end
	
	if ( curstr != "" ) then
		args[ #args + 1 ] = curstr
	end
	
	return args
end

if ( SERVER ) then
	function catherine.command.Run( pl, id, args )
		if ( !IsValid( pl ) or !id ) then return end
		
		local commandTable = catherine.command.FindByCMD( id )
		if ( !commandTable ) then
			catherine.util.Notify( pl, "Command not found!" )
			return
		end
		if ( commandTable.canRun and commandTable.canRun( pl, id ) == false ) then
			catherine.util.Notify( pl, "You do not have permission!" )
			return
		end
		if ( !commandTable.runFunc ) then return end
		
		cmdTab.runFunc( pl, args )
	end
	
	function catherine.command.RunByText( pl, text )
		if ( !IsValid( pl ) or !text ) then return end
		local args = catherine.command.TransferToArgsTab( text )
		
		table.remove( args, 1 )
		catherine.command.Run( pl, args[ 1 ]:sub( 2, #args[ 1 ] ), args )
	end
	
	netstream.Hook( "catherine.command.Run", function( pl, data )
		catherine.command.Run( pl, data[ 1 ], data[ 2 ] )
	end )
else
	function catherine.command.Run( id, args )
		netstream.Start( "catherine.command.Run", { id, args } )
	end
end