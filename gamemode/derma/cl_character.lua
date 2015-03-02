local PANEL = { }

function PANEL:Init( )
	local LP = LocalPlayer( )
	
	self.w = ScrW( )
	self.h = ScrH( )

	self.blur = Material( "pp/blurscreen" )
	self.status = nil
	self.blurAmount = 0
	self.schemaImageAlpha = 0
	self.alpha = 0
	
	self.music = CreateSound( LocalPlayer( ), catherine.configs.characterMenuMusic )
	self.music:Play( )
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:MakePopup( )
	self.Paint = function( pnl, w, h )
		self.blurAmount = Lerp( 0.03, self.blurAmount, 5 )
	
		catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
	
		draw.RoundedBox( 0, 0, 0, w, h, Color( 40, 40, 40, self.alpha / 1.5 ) )

		if ( !self.createCharacter and !self.loadCharacter ) then
			self.schemaImageAlpha = Lerp( 0.03, self.schemaImageAlpha, 255 )
		else
			self.schemaImageAlpha = Lerp( 0.03, self.schemaImageAlpha, 0 )
		end
		
		self.alpha = Lerp( 0.01, self.alpha, 255 )

		if ( catherine.configs.schemaImage != nil and catherine.configs.schemaImage != "" ) then
			surface.SetDrawColor( 255, 255, 255, self.schemaImageAlpha )
			surface.SetMaterial( Material( catherine.configs.schemaImage ) )
			surface.DrawTexturedRect( w / 2 - 512 / 2, h / 2 - 256 / 2, 512, 256 )
		end
	end

	self.NewCharacter = vgui.Create( "catherine.vgui.button", self )
	self.NewCharacter:SetPos( 5, self.h - 35 )
	self.NewCharacter:SetSize( self.w * 0.2, 30 )
	self.NewCharacter:SetStr( "Create" )
	self.NewCharacter:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.NewCharacter:RunFadeInAnimation( 0.3, 1 )
	self.NewCharacter.Click = function( )
		if ( !self.createCharacter and !self.loadCharacter ) then 
			self:CreateCharacter_Init( )
			self:NextStage( )
		end
		
		if ( self.loadCharacter ) then
			self:LoadCharacter_Refresh( )
			self.loadCharacter = nil
		end
	end
	
	self.LoadCharacter = vgui.Create( "catherine.vgui.button", self )
	self.LoadCharacter:SetPos( 10 + self.w * 0.2, self.h - 35 )
	self.LoadCharacter:SetSize( self.w * 0.2, 30 )
	self.LoadCharacter:SetStr( "Load" )
	self.LoadCharacter:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.LoadCharacter:RunFadeInAnimation( 0.3, 1 )
	self.LoadCharacter.Click = function( )
		if ( !self.createCharacter ) then 
			self:LoadCharacter_Refresh( )
			self:LoadCharacter_Init( )
		end
	end
	
	self.Disconnect = vgui.Create( "catherine.vgui.button", self )
	self.Disconnect:SetPos( self.w - self.w * 0.2 - 5, self.h - 35 )
	self.Disconnect:SetSize( self.w * 0.2, 30 )
	self.Disconnect:SetStr( "Disconnect" )
	self.Disconnect:RunFadeInAnimation( 0.3, 1 )
	self.Disconnect.PaintOverAll = function( )
		if ( LocalPlayer( ):IsCharacterLoaded( ) ) then
			self.Disconnect:SetStr( "Close" )
		else
			self.Disconnect:SetStr( "Disconnect" )
		end
	end
	self.Disconnect:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	self.Disconnect.Click = function( )
		if ( LocalPlayer( ):IsCharacterLoaded( ) ) then
			self:Close( )
		else
			RunConsoleCommand( "disconnect" )
		end
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
	
	self.CharacterPanel = vgui.Create( "DPanel", self )
	self.CharacterPanel:SetPos( 10, 120 )
	self.CharacterPanel:SetSize( self.w - 20, self.h - ( 170 ) - 10  )	
	self.CharacterPanel:SetDrawBackground( false )
end

function PANEL:PrintErrorMessage( msg )
	Derma_Message( msg )
end

