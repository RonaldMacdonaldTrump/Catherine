local BUTTON = { }

function BUTTON:Init( )
	local rgb = Color
	self.Font = "Default"
	self.Text = ""
	self.Status = true
	self.CursorIsOn = false
	self.ButtonPressed = false
	self.ButtonPressing = false
	self.PressingCurTime = nil
	
	self.ChangeTime = 0.05
	self.Theme = {
		rgb( 255, 255, 255, 255 ),
		rgb( 10, 10, 10, 255 ),
		rgb( 0, 0, 0, 255 ),
		rgb( 255, 255, 255, 255 ),
		rgb( 0, 0, 0, 255 ),
		rgb( 0, 0, 0, 255 )
	}
	self:SetText( "" )
	
	self.BackgroundColor = self.Theme[ 1 ]
	self.TextColor = self.Theme[ 3 ]
	self.LineColor = self.Theme[ 5 ]
	
	self.BackgroundColor_Ani = Color( 0, 0, 0, 0 )
	self.TextColor_Ani = Color( 0, 0, 0, 0 )
	self.LineColor_Ani = Color( 0, 0, 0, 0 )
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

function BUTTON:SetTheme( tab )
	self.Theme = tab
end

function BUTTON:SetStatus( bool )
	self.Status = bool
end

function BUTTON:Click( ) end

function BUTTON:DoClick( )
	surface.PlaySound( "buttons/lightswitch2.wav" )
	if ( !self.Status ) then return end
	self:Click( func )
end

function BUTTON:PaintBackground( w, h ) end
function BUTTON:PaintOverThenBackground( w, h ) end
function BUTTON:PaintOverAll( w, h ) end

function BUTTON:Paint( w, h )
//	self:PaintBackground( w, h )
//	self:PaintOverThenBackground( w, h )

	if ( self.CursorIsOn ) then
		self.BackgroundColor = self.Theme[ 2 ]
		self.TextColor = self.Theme[ 4 ]
		self.LineColor = self.Theme[ 6 ]
	else
		self.BackgroundColor = self.Theme[ 1 ]
		self.TextColor = self.Theme[ 3 ]
		self.LineColor = self.Theme[ 5 ]		
	end

	self.BackgroundColor_Ani.r = Lerp( self.ChangeTime, self.BackgroundColor_Ani.r, self.BackgroundColor.r )
	self.BackgroundColor_Ani.g = Lerp( self.ChangeTime, self.BackgroundColor_Ani.g, self.BackgroundColor.g )
	self.BackgroundColor_Ani.b = Lerp( self.ChangeTime, self.BackgroundColor_Ani.b, self.BackgroundColor.b )
	self.BackgroundColor_Ani.a = Lerp( self.ChangeTime, self.BackgroundColor_Ani.a, self.BackgroundColor.a )

	self.TextColor_Ani.r = Lerp( self.ChangeTime, self.TextColor_Ani.r, self.TextColor.r )
	self.TextColor_Ani.g = Lerp( self.ChangeTime, self.TextColor_Ani.g, self.TextColor.g )
	self.TextColor_Ani.b = Lerp( self.ChangeTime, self.TextColor_Ani.b, self.TextColor.b )
	self.TextColor_Ani.a = Lerp( self.ChangeTime, self.TextColor_Ani.a, self.TextColor.a )
	
	self.LineColor_Ani.r = Lerp( self.ChangeTime, self.LineColor_Ani.r, self.LineColor.r )
	self.LineColor_Ani.g = Lerp( self.ChangeTime, self.LineColor_Ani.g, self.LineColor.g )
	self.LineColor_Ani.b = Lerp( self.ChangeTime, self.LineColor_Ani.b, self.LineColor.b )
	self.LineColor_Ani.a = Lerp( self.ChangeTime, self.LineColor_Ani.a, self.LineColor.a )
	
	surface.SetDrawColor( self.BackgroundColor_Ani )
	surface.SetMaterial( Material( "gui/center_gradient" ) )
	surface.DrawTexturedRect( 0, h - 3, w, 3 )
	
	draw.SimpleText( self.Text, self.Font, w / 2, h / 2, self.TextColor_Ani, 1, 1 )

	self:PaintOverAll( w, h )
end

vgui.Register( "nexus.vgui.button", BUTTON, "DButton" )