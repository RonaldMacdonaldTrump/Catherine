catherine.font = catherine.font or { }
catherine.font.Lists = catherine.font.Lists or { }
catherine.font.FontString = catherine.font.FontString or ""

function catherine.font.Add( uniqueID, font, size, weight, outline )
	local isValid = catherine.font.GetByID( uniqueID )
	if ( isValid ) then return end
	catherine.font.Lists[ #catherine.font.Lists + 1 ] = { uniqueID = uniqueID, font = font, size = size, weight = weight, outline = outline }
	surface.CreateFont( uniqueID, { font = font, size = size, weight = weight, antialias = true, outline = outline } )
end

function catherine.font.Set( uniqueID, font, size, weight, outline )
	if ( !uniqueID ) then return end
	local fontTab = catherine.font.GetByID( uniqueID )
	if ( !fontTab ) then return end
	font = font or fontTab.font
	size = size or fontTab.size
	weight = weight or fontTab.weight
	outline = outline or fontTab.outline or false
	
	surface.CreateFont( uniqueID, { font = font, size = size, weight = weight, antialias = true, outline = outline } )
end

function catherine.font.GetByID( id )
	if ( !id ) then return nil end
	for k, v in pairs( catherine.font.Lists ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
	return nil
end

catherine.font.FontString = "Segoe UI"
catherine.font.Add( "catherine_menuTitle", catherine.font.FontString, 20, 1000 )
catherine.font.Add( "catherine_button20", catherine.font.FontString, 20, 1000 )
catherine.font.Add( "catherine_normal15", catherine.font.FontString, 15, 1000 )
catherine.font.Add( "catherine_normal20", catherine.font.FontString, 20, 1000 )
catherine.font.Add( "catherine_normal25", catherine.font.FontString, 25, 1000 )
catherine.font.Add( "catherine_normal30", catherine.font.FontString, 30, 1000 )
<<<<<<< HEAD
=======
catherine.font.Add( "catherine_normal50", catherine.font.FontString, 50, 1000 )
>>>>>>> dev
catherine.font.Add( "catherine_schema_title", catherine.font.FontString, 50, 1000 )
catherine.font.Add( "catherine_good15", catherine.font.FontString, 15, 1000 )
catherine.font.Add( "catherine_hostname", catherine.font.FontString, 25, 1000 )
catherine.font.Add( "catherine_outline20", catherine.font.FontString, 20, 1000, true )
catherine.font.Add( "catherine_outline15", catherine.font.FontString, 15, 1000, true )