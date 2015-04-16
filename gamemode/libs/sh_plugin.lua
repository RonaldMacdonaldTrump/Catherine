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

catherine.plugin = catherine.plugin or { Lists = { } }

function catherine.plugin.LoadAll( dir )
	local _, folders = file.Find( dir .. "/gamemode/plugins/*", "LUA" )

	for k, v in pairs( folders ) do
		PLUGIN = catherine.plugin.Get( v ) or { }
		
		local Pdir = dir .. "/gamemode/plugins/" .. v
		
		if ( file.Exists( Pdir .. "/sh_plugin.lua", "LUA" ) ) then
			catherine.util.Include( Pdir .. "/sh_plugin.lua" )
			catherine.item.Include( Pdir )
			
			catherine.plugin.IncludeEntities( Pdir )
			
			for k1, v1 in pairs( file.Find( Pdir .. "/derma/*.lua", "LUA" ) ) do
				catherine.util.Include( Pdir .. "/derma/" .. v1 )
			end
			
			for k1, v1 in pairs( file.Find( Pdir .. "/libs/*.lua", "LUA" ) ) do
				catherine.util.Include( Pdir .. "/libs/" .. v1 )
			end
			
			catherine.plugin.Lists[ v ] = PLUGIN
		end
		
		PLUGIN = nil
	end
	
	if ( CLIENT ) then
		local html = [[<b>Plugins</b><br>]]
			
		for k, v in pairs( catherine.plugin.GetAll( ) ) do
			html = html .. "<p><b>&#10022; " .. v.name .. "</b><br>" .. v.desc .. "<br>By " .. v.author .. "<br>"
		end
			
		catherine.help.Register( CAT_HELP_HTML, "Plugins", html )
	end
end

function catherine.plugin.IncludeEntities( dir )
	for k, v in pairs( file.Find( dir .. "/entities/entities/*.lua", "LUA" ) ) do
		ENT = { Type = "anim", ClassName = v:sub( 1, #v - 4 ) }
		
		catherine.util.Include( dir .. "/entities/entities/" .. v, "SHARED" )
		scripted_ents.Register( ENT, ENT.ClassName )
		
		ENT = nil
	end
end

function catherine.plugin.Get( id )
	return catherine.plugin.Lists[ id ]
end

function catherine.plugin.GetAll( )
	return catherine.plugin.Lists
end