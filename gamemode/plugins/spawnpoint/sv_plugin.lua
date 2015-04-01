--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

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