local PANEL = { }

function PANEL:Init( )
	catherine.vgui.attribute = self

	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( "Attribute" )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end

	self:BuildAttribute( )
end

function PANEL:BuildAttribute( )
	self.Lists:Clear( )
	local delta = 0
	for k, v in pairs( catherine.attribute.GetAll( ) ) do
		local item = vgui.Create( "catherine.vgui.attributeItem" )
		item:SetTall( 90 )
		item:SetAttribute( v )
		item:SetProgress( catherine.attribute.GetProgress( v ) )
		item:AlphaTo( 255, 0.1, delta )
		delta = delta + 0.05
		
		self.Lists:AddItem( item )
	end
end

vgui.Register( "catherine.vgui.attribute", PANEL, "catherine.vgui.menuBase" )


local PANEL = { }

function PANEL:Init( )
	self.attributeTable, self.attAni, self.attTextAni, self.attProgress = nil, 0, 0, 0
end

function PANEL:Paint( w, h )
	if ( !self.attributeTable ) then return end
	self.attAni = Lerp( 0.08, self.attAni, ( self.attProgress / self.attributeTable.max ) * 360 )
	self.attTextAni = Lerp( 0.1, self.attTextAni, ( self.attProgress / self.attributeTable.max ) )
	
	draw.NoTexture( )
	surface.SetDrawColor( 200, 200, 200, 255 )
	catherine.geometry.DrawCircle( w - ( h / 3 ) - 15, h / 2, h / 3, 5, 90, 360, 100 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 90, 90, 90, 255 )
	catherine.geometry.DrawCircle( w - ( h / 3 ) - 15, h / 2, h / 3, 5, 90, self.attAni, 100 )
	
	if ( self.attributeTable.image ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material( self.attributeTable.image, "smooth" ) )
		surface.DrawTexturedRect( 10, 10, 70, 70 )
	else
		draw.RoundedBox( 0, 10, 10, 70, 70, Color( 50, 50, 50, 100 ) )
	end
	
	draw.SimpleText( self.attributeTable.name, "catherine_normal35", 100, 30, Color( 90, 90, 90, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( self.attributeTable.desc, "catherine_normal15", 100, 60, Color( 90, 90, 90, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
	
	draw.SimpleText( math.Round( self.attTextAni * 100 ) .. " %", "catherine_normal20", w - ( h / 3 ) - 15, h / 2, Color( 90, 90, 90, 255 ), 1, 1 )
end

function PANEL:SetAttribute( attributeTable )
	self.attributeTable = attributeTable
end

function PANEL:SetProgress( progress )
	self.attProgress = progress
end

vgui.Register( "catherine.vgui.attributeItem", PANEL, "DPanel" )

hook.Add( "AddMenuItem", "catherine.vgui.attribute", function( tab )
	tab[ "Attribute" ] = function( menuPnl, itemPnl )
		return vgui.Create( "catherine.vgui.attribute", menuPnl )
	end
end )