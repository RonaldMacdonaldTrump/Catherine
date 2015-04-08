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

catherine.faction = catherine.faction or { }
catherine.faction.Lists = { }

function catherine.faction.Register( factionTable )
	if ( !factionTable or !factionTable.index ) then
		catherine.util.ErrorPrint( "Faction register error, can't found faction table!" )
		return
	end
	catherine.faction.Lists[ factionTable.index ] = factionTable
	team.SetUp( factionTable.index, factionTable.name, factionTable.color )
	return factionTable.index
end

function catherine.faction.New( uniqueID )
	return { uniqueID = uniqueID, index = table.Count( catherine.faction.Lists ) + 1 }
end

function catherine.faction.GetPlayerUsableFaction( pl )
	if ( !IsValid( pl ) ) then return { } end
	local factions = { }
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.isWhitelist and ( SERVER and catherine.faction.HasWhiteList( pl, v.uniqueID ) or catherine.faction.HasWhiteList( v.uniqueID ) ) == false ) then continue end
		factions[ #factions + 1 ] = v
	end
	return factions
end

function catherine.faction.GetAll( )
	return catherine.faction.Lists
end

function catherine.faction.FindByName( name )
	if ( !name ) then return nil end
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.name == name ) then
			return v
		end
	end
	
	return nil
end

function catherine.faction.FindByID( id )
	if ( !id ) then return nil end
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
	
	return nil
end

function catherine.faction.FindByIndex( index )
	if ( !index ) then return nil end
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.index == index ) then
			return v
		end
	end
	
	return nil
end

function catherine.faction.Include( dir )
	if ( !dir ) then return end
	for k, v in pairs( file.Find( dir .. "/factions/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/factions/" .. v, "SHARED" )
	end
end

if ( SERVER ) then
	function catherine.faction.AddWhiteList( pl, id )
		if ( !IsValid( pl ) or !id ) then return end
		
		local factionTable = catherine.faction.FindByID( id )
		if ( !factionTable or !factionTable.isWhitelist or catherine.faction.HasWhiteList( pl, id ) ) then
			return false, ""
		end
		
		local whiteLists = catherine.catData.Get( pl, "whitelists", { } )
		whiteLists[ #whiteLists + 1 ] = id
		
		catherine.catData.Set( pl, "whitelists", whiteLists, false, true )
		return true
	end
	
	function catherine.faction.RemoveWhiteList( pl, id )
		if ( !IsValid( pl ) or !id ) then return false, "player or faction id is not valid!" end
		local factionTable = catherine.faction.FindByID( id )
		if ( !factionTable or !factionTable.isWhitelist ) then return false, "faction is not whitelist!" end
		local whiteLists = catherine.catData.Get( pl, "whitelists", { } )
		table.RemoveByValue( whiteLists, id )
		catherine.catData.Set( pl, "whitelists", whiteLists, false, true )
		return true
	end

	function catherine.faction.HasWhiteList( pl, id )
		local factionTable = catherine.faction.FindByID( id )
		if ( !factionTable or !factionTable.isWhitelist ) then return false end
		local whiteLists = catherine.catData.Get( pl, "whitelists", { } )
		return table.HasValue( whiteLists, id )
	end
	
	function catherine.faction.PlayerFirstSpawned( pl )
		local factionTable = catherine.faction.FindByIndex( pl:Team( ) )
		if ( !factionTable or !factionTable.PlayerFirstSpawned ) then return end
		factionTable:PlayerFirstSpawned( pl )
	end
	
	hook.Add( "PlayerFirstSpawned", "catherine.faction.PlayerFirstSpawned", catherine.faction.PlayerFirstSpawned )
else
	function catherine.faction.HasWhiteList( id )
		if ( !id ) then return false end
		local factionTable = catherine.faction.FindByID( id )
		if ( !factionTable or !factionTable.isWhitelist ) then return false end
		local whiteLists = catherine.catData.Get( "whitelists", { } )
		return table.HasValue( whiteLists, id )
	end
end

local META = FindMetaTable( "Player" )

function META:HasWhiteList( id )
	if ( SERVER ) then
		return catherine.faction.HasWhiteList( self, id )
	else
		return catherine.faction.HasWhiteList( id )
	end
end

catherine.command.Register( {
	command = "plygivewhitelist",
	syntax = "[Name] [Faction Name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, reason = catherine.faction.AddWhiteList( target, args[ 2 ] )
					if ( success ) then
						catherine.util.Notify( pl, catherine.language.GetValue( pl, "Faction_AddMessage01" ) )
					else
						catherine.util.Notify( pl, reason or catherine.language.GetValue( pl, "UnknownError" ) )
					end
				else
					catherine.util.Notify( pl, catherine.language.GetValue( pl, "UnknownPlayerError" ) )
				end
			else
				catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 2 ) )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
		end
	end
} )

catherine.command.Register( {
	command = "plytakewhitelist",
	syntax = "[Name] [Faction Name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, reason = catherine.faction.RemoveWhiteList( target, args[ 2 ] )
					if ( success ) then
						catherine.util.Notify( pl, catherine.language.GetValue( pl, "Faction_RemoveMessage01" ) )
					else
						catherine.util.Notify( pl, reason or catherine.language.GetValue( pl, "UnknownError" ) )
					end
				else
					catherine.util.Notify( pl, catherine.language.GetValue( pl, "UnknownPlayerError" ) )
				end
			else
				catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 2 ) )
			end
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
		end
	end
} )

