function GM:ScoreboardShow()
	if ( IsValid( catherine.vgui.menu ) ) then
		catherine.vgui.menu:Close( )
		gui.EnableScreenClicker( false )
	else
		catherine.vgui.menu = vgui.Create( "catherine.vgui.menu" )
		gui.EnableScreenClicker( true )
	end
end

function GM:ScoreboardHide()

end

local PANEL = { }

function PANEL:Init( )
	local LP = LocalPlayer( )
	
	self.w = ScrW( )
	self.h = ScrH( )

	self.blur = Material( "pp/blurscreen" )
	self.open = CurTime( )
	self.staying = false
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( true )
	self:SetDraggable( false )
	
	self.CloseMenu = vgui.Create( "catherine.vgui.button", self )
	self.CloseMenu:SetSize( self.w * 0.15, 30 )
	self.CloseMenu:SetPos( 10, 50 )
	self.CloseMenu:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.CloseMenu:SetStr( "Close Menu" )
	self.CloseMenu.Click = function( )
		self:Close( )
	end
	
	self.Character = vgui.Create( "catherine.vgui.button", self )
	self.Character:SetSize( self.w * 0.15, 30 )
	self.Character:SetPos( 10, 90 )
	self.Character:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.Character:SetStr( "Character" )
	self.Character.Click = function( )
		self:Close( )
	end

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 150 )
	self.Lists:SetSize( self.w * 0.15, self.h - 50 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )

	end
	
	hook.Run( "AddMenu" )
	
	self:MenuInit( )
end

function PANEL:Think( )
	if ( self.open <= CurTime( ) + 1 ) then
		self.staying = true
	end
end

function PANEL:MenuInit( )
	self.Lists:Clear( )
	for k, v in pairs( catherine.menuList ) do
		local panel = vgui.Create( "catherine.vgui.button", self )
		panel:SetSize( self.Lists:GetWide( ), 30 )
		panel:SetOutlineColor( Color( 255, 255, 255, 255 ) )
		panel:SetStr( v.text )
		panel.Click = function( )
			v.func( )
		end
		self.Lists:AddItem( panel )
	end
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 40, 40, 40, 200 )
	surface.SetMaterial( Material( "gui/gradient" ) )
	surface.DrawTexturedRect( 0, 0, w / 3, h )
end

function PANEL:Close( )
	self:Remove( )
	self = nil
	catherine.vgui.menu = nil
	gui.EnableScreenClicker( false )
end

vgui.Register( "catherine.vgui.menu", PANEL, "DFrame" )