local BUTTON = { }

function BUTTON:Init( )
	local rgb = Color
	self.Font = "catherine_font01_20"
	self.Text = ""
	self.Status = true
	self.CursorIsOn = false
	self.ButtonPressed = false
	self.ButtonPressing = false
	self.PressingCurTime = nil
	
	self.outlineColorDraw = Color( 0, 0, 0, 0 )
	self.outlineColorOriginal = Color( 0, 0, 0, 0 )
	self.outlineColor = Color( 0, 0, 0, 0 )
	self.textColor = Color( 255, 255, 255, 255 )
	
	self:SetText( "" )
	self:SetFont( self.Font )
end

function BUTTON:Think( )
	if ( self.ButtonPressed ) then
		self.ButtonPressing = true
		self:IsPressing( )
	else
		self.ButtonPressing = false
		self:IsNotPressing( )
	end
end

function BUTTON:SetOutlineColor( col )
	self.outlineColorOriginal = col
end

function BUTTON:SetTextColor( col )
	self.textColor = col
end

function BUTTON:SetStr( str )
	self.Text = str
end

function BUTTON:GetStr( )
	return self.Text
end

function BUTTON:SetFont( font )
	self.Font = font
end

function BUTTON:CursorOn( ) end

function BUTTON:CursorNotOn( ) end

function BUTTON:SetThemeChangeTime( time )
	self.ChangeTime = time
end

function BUTTON:OnCursorEntered( )
	self.CursorIsOn = true
	self:CursorOn( )
end

function BUTTON:OnCursorExited( )
	self.CursorIsOn = false
	self:CursorNotOn( )
end

function BUTTON:OnMousePressed( )
	self.ButtonPressed = true
	self:OnPress( )
	self:DoClick( )
end

function BUTTON:OnMouseReleased( )
	self.ButtonPressed = false
	self:OnRelease( )
end

function BUTTON:OnPress( ) end

function BUTTON:OnRelease( ) end

function BUTTON:IsPressing( ) end

function BUTTON:IsNotPressing( ) end

function BUTTON:RunFadeInAnimation( time, delay )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, time or 0.1, delay or 0 )
end

function BUTTON:SetStatus( bool )
	self.Status = bool
	if ( bool == true ) then
		self:SetAlpha( 255 )
	else
		self:SetAlpha( 50 )
	end
end

function BUTTON:Click( ) end

function BUTTON:DoClick( )
	surface.PlaySound( "buttons/lightswitch2.wav" )
	if ( !self.Status ) then return end
	self:Click( func )
end

function BUTTON:PaintOverAll( w, h ) end

function BUTTON:Paint( w, h )
	if ( self.CursorIsOn ) then
		self.outlineColor = self.outlineColorOriginal
	else
		self.outlineColor = Color( 0, 0, 0, 0 )
	end
	
	self.outlineColorDraw.r = Lerp( 0.03, self.outlineColorDraw.r, self.outlineColor.r )
	self.outlineColorDraw.g = Lerp( 0.03, self.outlineColorDraw.g, self.outlineColor.g )
	self.outlineColorDraw.b = Lerp( 0.03, self.outlineColorDraw.b, self.outlineColor.b )
	self.outlineColorDraw.a = Lerp( 0.03, self.outlineColorDraw.a, self.outlineColor.a )

	surface.SetDrawColor( self.outlineColorDraw )
	draw.NoTexture( )
	surface.DrawLine( 0, 5, 5, 0 )
	
	draw.RoundedBox( 0, 0, 5, 1, 10, self.outlineColorDraw )
	draw.RoundedBox( 0, 5, 0, 10, 1, self.outlineColorDraw )
	
	surface.SetDrawColor( self.outlineColorDraw )
	draw.NoTexture( )
	surface.DrawLine( w, h - 6, w - 6, h )
	
	draw.RoundedBox( 0, w - 1, h - 15, 1, 10, self.outlineColorDraw )
	draw.RoundedBox( 0, w - 15, h - 1, 10, 1, self.outlineColorDraw )
	
	draw.SimpleText( self.Text, self.Font, w / 2, h / 2, self.textColor, 1, 1 )

	self:PaintOverAll( w, h )
end

vgui.Register( "catherine.vgui.button", BUTTON, "DButton" )