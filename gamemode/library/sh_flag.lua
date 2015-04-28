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

catherine.flag = catherine.flag or { lists = { } }
local META = FindMetaTable( "Player" )

function catherine.flag.Register( id, desc, flagTable )
	flagTable = flagTable or { }
	
	table.Merge( flagTable, {
		id = id,
		desc = desc
	} )
	
	catherine.flag.lists[ id ] = flagTable
end

function catherine.flag.GetAll( )
	return catherine.flag.lists
end

function catherine.flag.FindByID( id )
	return catherine.flag.lists[ id ]
end

function catherine.flag.GetAllToString( )
	local flags = ""
	
	for k, v in pairs( catherine.flag.GetAll( ) ) do
		flags = flags .. k
	end
	
	return flags
end

catherine.flag.Register( "p", "Access to physgun.", {
	onSpawn = function( pl )
		pl:Give( "weapon_physgun" )
	end,
	onGive = function( pl )
		pl:Give( "weapon_physgun" )
	end,
	onTake = function( pl )
		pl:StripWeapon( "weapon_physgun" )
	end
} )
catherine.flag.Register( "t", "Access to toolgun.", {
	onSpawn = function( pl )
		pl:Give( "gmod_tool" )
	end,
	onGive = function( pl )
		pl:Give( "gmod_tool" )
	end,
	onTake = function( pl )
		pl:StripWeapon( "gmod_tool" )
	end
} )
catherine.flag.Register( "e", "Access to prop spawn." )
catherine.flag.Register( "x", "Access to entity spawn." )
catherine.flag.Register( "V", "Access to vehicle spawn." )
catherine.flag.Register( "n", "Access to NPC spawn." )
catherine.flag.Register( "R", "Access to ragdoll spawn." )

if ( SERVER ) then
	function catherine.flag.Give( pl, flagID )
		local ex = string.Explode( "", flagID )
		local flags = catherine.character.GetCharVar( pl, "flags", "" )
		
		for k, v in pairs( ex ) do
			local flagTable = catherine.flag.FindByID( v )
			
			if ( !flagTable ) then
				return false, "Flag_Notify_NotValid", { v }
			end
			
			if ( catherine.flag.Has( pl, v ) ) then
				return false, "Flag_Notify_AlreadyHas", { pl.Name( pl ), v }
			end
			
			flags = flags .. v
			
			if ( flagTable.onGive ) then
				flagTable.onGive( pl )
			end
		end
		
		catherine.character.SetCharVar( pl, "flags", flags )
		netstream.Start( pl, "catherine.flag.BuildHelp" )
		
		return true
	end
	
	function catherine.flag.Take( pl, flagID )
		local ex = string.Explode( "", flagID )
		local flags = catherine.character.GetCharVar( pl, "flags", "" )
		
		for k, v in pairs( ex ) do
			local flagTable = catherine.flag.FindByID( v )
			
			if ( !flagTable ) then
				return false, "Flag_Notify_NotValid", { v }
			end
			
			if ( !catherine.flag.Has( pl, v ) ) then
				return false, "Flag_Notify_HasNot", { pl.Name( pl ), v }
			end
			
			flags = flags:gsub( v, "" )
			
			if ( flagTable.onTake ) then
				flagTable.onTake( pl )
			end
		end
		
		catherine.character.SetCharVar( pl, "flags", result )
		netstream.Start( pl, "catherine.flag.BuildHelp" )
		
		return true
	end
	
	function catherine.flag.Has( pl, id )
		return catherine.character.GetCharVar( pl, "flags", "" ):find( id )
	end
	
	function META:HasFlag( id )
		return catherine.flag.Has( self, id )
	end
	
	function catherine.flag.PlayerSpawnedInCharacter( pl )
		for k, v in pairs( catherine.flag.GetAll( ) ) do
			if ( !catherine.flag.Has( pl, v.id ) or !v.onSpawn ) then continue end
			v.onSpawn( pl )
		end

		if ( !pl.CAT_flag_buildHelp or pl.CAT_flag_buildHelp != pl.GetCharacterID( pl ) ) then
			netstream.Start( pl, "catherine.flag.BuildHelp" )
			pl.CAT_flag_buildHelp = pl.GetCharacterID( pl )
		end
	end
	
	hook.Add( "PlayerSpawnedInCharacter", "catherine.flag.PlayerSpawnedInCharacter", catherine.flag.PlayerSpawnedInCharacter )
else
	local function rebuildFlag( )
		local title_flag = LANG( "Help_Category_Flag" )
		local html = [[<b>]] .. title_flag .. [[</b><br>]]
		
		for k, v in pairs( catherine.flag.GetAll( ) ) do
			local col = catherine.flag.Has( k ) and ( "<font color=\"green\">&#10004;</font>" ) or ( "<font color=\"red\">&#10005;</font>" )

			html = html .. "<p>" .. col .. "<b> " .. k .. "</b><br>" .. catherine.util.StuffLanguage( v.desc ) .. "<br>"
		end

		catherine.help.Register( CAT_HELP_HTML, title_flag, html )
	end
	
	netstream.Hook( "catherine.flag.BuildHelp", function( data )
		rebuildFlag( )
	end )
	
	function catherine.flag.Has( id )
		return catherine.character.GetCharVar( LocalPlayer( ), "flags", "" ):find( id )
	end
	
	function META:HasFlag( id )
		return catherine.flag.Has( id )
	end
	
	function catherine.flag.LanguageChanged( )
		rebuildFlag( )
	end

	hook.Add( "LanguageChanged", "catherine.flag.LanguageChanged", catherine.flag.LanguageChanged )
end