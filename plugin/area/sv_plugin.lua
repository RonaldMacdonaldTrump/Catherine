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
local META = FindMetaTable( "Player" )
PLUGIN.areas = PLUGIN.areas or { }

function PLUGIN:SaveAreas( )
	catherine.data.Set( "areas", self.areas )
end

function PLUGIN:LoadAreas( )
	self.areas = catherine.data.Get( "areas", { } )
end

function PLUGIN:DataLoad( )
	self:LoadAreas( )
end

function PLUGIN:DataSave( )
	self:SaveAreas( )
end

function PLUGIN:AddArea( name, minVector, maxVector )
	self.areas[ #self.areas + 1 ] = {
		name = name,
		minVector = minVector,
		maxVector = maxVector
	}
	
	self:SaveAreas( )
end

function PLUGIN:RemoveArea( areaID )
	self.areas[ areaID ] = nil
	
	self:SaveAreas( )
end

function PLUGIN:GetAllAreas( )
	return self.areas
end

function PLUGIN:FindAreaByID( id )
	return self.areas[ id ]
end

function PLUGIN:PlayerThink( pl )
	if ( ( pl.CAT_area_nextUpdate or 0 ) <= CurTime( ) ) then
		if ( pl:Alive( ) ) then
			local currArea = pl:GetCurrentArea( )

			for k, v in pairs( self:GetAllAreas( ) ) do
				if ( catherine.util.IsInBox( pl, v.minVector, v.maxVector, true ) and currArea != k ) then
					pl.CAT_area_currArea = k

					hook.Run( "PlayerAreaChanged", pl, k )
				end
			end
		end

		pl.CAT_area_nextUpdate = CurTime( ) + 0.5
	end
end

function PLUGIN:PlayerSpawnedInCharacter( pl )
	pl.CAT_area_currArea = nil
end

function PLUGIN:PlayerDeath( pl )
	pl.CAT_area_currArea = nil
end

function PLUGIN:PlayerAreaChanged( pl, areaID )
	if ( pl:GetInfo( "cat_convar_showarea" ) == "1" ) then
		local areaTable = self:FindAreaByID( areaID )
		
		if ( areaTable ) then
			netstream.Start( pl, "catherine.plugin.area.Display", areaTable.name )
		end
	end
end

function META:GetCurrentArea( )
	return self.CAT_area_currArea
end