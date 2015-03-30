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
	function catherine.language.SyncByGMod( pl )
		--[[ // have bug ^-^;
		if ( !IsValid( pl ) ) then return end
		local languageConfig = pl:GetInfo( "gmod_language" )
		pl:ConCommand( "cat_convar_language " .. ( catherine.language.Lists[ languageConfig ] and languageConfig or "english" ) )
		--]]
	end
	

	function catherine.language.GetLists( pl )
		if ( !IsValid( pl ) ) then return { data = { } } end
		local uniqueID = pl:GetInfo( "cat_convar_language" )
		return catherine.language.Lists[ uniqueID ] or catherine.language.Lists[ "english" ] or { data = { } }
	end

	function catherine.language.GetValue( pl, key, ... )
		if ( !IsValid( pl ) or !key ) then return end
		local languageTable = catherine.language.GetLists( pl )
		return string.format( languageTable.data[ key ] or "LanguageError01", ... ) or "Language Error"
	end
else
	CAT_CONVAR_LANGUAGE = CreateClientConVar( "cat_convar_language", "english", true, true )
	
	function catherine.language.GetLists( )
		local uniqueID = CAT_CONVAR_LANGUAGE:GetString( )
		return catherine.language.Lists[ uniqueID ] or catherine.language.Lists[ "english" ] or { data = { } }
	end
	
	function catherine.language.GetValue( key, ... )
		local languageTable = catherine.language.GetLists( )
		return string.format( languageTable.data[ key ] or "LanguageError01", ... ) or "Language Error"
	end
end