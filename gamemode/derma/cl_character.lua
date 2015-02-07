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
	self.createCharacter.data = { 
		name = "",
		faction = "",
		desc = "",
		model = ""
	}
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
	if ( self.createCharacter.currProgress < self.createCharacter.maxProgress ) then
		if ( !self.createCharacter.activePanel ) then
			self.createCharacter.currProgress = self.createCharacter.currProgress + 1
			self.createCharacter.activePanel = vgui.Create( self.createCharacter.progressList[ self.createCharacter.currProgress ], self )
			self.createCharacter.activePanel:SetSize( 512, 312 )
			self.createCharacter.activePanel:SetAlpha( 0 )
			self.createCharacter.activePanel:AlphaTo( 255, 0.3, 0 )
			self.createCharacter.activePanel:SetPos( ScrW( ) / 2 - self.createCharacter.activePanel:GetWide( ) / 2, ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2 )
			//self.createCharacter.activePanel:MoveTo( 0 - self.createCharacter.activePanel:GetWide( ), ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2, 1, 0 )
		else
			if ( !self.createCharacter.activePanel:CanContinue( ) ) then return end
			self.createCharacter.currProgress = self.createCharacter.currProgress + 1
			self.createCharacter.activePanel:AlphaTo( 0, 0.3, 0 )
			self.createCharacter.activePanel:OnContinue( )
			
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
		if ( self.createCharacter.currProgress == #self.createCharacter.progressList ) then
			self.createCharacter.activePanel:OnContinue( )
			//PrintTable(self.createCharacter.data)
			netstream.Start( "catherine.character.RegisterCharacter", self.createCharacter.data )
		end
	end
end

function PANEL:PreviousStage( )
	if ( !self.createCharacter ) then return end
	if ( self.status == 1 ) then
		if ( self.createCharacter.currProgress > 1 ) then
			self.createCharacter.currProgress = self.createCharacter.currProgress - 1
			self.createCharacter.activePanel:AlphaTo( 0, 0.3, 0 )
			timer.Simple( 0.3, function( )
				if ( !IsValid( self.createCharacter.activePanel ) ) then return end
				
				self.createCharacter.activePanel:Remove( )
				self.createCharacter.activePanel = nil
				
				self.createCharacter.activePanel = vgui.Create( self.createCharacter.progressList[ self.createCharacter.currProgress ], self )
				self.createCharacter.activePanel:SetSize( 512, 312 )
				self.createCharacter.activePanel:SetPos( ScrW( ) / 2 - self.createCharacter.activePanel:GetWide( ) / 2, ScrH( ) / 2 - self.createCharacter.activePanel:GetTall( ) / 2 )
				self.createCharacter.activePanel:SetAlpha( 0 )
				self.createCharacter.activePanel:AlphaTo( 255, 0.3, 0 )
				self.createCharacter.activePanel:OnPrevious( )
				
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
	self.faction = ""
	self.w, self.h = 512, 312
	self.factionImage = nil
	self.factionList = self:GetFactionList( )
	
	self.NameLabel = vgui.Create( "DLabel", self )
	self.NameLabel:SetPos( 10, 10 )
	self.NameLabel:SetColor( Color( 255, 255, 255, 255 ) )
	self.NameLabel:SetFont( "catherine_font01_30" )
	self.NameLabel:SetText( "Faction" )
	self.NameLabel:SizeToContents( )
	
	self.FactionSelect = vgui.Create( "catherine.vgui.button", self )
	self.FactionSelect:SetPos( 40 + self.NameLabel:GetSize( ), 10 )
	self.FactionSelect:SetSize( self.w - ( 40 + self.NameLabel:GetSize( ) ) - 20, 30 )
	self.FactionSelect:SetStr( "Select Faction >" )
	self.FactionSelect:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.FactionSelect.Click = function( )
		local menu = DermaMenu( )
		
		for k, v in pairs( self.factionList ) do
			menu:AddOption( v.name, function( )
				if ( v.image ) then self:SetFactionImage( v.image ) end
				self.faction = v.uniqueID
				self.FactionSelect:SetStr( v.name )
			end )
		end
		
		menu:Open( )
	end
end

function PANEL:GetFactionList( )
	local faction = { }
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.isWhitelist and ( !LocalPlayer( ):HasFaction( v.uniqueID ) ) ) then continue end
		faction[ #faction + 1 ] = v
	end
	
	return faction
end

function PANEL:RefreshPanelList( )
	local faction = { }
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.isWhitelist and ( !LocalPlayer( ):HasFaction( v.uniqueID ) ) ) then continue end
		faction[ #faction + 1 ] = v
	end
	
	return faction
end

function PANEL:SetFactionImage( image )
	self.factionImage = Material( image )
end

function PANEL:GetFactionImage( )
	return self.factionImage
end

function PANEL:CanContinue( )
	if ( self.faction != "" ) then
		return true
	end
	print("Please select faction!")
	return false
end

function PANEL:OnContinue( )
	self:GetParent( ).createCharacter.data.faction = self.faction
end

function PANEL:OnPrevious( )
	print("OH YEAH")
	local factionData = catherine.faction.FindByID( self:GetParent( ).createCharacter.data.faction )
	if ( !factionData ) then return end
	self.FactionSelect:SetStr( factionData.name )
	self:SetFactionImage( factionData.image )
	self.faction = factionData.uniqueID
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 255, 255, 255 ) )
	draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
	
	local factionImage = self:GetFactionImage( )
	if ( factionImage ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( factionImage )
		surface.DrawTexturedRect( w / 2 - 512 / 2, 50, 512, 256 )
	end
end

vgui.Register( "catherine.character.create.stageOne", PANEL, "DPanel" )

local PANEL = { }

function PANEL:Init( )
	self.data = { name = "", desc = "", model = "" }
	self.w, self.h = 512, 312
	self.selectedModel = nil
	
	self.NameLabel = vgui.Create( "DLabel", self )
	self.NameLabel:SetPos( 10, self.h * 0.1 - 20 / 2 )
	self.NameLabel:SetColor( Color( 255, 255, 255, 255 ) )
	self.NameLabel:SetFont( "catherine_font01_20" )
	self.NameLabel:SetText( "Character Name" )
	self.NameLabel:SizeToContents( )
	
	self.DescLabel = vgui.Create( "DLabel", self )
	self.DescLabel:SetPos( 10, self.h * 0.1 + 30 )
	self.DescLabel:SetColor( Color( 255, 255, 255, 255 ) )
	self.DescLabel:SetFont( "catherine_font01_20" )
	self.DescLabel:SetText( "Character Description" )
	self.DescLabel:SizeToContents( )
	
	self.ModelLabel = vgui.Create( "DLabel", self )
	self.ModelLabel:SetPos( 10, self.h * 0.35 - 20 / 2 )
	self.ModelLabel:SetColor( Color( 255, 255, 255, 255 ) )
	self.ModelLabel:SetFont( "catherine_font01_20" )
	self.ModelLabel:SetText( "Character Model" )
	self.ModelLabel:SizeToContents( )
	
	self.Name = vgui.Create( "DTextEntry", self )
	self.Name:SetPos( 40 + self.NameLabel:GetSize( ), self.h * 0.1 - 20 / 2 )
	self.Name:SetSize( self.w - ( 40 + self.NameLabel:GetSize( ) ) - 20, 20 )	
	self.Name:SetFont( "catherine_font01_15" )
	self.Name:SetText( "" )
	self.Name:SetAllowNonAsciiCharacters( true )
	self.Name.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
		pnl:DrawTextEntryText( Color( 255, 255, 255 ), Color( 45, 45, 45 ), Color( 255, 255, 0 ) )
	end
	self.Name.OnTextChanged = function( pnl )
		self.data.name = pnl:GetText( )
	end
	
	self.Desc = vgui.Create( "DTextEntry", self )
	self.Desc:SetPos( 40 + self.DescLabel:GetSize( ), ( self.h * 0.1 + 30 ) )
	self.Desc:SetSize( self.w - ( 40 + self.DescLabel:GetSize( ) ) - 20, 20 )	
	self.Desc:SetFont( "catherine_font01_15" )
	self.Desc:SetText( "" )
	self.Desc:SetAllowNonAsciiCharacters( true )
	self.Desc.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
		pnl:DrawTextEntryText( Color( 255, 255, 255 ), Color( 45, 45, 45 ), Color( 255, 255, 0 ) )
		self.data.desc = pnl:GetText( )
	end
	self.Desc.OnTextChanged = function( pnl )
		self.data.desc = pnl:GetText( )
	end
	
	self.ModelList = vgui.Create( "DPanelList", self )
	self.ModelList:SetPos( 10, self.h * 0.45 )
	self.ModelList:SetSize( self.w - 20, self.h - ( self.h * 0.45 ) - 10  )	
	self.ModelList:SetSpacing( 5 )
	self.ModelList:EnableHorizontal( true )
	self.ModelList:EnableVerticalScrollbar( false )	
	self.ModelList.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
	end
	
	self:RefreshModelList( )
end

function PANEL:OnContinue( )
	self:GetParent( ).createCharacter.data.name = self.data.name
	self:GetParent( ).createCharacter.data.desc = self.data.desc
	self:GetParent( ).createCharacter.data.model = self.data.model
end

function PANEL:OnPrevious( )
	self.Name:SetText( self:GetParent( ).createCharacter.data.name )
	self.Desc:SetText( self:GetParent( ).createCharacter.data.desc )
end

function PANEL:RefreshModelList( )
	local data = self:GetParent().createCharacter.data
	self.ModelList:Clear( )
	local factionData = catherine.faction.FindByID( data.faction ) //self.createCharacter.data.faction )
	if ( !factionData ) then return end
	for k, v in pairs( factionData.models ) do
		local spawnIcon = vgui.Create( "SpawnIcon" )
		spawnIcon:SetSize( 64, 64 )
		spawnIcon:SetModel( v )
		spawnIcon.DoClick = function( )
			self.data.model = v
			self.selectedModel = k
		end
		spawnIcon.PaintOver = function( pnl, w, h )
			if ( !self.selectedModel ) then return end
			if ( self.selectedModel == k ) then
				draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 0, 0, 255 ) )
				draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 0, 0, 255 ) )
			end
		end
		
		self.ModelList:AddItem( spawnIcon )
	end
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 255, 255, 255 ) )
	draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
end

vgui.Register( "catherine.character.create.stageTwo", PANEL, "DPanel" )