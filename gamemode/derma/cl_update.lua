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
	catherine.vgui.version = self
	
	self.version = catherine.update.VERSION
	self.latestVersion = GetGlobalString( "catherine.update.LATESTVERSION", nil )
	self.status = { text = "Checking update ...", status = false, alpha = 0, rotate = 0 }
	
	self:SetMenuSize( ScrW( ) * 0.5, ScrH( ) * 0.5 )
	self:SetMenuName( "Version" )

	self.check = vgui.Create( "catherine.vgui.button", self )
	self.check:SetPos( self.w - ( self.w * 0.2 ) - 10, 30 )
	self.check:SetSize( self.w * 0.2, 30 )
	self.check:SetStr( "Update check" )
	self.check.Cant = false
	self.check.PaintOverAll = function( pnl )
		if ( self.status.status ) then
			pnl:SetStr( "Checking ..." )
			pnl.Cant = true
		else
			pnl:SetStr( "Update check" )
			pnl.Cant = false
		end
	end
	self.check:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.check:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.check.Click = function( )
		if ( self.check.Cant ) then return end
		self.status.status = true
		self.status.text = "Checking update ..."
		netstream.Start( "catherine.update.Check" )
	end
end

function PANEL:Refresh( )
	self.version = catherine.update.VERSION
	self.latestVersion = GetGlobalString( "catherine.update.LATESTVERSION", nil )
end

function PANEL:MenuPaint( w, h )
	if ( self.status.status ) then
		self.status.rotate = math.Approach( self.status.rotate, self.status.rotate - 3, 3 )
		self.status.alpha = math.Approach( self.status.alpha, 255, 5 )
	else
		if ( math.Round( self.status.alpha ) > 0 ) then
			self.status.rotate = math.Approach( self.status.rotate, 90, 5 )
			self.status.alpha = math.Approach( self.status.alpha, 0, 3 )
		end
	end
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( Material( catherine.configs.frameworkLogo ) )
	surface.DrawTexturedRect( w / 2 - 512 / 2, h / 2 - 256 / 2, 512, 256 )
	
	draw.SimpleText( self.latestVersion and ( "Latest Version - " .. self.latestVersion ) or "Latest Version - None", "catherine_normal20", w / 2, h - 60, Color( 50, 50, 50, 255 ), 1, 1 )
	draw.SimpleText( self.version and ( "Your Version - " .. self.version ) or "Your Version - None", "catherine_normal20", w / 2, h - 25, Color( 50, 50, 50, 255 ), 1, 1 )
	
	if ( math.Round( self.status.alpha ) > 0 ) then
		draw.NoTexture( )
		surface.SetDrawColor( 90, 90, 90, self.status.alpha )
		catherine.geometry.DrawCircle( 30, 50, 10, 3, 90, 360, 100 )
		
		draw.NoTexture( )
		surface.SetDrawColor( 255, 255, 255, self.status.alpha )
		catherine.geometry.DrawCircle( 30, 50, 10, 3, self.status.rotate, 100, 100 )
		
		draw.SimpleText( self.status.text, "catherine_normal20", 60, 40, Color( 50, 50, 50, self.status.alpha ), TEXT_ALIGN_LEFT )
	end
end

vgui.Register( "catherine.vgui.version", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( "Version", function( menuPnl, itemPnl )
	return vgui.Create( "catherine.vgui.version", menuPnl )
end, function( pl )
	return pl:IsSuperAdmin( )
end )