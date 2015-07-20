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
	
	self.version = catherine.GetVersion( )
	self.needUpdate = catherine.net.GetNetGlobalVar( "cat_needUpdate", false )
	self.status = false
	self.mat = {
		Material( "CAT/ui/accept.png" ),
		Material( "icon16/error.png" )
	}
	
	self:SetMenuSize( ScrW( ) * 0.7, ScrH( ) * 0.7 )
	self:SetMenuName( LANG( "Version_UI_Title" ) )

	self.check = vgui.Create( "catherine.vgui.button", self )
	self.check:SetPos( self.w - ( self.w * 0.4 ) - 10, 30 )
	self.check:SetSize( self.w * 0.4, 30 )
	self.check:SetStr( LANG( "Version_UI_CheckButtonStr" ) )
	self.check.Cant = false
	self.check.PaintOverAll = function( pnl )
		if ( self.status and !pnl.Cant ) then
			pnl:SetStr( LANG( "Version_UI_Checking" ) )
			pnl.Cant = true
		elseif ( !self.status and pnl.Cant ) then
			pnl:SetStr( LANG( "Version_UI_CheckButtonStr" ) )
			pnl.Cant = false
		end
	end
	self.check:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.check:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.check.Click = function( pnl )
		if ( pnl.Cant ) then return end
		
		self.status = true
		netstream.Start( "catherine.version.Check" )
	end
	
	self.updateLog = vgui.Create( "catherine.vgui.button", self )
	self.updateLog:SetPos( 10, 30 )
	self.updateLog:SetSize( self.w * 0.4, 30 )
	self.updateLog:SetStr( LANG( "Version_UI_OpenUpdateLogStr" ) )
	self.updateLog:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.updateLog:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.updateLog.Click = function( pnl )
		gui.OpenURL( "http://github.com/L7D/Catherine/commits" )
	end
end

function PANEL:Refresh( )
	self.version = catherine.GetVersion( )
	self.needUpdate = catherine.net.GetNetGlobalVar( "cat_needUpdate", false )
end

function PANEL:MenuPaint( w, h )
	local mat = self.mat[ 2 ]
	local txt = LANG( "Version_Notify_FoundNew" )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( Material( catherine.configs.frameworkLogo ) )
	surface.DrawTexturedRect( w / 2 - 512 / 2, h / 2 - 256 / 2, 512, 256 )
	
	if ( !self.needUpdate ) then
		mat = self.mat[ 1 ]
		txt = LANG( "Version_Notify_AlreadyNew" )
	end
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( mat )
	surface.DrawTexturedRect( 10, h - 25, 16, 16 )

	draw.SimpleText( txt, "catherine_normal15", 35, h - 18, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( LANG( "Version_UI_YourVer_AV", self.version ) .. " " .. catherine.GetBuild( ), "catherine_normal20", w - 10, h - 18, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

vgui.Register( "catherine.vgui.version", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "Version_UI_Title" )
end, function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.version ) and catherine.vgui.version or vgui.Create( "catherine.vgui.version", menuPnl )
end, function( pl )
	return pl:IsSuperAdmin( )
end )