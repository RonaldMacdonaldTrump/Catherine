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

catherine.plugin = catherine.plugin or { lists = { } }

local plugin_htmlValue = [[
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

local function rebuildPlugin( )
	local title_plugin = LANG( "Help_Category_Plugin" )
	local html = Format( plugin_htmlValue, title_plugin, LANG( "Help_Desc_Plugin" ) )
	
	for k, v in SortedPairs( catherine.plugin.GetAll( ) ) do
		html = html .. [[
			<div class="panel panel-default">
				<div class="panel-heading">
					<h3 class="panel-title">]] .. catherine.util.StuffLanguage( v.name ) .. [[</h3>
				</div>
					<div class="panel-body">]] .. catherine.util.StuffLanguage( v.desc ) .. [[<br>]] .. LANG( "Plugin_Value_Author", v.author ) .. [[
					</div>
			</div>
		]]
	end
	
	html = html .. [[</body></html>]]
	
	catherine.help.Register( CAT_HELP_HTML, title_plugin, html, true )
end

function catherine.plugin.Include( dir )
	local _, folders = file.Find( dir .. "/plugin/*", "LUA" )

	for k, v in pairs( folders ) do
		PLUGIN = catherine.plugin.Get( v ) or { uniqueID = v, FolderName = dir .. "/plugin/" .. v }
		
		local pluginDir = PLUGIN.FolderName
		
		if ( file.Exists( pluginDir .. "/sh_plugin.lua", "LUA" ) ) then
			catherine.util.Include( pluginDir .. "/sh_plugin.lua" )
			catherine.item.Include( pluginDir )
			
			catherine.plugin.IncludeEntities( pluginDir )
			catherine.plugin.IncludeWeapons( pluginDir )
			catherine.plugin.IncludeEffects( pluginDir )
			catherine.plugin.IncludeTools( pluginDir )
			
			for k1, v1 in pairs( file.Find( pluginDir .. "/derma/*.lua", "LUA" ) ) do
				catherine.util.Include( pluginDir .. "/derma/" .. v1 )
			end
			
			for k1, v1 in pairs( file.Find( pluginDir .. "/attribute/*.lua", "LUA" ) ) do
				catherine.util.Include( pluginDir .. "/attribute/" .. v1, "SHARED" )
			end
			
			for k1, v1 in pairs( file.Find( pluginDir .. "/library/*.lua", "LUA" ) ) do
				catherine.util.Include( pluginDir .. "/library/" .. v1 )
			end
			
			for k1, v1 in pairs( file.Find( pluginDir .. "/class/*.lua", "LUA" ) ) do
				catherine.util.Include( pluginDir .. "/class/" .. v1, "SHARED" )
			end
			
			for k1, v1 in pairs( file.Find( pluginDir .. "/faction/*.lua", "LUA" ) ) do
				catherine.util.Include( pluginDir .. "/faction/" .. v1, "SHARED" )
			end
			
			for k, v in pairs( PLUGIN ) do
				if ( type( v ) == "function" ) then
					CAT_HOOK_PLUGIN_CACHES[ k ] = CAT_HOOK_PLUGIN_CACHES[ k ] or { }
					CAT_HOOK_PLUGIN_CACHES[ k ][ PLUGIN ] = v
				end
			end
			
			catherine.plugin.lists[ v ] = PLUGIN
		else
			MsgC( Color( 255, 0, 0 ), "[CAT ERROR] SORRY, The plugin <" .. v .. "> are do not have files named sh_plugin.lua, failed to loading it ...\n" )
		end
		
		PLUGIN = nil
	end
	
	if ( CLIENT ) then
		rebuildPlugin( )
	end
end

function catherine.plugin.IncludeEntities( dir )
	for k, v in pairs( file.Find( dir .. "/entities/entities/*.lua", "LUA" ) ) do
		ENT = { Type = "anim", Base = "base_gmodentity", ClassName = v:sub( 1, #v - 4 ) }
		
		catherine.util.Include( dir .. "/entities/entities/" .. v, "SHARED" )
		scripted_ents.Register( ENT, ENT.ClassName )
		
		ENT = nil
	end
end

function catherine.plugin.IncludeWeapons( dir )
	for k, v in pairs( file.Find( dir .. "/entities/weapons/*.lua", "LUA" ) ) do
		SWEP = { Base = "weapon_base", Primary = { }, Secondary = { }, ClassName = v:sub( 1, #v - 4 ) }
		
		catherine.util.Include( dir .. "/entities/weapons/" .. v, "SHARED" )
		weapons.Register( SWEP, SWEP.ClassName )
		
		SWEP = nil
	end
end

function catherine.plugin.IncludeEffects( dir )
	for k, v in pairs( file.Find( dir .. "/entities/effects/*.lua", "LUA" ) ) do
		EFFECT = { ClassName = v:sub( 1, #v - 4 ) }
		
		catherine.util.Include( dir .. "/entities/effects/" .. v, "SHARED" )
		effects.Register( EFFECT, EFFECT.ClassName )
		
		EFFECT = nil
	end
end

function catherine.plugin.IncludeTools( dir )
	for k, v in pairs( file.Find( dir .. "/tools/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/tools/" .. v, "SHARED" )
	end
end

function catherine.plugin.GetAll( )
	return catherine.plugin.lists
end

function catherine.plugin.Get( id )
	return catherine.plugin.lists[ id ]
end

function catherine.plugin.FrameworkInitialized( )
	local toolGun = weapons.GetStored( "gmod_tool" )

	for k, v in pairs( catherine.tool.GetAll( ) ) do
		toolGun.Tool[ v.Mode ] = v
	end
end

hook.Add( "FrameworkInitialized", "catherine.plugin.FrameworkInitialized", catherine.plugin.FrameworkInitialized )

if ( SERVER ) then return end

function catherine.plugin.LanguageChanged( )
	rebuildPlugin( )
end

function catherine.plugin.InitPostEntity( )
	if ( IsValid( catherine.pl ) ) then
		rebuildPlugin( )
	end
end

hook.Add( "LanguageChanged", "catherine.plugin.LanguageChanged", catherine.plugin.LanguageChanged )
hook.Add( "InitPostEntity", "catherine.plugin.InitPostEntity", catherine.plugin.InitPostEntity )