catherine.option = catherine.option or { }
catherine.option.Lists = { }
CAT_OPTION_SWITCH = 0

function catherine.option.Register( uniqueID, conVar, name, desc, category, typ, optionTable )
	if ( !optionTable ) then optionTable = { } end
	table.Merge( optionTable, { uniqueID = uniqueID, name = name, desc = desc, conVar = conVar, typ = typ, category = category } )
	catherine.option.Lists[ uniqueID ] = optionTable
end

function catherine.option.Remove( uniqueID )
	if ( !catherine.option.FindByID( uniqueID ) ) then return end
	catherine.option.Lists[ uniqueID ] = nil
end

function catherine.option.Set( uniqueID, val )
	local optionTable = catherine.option.FindByID( uniqueID )
	if ( !optionTable or !optionTable.onSet ) then return end
	optionTable.onSet( optionTable.conVar, val )
end

function catherine.option.Toggle( uniqueID )
	local optionTable = catherine.option.FindByID( uniqueID )
	if ( !optionTable or optionTable.typ != CAT_OPTION_SWITCH or !optionTable.conVar ) then return end
	RunConsoleCommand( optionTable.conVar, tostring( tobool( GetConVarString( optionTable.conVar ) ) == true and 0 or 1 ) )
end

function catherine.option.Get( uniqueID )
	local optionTable = catherine.option.FindByID( uniqueID )
	if ( !optionTable ) then return nil end
	if ( optionTable.onGet ) then
		return optionTable.onGet( optionTable )
	else
		return GetConVarString( optionTable.conVar )
	end
end

function catherine.option.FindByID( uniqueID )
	if ( !uniqueID ) then return nil end
	return catherine.option.Lists[ uniqueID ]
end

function catherine.option.GetAll( )
	return catherine.option.Lists
end

catherine.option.Register( "CONVAR_BAR", "cat_convar_bar", "Bar", "Displays the Bar.", "Framework Settings", CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_MAINHUD", "cat_convar_hud", "Main HUD", "Displays the main HUD.", "Framework Settings", CAT_OPTION_SWITCH )