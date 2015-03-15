local PANEL = { }

function PANEL:Init( )
	catherine.vgui.version = self
	
	self.version = catherine.update.VERSION
	self.latestVersion = GetGlobalString( "catherine.update.LATESTVERSION", nil )
	self.status = { text = "Checking update ...", status = false, alpha = 255, rotate = 0 }
	
	self:SetMenuSize( ScrW( ) * 0.5, ScrH( ) * 0.5 )
	self:SetMenuName( "Version" )

	if ( !self.player:IsSuperAdmin( ) ) then return end
	self.check = vgui.Create( "catherine.vgui.button", self )
	self.check:SetPos( self.w - ( self.w * 0.2 ) - 10, 30 )
	self.check:SetSize( self.w * 0.2, 30 )
	self.check:SetStr( "Check update!" )
	self.check.Cant = false
	self.check.PaintOverAll = function( pnl )
		if ( self.status.status ) then
			self.check:SetStr( "Checking ..." )
			self.check.Cant = true
		else
			self.check:SetStr( "Check update!" )
			self.check.Cant = false
		end
	end
	self.check:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.check:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.check.Click = function( )
		if ( self.check.Cant ) then return end
		self.status.status = true
		self.status.text = "Checking update ..."
		netstream.Start( "catherine.update.Check" )
	end
end

function PANEL:Refresh( )
	self.version = catherine.update.VERSION
	self.latestVersion = GetGlobalString( "catherine.update.LATESTVERSION", nil )
end

function PANEL:MenuPaint( w, h )
	
	if ( self.status.status ) then
		self.status.rotate = math.Approach( self.status.rotate, self.status.rotate - 3, 3 )
		self.status.alpha = math.Approach( self.status.alpha, 255, 5 )
	else
		self.status.rotate = math.Approach( self.status.rotate, 90, 5 )
		self.status.alpha = math.Approach( self.status.alpha, 0, 3 )
	end
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( Material( "CAT/logo67.png" ) )
	surface.DrawTexturedRect( w / 2 - 512 / 2, h / 2 - 256 / 2, 512, 256 )
	
	if ( self.latestVersion ) then
		draw.SimpleText( "Latest Version - " .. self.latestVersion, "catherine_normal20", w / 2, h - 60, Color( 50, 50, 50, 255 ), 1, 1 )
	else
		draw.SimpleText( "Latest Version - None", "catherine_normal20", w / 2, h - 60, Color( 50, 50, 50, 255 ), 1, 1 )
	end
	
	if ( self.version ) then
		draw.SimpleText( "Your Version - " .. self.version, "catherine_normal20", w / 2, h - 25, Color( 50, 50, 50, 255 ), 1, 1 )
	else
		draw.SimpleText( "Your Version - None", "catherine_normal20", w / 2, h - 25, Color( 50, 50, 50, 255 ), 1, 1 )
	end
	
	if ( self.status.alpha > 0 ) then
		draw.NoTexture( )
		surface.SetDrawColor( 90, 90, 90, self.status.alpha )
		catherine.geometry.DrawCircle( 30, 50, 10, 3, 90, 360, 100 )
		
		draw.NoTexture( )
		surface.SetDrawColor( 255, 255, 255, self.status.alpha )
		catherine.geometry.DrawCircle( 30, 50, 10, 3, self.status.rotate, 100, 100 )
		
		draw.SimpleText( self.status.text, "catherine_normal20", 60, 40, Color( 50, 50, 50, self.status.alpha ), TEXT_ALIGN_LEFT )
	end
end

vgui.Register( "catherine.vgui.version", PANEL, "catherine.vgui.menuBase" )

hook.Add( "AddMenuItem", "catherine.vgui.version", function( tab )
	tab[ "Version" ] = function( menuPnl, itemPnl )
		return vgui.Create( "catherine.vgui.version", menuPnl )
	end
end )