concommand.Add("char_open", function( )
	if ( IsValid( catherine.vgui.character ) ) then
		catherine.vgui.character:Close( )
		catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
	else
		catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
	end
end)
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
			draw.SimpleText( Schema.Name, "catherine_font01_40", w / 2, h * 0.3, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( Schema.Desc, "catherine_font01_20", w / 2, h * 0.3 + 60, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end

	self.NewCharacter = vgui.Create( "catherine.vgui.button", self )
	self.NewCharacter:SetPos( 5, self.h - 35 )
	self.NewCharacter:SetSize( self.w * 0.2, 30 )
	self.NewCharacter:SetStr( "Create" )
	self.NewCharacter:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.NewCharacter.Click = function( )
		if ( !self.createCharacter ) then 
			self:CreateCharacter_Init( )
			self:NextStage( )
		end
	end
	
	self.LoadCharacter = vgui.Create( "catherine.vgui.button", self )
	self.LoadCharacter:SetPos( 10 + self.w * 0.2, self.h - 35 )
	self.LoadCharacter:SetSize( self.w * 0.2, 30 )
	self.LoadCharacter:SetStr( "Load" )
	self.LoadCharacter:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.LoadCharacter.Click = function( )

	end
	
	self.Disconnect = vgui.Create( "catherine.vgui.button", self )
	self.Disconnect:SetPos( self.w - self.w * 0.2 - 5, self.h - 35 )
	self.Disconnect:SetSize( self.w * 0.2, 30 )
	self.Disconnect:SetStr( "Disconnect" )
	self.Disconnect:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.Disconnect.Click = function( )
		self:Close( )
	end
	
	self.Previous = vgui.Create( "catherine.vgui.button", self )
	self.Previous:SetPos( self.w * 0.2, 50 )
	self.Previous:SetSize( 30, 30 )
	self.Previous:SetStr( "<" )
	self.Previous:SetFont( "catherine_font01_30" )
	self.Previous.Click = function( )
		self:PreviousStage( )
	end
	
	self.Cancel = vgui.Create( "catherine.vgui.button", self )
	self.Cancel:SetPos( self.w / 2 - ( 30 / 2 ), 50 )
	self.Cancel:SetSize( 30, 30 )
	self.Cancel:SetStr( "X" )
	self.Cancel:SetFont( "catherine_font01_30" )
	self.Cancel.Click = function( )
		self:CancelStage( )
	end
	
	self.Next = vgui.Create( "catherine.vgui.button", self )
	self.Next:SetPos( self.w * 0.8, 50 )
	self.Next:SetSize( 30, 30 )
	self.Next:SetStr( ">" )
	self.Next:SetFont( "catherine_font01_30" )
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
	else
		self.Previous:SetStatus( true )
	end
	
	if ( self.createCharacter.currProgress == #self.createCharacter.progressList ) then
		self.Next:SetStatus( false )
	else
		self.Next:SetStatus( true )
	end
end

function PANEL:CreateCharacter_Init( )
	self.createCharacter = { }
	self.createCharacter.progressList = {
		"catherine.character.create.stageOne",
		"catherine.character.create.stageTwo"
	}
	self.createCharacter.data = { }
	self.createCharacter.currProgress = 0
	self.createCharacter.maxProgress = #self.createCharacter.progressList
	self.status = 1
end

			

function PANEL:CancelStage( )
	if ( IsValid( self.createCharacter.activePanel ) ) then
		self.createCharacter.activePanel:AlphaTo( 0, 0.3, 0 )
		timer.Simple( 0.3, function( )
			if ( !IsValid( self.createCharacter.activePanel ) ) then return end
			self.createCharacter.activePanel:Remove( )
			self.createCharacter.activePanel = nil
			self.createCharacter = nil
		end )
	end
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
				self.createCharacter.activePanel:SetAlpha( 0 )
				self.createCharacter.activePanel:AlphaTo( 255, 0.3, 0 )
				self.createCharacter.activePanel:SetPos( ScrW( ) / 2 - self.createCharacter.activePanel:GetWide( ) / 2, ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2 )
				//self.createCharacter.activePanel:MoveTo( 0 - self.createCharacter.activePanel:GetWide( ), ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2, 1, 0 )
			else
				self.createCharacter.activePanel:AlphaTo( 0, 0.3, 0 )
				self.createCharacter.data = table.Copy( self.createCharacter.activePanel.data )
				timer.Simple( 0.3, function( )
					if ( !IsValid( self.createCharacter.activePanel ) ) then return end
					
					self.createCharacter.activePanel:Remove( )
					self.createCharacter.activePanel = nil
					
					self.createCharacter.activePanel = vgui.Create( self.createCharacter.progressList[ self.createCharacter.currProgress ], self )
					self.createCharacter.activePanel:SetSize( 512, 312 )
					self.createCharacter.activePanel:SetPos( ScrW( ) / 2 - self.createCharacter.activePanel:GetWide( ) / 2, ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2 )
					self.createCharacter.activePanel:SetAlpha( 0 )
					self.createCharacter.activePanel:AlphaTo( 255, 0.3, 0 )
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

			self.createCharacter.activePanel:AlphaTo( 0, 0.3, 0 )
			self.createCharacter.activePanel.data = nil
			//self.createCharacter.data = table.Copy( self.createCharacter.activePanel.data )
			timer.Simple( 0.3, function( )
				if ( !IsValid( self.createCharacter.activePanel ) ) then return end
				
				self.createCharacter.activePanel:Remove( )
				self.createCharacter.activePanel = nil
				
				self.createCharacter.activePanel = vgui.Create( self.createCharacter.progressList[ self.createCharacter.currProgress ], self )
				self.createCharacter.activePanel:SetSize( 512, 312 )
				self.createCharacter.activePanel:SetPos( ScrW( ) / 2 - self.createCharacter.activePanel:GetWide( ) / 2, ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2 )
				self.createCharacter.activePanel:SetAlpha( 0 )
				self.createCharacter.activePanel:AlphaTo( 255, 0.3, 0 )
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
	catherine.vgui.character = nil
end

vgui.Register( "catherine.vgui.character", PANEL, "DFrame" )


local PANEL = { }

function PANEL:Init( )
	
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	draw.NoTexture( )
	surface.DrawLine( 0, 5, 5, 0 )
	
	draw.RoundedBox( 0, 0, 5, 1, 10, Color( 255, 255, 255, 255 ) )
	draw.RoundedBox( 0, 5, 0, 10, 1, Color( 255, 255, 255, 255 ) )
	
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	draw.NoTexture( )
	surface.DrawLine( w, h - 6, w - 6, h )
	
	draw.RoundedBox( 0, w - 1, h - 15, 1, 10, Color( 255, 255, 255, 255 ) )
	draw.RoundedBox( 0, w - 15, h - 1, 10, 1, Color( 255, 255, 255, 255 ) )
end

vgui.Register( "catherine.character.create.stageOne", PANEL, "DPanel" )

local PANEL = { }

function PANEL:Init( )

end

function PANEL:Paint( w, h )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	draw.NoTexture( )
	surface.DrawLine( 0, 5, 5, 0 )
	
	draw.RoundedBox( 0, 0, 5, 1, 10, Color( 255, 255, 255, 255 ) )
	draw.RoundedBox( 0, 5, 0, 10, 1, Color( 255, 255, 255, 255 ) )
	
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	draw.NoTexture( )
	surface.DrawLine( w, h - 6, w - 6, h )
	
	draw.RoundedBox( 0, w - 1, h - 15, 1, 10, Color( 255, 255, 255, 255 ) )
	draw.RoundedBox( 0, w - 15, h - 1, 10, 1, Color( 255, 255, 255, 255 ) )
end

vgui.Register( "catherine.character.create.stageTwo", PANEL, "DPanel" )