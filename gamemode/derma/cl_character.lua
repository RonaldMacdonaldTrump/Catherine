local PANEL = { }

function PANEL:Init( )
	local LP = LocalPlayer( )
	
	self.w = ScrW( )
	self.h = ScrH( )

	self.blur = Material( "pp/blurscreen" )
	self.status = nil
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:MakePopup( )
	self.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.SetMaterial( Material( "gui/gradient_up" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		if ( !self.createCharacter ) then
			draw.SimpleText( Schema.Name, "nexus_font01_40", w / 2, h * 0.3, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( Schema.Desc, "nexus_font01_20", w / 2, h * 0.3 + 60, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end

	self.CreateNewCharacter = vgui.Create( "nexus.vgui.button", self )
	self.CreateNewCharacter:SetPos( 5, self.h - 35 )
	self.CreateNewCharacter:SetSize( self.w * 0.2, 30 )
	self.CreateNewCharacter:SetStr( "Create" )
	self.CreateNewCharacter:SetFont( "nexus_font01_20" )
	self.CreateNewCharacter:RunFadeInAnimation( 0.4, 2 )
	self.CreateNewCharacter:SetTheme(
		{
			Color( 255, 255, 255, 0 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 0, 0, 0, 0 ),
			Color( 0, 0, 0, 0 )
		}
	)

	self.CreateNewCharacter.PaintOverAll = function( pnl, w, h )

	end
	self.CreateNewCharacter.Click = function( )
		if ( !self.createCharacter ) then 
			self:CreateCharacter_Init( )
			self:NextStage( )
		end
	end
	
	self.LoadCharacter = vgui.Create( "nexus.vgui.button", self )
	self.LoadCharacter:SetPos( 10 + self.w * 0.2, self.h - 35 )
	self.LoadCharacter:SetSize( self.w * 0.2, 30 )
	self.LoadCharacter:SetStr( "Load" )
	self.LoadCharacter:SetFont( "nexus_font01_20" )
	self.LoadCharacter:RunFadeInAnimation( 0.4, 2 )
	self.LoadCharacter:SetTheme(
		{
			Color( 255, 255, 255, 0 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 0, 0, 0, 0 ),
			Color( 0, 0, 0, 0 )
		}
	)
	self.LoadCharacter.PaintOverAll = function( pnl, w, h )

	end
	self.LoadCharacter.Click = function( )

	end
	
	self.Disconnect = vgui.Create( "nexus.vgui.button", self )
	self.Disconnect:SetPos( self.w - self.w * 0.2 - 5, self.h - 35 )
	self.Disconnect:SetSize( self.w * 0.2, 30 )
	self.Disconnect:SetStr( "Disconnect" )
	self.Disconnect:SetFont( "nexus_font01_20" )
	self.Disconnect:RunFadeInAnimation( 0.4, 2 )
	self.Disconnect:SetTheme(
		{
			Color( 255, 255, 255, 0 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 0, 0, 0, 0 ),
			Color( 0, 0, 0, 0 )
		}
	)
	self.Disconnect.PaintOverAll = function( pnl, w, h )

	end
	self.Disconnect.Click = function( )
		self:Close( )
	end
	
	self.Previous = vgui.Create( "nexus.vgui.button", self )
	self.Previous:SetPos( self.w * 0.2, 50 )
	self.Previous:SetSize( 30, 30 )
	self.Previous:SetStr( "<" )
	self.Previous:SetFont( "nexus_font01_30" )
	self.Previous:RunFadeInAnimation( 0.4, 2 )
	self.Previous:SetTheme(
		{
			Color( 255, 255, 255, 0 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 0, 0, 0, 0 ),
			Color( 0, 0, 0, 0 )
		}
	)
	self.Previous.PaintOverAll = function( pnl, w, h )

	end
	self.Previous.Click = function( )
		self:PreviousStage( )
	end
	
	self.Cancel = vgui.Create( "nexus.vgui.button", self )
	self.Cancel:SetPos( self.w / 2 - ( 30 / 2 ), 50 )
	self.Cancel:SetSize( 30, 30 )
	self.Cancel:SetStr( "X" )
	self.Cancel:SetFont( "nexus_font01_30" )
	self.Cancel:RunFadeInAnimation( 0.4, 2 )
	self.Cancel:SetTheme(
		{
			Color( 255, 255, 255, 0 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 0, 0, 0, 0 ),
			Color( 0, 0, 0, 0 )
		}
	)
	self.Cancel.PaintOverAll = function( pnl, w, h )

	end
	self.Cancel.Click = function( )
		self:CancelStage( )
	end
	
	self.Next = vgui.Create( "nexus.vgui.button", self )
	self.Next:SetPos( self.w * 0.8, 50 )
	self.Next:SetSize( 30, 30 )
	self.Next:SetStr( ">" )
	self.Next:SetFont( "nexus_font01_30" )
	self.Next:RunFadeInAnimation( 0.4, 2 )
	self.Next:SetTheme(
		{
			Color( 255, 255, 255, 0 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 255, 255, 255, 255 ),
			Color( 0, 0, 0, 0 ),
			Color( 0, 0, 0, 0 )
		}
	)
	self.Next.PaintOverAll = function( pnl, w, h )

	end
	self.Next.Click = function( )
		self:NextStage( )
	end
	
	self.CharcreateModelPreview = vgui.Create( "DModelPanel", self )
	self.CharcreateModelPreview:SetSize( self.w * 0.35, self.h * 0.8 )
	self.CharcreateModelPreview:SetPos( self.w, self.h * 0.1 )
	self.CharcreateModelPreview.OnCursorEntered = function() 
	end
	self.CharcreateModelPreview.OnCursorExited = function() 
	end
	self.CharcreateModelPreview:SetDisabled( false )
	self.CharcreateModelPreview:SetCursor( "none" )
	self.CharcreateModelPreview:MoveToBack( )
	self.CharcreateModelPreview:SetVisible( false )
	self.CharcreateModelPreview:SetFOV( 60 )
	self.CharcreateModelPreview.LayoutEntity = function( pnl, entity )
		entity:SetAngles( Angle( 0, 45, 0 ) )
		self.CharcreateModelPreview:RunAnimation( )
	end
end

function PANEL:Think( )
	if ( !self.createCharacter ) then
		self.Previous:SetVisible( false )
		self.Next:SetVisible( false )
		self.Cancel:SetVisible( false )
		return
	else
		self.Previous:SetVisible( true )
		self.Next:SetVisible( true )
		self.Cancel:SetVisible( true )
	end
	
	if ( self.createCharacter.currProgress == 1 ) then
		self.Previous:SetStatus( false )
		self.Previous:SetAlpha( 30 )
	else
		self.Previous:SetStatus( true )
		self.Previous:SetAlpha( 255 )
	end
	
	if ( self.createCharacter.currProgress == #self.createCharacter.progressList ) then
		self.Next:SetStatus( false )
		self.Next:SetAlpha( 30 )
	else
		self.Next:SetStatus( true )
		self.Next:SetAlpha( 255 )
	end
end

function PANEL:CreateCharacter_Init( )
	self.createCharacter = { }
	self.createCharacter.progressList = {
		"nexus.character.create.stageOne",
		"nexus.character.create.stageTwo"
	}
	self.createCharacter.data = { }
	self.createCharacter.currProgress = 0
	self.createCharacter.maxProgress = #self.createCharacter.progressList
	self.status = 1
end

			

function PANEL:CancelStage( )
	if ( IsValid( self.createCharacter.activePanel ) ) then
		self.createCharacter.activePanel:Remove( )
		self.createCharacter.activePanel = nil
	end
	self.createCharacter = nil
	self.status = 0
end

function PANEL:NextStage( )
	if ( !self.createCharacter ) then return end
	if ( self.status == 1 ) then
		if ( self.createCharacter.currProgress < self.createCharacter.maxProgress ) then
			self.createCharacter.currProgress = self.createCharacter.currProgress + 1
			if ( !self.createCharacter.activePanel ) then
				self.createCharacter.activePanel = vgui.Create( self.createCharacter.progressList[ self.createCharacter.currProgress ], self )
				self.createCharacter.activePanel:SetSize( 512, 312 )
				self.createCharacter.activePanel:SetPos( ScrW( ) / 2 - self.createCharacter.activePanel:GetWide( ) / 2, ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2 )
				//self.createCharacter.activePanel:MoveTo( 0 - self.createCharacter.activePanel:GetWide( ), ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2, 1, 0 )
			else
				self.createCharacter.activePanel:AlphaTo( 0, 1, 0 )
				self.createCharacter.data = table.Copy( self.createCharacter.activePanel.data )
				timer.Simple( 1, function( )
					self.createCharacter.activePanel:Remove( )
					self.createCharacter.activePanel = nil
					
					self.createCharacter.activePanel = vgui.Create( self.createCharacter.progressList[ self.createCharacter.currProgress ], self )
					self.createCharacter.activePanel:SetSize( 512, 312 )
					self.createCharacter.activePanel:SetPos( ScrW( ) / 2 - self.createCharacter.activePanel:GetWide( ) / 2, ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2 )
					self.createCharacter.activePanel:SetAlpha( 0 )
					self.createCharacter.activePanel:AlphaTo( 255, 1, 0 )
					//self.createCharacter.activePanel:SetPos( ScrW( ), ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2 )
					//self.createCharacter.activePanel:MoveTo( ScrW( ) / 2 - self.createCharacter.activePanel:GetWide( ) / 2, ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2, 1, 0 )
				end )
			end
		else
			print("Cant!")
		end
	else
	
	end
end

function PANEL:PreviousStage( )
	if ( !self.createCharacter ) then return end
	if ( self.status == 1 ) then
		if ( self.createCharacter.currProgress > 1 ) then
			self.createCharacter.currProgress = self.createCharacter.currProgress - 1

			self.createCharacter.activePanel:AlphaTo( 0, 1, 0 )
			self.createCharacter.activePanel.data = nil
			//self.createCharacter.data = table.Copy( self.createCharacter.activePanel.data )
			timer.Simple( 1, function( )
				self.createCharacter.activePanel:Remove( )
				self.createCharacter.activePanel = nil
				
				self.createCharacter.activePanel = vgui.Create( self.createCharacter.progressList[ self.createCharacter.currProgress ], self )
				self.createCharacter.activePanel:SetSize( 512, 312 )
				self.createCharacter.activePanel:SetPos( ScrW( ) / 2 - self.createCharacter.activePanel:GetWide( ) / 2, ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2 )
				self.createCharacter.activePanel:SetAlpha( 0 )
				self.createCharacter.activePanel:AlphaTo( 255, 1, 0 )
			end )
		else
			print("Cant!")
		end
	else
	
	end
end

function PANEL:Close( )
	self:Remove( )
	self = nil
	nexus.vgui.character = nil
end

vgui.Register( "nexus.vgui.character", PANEL, "DFrame" )


local PANEL = { }

function PANEL:Init( )
	
end

vgui.Register( "nexus.character.create.stageOne", PANEL, "DPanel" )

local PANEL = { }

function PANEL:Init( )

end

vgui.Register( "nexus.character.create.stageTwo", PANEL, "DPanel" )