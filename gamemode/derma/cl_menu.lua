local PANEL = { }

function PANEL:Init( )
	if ( IsValid( catherine.vgui.menu ) ) then
		catherine.vgui.menu:Remove( )
	end
	catherine.vgui.menu = self
	
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ), ScrH( )
	self.menuItems = { }
	self.lastmenuPnl = nil
	self.lastmenuName = ""
	self.closeing = false
	self.blurAmount = 0

	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.1, 0 )
	self:MakePopup( )
	
	self.ListsBase = vgui.Create( "DPanel", self )
	self.ListsBase:SetSize( self.w, 50 )
	self.ListsBase:SetPos( 0, self.h )
	self.ListsBase:MoveTo( 0, self.h - self.ListsBase:GetTall( ), 0.2, 0.1, nil, function( )
		hook.Run( "AddMenuItem", self.menuItems )
		
		local delta = 0
		for k, v in pairs( self.menuItems ) do
			local itemPnl = self:AddMenuItem( k, v )
			itemPnl:SetAlpha( 0 )
			itemPnl:AlphaTo( 255, 0.2, delta )
			delta = delta + 0.05
		end
	end )
	
	self.ListsBase.Lists = vgui.Create( "DHorizontalScroller", self.ListsBase )
	self.ListsBase.Lists:SetSize( 0, self.ListsBase:GetTall( ) )
end

function PANEL:AddMenuItem( name, func )
	local textW = surface.GetTextSize( name )
	local item = vgui.Create( "DButton" )
	item:SetText( name )
	item:SetFont( "catherine_font01_20" )
	item:SetTextColor( Color( 50, 50, 50 ) )
	item:SetSize( textW + 30, self.ListsBase:GetTall( ) )
	item.Paint = function( pnl, w, h )
		if ( self.lastmenuName == name ) then
			draw.RoundedBox( 0, 0, 0, w, 10, Color( 50, 50, 50, 255 ) )
		end
	end
	item.DoClick = function( pnl )
		if ( self.lastmenuName == name ) then
			if ( IsValid( self.lastmenuPnl ) ) then
				self.lastmenuPnl:Close( )
				self.lastmenuPnl = nil
				self.lastmenuName = ""
			else
				self.lastmenuPnl = func( self, pnl )
				self.lastmenuName = name
			end
		else
			if ( IsValid( self.lastmenuPnl ) ) then
				self.lastmenuPnl:Close( )
				self.lastmenuPnl = func( self, pnl )
				self.lastmenuName = name
			else
				self.lastmenuPnl = func( self, pnl )
				self.lastmenuName = name
			end
		end
	end
	
	self.ListsBase.Lists:AddPanel( item )
	self.ListsBase.Lists:SetWide( math.min( self.ListsBase.Lists:GetWide( ) + item:GetWide( ), self.w ) )
	self.ListsBase.Lists:SetPos( self.w / 2 - self.ListsBase.Lists:GetWide( ) / 2, 0 )
	
	return item
end

function PANEL:OnKeyCodePressed( key )
	if ( key != KEY_TAB ) then return end
	self:Close( )
end

function PANEL:Paint( w, h )
	if ( self.closeing ) then
		self.blurAmount = Lerp( 0.03, self.blurAmount, 0 )
	else
		self.blurAmount = Lerp( 0.03, self.blurAmount, 5 )
	end
	catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
	draw.SimpleText( catherine.cash.GetName( catherine.cash.Get( LocalPlayer( )	) ), "catherine_font01_25", w - 15, h - 70, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

function PANEL:Close( )
	CloseDermaMenus( )
	gui.EnableScreenClicker( false )
	self.closeing = true
	if ( IsValid( self.lastmenuPnl ) ) then
		self.lastmenuPnl:Close( )
	end
	self.ListsBase:MoveTo( self.w / 2 - self.ListsBase:GetWide( ) / 2, self.h, 0.2, 0, nil, function( anim, pnl )
		if ( !IsValid( self ) ) then return end
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.menu", PANEL, "DFrame" )