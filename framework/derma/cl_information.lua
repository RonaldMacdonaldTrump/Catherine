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
	hook.Run( "RPInformationMenuJoined", catherine.pl, self )
	
	catherine.vgui.information = self
	
	self.player = catherine.pl
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
	self:AlphaTo( 255, 0.3, 0 )
	--[[
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

		draw.SimpleText( pnl.descEnt:GetText( ):utf8len( ) .. "/" .. maxDescLen, "catherine_normal15", w - 10, 60, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
		
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
	self.TopPanel.Lists:SetSize( self.TopPanel.w - 30, self.TopPanel.h - 145 )
	self.TopPanel.Lists:SetSpacing( 5 )
	self.TopPanel.Lists:EnableHorizontal( false )
	self.TopPanel.Lists:EnableVerticalScrollbar( true )	
	self.TopPanel.Lists:SetDrawBackground( false )
	
	self.TopPanel.playerModel = vgui.Create( "SpawnIcon", self.TopPanel )
	self.TopPanel.playerModel:SetPos( 15, 15 )
	self.TopPanel.playerModel:SetSize( 60, 60 )
	self.TopPanel.playerModel:SetModel( pl:GetModel( ), pl:GetSkin( ) )
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
		catherine.command.Run( "&uniqueID_charPhysDesc", pnl:GetText( ) )
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
		
		local temp = catherine.environment.GetTemperatureString( )
		
		surface.SetFont( "catherine_normal25" )
		local tw, th = surface.GetTextSize( temp )

		if ( catherine.configs.enable_rpTime ) then
			draw.SimpleText( catherine.environment.GetDateString( ), "catherine_normal40", 10, h - 65, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			draw.SimpleText( catherine.environment.GetTimeString( ), "catherine_normal25", 10, h - 30, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			draw.SimpleText( temp, "catherine_normal25", w - 10, h - 30, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_LEFT )
		else
			if ( !pnl.overrideSize ) then
				pnl.w, pnl.h = tw * 2 - 10, 35
				pnl:SetSize( pnl.w, pnl.h )
				pnl.overrideSize = true
			end
			
			draw.SimpleText( temp, "catherine_normal25", w / 2, h - 30, Color( 50, 50, 50, 255 ), 1, TEXT_ALIGN_LEFT )
		end
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
	end--]]
	
	self.limbBaseMaterial = Material( "CAT/limb/body.png", "smooth" ) or "__error_material"
	
	local limbBaseMaterial_w, limbBaseMaterial_h = 150, 341
	
	if ( self.limbBaseMaterial != "__error_material" ) then
		limbBaseMaterial_w, limbBaseMaterial_h = self.limbBaseMaterial:Width( ) / 1.7, self.limbBaseMaterial:Height( ) / 1.5 // 150, 341
	end
	
	surface.SetFont( "catherine_lightUI50" )
	local pl = catherine.pl
	local tw, th = surface.GetTextSize( pl:Name( ) )
	
	self.name = vgui.Create( "DLabel", self )
	self.name.fixed = false
	self.name:SetSize( self.w / 2 - limbBaseMaterial_w / 2 - 20, 50 )
	self.name:SetTextColor( Color( 255, 255, 255 ) )
	self.name:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 - 10 )
	self.name:SetFont( "catherine_lightUI50" )
	self.name:SetText( pl:Name( ) )
	self.name.PerformLayout = function( pnl )
		if ( tw > pnl:GetWide( ) ) then
			for i = 1, 7 do
				local newFontSize = math.Clamp( 50 - ( 5 * i ), 15, 50 )
				
				surface.SetFont( "catherine_lightUI" .. newFontSize )
				tw, th = surface.GetTextSize( pl:Name( ) )
				
				if ( tw <= pnl:GetWide( ) ) then
					self.name:SetSize( self.w / 2 - limbBaseMaterial_w / 2 - 20, newFontSize )
					self.name:SetFont( "catherine_lightUI" .. newFontSize )
					self.name:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 - newFontSize / 2 )
					self.name:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 - newFontSize / 2, 0.3, 0 )
					pnl.fixed = true
					break
				end
			end
		else
			if ( !pnl.fixed ) then
				self.name:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 - 10, 0.3, 0 )
			end
		end
	end
	
	self.desc = vgui.Create( "DLabel", self )
	self.desc:SetSize( self.w / 2 - limbBaseMaterial_w / 2 - 20, 50 )
	self.desc:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ) )
	self.desc:SetTextColor( Color( 255, 255, 255 ) )
	self.desc:SetFont( "catherine_normal15" )
	self.desc:SetText( pl:Desc( ) )
	self.desc.PerformLayout = function( pnl )
		pnl:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ), 0.3, 0.1 )
	end
	
	self.factionName = vgui.Create( "DLabel", self )
	self.factionName:SetSize( self.w / 2 - limbBaseMaterial_w / 2 - 20, 50 )
	self.factionName:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ) + ( self.desc:GetTall( ) / 2 ) )
	self.factionName:SetTextColor( Color( 255, 255, 255 ) )
	self.factionName:SetFont( "catherine_normal20" )
	self.factionName:SetText( pl:FactionName( ) )
	self.factionName.PerformLayout = function( pnl )
		pnl:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ) + ( self.desc:GetTall( ) / 2 ), 0.3, 0.2 )
	end
	
	self.playerModel = vgui.Create( "DModelPanel", self )
	self.playerModel:SetSize( 150, 150 )
	self.playerModel:SetPos( 0 - self.playerModel:GetWide( ), self.h / 2 - limbBaseMaterial_h / 2 )
	self.playerModel:MoveTo( self.w / 2 - limbBaseMaterial_w / 2 - 40 - self.playerModel:GetWide( ), self.h / 2 - limbBaseMaterial_h / 2, 0.3, 0 )
	self.playerModel:MoveToBack( )
	self.playerModel:SetModel( pl:GetModel( ) )
	self.playerModel:SetDrawBackground( false )
	self.playerModel:SetDisabled( true )
	self.playerModel:SetFOV( 15 )
	self.playerModel:SetLookAt( Vector( 0, 0, 65 ) )
	self.playerModel.LayoutEntity = function( pnl, ent )
		draw.RoundedBox( 0, 0, 0, pnl:GetWide( ), pnl:GetTall( ), Color( 255, 255, 255, 255 ) )
		
		local boneIndex = ent:LookupBone( "ValveBiped.Bip01_Head1" )
		local entMin, entMax = ent:GetRenderBounds( )
		
		if ( boneIndex ) then
			local pos, ang = ent:GetBonePosition( boneIndex )
			
			if ( pos ) then
				pnl:SetLookAt( pos )
			end
		else
			pnl:SetLookAt( ( entMax + entMin ) / 2 )
		end
		
		ent:SetAngles( Angle( 0, 45, 0 ) )
		ent:SetIK( false )
		pnl:RunAnimation( )
	end
	
	self.rpInformations = vgui.Create( "DPanelList", self )
	self.rpInformations.init = false
	self.rpInformations:SetSpacing( 5 )
	self.rpInformations:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 + 20 + ( self.name:GetTall( ) / 2 ) + ( self.desc:GetTall( ) / 2 ) + ( self.factionName:GetTall( ) / 2 ) )
	self.rpInformations:SetSize( self.w - ( self.w / 2 + limbBaseMaterial_w / 2 + 20 ) - 20, limbBaseMaterial_h - 90 )
	self.rpInformations:EnableHorizontal( false )
	self.rpInformations:EnableVerticalScrollbar( true )
	self.rpInformations:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 + 20 + ( self.name:GetTall( ) / 2 ) + ( self.desc:GetTall( ) / 2 ) + ( self.factionName:GetTall( ) / 2 ), 0.3, 0.3, nil, function( )
		local data = { }
		local delta = 0
		local rpInformation = hook.Run( "AddRPInformation", self, data, pl )
		
		for k, v in pairs( data ) do
			self:AddRPInformation( v, delta )
			
			delta = delta + 0.03
		end
	end )
