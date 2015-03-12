local Plugin = Plugin
local PANEL = { }

function PANEL:Init( )
	catherine.vgui.bugreport = self

	self.notifyMessage = nil
	self.isError = false
	self.data = {
		title = "",
		titleLen = 0,
		value = "",
		valueLen = 0
	}
	self.canReport = false
	self.oneFin = false
	self.twoFin = false
	self.acceptMaterial = Material( "icon16/accept.png" )
	self.cantMaterial = Material( "icon16/error.png" )
	self.vguis = { }
	
	self:SetMenuSize( ScrW( ) * 0.5, ScrH( ) * 0.7 )
	self:SetMenuName( "Bug Report" )
	
	self.warningLabel = vgui.Create( "DLabel", self )
	self.warningLabel:SetPos( 10, 30 )
	self.warningLabel:SetColor( Color( 255, 50, 50 ) )
	self.warningLabel:SetFont( "catherine_normal20" )
	self.warningLabel:SetText( "Don't send spam report, please :) ..." )
	self.warningLabel:SizeToContents( )
	
	self.vguis[ #self.vguis + 1 ] = self.warningLabel
	
	self.titleLabel = vgui.Create( "DLabel", self )
	self.titleLabel:SetPos( 10, 60 )
	self.titleLabel:SetColor( Color( 50, 50, 50 ) )
	self.titleLabel:SetFont( "catherine_normal20" )
	self.titleLabel:SetText( "Report Title" )
	self.titleLabel:SizeToContents( )
	
	self.vguis[ #self.vguis + 1 ] = self.titleLabel
	
	self.titleEnt = vgui.Create( "DTextEntry", self )
	self.titleEnt:SetPos( 20 + self.titleLabel:GetSize( ), 60 )
	self.titleEnt:SetSize( self.w - ( 20 + self.titleLabel:GetSize( ) ) - 40, 20 )	
	self.titleEnt:SetFont( "catherine_normal15" )
	self.titleEnt:SetText( "" )
	self.titleEnt:SetAllowNonAsciiCharacters( true )
	self.titleEnt.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 50, 50, 50, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	self.titleEnt.OnTextChanged = function( pnl )
		self.data.title = pnl:GetText( )
		self.data.titleLen = self.data.title:len( )
	end
	
	self.vguis[ #self.vguis + 1 ] = self.titleEnt
	
	self.valueLabel = vgui.Create( "DLabel", self )
	self.valueLabel:SetPos( 10, 100 )
	self.valueLabel:SetColor( Color( 50, 50, 50 ) )
	self.valueLabel:SetFont( "catherine_normal20" )
	self.valueLabel:SetText( "Report Message" )
	self.valueLabel:SizeToContents( )
	
	self.vguis[ #self.vguis + 1 ] = self.valueLabel
	
	self.valueEnt = vgui.Create( "DTextEntry", self )
	self.valueEnt:SetPos( 10, 125 )
	self.valueEnt:SetSize( self.w - 50, self.h - ( 125 + 50 ) )	
	self.valueEnt:SetFont( "catherine_normal15" )
	self.valueEnt:SetText( "" )
	self.valueEnt:SetMultiline( true )
	self.valueEnt:SetAllowNonAsciiCharacters( true )
	self.valueEnt.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 50, 50, 50, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	self.valueEnt.OnTextChanged = function( pnl )
		self.data.value = pnl:GetText( )
		self.data.valueLen = self.data.value:len( )
	end
	
	self.vguis[ #self.vguis + 1 ] = self.valueEnt
	
	self.sendReport = vgui.Create( "catherine.vgui.button", self )
	self.sendReport:SetPos( 10, self.h - 40 )
	self.sendReport:SetSize( self.w - 20, 30 )
	self.sendReport:SetStr( "Send This Report!" )
	self.sendReport:SetStrColor( Color( 50, 50, 50 ) )
	self.sendReport:SetStrFont( "catherine_normal20" )
	self.sendReport.Click = function( )
		Derma_Query( "Are your sure send this report?", "WARNING", "Yes", function( )
			self:SendReport( )
			end, "No",
			function( )
			
			end
		)
	end
	
	self.vguis[ #self.vguis + 1 ] = self.sendReport
	
	if ( self.player:GetNWBool( "catherine.plugin.bugreport.Cooltime" ) == true ) then
		self:SetNotify( false, "You have report already, please wait.", true )
	end
end

function PANEL:SendReport( )
	if ( !self.oneFin or !self.twoFin ) then
		self:SetNotify( false, "Can't send report, check out all the terms :) ...", false, true )
		return
	end
	self:SetNotify( false, "Sending report, please wait :) ...", true )
	netstream.Start( "catherine.plugin.bugreport.Send", { self.data.title, self.data.value } )
end

function PANEL:MenuPaint( w, h )
	if ( self.notifyMessage ) then
		catherine.util.DrawCoolText( self.notifyMessage, "catherine_normal25", w / 2, h / 2 )
		return
	end
	
	if ( self.data.titleLen > 10 and self.data.titleLen < Plugin.maxTitle ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( self.acceptMaterial )
		surface.DrawTexturedRect( self.w - 16 - 10, 60 + 3, 16, 16 )
		self.oneFin = true
	else
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( self.cantMaterial )
		surface.DrawTexturedRect( self.w - 16 - 10, 60 + 3, 16, 16 )
		self.oneFin = false
	end
	
	if ( self.data.valueLen > 20 and self.data.valueLen < Plugin.maxValue ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( self.acceptMaterial )
		surface.DrawTexturedRect( self.w - 16 - 10, 125 + 3, 16, 16 )
		self.twoFin = true
	else
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( self.cantMaterial )
		surface.DrawTexturedRect( self.w - 16 - 10, 125 + 3, 16, 16 )
		self.twoFin = false
	end
end

function PANEL:Think( )

end

function PANEL:SetNotify( isFin, message, isStuck, isError )
	for k, v in pairs( self.vguis ) do
		v:SetVisible( false )
	end
	self.notifyMessage = message
	self.isError = isError
	if ( !isFin ) then
		if ( !isStuck ) then
			timer.Simple( 4, function( )
				if ( !IsValid( self ) ) then return end
				self.notifyMessage = nil
				for k, v in pairs( self.vguis ) do
					v:SetVisible( true )
				end
			end )
		end
	else
		timer.Simple( 4, function( )
			if ( !IsValid( self ) ) then return end
			self:Close( )
		end )
	end
end

vgui.Register( "catherine.vgui.bugreport", PANEL, "catherine.vgui.menuBase" )


hook.Add( "AddMenuItem", "catherine.vgui.bugreport", function( tab )
	tab[ "Bug Report" ] = function( menuPnl, itemPnl )
		return vgui.Create( "catherine.vgui.bugreport", menuPnl )
	end
end )