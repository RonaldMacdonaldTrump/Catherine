catherine.font = catherine.font or { }
catherine.font.Lists = { }

function catherine.font.Register( uniqueID, font, size, weight, fontTable )
	if ( !fontTable ) then fontTable = { } end
	table.Merge( fontTable, { uniqueID = uniqueID, font = font, size = size, weight = weight } )
	catherine.font.Lists[ #catherine.font.Lists + 1 ] = fontTable
	surface.CreateFont( uniqueID, fontTable )
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

local font = catherine.configs.Font
catherine.font.Register( "catherine_menuTitle", font, 20, 1000 )
catherine.font.Register( "catherine_button20", font, 20, 1000 )
catherine.font.Register( "catherine_normal15", font, 15, 1000 )
catherine.font.Register( "catherine_normal20", font, 20, 1000 )
catherine.font.Register( "catherine_normal25", font, 25, 1000 )
catherine.font.Register( "catherine_normal30", font, 30, 1000 )
catherine.font.Register( "catherine_normal35", font, 35, 1000 )
catherine.font.Register( "catherine_normal40", font, 40, 1000 )
catherine.font.Register( "catherine_normal50", font, 50, 1000 )
catherine.font.Register( "catherine_schema_title", font, 50, 1000 )
catherine.font.Register( "catherine_good15", font, 15, 1000 )
catherine.font.Register( "catherine_hostname", font, 25, 1000 )
catherine.font.Register( "catherine_outline30", font, 30, 1000, { outline = true } )
catherine.font.Register( "catherine_outline25", font, 25, 1000, { outline = true } )
catherine.font.Register( "catherine_outline20", font, 20, 1000, { outline = true } )
catherine.font.Register( "catherine_outline15", font, 15, 1000, { outline = true } )