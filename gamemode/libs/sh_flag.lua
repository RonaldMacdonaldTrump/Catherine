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
	if ( !id ) then return nil end
	for k, v in pairs( catherine.flag.GetAll( ) ) do
		if ( v.id == id ) then
			return v
		end
	end
	return nil
end

function catherine.flag.Has( pl, id )
	local flagData = catherine.character.GetCharacterVar( pl, "flags", "" )
	return table.HasValue( flagData, id )
end

function catherine.flag.GetAllToString( )
	local flags = ""
	for k, v in pairs( catherine.flag.GetAll( ) ) do
		flags = flags .. v.id
	end
	return flags
end

function META:HasFlag( id )
	return catherine.flag.Has( self, id )
end

if ( SERVER ) then
	function catherine.flag.Give( pl, ids )
		if ( !IsValid( pl ) or !ids ) then return end
		local ex = string.Explode( "", ids )
		local result = catherine.character.GetCharacterVar( pl, "flags", "" )
		for k, v in pairs( ex ) do
			if ( catherine.flag.Has( pl, v.id ) ) then
				return false, pl:Name( ) .. " alreay has " .. v .. " flag!"
			end
			
			result = result .. v
		end
	end

	function catherine.flag.Take( pl, ids )
	
	end
	
	function catherine.flag.PlayerSpawnedInCharacter( pl )
		for k, v in pairs( catherine.flag.GetAll( ) ) do
			//if ( !catherine.flag.Has( pl, v.id ) or !v.onSpawn ) then continue end
			//v.onSpawn( pl )
		end
	end
	
	hook.Add( "PlayerSpawnedInCharacter", "catherine.flag.PlayerSpawnedInCharacter", catherine.flag.PlayerSpawnedInCharacter )
else

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