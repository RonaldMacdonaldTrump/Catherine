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

catherine.class = catherine.class or { }
catherine.class.Lists = { }

function catherine.class.Register( classTable )
	if ( !classTable or !classTable.index ) then
		catherine.util.ErrorPrint( "Class register error, can't found class table!" )
		return
	end
	
	if ( !classTable.onCanJoin ) then
		function classTable:onCanJoin( pl )
			return true
		end
	end
	catherine.class.Lists[ classTable.index ] = classTable
end

function catherine.class.New( uniqueID )
	return { uniqueID = uniqueID, index = table.Count( catherine.class.Lists ) + 1 }
end

function catherine.class.GetAll( )
	return catherine.class.Lists
end

function catherine.class.FindByID( id )
	for k, v in pairs( catherine.class.GetAll( ) ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
end

function catherine.class.CanJoin( pl, uniqueID )
	if ( !IsValid( pl ) or !uniqueID ) then return false end
	
	local classTable = catherine.class.FindByID( uniqueID )
	
	if ( !classTable ) then
		return false, "Class error"
	end

	if ( pl:Team( ) != classTable.faction ) then
		return false, "Team error"
	end

	if ( catherine.character.GetCharVar( pl, "class", "" ) == uniqueID ) then
		return false, "Same class"
	end
	
	if ( classTable.limit and ( #catherine.class.GetPlayers( uniqueID ) >= classTable.limit ) ) then
		return false, "Hit limit"
	end
	
	return classTable:onCanJoin( pl )
end

function catherine.class.GetPlayers( uniqueID )
	local players = { }
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( catherine.character.GetCharVar( v, "class", "" ) != uniqueID ) then continue end
		players[ #players + 1 ] = v
	end

	return players
end

function catherine.class.Include( dir )
	for k, v in pairs( file.Find( dir .. "/classes/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/classes/" .. v, "SHARED" )
	end
end

if ( SERVER ) then
	function catherine.class.Set( pl, uniqueID )
		if ( !uniqueID ) then
			local defaultClass = catherine.class.GetDefaultClass( pl:Team( ) )
			if ( !defaultClass ) then return end
			local defaultModel = catherine.character.GetCharVar( pl, "originalModel" )
			if ( !defaultModel ) then return end
			
			catherine.character.SetCharVar( pl, "class", defaultClass.uniqueID )
			pl:SetModel( defaultModel )
			return
		end
		
		local success, reason = catherine.class.CanJoin( pl, uniqueID )

		if ( !success ) then
			catherine.util.NotifyLang( pl, reason )
			return
		end
		
		local classTable = catherine.class.FindByID( uniqueID )
		
		if ( classTable.model ) then
			if ( !catherine.character.GetCharVar( pl, "originalModel" ) ) then
				catherine.character.SetCharVar( pl, "originalModel", pl:GetModel( ) )
			end
			
			pl:SetModel( ( type( classTable.model ) == "table" and table.Random( classTable.model ) or classTable.model ) )
		end
		
		catherine.character.SetCharVar( pl, "class", uniqueID )
	end

	function catherine.class.GetDefaultClass( factionID )
		for k, v in pairs( catherine.class.GetAll( ) ) do
			if ( v.faction == factionID and v.isDefault ) then
				return v
			end
		end
	end

	netstream.Hook( "catherine.class.Set", function( pl, data )
		catherine.class.Set( pl, data )
	end )
end

local META = FindMetaTable( "Player" )

function META:Class( )
	return catherine.character.GetCharVar( self, "class", nil )
end

function META:ClassName( )
	return catherine.class.FindByID( self:Class( ) ) and catherine.class.FindByID( self:Class( ) ).name or nil
end