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
		
		catherine.log.Add( CAT_LOG_FLAG_BASIC, pl:Name( ) .. ", " .. pl:SteamName( ) .. " are using /" .. id .. " " .. table.concat( args or { }, " " ), true )
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
	
	function catherine.command.PlayerUserGroupChanged( pl )
		timer.Simple( 1, function( )
			netstream.Start( pl, "catherine.command.BuildHelp" )
		end )
	end
	
	hook.Add( "PlayerSpawnedInCharacter", "catherine.command.PlayerSpawnedInCharacter", catherine.command.PlayerSpawnedInCharacter )
	hook.Add( "PlayerUserGroupChanged", "catherine.command.PlayerUserGroupChanged", catherine.command.PlayerUserGroupChanged )
	
	netstream.Hook( "catherine.command.Run", function( pl, data )
		catherine.command.Run( pl, data[ 1 ], data[ 2 ] )
	end )
else
	local command_htmlValue = [[
	<!DOCTYPE html>
	<html lang="ko">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<title></title>
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css">
		<style>
			@import url(http://fonts.googleapis.com/css?family=Open+Sans);
			body {
				font-family: "Open Sans", "나눔고딕", "NanumGothic", "맑은 고딕", "Malgun Gothic", "serif", "sans-serif"; 
				-webkit-font-smoothing: antialiased;
			}
		</style>
	</head>
	<body>
		<div class="container" style="margin-top:15px;">
		<div class="page-header">
			<h1>%s&nbsp&nbsp<small>%s</small></h1>
		</div>

		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
	]]

	local function rebuildCommand( )
		local title_command = LANG( "Help_Category_Command" )
		local html = Format( command_htmlValue, title_command, LANG( "Help_Desc_Command" ) )
		local pl = LocalPlayer( )
		
		for k, v in pairs( catherine.command.GetAll( ) ) do
			local havePermission = nil
			
			if ( v.canRun and v.canRun( pl, k ) == true ) then
				havePermission = true
			elseif ( !v.canRun ) then
				havePermission = true
			else
				havePermission = false
			end
			
			html = html .. [[
				<div class="]] .. ( havePermission and "panel panel-default" or "panel panel-danger" ) .. [[">
					<div class="panel-heading">
						<h3 class="panel-title">]] .. k .. [[</h3>
					</div>
						<div class="panel-body">]] .. v.syntax .. [[<br>]] .. catherine.util.StuffLanguage( v.desc ) .. [[
						</div>
				</div>
			]]
		end
		
		html = html .. [[</body></html>]]
		
		catherine.help.Register( CAT_HELP_HTML, title_command, html, true )
	end
	
	netstream.Hook( "catherine.command.BuildHelp", function( data )
		rebuildCommand( )
	end )
	
	function catherine.command.Run( id, ... )
		netstream.Start( "catherine.command.Run", { id, { ... } } )
	end
	
	function catherine.command.GetMatchCommands( text )
		local commands = { }
		local sub = 0
		text = text:sub( 2 )
		
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