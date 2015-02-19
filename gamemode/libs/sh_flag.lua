catherine.flag = catherine.flag or { }
catherine.flag.Lists = { }
local META = FindMetaTable( "Player" )

function catherine.flag.Register( code, desc )
	catherine.flag.Lists[ #catherine.flag.Lists + 1 ] = { code = code, desc = desc }
end

function catherine.flag.FindByCode( code )
	if ( !code ) then return nil end
	for k, v in pairs( catherine.flag.Lists ) do
		if ( v.code == code ) then
			return v
		end
	end
	
	return nil
end

function catherine.flag.Has( pl, code )
	local flagData = catherine.character.GetCharData( pl, "flags", { } )
	return table.HasValue( flagData, code )
end

if ( SERVER ) then
	function catherine.flag.Give( pl, code )
		if ( !IsValid( pl ) ) then return end
		local flagTab = catherine.flag.FindByCode( code )
		if ( !flagTab or catherine.flag.Has( pl, code ) ) then return end
		local flagData = table.Copy( catherine.character.GetCharData( pl, "flags", { } ) )
		flagData[ #flagData + 1 ] = code
		catherine.character.SetCharData( pl, "flags", flagData )
	end
	
	function catherine.flag.Take( pl, code )
		if ( !IsValid( pl ) ) then return end
		local flagTab = catherine.flag.FindByCode( code )
		if ( !flagTab or !catherine.flag.Has( pl, code ) ) then return end
		local flagData = table.Copy( catherine.character.GetCharData( pl, "flags", { } ) )
		for k, v in pairs( flagData ) do
			if ( v == code ) then
				table.remove( flagData, k )
			end
		end
		catherine.character.SetCharData( pl, "flags", flagData )
	end
	
	function META:GiveFlag( code )
		catherine.flag.Give( self, code )
	end
	
	function META:TakeFlag( code )
		catherine.flag.Take( self, code )
	end
end

function META:HasFlag( code )
	return catherine.flag.Has( self, code )
end