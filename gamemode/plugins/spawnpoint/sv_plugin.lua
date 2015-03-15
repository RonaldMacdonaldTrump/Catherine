local Plugin = Plugin
Plugin.Lists = Plugin.Lists or { }

function Plugin:SavePoints( )
	catherine.data.Set( "spawnpoints", self.Lists )
end

function Plugin:LoadPoints( )
	self.Lists = catherine.data.Get( "spawnpoints", { } )
end

function Plugin:DataLoad( )
	self:LoadPoints( )
end

function Plugin:DataSave( )
	self:SavePoints( )
end

function Plugin:CalcRandomPoint( faction )
	if ( !faction ) then return end
	local map = game.GetMap( )
	if ( !faction or !self.Lists[ map ] or !self.Lists[ map ][ faction ] or self.Lists[ map ][ faction ] == 0 ) then return nil end
	return table.Random( self.Lists[ map ][ faction ] )
end

function Plugin:PlayerSpawnedInCharacter( pl )
	local randPoint = self:CalcRandomPoint( catherine.character.GetGlobalVar( pl, "_faction", nil ) )
	if ( !randPoint ) then return end
	pl:SetPos( randPoint + Vector( 0, 0, 10 ) )
end