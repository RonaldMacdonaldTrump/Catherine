catherine.option = catherine.option or { }
catherine.option.Lists = catherine.option.Lists or { }

function catherine.option.Register( uniqueID, conVar, name, desc, optionTable )
	if ( !optionTable ) then optionTable = { } end
	table.Merge( optionTable, { uniqueID = uniqueID, name = name, desc = desc, conVar = conVar } )
	catherine.option.Lists[ uniqueID ] = optionTable
end

function catherine.option.Remove( uniqueID )
	if ( !catherine.option.GetByID( uniqueID ) ) then return end
	catherine.option.Lists[ uniqueID ] = nil
end

function catherine.option.Set( uniqueID, val )
	local optionTable = catherine.option.GetByID( uniqueID )
	if ( !optionTable or !optionTable.onSet ) then return end
	optionTable.onSet( optionTable.conVar, val )
end

function catherine.option.GetByID( uniqueID )
	if ( !uniqueID ) then return nil end
	return catherine.option.Lists[ uniqueID ]
end

function catherine.option.GetAll( )
	return catherine.option.Lists
end