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
	
	return classTable.index
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

function catherine.class.FindByIndex( index )
	for k, v in pairs( catherine.class.GetAll( ) ) do
		if ( v.index == index ) then
			return v
		end
	end
end

function catherine.class.CanJoin( pl, index )
	local classTable = catherine.class.FindByIndex( index )
	
	if ( !classTable ) then
		return false, "Class error"
	end

	if ( pl:Team( ) != classTable.faction ) then
		return false, "Team error"
	end

	if ( catherine.character.GetCharVar( pl, "class", "" ) == index ) then
		return false, "Same class"
	end
	
	if ( classTable.limit and ( #catherine.class.GetPlayers( index ) >= classTable.limit ) ) then
		return false, "Hit limit"
	end
	
	return classTable:onCanJoin( pl )
end

function catherine.class.GetPlayers( index )
	local players = { }
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( catherine.character.GetCharVar( v, "class", "" ) != index ) then continue end
		players[ #players + 1 ] = v
	end

	return players
end

function catherine.class.Include( dir )
	for k, v in pairs( file.Find( dir .. "/class/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/class/" .. v, "SHARED" )
	end
end

if ( SERVER ) then
	function catherine.class.Set( pl, index )
		if ( !index ) then
			local defaultClass = catherine.class.GetDefaultClass( pl:Team( ) )
			if ( !defaultClass ) then return end
			local defaultModel = catherine.character.GetCharVar( pl, "originalModel" )
			if ( !defaultModel ) then return end
			
			catherine.character.SetCharVar( pl, "class", defaultClass.index )
			pl:SetModel( defaultModel )
			return
		end
		
		local success, reason = catherine.class.CanJoin( pl, index )

		if ( !success ) then
			catherine.util.NotifyLang( pl, reason )
			return
		end
		
		local classTable = catherine.class.FindByIndex( index )
		
		if ( classTable.model ) then
			if ( !catherine.character.GetCharVar( pl, "originalModel" ) ) then
				catherine.character.SetCharVar( pl, "originalModel", pl:GetModel( ) )
			end
			
			pl:SetModel( ( type( classTable.model ) == "table" and table.Random( classTable.model ) or classTable.model ) )
		end
		
		catherine.character.SetCharVar( pl, "class", index )
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
else
	function catherine.class.GetJoinable( )
		local classes = { }
		
		for k, v in pairs( catherine.class.GetAll( ) ) do
			if ( v.faction == LocalPlayer( ):Team( ) and LocalPlayer( ):Class( ) != v.index ) then
				classes[ #classes + 1 ] = v
			end
		end
		
		return classes
	end
	
	function catherine.class.CharacterCharVarChanged( )
		if ( IsValid( catherine.vgui.class ) ) then
			catherine.vgui.class:InitializeClasses( )
		end
	end
	
	hook.Add( "CharacterCharVarChanged", "catherine.class.CharacterCharVarChanged", catherine.class.CharacterCharVarChanged )
end

local META = FindMetaTable( "Player" )

function META:Class( )
	return catherine.character.GetCharVar( self, "class", nil )
end

function META:ClassName( )
	local classTable = catherine.class.FindByIndex( self:Class( ) )
	
	return classTable and classTable.name or nil
end