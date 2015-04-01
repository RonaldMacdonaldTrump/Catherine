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
	catherine.vgui.help = self
	self.helps = { }
	local data = { }
	self.loadingAni = 0
	
	self:SetMenuSize( ScrW( ) * 0.95, ScrH( ) * 0.8 )
	self:SetMenuName( "Help" )

	self.folders = vgui.Create( "DPanelList", self )
	self.folders:SetPos( 10, 35 )
	self.folders:SetSize( self.w * 0.2, self.h - 45 )
	self.folders:SetSpacing( 5 )
	self.folders:EnableHorizontal( false )
	self.folders:EnableVerticalScrollbar( true )
	self.folders.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end
	
	self.html = vgui.Create( "DHTML", self )
	self.html:SetPos( self.w * 0.2 + 20, 35 )
	self.html:SetSize( self.w * 0.8 - 60, self.h - 45 )
	self.html.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end
	
	function data:AddItem( folder, html )
		catherine.vgui.help.helps[ folder ] = html
	end
	
	hook.Run( "AddHelpItem", data )

	self:BuildHelps( )
end

function PANEL:MenuPaint( w, h )
	draw.NoTexture( )
	if ( self.html:IsLoading( ) ) then
		surface.SetDrawColor( 90, 90, 90, 255 )
		self.loadingAni = math.Approach( self.loadingAni, self.loadingAni - 5, 5 )
	else
		surface.SetDrawColor( 90, 90, 90, 0 )
	end
	catherine.geometry.DrawCircle( w - 20, 50, 10, 5, self.loadingAni, 70, 100 )
end

function PANEL:DoWork( html )
	if ( html:find( "http://" ) ) then
		self.html:OpenURL( html )
		return
	end
	local prefix = [[
		<head>
		<style>
			body {
				background-color: #fbfcfc;
				color: #2c3e50;
				font-family: 맑은 고딕, Geneva, sans-serif;
			}
		</style>
		</head>
	]]
	self.html:SetHTML( prefix .. html )
end

function PANEL:BuildHelps( )
	self.folders:Clear( )
	for k, v in pairs( self.helps ) do
		local panel = vgui.Create( "catherine.vgui.button", self )
		panel:SetSize( self.folders:GetWide( ), 50 )
		panel:SetStr( k )
		panel:SetStrFont( "catherine_normal15" )
		panel:SetStrColor( Color( 50, 50, 50, 255 ) )
		panel:SetGradientColor( Color( 255, 255, 255, 150 ) )
		panel.Click = function( )
			self:DoWork( v )
		end
		panel.PaintBackground = function( pnl, w, h )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
		end
		
		self.folders:AddItem( panel )
	end
end

vgui.Register( "catherine.vgui.help", PANEL, "catherine.vgui.menuBase" )

hook.Add( "AddMenuItem", "catherine.vgui.help", function( tab )
	tab[ "Help" ] = function( menuPnl, itemPnl )
		return vgui.Create( "catherine.vgui.help", menuPnl )
	end
end )