function PANEL:Think( )
	if ( !self.createCharacter and !self.loadCharacter ) then
		self.Previous:SetVisible( false )
		self.Next:SetVisible( false )
		self.Cancel:SetVisible( false )
		self.CharacterPanel:SetVisible( false )
		return
	else
		if ( self.createCharacter ) then
			self.Previous:SetVisible( true )
			self.Next:SetVisible( true )
			self.Cancel:SetVisible( true )
		end
		if ( self.loadCharacter ) then
			self.CharacterPanel:SetVisible( true )
		end
	end
	
	if ( self.createCharacter ) then
		self.Previous:SetVisible( true )
		self.Next:SetVisible( true )
		self.Cancel:SetVisible( true )
		self.CharacterPanel:SetVisible( false )
	elseif ( !self.createCharacter and !self.loadCharacter ) then
		self.Previous:SetVisible( false )
		self.Next:SetVisible( false )
		self.Cancel:SetVisible( false )
		self.CharacterPanel:SetVisible( false )
	elseif ( !self.createCharacter and self.loadCharacter ) then
		self.Previous:SetVisible( false )
		self.Next:SetVisible( false )
		self.Cancel:SetVisible( true )
		self.CharacterPanel:SetVisible( true )
	end
	
	if ( self.createCharacter ) then
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
end

function PANEL:ManageTargets( pnl, pos, a )
	if ( !pnl.targetPos or !pnl.targetA ) then
		pnl.targetPos = pos pnl.targetA = a
	end;
	pnl.targetPos = Lerp( 0.2, pnl.targetPos, pos )
	pnl.targetA = Lerp( 0.2, pnl.targetA, a )
	pnl:SetPos( pnl.targetPos, 0 )
	pnl:SetAlpha( pnl.targetA )
end;

function PANEL:LoadCharacter_Refresh( )
	if ( !self.loadCharacter ) then return end
	for k, v in pairs( self.loadCharacter.Lists ) do
		if ( !IsValid( v.panel ) ) then continue end
		v.panel:Remove( )
		v.panel = nil
	end
end

