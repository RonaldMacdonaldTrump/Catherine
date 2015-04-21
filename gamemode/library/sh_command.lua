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
	tab.syntax = tab.syntax or "[None]"
	catherine.command.Lists[ tab.command ] = tab
end

function catherine.command.GetAll( )
	return catherine.command.Lists
end

function catherine.command.FindByCMD( id )
	return catherine.command.Lists[ id ]
end

function catherine.command.IsCommand( text )
	if ( text:sub( 1, 1 ) != "/" ) then return end
	local toArgs = catherine.command.TransferToArgsTab( text )
	local id = toArgs[ 1 ]:sub( 2, #toArgs[ 1 ] )
	
	return catherine.command.Lists[ id ]
end

function catherine.command.TransferToArgsTab( text )
	local skip = 0
	local args = { }
	local curstr = ""
	
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
		local commandTable = catherine.command.FindByCMD( id )
		
		if ( !commandTable ) then
			catherine.util.NotifyLang( pl, "Command_Notify_NotFound" )
			return
		end
		
		if ( commandTable.canRun and commandTable.canRun( pl, id ) == false ) then
			catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
			return
		end
		
		if ( !commandTable.runFunc ) then
			return
		end
		
		commandTable.runFunc( pl, args )
	end
	
	function catherine.command.RunByText( pl, text )
		local args = catherine.command.TransferToArgsTab( text )
		local id = args[ 1 ]:sub( 2, #args[ 1 ] )
		
		table.remove( args, 1 )
		catherine.command.Run( pl, id, args )
	end
	
	function catherine.command.PlayerSpawnedInCharacter( pl )
		if ( !pl.CAT_command_buildHelp or pl.CAT_command_buildHelp != pl:GetCharacterID( ) ) then
			netstream.Start( pl, "catherine.command.BuildHelp" )
			pl.CAT_command_buildHelp = pl:GetCharacterID( )
		end
	end
	
	hook.Add( "PlayerSpawnedInCharacter", "catherine.command.PlayerSpawnedInCharacter", catherine.command.PlayerSpawnedInCharacter )
	
	netstream.Hook( "catherine.command.Run", function( pl, data )
		catherine.command.Run( pl, data[ 1 ], data[ 2 ] )
	end )
else
	netstream.Hook( "catherine.command.BuildHelp", function( data )
		local html = [[<b>Commands</b><br>]]
	
		for k, v in pairs( catherine.command.GetAll( ) ) do
			if ( v.canRun and v.canRun( LocalPlayer( ), v.command ) == false ) then continue end
			html = html .. "<p><b>&#10022; " .. v.command .. "</b><br>" .. v.syntax .. "<br>"
		end
		
		catherine.help.Register( CAT_HELP_HTML, "Commands", html )
	end )
	
	function catherine.command.Run( id, args )
		netstream.Start( "catherine.command.Run", { id, args } )
	end
end