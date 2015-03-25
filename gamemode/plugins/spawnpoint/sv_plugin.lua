local PLUGIN = PLUGIN
PLUGIN.Lists = PLUGIN.Lists or { }

function PLUGIN:SavePoints( )
	catherine.data.Set( "spawnpoints", self.Lists )
end

function PLUGIN:LoadPoints( )
	self.Lists = catherine.data.Get( "spawnpoints", { } )
end

function PLUGIN:DataLoad( )
	self:LoadPoints( )
end

function PLUGIN:DataSave( )
	self:SavePoints( )
end

function PLUGIN:CalcRandomPoint( faction )
	if ( !faction ) then return end
	local map = game.GetMap( )
	if ( !faction or !self.Lists[ map ] or !self.Lists[ map ][ faction ] or self.Lists[ map ][ faction ] == 0 ) then return nil end
	return table.Random( self.Lists[ map ][ faction ] )
end

function PLUGIN:PlayerSpawnedInCharacter( pl )
	local randPoint = self:CalcRandomPoint( catherine.character.GetGlobalVar( pl, "_faction", nil ) )
	if ( !randPoint ) then return end
	pl:SetPos( randPoint + Vector( 0, 0, 10 ) )
end