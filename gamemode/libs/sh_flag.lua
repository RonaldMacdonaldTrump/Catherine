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

catherine.flag = catherine.flag or { }
catherine.flag.Lists = { }
local META = FindMetaTable( "Player" )

function catherine.flag.Register( id, desc, flagTable )
	if ( !flagTable ) then flagTable = { } end
	table.Merge( flagTable, { id = id, desc = desc } )
	catherine.flag.Lists[ #catherine.flag.Lists + 1 ] = flagTable
end

function catherine.flag.GetAll( )
	return catherine.flag.Lists
end

function catherine.flag.FindByID( id )
	if ( !id ) then return end
	for k, v in pairs( catherine.flag.GetAll( ) ) do
		if ( v.id == id ) then
			return v
		end
	end
end

function catherine.flag.GetAllToString( )
	local flags = ""
	for k, v in pairs( catherine.flag.GetAll( ) ) do
		flags = flags .. v.id
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

if ( SERVER ) then
	function catherine.flag.Give( pl, ids )
		if ( !IsValid( pl ) or !ids ) then return end
		local ex = string.Explode( "", ids )
		local result = catherine.character.GetCharacterVar( pl, "flags", "" )
		
		for k, v in pairs( ex ) do
			local flagTable = catherine.flag.FindByID( v )
			if ( !flagTable ) then
				return false, "Flag_Notify_NotValid", { v }
			end
			if ( catherine.flag.Has( pl, v ) ) then
				return false, "Flag_Notify_AlreadyHas", { pl:Name( ), v }
			end
			
			result = result .. v
			if ( flagTable.onGive ) then
				flagTable.onGive( pl )
			end
		end
		
		catherine.character.SetCharacterVar( pl, "flags", result )
		return true, nil, ids
	end
	
	function catherine.flag.Take( pl, ids )
		if ( !IsValid( pl ) or !ids ) then return end
		local ex = string.Explode( "", ids )
		local result = catherine.character.GetCharacterVar( pl, "flags", "" )
		
		for k, v in pairs( ex ) do
			local flagTable = catherine.flag.FindByID( v )
			if ( !flagTable ) then
				return false, "Flag_Notify_NotValid", { v }
			end
			if ( !catherine.flag.Has( pl, v ) ) then
				return false, "Flag_Notify_HasNot", { pl:Name( ), v }
			end
			
			result = result:gsub( v, "" )
			if ( flagTable.onTake ) then
				flagTable.onTake( pl )
			end
		end
		
		catherine.character.SetCharacterVar( pl, "flags", result )
		return true, nil, ids
	end
	
	function catherine.flag.Has( pl, id )
		if ( !IsValid( pl ) or !id ) then return end
		local flagData = catherine.character.GetCharacterVar( pl, "flags", "" )
		return flagData:find( id )
	end
	
	function META:HasFlag( id )
		return catherine.flag.Has( self, id )
	end
	
	function catherine.flag.PlayerSpawnedInCharacter( pl )
		for k, v in pairs( catherine.flag.GetAll( ) ) do
			if ( !catherine.flag.Has( pl, v.id ) or !v.onSpawn ) then continue end
			v.onSpawn( pl )
		end
	end
	
	hook.Add( "PlayerSpawnedInCharacter", "catherine.flag.PlayerSpawnedInCharacter", catherine.flag.PlayerSpawnedInCharacter )
else
	function catherine.flag.Has( id )
		if ( !id ) then return end
		local flagData = catherine.character.GetCharacterVar( LocalPlayer( ), "flags", "" )
		return flagData:find( id )
	end
	
	function META:HasFlag( id )
		return catherine.flag.Has( id )
	end
	
	local html = [[<b>Flags</b><br>]]
		
	for k, v in pairs( catherine.flag.GetAll( ) ) do
		local col = "<font color=\"red\">&#10005;</font>"
		if ( catherine.flag.Has( v.id ) ) then
			col = "<font color=\"green\">&#10004;</font>"
		end
		
		print("asdds")
		
		html = html .. "<p>" .. col .. "<b> " .. v.id .. "</b><br>" .. v.desc .. "<br>"
	end

	catherine.help.Register( CAT_HELP_HTML, "Flags", html )
end

catherine.command.Register( {
	command = "flaggive",
	syntax = "[name] [flag name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, langKey, par = catherine.flag.Give( target, args[ 2 ] )
					if ( success ) then
						catherine.util.NotifyAllLang( "Flag_Notify_Give", pl:Name( ), par, target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par ) )
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
	command = "flagtake",
	syntax = "[name] [flag name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, langKey, par = catherine.flag.Take( target, args[ 2 ] )
					if ( success ) then
						catherine.util.NotifyAllLang( "Flag_Notify_Take", pl:Name( ), par, target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par ) )
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