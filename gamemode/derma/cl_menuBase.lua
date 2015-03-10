local PANEL = { }

function PANEL:Init( )
	self.w = ScrW( ) * 0.5
	self.h = ScrH( ) * 0.5
	self.name = "MENU"
	self.player = LocalPlayer( )
	
	self:SetSize( self.w, self.h )
	self:SetPos( ScrW( ) / 2 - self.w / 2, 80 )
	self:SetTitle( "" )
	self:SetAlpha( 0 )
	self:ShowCloseButton( false )
	self:SetDraggable( false )

	self:PanelCalled( )
	self:AlphaTo( 255, 0.3, 0 )
end

function PANEL:OnMenuSizeChanged( w, h ) end
function PANEL:PanelCalled( ) end

function PANEL:SetMenuSize( w, h )
	self.w, self.h = w, h
	self:SetSize( w, h )
	self:SetPos( ScrW( ) / 2 - w / 2, 80 )
	self:OnMenuSizeChanged( w, h )
end

function PANEL:SetMenuName( name )
	self.name = name
end

function PANEL:MenuPaint( w, h ) end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 25, w, h, Color( 255, 255, 255, 235 ) )
		
	surface.SetDrawColor( 200, 200, 200, 235 )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 25, w, h )

	draw.SimpleText( self.name, "catherine_normal25", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
	self:MenuPaint( w, h )
end

function PANEL:Close( )
	self:AlphaTo( 0, 0.2, 0, nil, function( )
		if ( !IsValid( self ) ) then return end
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.menuBase", PANEL, "DFrame" )