end

function PANEL:AddRPInformation( text, delta )
	local panel = vgui.Create( "DPanel" )
	panel:SetSize( self.rpInformations:GetWide( ), 15 )
	panel:SetAlpha( 0 )
	panel:AlphaTo( 255, 0.2, delta )
	panel.Paint = function( pnl, w, h )
		draw.SimpleText( text, "catherine_normal15", 0, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
	end
	
	self.rpInformations:AddItem( panel )
end

function PANEL:Paint( w, h )
	hook.Run( "PreRPInformationPaint", self, w, h )
	
	if ( !self.closing ) then
		self.blurAmount = Lerp( 0.03, self.blurAmount, 5 )
	end
	
	draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 150 ) )
	catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
	
	local limbBaseMaterial_w, limbBaseMaterial_h = 150, 341 // 150, 341
	
	if ( self.limbBaseMaterial != "__error_material" ) then
		limbBaseMaterial_w, limbBaseMaterial_h = self.limbBaseMaterial:Width( ) / 1.7, self.limbBaseMaterial:Height( ) / 1.5
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( self.limbBaseMaterial )
		surface.DrawTexturedRect( w / 2 - limbBaseMaterial_w / 2, h / 2 - limbBaseMaterial_h / 2, limbBaseMaterial_w, limbBaseMaterial_h )
		
		for k, v in pairs( catherine.limb.GetTable( ) ) do
			local mat = catherine.limb.materials[ k ]
			
			if ( mat ) then
				surface.SetDrawColor( catherine.limb.GetColor( v ) )
				surface.SetMaterial( mat )
				surface.DrawTexturedRect( w / 2 - limbBaseMaterial_w / 2, h / 2 - limbBaseMaterial_h / 2, limbBaseMaterial_w, limbBaseMaterial_h )
			end
		end
	end
	
	if ( catherine.configs.enable_rpTime ) then
		draw.SimpleText( catherine.environment.GetDateString( ), "catherine_lightUI50", w / 2, h / 2 - limbBaseMaterial_h / 2 - 60, Color( 255, 255, 255, 255 ), 1, 1 )
		draw.SimpleText( catherine.environment.GetTimeString( ), "catherine_lightUI30", w / 2, h / 2 - limbBaseMaterial_h / 2 - 30, Color( 255, 255, 255, 255 ), 1, 1 )
	end
	
	hook.Run( "PostRPInformationPaint", self, w, h )
end

function PANEL:OnKeyCodePressed( key )
	if ( key == KEY_F1 and !self.closing ) then
		self:Close( )
	end
end

function PANEL:Close( )
	if ( self.closing ) then
		timer.Remove( "Catherine.timer.F1MenuFix" )
		timer.Create( "Catherine.timer.F1MenuFix", 0.2, 1, function( )
			if ( IsValid( self ) ) then
				self:Remove( )
				self = nil
			end
		end )
		
		return
	end
	
	self.closing = true
	
	self:AlphaTo( 0, 0.3, 0, function( )
		hook.Run( "RPInformationMenuExited", self.player )
		
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.information", PANEL, "DFrame" )