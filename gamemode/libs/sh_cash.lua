catherine.cash = catherine.cash or { }

function catherine.cash.GetOnlyName( )
	return catherine.configs.cashName
end

function catherine.cash.GetName( amount )
	return amount .. " " .. catherine.configs.cashName
end