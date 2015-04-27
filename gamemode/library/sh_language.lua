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

catherine.language = catherine.language or { lists = { } }

function catherine.language.Register( languageTable )
	catherine.language.lists[ languageTable.uniqueID ] = languageTable
end

function catherine.language.New( uniqueID )
	return { name = "Unknown", data = { }, uniqueID = uniqueID }
end

function catherine.language.GetAll( )
	return catherine.language.lists
end

function catherine.language.FindByID( uniqueID )
	return catherine.language.lists[ uniqueID ]
end

function catherine.language.Include( dir )
	for k, v in pairs( file.Find( dir .. "/language/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/language/" .. v, "SHARED" )
	end
end

function catherine.language.Merge( uniqueID, data )
	local languageTable = catherine.language.FindByID( uniqueID )
	if ( !languageTable ) then return end
	
	languageTable.data = table.Merge( languageTable.data, data )
end

catherine.language.Include( catherine.FolderName .. "/gamemode" )

if ( SERVER ) then
	function LANG( pl, key, ... )
		local languageTable = catherine.language.lists[ pl.GetInfo( pl, "cat_convar_language" ) ] or catherine.language.lists[ "english" ]
		if ( !languageTable or !languageTable.data or !languageTable.data[ key ] ) then return key .. "-Error" end
		
		return Format( languageTable.data[ key ], ... )
	end
else
	CAT_CONVAR_LANGUAGE = CreateClientConVar( "cat_convar_language", catherine.configs.defaultLanguage, true, true )

	function LANG( key, ... )
		local languageTable = catherine.language.lists[ CAT_CONVAR_LANGUAGE.GetString( CAT_CONVAR_LANGUAGE ) ] or catherine.language.lists[ "english" ]
		if ( !languageTable or !languageTable.data or !languageTable.data[ key ] ) then return key .. "-Error" end
		
		return Format( languageTable.data[ key ], ... )
	end
end