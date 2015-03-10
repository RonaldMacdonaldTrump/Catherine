local Plugin = Plugin

function Plugin:EntityDataLoaded( pl )
	self:SyncTextAll( pl )
end

function Plugin:SaveTexts( )
	catherine.data.Set( "goodtexts", self.textLists )
end

function Plugin:LoadTexts( )
	self.textLists = catherine.data.Get( "goodtexts", { } )
end

function Plugin:DataLoad( )
	self:LoadTexts( )
end

function Plugin:DataSave( )
	self:SaveTexts( )
end

function Plugin:AddText( pl, text, size )
	local tr = pl:GetEyeTraceNoCursor( )
	local data = {
		index = #self.textLists + 1,
		pos = tr.HitPos + tr.HitNormal,
		ang = tr.HitNormal:Angle( ),
		text = text,
		size = math.max( math.abs( size or 0.25 ), 0.005 )
	}
	
	data.ang:RotateAroundAxis( data.ang:Up( ), 90 )
	data.ang:RotateAroundAxis( data.ang:Forward( ), 90 )

	self.textLists[ data.index ] = data
	
	self:SyncTextAll( )
	self:SaveTexts( )
end

function Plugin:RemoveText( pos, range )
	range = tonumber( range )
	local count = 0
	for k, v in pairs( self.textLists ) do
		if ( v.pos:Distance( pos ) <= range ) then
			netstream.Start( nil, "catherine.plugin.goodtext.RemoveText", v.index )
			table.remove( self.textLists, k )
			count = count + 1
		end
	end
	
	self:SaveTexts( )
	
	return count
end

function Plugin:SyncTextAll( pl )
	if ( !pl ) then pl = nil end
	for k, v in pairs( self.textLists ) do
		netstream.Start( pl, "catherine.plugin.goodtext.SyncText", { index = k, text = v.text, pos = v.pos, ang = v.ang, size = v.size } )
	end
end