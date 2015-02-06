concommand.Add("inv_open", function( )
	if ( IsValid( catherine.vgui.inventory ) ) then
		catherine.vgui.inventory:Close( )
		catherine.vgui.inventory = vgui.Create( "catherine.vgui.inventory" )
	else
		catherine.vgui.inventory = vgui.Create( "catherine.vgui.inventory" )
	end
end)

local PANEL = { }

function PANEL:Init( )
	local LP = LocalPlayer( )
	
	self.w = ScrW( ) * 0.5
	self.h = ScrH( ) * 0.5

	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "Inventory" )
	self:ShowCloseButton( true )
	self:SetDraggable( false )
	self:MakePopup( )
	self:Center( )
	self.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.SetMaterial( Material( "gui/gradient_up" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	
	self.Disconnect = vgui.Create( "catherine.vgui.button", self )
	self.Disconnect:SetSize( self.w * 0.2, 100 )
	self.Disconnect:SetStr( "Disconnect" )
	self.Disconnect:Center( )
	self.Disconnect:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.Disconnect.Click = function( )
		self:Close( )
	end
end

function PANEL:Close( )
	self:Remove( )
	self = nil
	catherine.vgui.inventory = nil
end

vgui.Register( "catherine.vgui.inventory", PANEL, "DFrame" )
