catherine.meta = catherine.meta or { }
catherine.meta.objects = catherine.meta.objects or { }

function catherine.meta.Create( class, data )
	local self = setmetatable( data, catherine.meta.objects[ class ] )
	catherine.meta.objects[ #catherine.meta.objects + 1 ] = self
	return self
end

function catherine.meta.Register( class, data )
	data.__index = data
	catherine.meta.objects[ class ] = data
end