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

catherine.command = catherine.command or { lists = { } }

function catherine.command.Register( commandTable )
	commandTable.syntax = commandTable.syntax or "[None]"
	commandTable.desc = commandTable.desc or "^Command_DefDesc"
	catherine.command.lists[ commandTable.command ] = commandTable
end

function catherine.command.GetAll( )
	return catherine.command.lists
end

function catherine.command.FindByCMD( id )
	return catherine.command.lists[ id ]
end

function catherine.command.IsCommand( text )
	if ( text:sub( 1, 1 ) != "/" ) then return end
	local toArgs = catherine.command.TransferToArgsTab( text )
	local id = toArgs[ 1 ]:sub( 2, #toArgs[ 1 ] )
	
	return catherine.command.lists[ id ]
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
			
			curstr = match and ( "" ) or ( curstr .. k )
			skip = i + #match
			args[ #args + 1 ] = match:sub( 2, -2 )
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
	local function rebuildCommand( )
		local title_command = LANG( "Help_Category_Command" )
		local html = [[<b>]] .. title_command .. [[</b><br>]]
		local pl = LocalPlayer( )
		
		for k, v in pairs( catherine.command.GetAll( ) ) do
			if ( v.canRun and v.canRun( pl, k ) == false ) then continue end
			
			html = html .. "<p><b>&#10022; " .. k .. "</b><br>" .. v.syntax .. "<br>" .. catherine.util.StuffLanguage( v.desc ) .. "<br>"
		end
		
		catherine.help.Register( CAT_HELP_HTML, title_command, html )
	end
	
	netstream.Hook( "catherine.command.BuildHelp", function( data )
		rebuildCommand( )
	end )
	
	function catherine.command.Run( id, args )
		netstream.Start( "catherine.command.Run", { id, args } )
	end
	
	function catherine.command.GetMatchCommands( text )
		local commands = { }
		local sub = 0
		text = text.sub( text, 2 )
		
		for k, v in pairs( catherine.command.GetAll( ) ) do
			if ( catherine.util.CheckStringMatch( k, text ) ) then
				commands[ #commands + 1 ] = v
				sub = #text
			end
		end
		
		return commands, sub
	end
	
	function catherine.command.LanguageChanged( )
		rebuildCommand( )
	end

	hook.Add( "LanguageChanged", "catherine.command.LanguageChanged", catherine.command.LanguageChanged )
	
	rebuildCommand( )
end