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
	catherine.vgui.information = self
	
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ), ScrH( )
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2
	self.blurAmount = 0
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetTitle( "" )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:MakePopup( )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.1, 0 )
	
	local pl = self.player
	local maxDescLen = catherine.configs.characterDescMaxLen
	
	self.TopPanel = vgui.Create( "DPanel", self )
	
	self.TopPanel.w, self.TopPanel.h = self.w - 40, self.h * 0.3
	self.TopPanel.x, self.TopPanel.y = self.w / 2 - self.TopPanel.w / 2, 0 - self.TopPanel.h
	
	self.TopPanel:SetSize( self.TopPanel.w, self.TopPanel.h )
	self.TopPanel:SetPos( self.TopPanel.x, self.TopPanel.y )
	
	self.TopPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 50 ) )
	
		surface.SetDrawColor( 255, 255, 255, 235 )
		surface.SetMaterial( Material( "gui/gradient_up" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		surface.SetDrawColor( 255, 255, 255, 100 )
		surface.SetMaterial( Material( "gui/gradient_down" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	
		draw.SimpleText( pl:Name( ), "catherine_normal30", 90, 25, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
		draw.SimpleText( pl:FactionName( ), "catherine_normal20", 15, 80, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

		draw.SimpleText( self.TopPanel.descEnt:GetText( ):utf8len( ) .. "/" .. maxDescLen, "catherine_normal15", w - 10, 60, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
		
		local icon = Material( "icon16/user.png" )
		
		if ( pl:SteamID( ) == "STEAM_0:1:25704824" ) then
			icon = Material( "icon16/thumb_up.png" )
		elseif ( pl:IsSuperAdmin( ) ) then
			icon = Material( "icon16/shield.png" )
		elseif ( pl:IsAdmin( ) ) then
			icon = Material( "icon16/star.png" )
		end
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( icon )
		surface.DrawTexturedRect( w - ( 20 + ( 16 / 2 ) ), 25 - 16 / 2, 16, 16 )
		
		local className = pl:ClassName( )
	
		if ( className ) then
			draw.SimpleText( className, "catherine_normal15", 15, 100, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		end
	end
	
	self.TopPanel.Lists = vgui.Create( "DPanelList", self.TopPanel )
	self.TopPanel.Lists:SetPos( 15, 130 )
	self.TopPanel.Lists:SetSize( self.TopPanel.w - 30, self.TopPanel.h - 220 )
	self.TopPanel.Lists:SetSpacing( 5 )
	self.TopPanel.Lists:EnableHorizontal( false )
	self.TopPanel.Lists:EnableVerticalScrollbar( true )	
	self.TopPanel.Lists:SetDrawBackground( false )
	
	self.TopPanel.playerModel = vgui.Create( "SpawnIcon", self.TopPanel )
	self.TopPanel.playerModel:SetPos( 15, 15 )
	self.TopPanel.playerModel:SetSize( 60, 60 )
	self.TopPanel.playerModel:SetModel( pl:GetModel( ) )
	self.TopPanel.playerModel:SetToolTip( false )
	self.TopPanel.playerModel:SetDisabled( true )
	self.TopPanel.playerModel.PaintOver = function( pnl, w, h )
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	
	self.TopPanel.descEnt = vgui.Create( "DTextEntry", self.TopPanel )
	self.TopPanel.descEnt:SetPos( 90, 45 )
	self.TopPanel.descEnt:SetSize( self.TopPanel.w - 150, 30 )
	self.TopPanel.descEnt:SetFont( "catherine_normal15" )
	self.TopPanel.descEnt:SetText( pl:Desc( ) )
	self.TopPanel.descEnt:SetAllowNonAsciiCharacters( true )
	self.TopPanel.descEnt.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	self.TopPanel.descEnt.OnEnter = function( pnl )
		catherine.command.Run( "charphysdesc", pnl:GetText( ) )
	end
	
	self.LeftPanel = vgui.Create( "DPanel", self )
	
	self.LeftPanel.w, self.LeftPanel.h = self.w * 0.2, 65
	self.LeftPanel.x, self.LeftPanel.y = 0 - self.LeftPanel.w, self.h - self.LeftPanel.h - 20
	self.LeftPanel.overrideSize = false
	
	self.LeftPanel:SetSize( self.LeftPanel.w, self.LeftPanel.h )
	self.LeftPanel:SetPos( self.LeftPanel.x, self.LeftPanel.y )
	
	self.LeftPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 100 ) )
	
		surface.SetDrawColor( 255, 255, 255, 235 )
		surface.SetMaterial( Material( "gui/gradient" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		if ( catherine.configs.enable_rpTime ) then
			draw.SimpleText( catherine.environment.GetDateString( ), "catherine_normal40", 10, h - 65, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			draw.SimpleText( catherine.environment.GetTimeString( ), "catherine_normal25", 10, h - 30, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		else
			if ( !pnl.overrideSize ) then
				pnl.w, pnl.h = 65, 65
				pnl:SetSize( pnl.w, pnl.h )
				pnl.overrideSize = true
			end
		end
		
		draw.SimpleText( catherine.environment.GetTemperatureString( ), "catherine_normal25", w - 10, h - 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_LEFT ) // to do;
	end
	
	self.RightPanel = vgui.Create( "DPanel", self )
	
	self.RightPanel.w, self.RightPanel.h = 131, 312
	self.RightPanel.x, self.RightPanel.y = self.w, self.h - self.RightPanel.h - 20
	
	self.RightPanel:SetSize( self.RightPanel.w, self.RightPanel.h )
	self.RightPanel:SetPos( self.RightPanel.x, self.RightPanel.y )
	
	self.RightPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 100 ) )
	
		surface.SetDrawColor( 255, 255, 255, 235 )
		surface.SetMaterial( Material( "VGUI/gradient-r" ) )
		surface.DrawTexturedRect( 0, 0, w, h )

		surface.SetDrawColor( 0, 0, 0, 235 )
		surface.SetMaterial( Material( "CAT/limb/body.png", "smooth" ) )
		surface.DrawTexturedRect( w / 2 - ( w - 20 ) / 2, h / 2 - ( h - 20 ) / 2, w - 20, h - 20 )
		
		for k, v in pairs( catherine.limb.GetTable( ) ) do
			local mat = catherine.limb.materials[ k ]
			
			if ( mat ) then
				local col = catherine.limb.GetColor( v )
				
				surface.SetDrawColor( col )
				surface.SetMaterial( mat )
				surface.DrawTexturedRect( w / 2 - ( w - 20 ) / 2, h / 2 - ( h - 20 ) / 2, w - 20, h - 20 )
			end
		end
	end
	
	self.TopPanel:MoveTo( self.TopPanel.x, 20, 0.1, 0 )
	self.LeftPanel:MoveTo( 20, self.LeftPanel.y, 0.1, 0 )
	self.RightPanel:MoveTo( self.w - self.RightPanel.w - 20, self.RightPanel.y, 0.1, 0 )
	
	local data = { }
	local rpInformation = hook.Run( "AddRPInformation", self, data, pl )
	
	for k, v in pairs( data ) do
		self:AddRPInformation( v )
	end
end

function PANEL:AddRPInformation( text )
	local panel = vgui.Create( "DPanel" )
	panel:SetSize( self.TopPanel.Lists:GetWide( ), 20 )
	panel.Paint = function( pnl, w, h )
		draw.SimpleText( text, "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
	end
	
	self.TopPanel.Lists:AddItem( panel )
end

function PANEL:Paint( w, h )
	if ( !self.closing ) then
		self.blurAmount = Lerp( 0.03, self.blurAmount, 3 )
	end

	catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
end

function PANEL:OnKeyCodePressed( key )
	if ( key == KEY_F1 and !self.closing ) then
		self:Close( )
	end
end

function PANEL:Close( )
	if ( self.closing ) then return end
	
	self.closing = true
	
	self.TopPanel:MoveTo( self.TopPanel.x, 0 - self.TopPanel.h, 0.3, 0 )
	self.LeftPanel:MoveTo( 0 - self.LeftPanel.w, self.LeftPanel.y, 0.3, 0 )
	self.RightPanel:MoveTo( self.w, self.RightPanel.y, 0.2, 0 )
	
	self:AlphaTo( 0, 0.3, 0, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.information", PANEL, "DFrame" )