function PANEL:LoadCharacter_Init( )
	if ( !catherine.character.LocalCharacters ) then return end
	self.loadCharacter = { }
	self.loadCharacter.Lists = { }
	self.loadCharacter.curr = 1
	
	local baseW, baseH = 300, ScrH( ) * 0.75
	local scrW, scrH = ScrW( ), ScrH( )

	for k, v in pairs( catherine.character.LocalCharacters ) do
		self.loadCharacter.Lists[ #self.loadCharacter.Lists + 1 ] = { characterDatas = v, panel = nil }
	end

	local function SetTargetPanelPos( pnl, pos, a )
		if ( !IsValid( pnl ) ) then return end
		if ( !pnl.targetPos or !pnl.targetA ) then
			pnl.targetPos = pos pnl.targetA = a
		end;
		pnl.targetPos = Lerp( 0.2, pnl.targetPos, pos )
		pnl.targetA = Lerp( 0.2, pnl.targetA, a )
		pnl:SetPos( pnl.targetPos, 0 )
		pnl:SetAlpha( pnl.targetA )
	end
	
	
	for k, v in pairs( self.loadCharacter.Lists ) do
		local factionData = catherine.faction.FindByID( v.characterDatas._faction )
		v.panel = vgui.Create( "DPanel", self.CharacterPanel )
		v.panel:SetSize( baseW, baseH )
		v.panel.x = 0
		v.panel.y = 0
		v.panel:Center( )
		v.panel.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
			draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 255, 255, 255 ) )
			draw.RoundedBox( 0, 0, 30, w, 1, Color( 255, 255, 255, 255 ) )
			draw.SimpleText( v.characterDatas._name, "catherine_font01_20", w / 2, h - 90, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( v.characterDatas._desc, "catherine_font01_15", w / 2, h - 70, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( factionData.name, "catherine_font01_20", w / 2, 15, Color( 255, 255, 255, 255 ), 1, 1 )
		end
		
		v.panel.button = vgui.Create( "DButton", v.panel )
		v.panel.button:SetSize( v.panel:GetWide( ), v.panel:GetTall( ) )
		v.panel.button:Center( )
		v.panel.button:SetText( "" )
		v.panel.button:SetDrawBackground( false )
		v.panel.button.DoClick = function( )
			self.loadCharacter.curr = k
		end
		
		v.panel.useCharacter = vgui.Create( "DButton", v.panel )
		v.panel.useCharacter:SetSize( 16, 16 )
		v.panel.useCharacter:SetPos( v.panel:GetWide( ) * 0.3, v.panel:GetTall( ) - 30 )
		v.panel.useCharacter:SetText( "" )
		v.panel.useCharacter:SetToolTip( "Use this character." )
		v.panel.useCharacter.Paint = function( pnl, w, h )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material( "icon16/accept.png" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		v.panel.useCharacter.DoClick = function( )
			netstream.Start( "catherine.character.LoadCharacter", v.characterDatas._id )
			self:Close( )
		end
		
		v.panel.deleteCharacter = vgui.Create( "DButton", v.panel )
		v.panel.deleteCharacter:SetSize( 16, 16 )
		v.panel.deleteCharacter:SetPos( v.panel:GetWide( ) * 0.6, v.panel:GetTall( ) - 30 )
		v.panel.deleteCharacter:SetText( "" )
		v.panel.deleteCharacter:SetToolTip( "Delete this character." )
		v.panel.deleteCharacter.Paint = function( pnl, w, h )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material( "icon16/delete.png" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		v.panel.deleteCharacter.DoClick = function( )
			Derma_Query( "Are you sure delete this character?", "Delete Character", "Yes", function( )
				netstream.Start( "catherine.character.DeleteCharacter", v.characterDatas._id )
			end, "No", function( ) end )
		end
		
		v.panel.model = vgui.Create( "DModelPanel", v.panel )
		v.panel.model:SetSize( v.panel:GetWide( ), v.panel:GetTall( ) )
		v.panel.model:SetPos( 0, 0 - 80 )
		v.panel.model:MoveToBack( )
		v.panel.model:SetModel( v.characterDatas._model )
		v.panel.model:SetDrawBackground( false )
		v.panel.model:SetFOV( 40 )
		v.panel.model.LayoutEntity = function( pnl, ent )
			ent:SetAngles( Angle( 0, 45, 0 ) )
			if ( k == self.loadCharacter.curr ) then 
				pnl:RunAnimation( )
			end
		end
	end

	self.CharacterPanel.Think = function( )
		if ( !self.loadCharacter ) then return end
		if ( self.loadCharacter.curr == 0 ) then self.loadCharacter.curr = 1 end
		if ( !self.loadCharacter.Lists[ self.loadCharacter.curr ] ) then return end
		
		local uniquePanel = self.loadCharacter.Lists[ self.loadCharacter.curr ].panel
		SetTargetPanelPos( uniquePanel, self.CharacterPanel:GetWide( ) / 2 - uniquePanel:GetWide( ) / 2, 255 )
			
		local right, left = uniquePanel.x + uniquePanel:GetWide( ) + 24, uniquePanel.x - 24
		for i = self.loadCharacter.curr - 1, 1, -1 do
			local prevPanel = self.loadCharacter.Lists[ i ].panel
			if ( !IsValid( prevPanel ) ) then continue end
			SetTargetPanelPos( prevPanel, left - prevPanel:GetWide( ), ( 255 / self.loadCharacter.curr ) * i )
			left = prevPanel.x - 24
		end
		
		for k, v in pairs( self.loadCharacter.Lists ) do
			if ( k > self.loadCharacter.curr ) then
				SetTargetPanelPos( v.panel, right, ( 255 / ( ( #self.loadCharacter.Lists + 1 ) - self.loadCharacter.curr ) ) * ( ( #self.loadCharacter.Lists + 1 ) - k ) )
				right = v.panel.x + v.panel:GetWide( ) + 24
			end
		end
	end
end

function PANEL:CancelStage( )
	if ( self.createCharacter ) then
		if ( IsValid( self.createCharacter.activePanel ) ) then
			self.createCharacter.activePanel:AlphaTo( 0, 0.3, 0 )
			timer.Simple( 0.3, function( )
				if ( !IsValid( self.createCharacter.activePanel ) ) then return end
				self.createCharacter.activePanel:Remove( )
				self.createCharacter.activePanel = nil
				self.createCharacter = nil
			end )
		end
	elseif ( self.loadCharacter ) then
		self:LoadCharacter_Refresh( )
		self.loadCharacter = nil
	end
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
			end )
		end
	else
		if ( self.createCharacter.currProgress == #self.createCharacter.progressList ) then
			if ( self.createCharacter.activePanel:CanContinue( ) ) then
				self.createCharacter.activePanel:OnContinue( )
				netstream.Start( "catherine.character.RegisterCharacter", self.createCharacter.data )
			end
		end
	end
end

function PANEL:PreviousStage( )
	if ( !self.createCharacter ) then return end
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
	end
end

function PANEL:Close( )
	self.music:FadeOut( 3 )
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
	
	self.FactionLabel = vgui.Create( "DLabel", self )
	self.FactionLabel:SetPos( 10, 10 )
	self.FactionLabel:SetColor( Color( 255, 255, 255, 255 ) )
	self.FactionLabel:SetFont( "catherine_font01_30" )
	self.FactionLabel:SetText( "Faction" )
	self.FactionLabel:SizeToContents( )
	
	self.FactionSelect = vgui.Create( "DComboBox", self )
	self.FactionSelect:SetPos( 40 + self.FactionLabel:GetSize( ), 10 )
	self.FactionSelect:SetSize( self.w - ( 40 + self.FactionLabel:GetSize( ) ), 30 )
	self.FactionSelect.OnSelect = function( _, index, value, data )
		local factionData = catherine.faction.FindByID( data )
		if ( factionData.image ) then
			self:SetFactionImage( factionData.image )
		end
		self.faction = data
	end
	
	for k, v in pairs( self.factionList ) do
		self.FactionSelect:AddChoice( v.name, v.uniqueID )
	end
end

function PANEL:GetFactionList( )
	local faction = { }
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.isWhitelist and LocalPlayer( ):HasWhiteList( v.uniqueID ) == false ) then continue end
		faction[ #faction + 1 ] = v
	end
	return faction
end

function PANEL:RefreshPanelList( )
	local faction = { }
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.isWhitelist and LocalPlayer( ):HasWhiteList( v.uniqueID ) == false ) then continue end
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
	if ( self.faction == "" ) then
		self:GetParent( ):PrintErrorMessage( "Please select faction!" )
		return false
	end
	if ( !catherine.faction.FindByID( self.faction ) ) then
		self:GetParent( ):PrintErrorMessage( "Faction is not valid!" )
		return false
	end

	return true
end

function PANEL:OnContinue( )
	self:GetParent( ).createCharacter.data.faction = self.faction
end

function PANEL:OnPrevious( )
	local factionData = catherine.faction.FindByID( self:GetParent( ).createCharacter.data.faction )
	if ( !factionData ) then return end
	self.FactionSelect:ChooseOption( factionData.name, factionData.index )
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

function PANEL:CanContinue( )
	if ( self.data.name == "" ) then
		self:GetParent( ):PrintErrorMessage( "Please input name!" )
		return false
	end
	if ( self.data.desc == "" ) then
		self:GetParent( ):PrintErrorMessage( "Please input desc!" )
		return false
	end
	if ( self.data.model == "" ) then
		self:GetParent( ):PrintErrorMessage( "Please select model!" )
		return false
	end
	if ( string.len( self.data.name ) > catherine.configs.characterNameMaxLen ) then
		self:GetParent( ):PrintErrorMessage( "Name is too long!, please input under " .. catherine.configs.characterNameMaxLen .. " len!" )
		return false
	end
	if ( string.len( self.data.name ) < catherine.configs.characterNameMinLen ) then
		self:GetParent( ):PrintErrorMessage( "Name is too short!, please input up " .. catherine.configs.characterNameMinLen .. " len!" )
		return false
	end
	if ( string.len( self.data.desc ) > catherine.configs.characterDescMaxLen ) then
		self:GetParent( ):PrintErrorMessage( "Desc is too long!, please input under " .. catherine.configs.characterDescMaxLen .. " len!" )
		return false
	end
	if ( string.len( self.data.desc ) < catherine.configs.characterDescMinLen ) then
		self:GetParent( ):PrintErrorMessage( "Desc is too short!, please input up " .. catherine.configs.characterDescMaxLen .. " len!" )
		return false
	end

	return true
end

function PANEL:RefreshModelList( )
	local data = self:GetParent().createCharacter.data
	self.ModelList:Clear( )
	local factionData = catherine.faction.FindByID( data.faction )
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

hook.Add( "AddMenuItem", "catherine.vgui.character", function( tab )
	tab[ "Character" ] = function( menuPnl, itemPnl )
		local pnl = vgui.Create( "catherine.vgui.character" )
		menuPnl:Close( )
	end
end )