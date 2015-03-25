if ( !catherine.character ) then
	catherine.util.Include( "sh_character.lua" )
end
catherine.attribute = catherine.attribute or { }
catherine.attribute.Lists = { }

function catherine.attribute.Register( uniqueID, name, desc, image, default, max )
	local index = #catherine.attribute.Lists + 1
	catherine.attribute.Lists[ index ] = {
		uniqueID = uniqueID,
		name = name,
		desc = desc,
		image = image,
		default = default or 0,
		max = max or 100
	}
	return catherine.attribute.Lists[ index ]
end

function catherine.attribute.GetAll( )
	return catherine.attribute.Lists
end

function catherine.attribute.FindByID( id )
	if ( !id ) then return nil end
	for k, v in pairs( catherine.attribute.GetAll( ) ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
	
	return nil
end

if ( SERVER ) then
	function catherine.attribute.SetProgress( pl, attributeTable, progress )
		if ( !IsValid( pl ) or !attributeTable or !progress ) then return end
		local attribute = catherine.character.GetGlobalVar( pl, "_att", { } )
		attribute[ attributeTable.uniqueID ] = attribute[ attributeTable.uniqueID ] or { per = 0, progress = attributeTable.default }
		attribute[ attributeTable.uniqueID ].progress = math.Clamp( progress, 0, attributeTable.max )
		catherine.character.SetGlobalVar( pl, "_att", attribute )
	end
	
	function catherine.attribute.AddProgress( pl, attributeTable, progress )
		if ( !IsValid( pl ) or !attributeTable or !progress ) then return end
		local attribute = catherine.character.GetGlobalVar( pl, "_att", { } )
		attribute[ attributeTable.uniqueID ] = attribute[ attributeTable.uniqueID ] or { per = 0, progress = attributeTable.default }
		attribute[ attributeTable.uniqueID ].progress = math.Clamp( attribute[ attributeTable.uniqueID ].progress + progress, 0, attributeTable.max )
		catherine.character.SetGlobalVar( pl, "_att", attribute )
	end
	
	function catherine.attribute.RemoveProgress( pl, attributeTable, progress )
		if ( !IsValid( pl ) or !attributeTable or !progress ) then return end
		local attribute = catherine.character.GetGlobalVar( pl, "_att", { } )
		attribute[ attributeTable.uniqueID ] = attribute[ attributeTable.uniqueID ] or { per = 0, progress = attributeTable.default }
		attribute[ attributeTable.uniqueID ].progress = math.Clamp( attribute[ attributeTable.uniqueID ].progress - progress, 0, attributeTable.max )
		catherine.character.SetGlobalVar( pl, "_att", attribute )
	end

	function catherine.attribute.GetProgress( pl, attributeTable )
		local attribute = catherine.character.GetGlobalVar( pl, "_att", { } )
		if ( !attribute[ attributeTable.uniqueID ] ) then return 0 end
		return attribute[ attributeTable.uniqueID ].progress or 0
	end
	
	catherine.hooks.Register( "InitializeNetworking", "catherine.attribute.hooks.InitializeNetworking", function( pl, charVars )
		if ( !charVars._att ) then return end
		local attribute, changed, count = charVars._att, false, 0
		for k, v in pairs( attribute ) do
			count = count + 1
			if ( catherine.attribute.FindByID( k ) ) then continue end
			attribute[ k ] = nil
			changed = true
		end
		local attAll = catherine.attribute.GetAll( )
		if ( count != #attAll ) then
			for k, v in pairs( attAll ) do
				if ( attribute[ v.uniqueID ] ) then continue end
				attribute[ v.uniqueID ] = { per = 0, progress = v.default }
				changed = true
			end
		end
		if ( changed ) then
			catherine.character.SetGlobalVar( pl, "_att", attribute )
		end
	end )
else
	function catherine.attribute.GetProgress( attributeTable )
		local attribute = catherine.character.GetGlobalVar( LocalPlayer( ), "_att", { } )
		if ( !attribute[ attributeTable.uniqueID ] ) then return 0 end
		return attribute[ attributeTable.uniqueID ].progress or 0
	end
end