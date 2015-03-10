catherine.language = catherine.language or { }
catherine.language.Lists = { }

function catherine.language.Include( dir )
	local langFiles = file.Find( dir .. "/languages/*.lua", "LUA" )
	
	for k, v in pairs( langFiles ) do
		local uniqueID = catherine.util.GetUniqueName( v )
		Lang = { uniqueID = uniqueID, name = "Unknown", datas = { } }
		catherine.util.Include( dir .. "/languages/" .. v )
		catherine.language.Lists[ uniqueID ] = Lang
		Lang = nil
	end
end

function catherine.language.Merge( uniqueID, datas )
	local langTab = catherine.language.Lists[ uniqueID ]
	if ( !langTab or !datas ) then return end
	catherine.language.Lists[ uniqueID ].datas = table.Merge( catherine.language.Lists[ uniqueID ].datas, datas )
end

catherine.language.Include( catherine.FolderName .. "/gamemode" )

if ( SERVER ) then
	function catherine.language.GetValue( pl, key, ... )
		local uniqueID = "english"
		if ( IsValid( pl ) ) then uniqueID = pl:GetInfo( "cat_convar_language" ) end
		local lists = catherine.language.Lists[ uniqueID ]
		if ( !lists or !lists.datas ) then return "Error" end
		return string.format( lists.datas[ key ], ... )
	end
else
	CAT_CONVAR_LANGUAGE = CreateClientConVar( "cat_convar_language", "english", true, true )
	
	function catherine.language.GetValue( key, ... )
		local uniqueID = CAT_CONVAR_LANGUAGE:GetString( )
		local lists = catherine.language.Lists[ uniqueID ]
		if ( !lists or !lists.datas ) then return "Error" end
		return string.format( lists.datas[ key ], ... )
	end
end