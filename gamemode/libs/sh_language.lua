catherine.language = catherine.language or { }
catherine.language.Lists = { }

function catherine.language.Register( languageTable )
	if ( !languageTable ) then
		catherine.util.ErrorPrint( "Language register error, can't found language table!" )
		return
	end
	catherine.language.Lists[ languageTable.uniqueID ] = languageTable
end

function catherine.language.New( uniqueID )
	if ( !uniqueID ) then
		catherine.util.ErrorPrint( "Language create error, can't found unique ID!" )
		return
	end
	return { name = "Unknown", data = { }, uniqueID = uniqueID }
end

function catherine.language.GetAll( )
	return catherine.language.Lists
end

function catherine.language.FindByID( id )
	if ( !id ) then return nil end
	for k, v in pairs( catherine.language.GetAll( ) ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
	
	return nil
end

function catherine.language.Include( dir )
	if ( !dir ) then return end
	for k, v in pairs( file.Find( dir .. "/languages/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/languages/" .. v, "SHARED" )
	end
end

function catherine.language.Merge( uniqueID, data )
	if ( !uniqueID or !data ) then return end
	local languageTable = catherine.language.FindByID( uniqueID )
	if ( !languageTable ) then return end
	languageTable.data = table.Merge( languageTable.data, data )
end

catherine.language.Include( catherine.FolderName .. "/gamemode" )

if ( SERVER ) then
	function catherine.language.GetValue( pl, key, ... )
		local uniqueID = "english"
		if ( IsValid( pl ) ) then uniqueID = pl:GetInfo( "cat_convar_language" ) end
		local lists = catherine.language.Lists[ uniqueID ]
		if ( !lists or !lists.data ) then return "Error" end
		return string.format( lists.data[ key ], ... )
	end
else
	CAT_CONVAR_LANGUAGE = CreateClientConVar( "cat_convar_language", "english", true, true )
	
	function catherine.language.GetValue( key, ... )
		local uniqueID = CAT_CONVAR_LANGUAGE:GetString( )
		local lists = catherine.language.Lists[ uniqueID ]
		if ( !lists or !lists.data ) then return "Error" end
		return string.format( lists.data[ key ], ... )
	end
end