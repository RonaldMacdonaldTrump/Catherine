local PANEL = { }

function PANEL:Init( )
	self.invWeight = 0
	self.invMaxWeight = 0
	self.invWeightAni = 0
	self.size = 10
	self.invWeightTextAni = 0
	self.weightStr = catherine.configs.spaceString
end

function PANEL:Paint( w, h )
	self.invWeightAni = Lerp( 0.08, self.invWeightAni, ( self.invWeight / self.invMaxWeight ) * 360 )
	self.invWeightTextAni = Lerp( 0.08, self.invWeightTextAni, ( self.invWeight / self.invMaxWeight ) )
	
	draw.NoTexture( )
	surface.SetDrawColor( 235, 235, 235, 255 )
	catherine.geometry.DrawCircle( w / 2, h / 2, self.size, 5, 90, 360, 100 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 90, 90, 90, 255 )
	catherine.geometry.DrawCircle( w / 2, h / 2, self.size, 5, 90, self.invWeightAni, 100 )

	draw.SimpleText( math.Round( self.invWeightTextAni * 100 ) .. " %", "catherine_normal25", w / 2, h / 2, Color( 90, 90, 90, 255 ), 1, 1 )
end

function PANEL:SetCircleSize( size )
	self.size = size
end

function PANEL:SetWeight( weight, maxWeight )
	self.invWeight = weight
	self.invMaxWeight = maxWeight
end

vgui.Register( "catherine.vgui.weight", PANEL, "DPanel" )