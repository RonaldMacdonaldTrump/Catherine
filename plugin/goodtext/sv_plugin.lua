--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

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

function PLUGIN:EntityDataLoaded( pl )
	self:SyncTextAll( pl )
end

function PLUGIN:SaveTexts( )
	catherine.data.Set( "goodtexts", self.textLists )
end

function PLUGIN:LoadTexts( )
	self.textLists = catherine.data.Get( "goodtexts", { } )
end

function PLUGIN:DataLoad( )
	self:LoadTexts( )
end

function PLUGIN:DataSave( )
	self:SaveTexts( )
end

function PLUGIN:AddText( pl, text, size )
	local tr = pl:GetEyeTraceNoCursor( )
	local index = #self.textLists + 1
	local data = {
		index = index,
		pos = tr.HitPos + tr.HitNormal,
		ang = tr.HitNormal:Angle( ),
		text = text,
		size = math.max( math.abs( size or 0.25 ), 0.005 )
	}
	
	data.ang:RotateAroundAxis( data.ang:Up( ), 90 )
	data.ang:RotateAroundAxis( data.ang:Forward( ), 90 )

	self.textLists[ index ] = data
	
	self:SyncTextAll( )
	self:SaveTexts( )
end

function PLUGIN:RemoveText( pos, range )
	range = tonumber( range )
	local count = 0
	
	for k, v in pairs( self.textLists ) do
		if ( v.pos:Distance( pos ) <= range ) then
			catherine.netXync.Send( nil, "catherine.plugin.goodtext.RemoveText", v.index )
			table.remove( self.textLists, k )
			count = count + 1
		end
	end
	
	self:SaveTexts( )
	
	return count
end

function PLUGIN:SyncTextAll( pl )
	if ( !pl ) then
		pl = nil
	end
	
	for k, v in pairs( self.textLists ) do
		catherine.netXync.Send( pl, "catherine.plugin.goodtext.SyncText", { index = k, text = v.text, pos = v.pos, ang = v.ang, size = v.size } )
	end
end