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

local PANEL = { }

function PANEL:Init( )
	catherine.vgui.help = self
	
	self.helps = { }
	self.loadingAni = 0
	self.loadingAlpha = 0
	
	self:SetMenuSize( ScrW( ) * 0.95, ScrH( ) * 0.8 )
	self:SetMenuName( "Help" )

	self.categorys = vgui.Create( "DPanelList", self )
	self.categorys:SetPos( 10, 35 )
	self.categorys:SetSize( self.w * 0.2, self.h - 45 )
	self.categorys:SetSpacing( 5 )
	self.categorys:EnableHorizontal( false )
	self.categorys:EnableVerticalScrollbar( true )
	self.categorys.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end
	
	self.html = vgui.Create( "DHTML", self )
	self.html:SetPos( self.w * 0.2 + 20, 35 )
	self.html:SetSize( self.w * 0.8 - 60, self.h - 45 )
	self.html.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end

	for k, v in pairs( catherine.help.GetAll( ) ) do
		self.helps[ v.category ] = v.codes
	end

	self:BuildHelps( )
end

function PANEL:MenuPaint( w, h )
	if ( self.html:IsLoading( ) ) then
		self.loadingAlpha = Lerp( 0.05, self.loadingAlpha, 255 )
	elseif ( !self.html:IsLoading( ) and math.Round( self.loadingAlpha ) > 0 ) then
		self.loadingAlpha = Lerp( 0.05, self.loadingAlpha, 0 )
	end
	
	if ( math.Round( self.loadingAlpha ) > 0 ) then
		self.loadingAni = math.Approach( self.loadingAni, self.loadingAni - 5, 5 )
		
		draw.NoTexture( )
		surface.SetDrawColor( 90, 90, 90, self.loadingAlpha )
		catherine.geometry.DrawCircle( w - 20, 50, 10, 5, self.loadingAni, 70, 100 )
	end
end

function PANEL:DoWork( data )
	if ( types.types == CAT_HELP_WEBPAGE ) then
		self.html:OpenURL( data.codes )
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
	self.html:SetHTML( prefix .. data.codes )
end

function PANEL:BuildHelps( )
	self.categorys:Clear( )
	for k, v in pairs( self.helps ) do
		local panel = vgui.Create( "catherine.vgui.button", self )
		panel:SetSize( self.categorys:GetWide( ), 30 )
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
		
		self.categorys:AddItem( panel )
	end
end

vgui.Register( "catherine.vgui.help", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( "Help", function( menuPnl, itemPnl )
	return vgui.Create( "catherine.vgui.help", menuPnl )
end )