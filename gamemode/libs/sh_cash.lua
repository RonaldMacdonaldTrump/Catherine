nexus.cash = nexus.cash or { }

function nexus.cash.GetOnlyName( )
	return nexus.configs.cashName
end

function nexus.cash.GetName( amount )
	return amount .. " " .. nexus.configs.cashName
end