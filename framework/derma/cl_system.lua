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
	catherine.vgui.system = self
	
	self.w, self.h = ScrW( ), ScrH( )
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:SetTitle( "" )
	self:MakePopup( )
	
	local foundNewMat = Material( "icon16/error.png" )
	local errorMat = Material( "icon16/exclamation.png" )
	local alreadyNewMat = Material( "CAT/ui/accept.png" )
	
	self.updatePanel = vgui.Create( "DPanel", self )
	
	self.updatePanel.w, self.updatePanel.h = self.w * 0.3, self.h * 0.5
	self.updatePanel.x, self.updatePanel.y = 20, 55
	self.updatePanel.status = false
	self.updatePanel.loadingAni = 0
	self.updatePanel.errorMessage = nil
	
	self.updatePanel:SetSize( self.updatePanel.w, self.updatePanel.h )
	self.updatePanel:SetPos( self.updatePanel.x, self.updatePanel.y )
	self.updatePanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 150 ) )
		
		surface.SetDrawColor( 0, 0, 0, 90 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		
		draw.RoundedBox( 0, 0, 30, w, 1, Color( 0, 0, 0, 90 ) )
		
		draw.SimpleText( LANG( "System_UI_Update_Title" ), "catherine_normal20", 15, 15, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
		
		if ( pnl.status ) then
			pnl.loadingAni = math.Approach( pnl.loadingAni, pnl.loadingAni - 10, 10 )
			
			draw.NoTexture( )
			surface.SetDrawColor( 90, 90, 90, 255 )
			catherine.geometry.DrawCircle( w / 2, h / 2, 15, 5, 0, 360, 100 )
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 255, 255, 255 )
			catherine.geometry.DrawCircle( w / 2, h / 2, 15, 5, pnl.loadingAni, 70, 100 )
		else
			draw.SimpleText( LANG( "System_UI_Update_CoreVer", catherine.GetVersion( ), catherine.GetBuild( ) ), "catherine_normal20", 15, 50, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
			
			if ( pnl.errorMessage ) then
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( errorMat )
				surface.DrawTexturedRect( 10, h - 97, 16, 16 )
				
				draw.SimpleText( pnl.errorMessage, "catherine_normal15", 33, h - 90, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
			else
				if ( catherine.net.GetNetGlobalVar( "cat_needUpdate", false ) ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( foundNewMat )
					surface.DrawTexturedRect( 10, h - 97, 16, 16 )
					
					draw.SimpleText( LANG( "System_UI_Update_FoundNew" ), "catherine_normal15", 33, h - 90, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
				else
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( alreadyNewMat )
					surface.DrawTexturedRect( 10, h - 97, 16, 16 )
					
					draw.SimpleText( LANG( "System_UI_Update_AlreadyNew" ), "catherine_normal15", 33, h - 90, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
				end
			end
		end
	end
	
	self.updatePanel.SetErrorMessage = function( pnl, text )
		pnl.errorMessage = text
		
		timer.Remove( "Catherine.timer.system.ErrorMessageRemove" )
		timer.Create( "Catherine.timer.system.ErrorMessageRemove", 5, 1, function( )
			if ( IsValid( catherine.vgui.system ) ) then
				pnl.errorMessage = nil
			end
		end )
	end
	
	self.updatePanel.check = vgui.Create( "catherine.vgui.button", self.updatePanel )
	self.updatePanel.check.progressing = false
	self.updatePanel.check:SetSize( self.updatePanel.w - 15, 30 )
	self.updatePanel.check:SetPos( self.updatePanel.w / 2 - self.updatePanel.check:GetWide( ) / 2, self.updatePanel.h - self.updatePanel.check:GetTall( ) - 10 )
	self.updatePanel.check:SetStr( LANG( "System_UI_Update_CheckButton" ) )
	self.updatePanel.check:SetStrFont( "catherine_normal15" )
	self.updatePanel.check:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.updatePanel.check:SetGradientColor( Color( 255, 255, 255, 150 ) )
	self.updatePanel.check.Click = function( pnl )
		if ( pnl.progressing ) then return end
		self.updatePanel.status = true
		netstream.Start( "catherine.version.Check" )
	end
	self.updatePanel.check.PaintBackground = function( pnl, w, h )
		if ( self.updatePanel.status and !pnl.progressing ) then
			pnl:SetStr( LANG( "System_UI_Update_CheckingUpdate" ) )
			pnl.progressing = true
		elseif ( !self.updatePanel.status and pnl.progressing ) then
			pnl:SetStr( LANG( "System_UI_Update_CheckButton" ) )
			pnl.progressing = false
		end
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
	end
	
	self.updatePanel.openLog = vgui.Create( "catherine.vgui.button", self.updatePanel )
	self.updatePanel.openLog:SetSize( self.updatePanel.w - 15, 30 )
	self.updatePanel.openLog:SetPos( self.updatePanel.w / 2 - self.updatePanel.openLog:GetWide( ) / 2, self.updatePanel.h - ( self.updatePanel.openLog:GetTall( ) * 2 ) - 15 )
	self.updatePanel.openLog:SetStr( LANG( "System_UI_Update_OpenUpdateLog" ) )
	self.updatePanel.openLog:SetStrFont( "catherine_normal15" )
	self.updatePanel.openLog:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.updatePanel.openLog:SetGradientColor( Color( 255, 255, 255, 150 ) )
	self.updatePanel.openLog.Click = function( pnl )
		gui.OpenURL( "http://github.com/L7D/Catherine/commits" )
	end
	self.updatePanel.openLog.PaintBackground = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
	end
	
	self.close = vgui.Create( "catherine.vgui.button", self )
	self.close:SetPos( 15, self.h - 45 )
	self.close:SetSize( self.w * 0.2, 30 )
	self.close:SetStr( LANG( "System_UI_Close" ) )
	self.close:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.close:SetGradientColor( Color( 255, 255, 255, 150 ) )
	self.close.Click = function( )
		self:Close( )
	end
	self.close.PaintBackground = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
	end
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 245, 245, 245, 255 ) )
	
	draw.SimpleText( LANG( "System_UI_Title" ), "catherine_normal35", 20, 25, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
end

function PANEL:Close( )
	if ( self.closing ) then return end
	
	self.closing = true
	
	self:Remove( )
	self = nil
end

vgui.Register( "catherine.vgui.system", PANEL, "DFrame" )

catherine.menu.Register( function( )
	return LANG( "System_UI_Title" )
end, function( menuPnl, itemPnl )
	vgui.Create( "catherine.vgui.system" )
	menuPnl:Close( )
end, function( pl )
	return pl:IsSuperAdmin( )
end )