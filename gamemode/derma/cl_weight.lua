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

local PANEL = { }

function PANEL:Init( )
	self.invWeight = 0
	self.invMaxWeight = 0
	self.invWeightAni = 0
	self.size = 10
	self.showText = true
	self.invWeightTextAni = 0
	self.weightStr = catherine.configs.spaceString
end

function PANEL:Paint( w, h )
	self.invWeightAni = Lerp( 0.08, self.invWeightAni, ( self.invWeight / self.invMaxWeight ) * 360 )
	self.invWeightTextAni = Lerp( 0.08, self.invWeightTextAni, ( self.invWeight / self.invMaxWeight ) )
	
	draw.NoTexture( )
	surface.SetDrawColor( 235, 235, 235, 255 )
	catherine.geometry.DrawCircle( w / 2, h / 2, self.size, 5, 90, 360, 100 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 90, 90, 90, 255 )
	catherine.geometry.DrawCircle( w / 2, h / 2, self.size, 5, 90, self.invWeightAni, 100 )

	if ( !self.showText ) then return end
	draw.SimpleText( math.Round( self.invWeightTextAni * 100 ) .. " %", "catherine_normal25", w / 2, h / 2, Color( 90, 90, 90, 255 ), 1, 1 )
end

function PANEL:SetCircleSize( size )
	self.size = size
end

function PANEL:SetShowText( bool )
	self.showText = bool
end

function PANEL:SetWeight( weight, maxWeight )
	self.invWeight = weight
	self.invMaxWeight = maxWeight
end

vgui.Register( "catherine.vgui.weight", PANEL, "DPanel" )