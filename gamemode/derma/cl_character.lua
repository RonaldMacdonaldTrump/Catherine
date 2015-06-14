--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

local PANEL = { }

function PANEL:Init( )
	catherine.vgui.character = self
	
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ), ScrH( )
	self.blurAmount = 0
	self.mainAlpha = 0
	self.mainButtons = { }
	self.mode = 0
	
	local schemaTitle = catherine.util.StuffLanguage( Schema and Schema.Title or "Example" )
	local schemaDesc = catherine.util.StuffLanguage( Schema and Schema.Desc or "Test" )
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:MakePopup( )
	self.Paint = function( pnl, w, h )
		if ( self.mode == 0 ) then
			self.mainAlpha = Lerp( 0.03, self.mainAlpha, 255 )
		else
			self.mainAlpha = Lerp( 0.05, self.mainAlpha, 0 )
		end
		
		local sin = math.sin( CurTime( ) / 2 )

		surface.SetDrawColor( 90, 90, 90, 100 )
		surface.SetMaterial( Material( "gui/gradient_down" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		surface.SetDrawColor( 0, 0, 0, math.max( sin * 255, 200 ) )
		surface.SetMaterial( Material( "gui/gradient_up" ) )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		surface.SetDrawColor( 110, 110, 110, self.mainAlpha / 3 )
		surface.SetMaterial( Material( "gui/gradient" ) )
		surface.DrawTexturedRect( 0, h * 0.7 - 35, w * 0.3, 70 )
		
		surface.SetDrawColor( 80, 80, 80, self.mainAlpha / 6 )
		surface.SetMaterial( Material( "gui/gradient" ) )
		surface.DrawTexturedRect( 0, h * 0.75 - 10, w * 0.3, 170 )
		
		draw.SimpleText( schemaTitle, "catherine_normal25", 30, h * 0.75 - 70, Color( 255, 255, 255, self.mainAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
		draw.SimpleText( schemaDesc, "catherine_normal15", 30, h * 0.75 - 35, Color( 255, 255, 255, self.mainAlpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end

	self.createCharacter = vgui.Create( "catherine.vgui.button", self )
	self.createCharacter:SetPos( 30, self.h * 0.75 )
	self.createCharacter:SetSize( self.w * 0.2, 30 )
	self.createCharacter:SetStr( LANG( "Character_UI_CreateCharStr" ) )
	self.createCharacter:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.createCharacter.Click = function( )
		if ( #catherine.character.localCharacters >= catherine.configs.maxCharacters ) then
			Derma_Message( LANG( "Character_Notify_MaxLimitHit" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			return
		end
		
		self:JoinMenu( function( )
			self:CreateCharacterPanel( )
		end )
	end
	self.mainButtons[ #self.mainButtons + 1 ] = self.createCharacter
	
	self.useCharacter = vgui.Create( "catherine.vgui.button", self )
	self.useCharacter:SetPos( 30, self.h * 0.75 + 40 )
	self.useCharacter:SetSize( self.w * 0.2, 30 )
	self.useCharacter:SetStr( LANG( "Character_UI_LoadCharStr" ) )
	self.useCharacter:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.useCharacter.Click = function( )
		self:JoinMenu( function( )
			self:UseCharacterPanel( )
		end )
	end
	self.mainButtons[ #self.mainButtons + 1 ] = self.useCharacter
	
	self.changeLog = vgui.Create( "catherine.vgui.button", self )
	self.changeLog:SetPos( 30, self.h * 0.75 + 80 )
	self.changeLog:SetSize( self.w * 0.2, 30 )
	self.changeLog:SetStr( LANG( "Character_UI_ChangeLogStr" ) )
	self.changeLog:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.changeLog.Click = function( )
		self:JoinMenu( function( )
			self:UpdateLogPanel( )
		end )
	end
	self.mainButtons[ #self.mainButtons + 1 ] = self.changeLog
	
	self.disconnect = vgui.Create( "catherine.vgui.button", self )
	self.disconnect:SetPos( 30, self.h * 0.75 + 120 )
	self.disconnect:SetSize( self.w * 0.2, 30 )
	self.disconnect:SetStr( "" )
	self.disconnect.PaintOverAll = function( pnl )
		if ( self.player:IsCharacterLoaded( ) ) then
			pnl:SetStr( LANG( "Character_UI_Close" ) )
		else
			pnl:SetStr( LANG( "Character_UI_ExitServerStr" ) )
		end
	end
	self.disconnect:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.disconnect.Click = function( )
		if ( self.player:IsCharacterLoaded( ) ) then
			self:Close( )
		else
			Derma_Query( LANG( "Character_Notify_ExitQ" ), "", LANG( "Basic_UI_YES" ), function( )
				self:JoinMenu( function( )
					RunConsoleCommand( "disconnect" )
				end )
			end, LANG( "Basic_UI_NO" ), function( ) end )
		end
	end
	self.mainButtons[ #self.mainButtons + 1 ] = self.disconnect
	
	self.back = vgui.Create( "catherine.vgui.button", self )
	self.back:SetPos( 30, 30 )
	self.back:SetSize( self.w * 0.2, 30 )
	self.back:SetStr( LANG( "Character_UI_BackStr" ) )
	self.back:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.back:SetVisible( false )
	self.back:SetAlpha( 0 )
	self.back.Click = function( )
		if ( self.mode == 0 ) then return end
		
		self:BackToMainMenu( )
	end
	
	self:PlayMusic( )
end

function PANEL:PlayMusic( )
	local musicDir = catherine.configs.characterMenuMusic
	local music = CreateSound( self.player, musicDir )
	
	music:Play( )
	
	if ( musicDir:find( ".wav" ) ) then
		timer.Create( "Catherine.timer.character.RepeatMusic", SoundDuration( musicDir ) + 2, 0, function( )
			if ( !IsValid( self ) or !music ) then
				timer.Remove( "Catherine.timer.character.RepeatMusic" )
				return
			end
			
			music:Stop( )
			music:Play( )
		end )
	end
	
	catherine.character.panelMusic = music
end

function PANEL:CreateCharacterPanel( )
	self.createData = { datas = { } }
	self.createData.currentStageInt = 1
	self.createData.maxStageInt = 2
	self.createData.currentStage = vgui.Create( "catherine.character.stageOne", self )
end

function PANEL:UseCharacterPanel( )
	self.loadCharacter = { Lists = { }, curr = 1 }

	local baseW, baseH, errMsg = 300, self.h * 0.85, nil
	for k, v in pairs( catherine.character.localCharacters ) do
		self.loadCharacter.Lists[ #self.loadCharacter.Lists + 1 ] = { characterDatas = v, panel = nil }
	end
	
	self.CharacterPanel = vgui.Create( "DPanel", self )
	self.CharacterPanel:SetPos( 0, 90 )
	self.CharacterPanel:SetSize( self.w - 20, self.h - ( 120 ) )
	self.CharacterPanel:SetAlpha( 0 )
	self.CharacterPanel:AlphaTo( 255, 0.2, 0 )
	self.CharacterPanel:SetDrawBackground( false )
	self.CharacterPanel.Paint = function( pnl, w, h )
		if ( errMsg ) then
			draw.SimpleText( errMsg, "catherine_normal30", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
			return
		end
		
		if ( #self.loadCharacter.Lists == 0 ) then
			draw.SimpleText( LANG( "Character_UI_DontHaveAny" ), "catherine_normal30", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end

	local function SetTargetPanelPos( pnl, pos, a )
		if ( !IsValid( pnl ) ) then return end
		
		if ( !pnl.targetPos or !pnl.targetA ) then
			pnl.targetPos = pos
			pnl.targetA = a
		end
		
		pnl.targetPos = Lerp( 0.2, pnl.targetPos, pos )
		pnl.targetA = Lerp( 0.5, pnl.targetA, a )
		
		pnl:SetPos( pnl.targetPos, 0 )
		pnl:SetAlpha( pnl.targetA )
	end

	for k, v in pairs( self.loadCharacter.Lists ) do
		local factionData = catherine.faction.FindByID( v.characterDatas._faction )
		if ( !factionData ) then return end
		local factionName = catherine.util.StuffLanguage( factionData.name )
		
		v.panel = vgui.Create( "DPanel", self.CharacterPanel )
		v.panel:SetSize( baseW, baseH )
		v.panel.x = 0
		v.panel.y = 0
		v.panel:Center( )
		v.panel.Paint = function( pnl, w, h )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material( "gui/gradient_up" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		
			draw.SimpleText( v.characterDatas._name, "catherine_normal20", w / 2, h - 100, Color( 0, 0, 0, 255 ), 1, 1 )
			draw.SimpleText( v.characterDatas._desc, "catherine_normal15", w / 2, h - 70, Color( 50, 50, 50, 255 ), 1, 1 )
			draw.SimpleText( factionName, "catherine_normal25", w / 2, 20, Color( 255, 255, 255, 255 ), 1, 1 )
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
		v.panel.useCharacter:SetPos( v.panel:GetWide( ) * 0.3, v.panel:GetTall( ) * 0.95 )
		v.panel.useCharacter:SetText( "" )
		v.panel.useCharacter:SetToolTip( LANG( "Character_UI_UseCharacter" ) )
		v.panel.useCharacter.Paint = function( pnl, w, h )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material( "icon16/accept.png" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		v.panel.useCharacter.DoClick = function( )
			netstream.Start( "catherine.character.Use", v.characterDatas._id )
		end
		
		v.panel.deleteCharacter = vgui.Create( "DButton", v.panel )
		v.panel.deleteCharacter:SetSize( 16, 16 )
		v.panel.deleteCharacter:SetPos( v.panel:GetWide( ) * 0.6, v.panel:GetTall( ) * 0.95 )
		v.panel.deleteCharacter:SetText( "" )
		v.panel.deleteCharacter:SetToolTip( LANG( "Character_UI_DeleteCharacter" ) )
		v.panel.deleteCharacter.Paint = function( pnl, w, h )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material( "icon16/delete.png" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		v.panel.deleteCharacter.DoClick = function( )
			Derma_Query( LANG( "Character_Notify_DeleteQ" ), "", LANG( "Basic_UI_YES" ), function( )
				netstream.Start( "catherine.character.Delete", v.characterDatas._id )
			end, LANG( "Basic_UI_NO" ), function( ) end )
		end
		
		v.panel.model = vgui.Create( "DModelPanel", v.panel )
		v.panel.model:SetSize( v.panel:GetWide( ) / 1.5, v.panel:GetTall( ) / 1.5 )
		v.panel.model:SetPos( v.panel:GetWide( ) / 2 - v.panel.model:GetWide( ) / 2, 60 )
		v.panel.model:MoveToBack( )
		v.panel.model:SetModel( v.characterDatas._model )
		v.panel.model:SetDrawBackground( false )
		v.panel.model:SetDisabled( true )
		v.panel.model:SetFOV( 30 )
		v.panel.model.LayoutEntity = function( pnl, ent )
			ent:SetAngles( Angle( 0, 45, 0 ) )
			ent:SetIK( false )
			
			if ( k == self.loadCharacter.curr ) then
				pnl:RunAnimation( )
			end
		end
	end

	self.CharacterPanel.Think = function( )
		if ( !self.loadCharacter ) then return end
		
		if ( self.loadCharacter.curr == 0 ) then
			self.loadCharacter.curr = 1
		end
		
		if ( !self.loadCharacter.Lists[ self.loadCharacter.curr ] ) then return end
		
		local uniquePanel = self.loadCharacter.Lists[ self.loadCharacter.curr ].panel
		SetTargetPanelPos( uniquePanel, self.CharacterPanel:GetWide( ) / 2 - uniquePanel:GetWide( ) / 2, 255 )
			
		local right, left = uniquePanel.x + uniquePanel:GetWide( ) + 24, uniquePanel.x - 24
		for i = self.loadCharacter.curr - 1, 1, -1 do
			local prevPanel = self.loadCharacter.Lists[ i ].panel
			
			if ( !IsValid( prevPanel ) ) then continue end
			
			SetTargetPanelPos( prevPanel, left - prevPanel:GetWide( ), ( 30 / self.loadCharacter.curr ) * i )
			left = prevPanel.x - 24
		end
		
		for k, v in pairs( self.loadCharacter.Lists ) do
			if ( k > self.loadCharacter.curr ) then
				SetTargetPanelPos( v.panel, right, ( 30 / ( ( #self.loadCharacter.Lists + 1 ) - self.loadCharacter.curr ) ) * ( ( #self.loadCharacter.Lists + 1 ) - k ) )
				right = v.panel.x + v.panel:GetWide( ) + 24
			end
		end
	end
end

function PANEL:UpdateLogPanel( )
	self.UpdatePanel = vgui.Create( "DPanel", self )
	self.UpdatePanel:SetPos( self.w * 0.1, 90 )
	self.UpdatePanel:SetSize( self.w - ( self.w * 0.2 ), self.h - ( 120 ) )
	self.UpdatePanel:SetAlpha( 0 )
	self.UpdatePanel:AlphaTo( 255, 0.2, 0 )
	self.UpdatePanel:SetDrawBackground( false )
	
	self.UpdatePanel.loadingAni = 0
	self.UpdatePanel.loadingAlpha = 255
	
	self.UpdatePanel.Paint = function( pnl, w, h )
		if ( pnl.html:IsLoading( ) ) then
			pnl.loadingAlpha = Lerp( 0.03, pnl.loadingAlpha, 255 )
		else
			pnl.loadingAlpha = Lerp( 0.03, pnl.loadingAlpha, 0 )
		end
		
		if ( math.Round( pnl.loadingAlpha ) > 0 ) then
			pnl.loadingAni = math.Approach( pnl.loadingAni, pnl.loadingAni - 8, 8 )
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 255, 255, pnl.loadingAlpha )
			catherine.geometry.DrawCircle( w / 2, h / 2, 25, 5, pnl.loadingAni, 70, 100 )
		end
	end
	
	self.UpdatePanel.html = vgui.Create( "DHTML", self.UpdatePanel )
	self.UpdatePanel.html:Dock( FILL )
	self.UpdatePanel.html:OpenURL( "http://github.com/L7D/Catherine/commits" )
end

function PANEL:BackToMainMenu( )
	if ( self.mode == 0 ) then return end
	local delta = 0
	
	for k, v in pairs( self.mainButtons ) do
		v:SetVisible( true )
		v:AlphaTo( 255, 0.2, delta )
		
		delta = delta + 0.05
	end
	
	self.back:AlphaTo( 0, 0.2, 0, function( _, pnl )
		pnl:SetVisible( false )
	end )
	
	self.mode = 0
	
	if ( self.createData and IsValid( self.createData.currentStage ) ) then
		self.createData.currentStage:AlphaTo( 0, 0.2, 0, function( _, pnl )
			pnl:Remove( )
			pnl = nil
		end )
	end
	
	if ( self.loadCharacter and IsValid( self.CharacterPanel ) ) then
		self.CharacterPanel:AlphaTo( 0, 0.2, 0, function( _, pnl )
			pnl:Remove( )
			pnl = nil
		end )
	end
	
	if ( IsValid( self.UpdatePanel ) ) then
		self.UpdatePanel:AlphaTo( 0, 0.2, 0, function( _, pnl )
			pnl:Remove( )
			pnl = nil
		end )
	end
end

function PANEL:JoinMenu( func )
	if ( self.mode == 1 ) then return end
	local delta = 0
	
	for k, v in pairs( self.mainButtons ) do
		v:AlphaTo( 0, 0.2, delta, function( )
			v:SetVisible( false )
		end )
		
		delta = delta + 0.1
	end
	
	self.back:SetVisible( true )
	self.back:AlphaTo( 255, 0.2, delta, function( )
		if ( func ) then
			func( )
		end
	end )
	
	self.mode = 1
end

function PANEL:Close( )
	if ( self.closing ) then return end
	local music = catherine.character.panelMusic
	
	self.closing = true
	
	if ( music ) then
		music:FadeOut( 3 )
		
		timer.Simple( 3, function( )
			catherine.character.panelMusic = nil
		end )
		
		timer.Remove( "Catherine.timer.character.RepeatMusic" )
	end
	
	self:AlphaTo( 0, 0.3, 0, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.character", PANEL, "DFrame" )

local PANEL = { }

function PANEL:Init( )
	self.parent = self:GetParent( )
	self.w, self.h = self.parent.w * 0.8, self.parent.h * 0.6
	self.data = { faction = nil }
	self.factionList = catherine.faction.GetPlayerUsableFaction( self.parent.player )
	self.progressPercent, self.progressPercentAni = 0, 0

	self:SetSize( self.w, self.h )
	self:SetPos( self.parent.w, self.parent.h / 2 - self.h / 2 )
	self:SetAlpha( 0 )
	self:MoveTo( self.parent.w / 2 - self.w / 2, self.parent.h / 2 - self.h / 2, 0.3, 0 )
	self:AlphaTo( 255, 0.3, 0 )
	
	self.label01 = vgui.Create( "DLabel", self )
	self.label01:SetPos( 10, 10 )
	self.label01:SetColor( Color( 50, 50, 50, 255 ) )
	self.label01:SetFont( "catherine_normal30" )
	self.label01:SetText( LANG( "Faction_UI_Title" ) )
	self.label01:SizeToContents( )

	self.Lists = vgui.Create( "DHorizontalScroller", self )
	self.Lists:SetPos( 10, 60 )
	self.Lists:SetSize( 0, self.h - 85 )
	
	for k, v in pairs( self.factionList ) do
		local factionName = catherine.util.StuffLanguage( v.name )
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( 200, self.Lists:GetTall( ) )
		panel.Paint = function( pnl, w, h )
			if ( self.data.faction == v.uniqueID ) then
				surface.SetDrawColor( 70, 70, 70, 255 )
				surface.SetMaterial( Material( "gui/gradient_up" ) )
				surface.DrawTexturedRect( 0, 0, w, h )
			
				draw.SimpleText( factionName, "catherine_normal15", w / 2, h - 30, Color( 255, 255, 255, 255 ), 1, 1 )
			else
				draw.SimpleText( factionName, "catherine_normal15", w / 2, h - 30, Color( 50, 50, 50, 255 ), 1, 1 )
			end
		end
		
		local model = vgui.Create( "DModelPanel", panel )
		model:SetSize( panel:GetWide( ), panel:GetTall( ) - 60 )
		model:SetCursor( "none" )
		model:SetPos( 0, 0 )
		model:MoveToBack( )
		model:SetModel( table.Random( v.models ) )
		model:SetVisible( true )
		model:SetFOV( 40 )
		model.LayoutEntity = function( pnl, ent )
			ent:SetIK( false )
			ent:SetAngles( Angle( 0, 45, 0 ) )
			pnl:RunAnimation( )
		end
		
		local button = vgui.Create( "DButton", panel )
		button:Dock( FILL )
		button:SetText( "" )
		button.DoClick = function( pnl )
			if ( self.data.faction == v.uniqueID ) then
				self.data.faction = nil
			else
				self.data.faction = v.uniqueID
			end
		end
		button:SetDrawBackground( false )
		
		self.Lists:AddPanel( panel )
		self.Lists:SetSize( self.Lists:GetWide( ) + 200, self.Lists:GetTall( ) )
		self.Lists:SetPos( self.w / 2 - self.Lists:GetWide( ) / 2, 60 )
	end

	self.nextStage = vgui.Create( "catherine.vgui.button", self )
	self.nextStage:SetPos( self.w - self.w * 0.2 - 10, 15 )
	self.nextStage:SetSize( self.w * 0.2, 25 )
	self.nextStage:SetStr( LANG( "Basic_UI_Continue" ) )
	self.nextStage:SetStrFont( "catherine_normal20" )
	self.nextStage:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.nextStage:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.nextStage.Click = function( )
		if ( self.data.faction ) then
			if ( catherine.faction.FindByID( self.data.faction ) ) then
				self.parent.createData.datas.faction = self.data.faction
				self:AlphaTo( 0, 0.3, 0 )
				self:MoveTo( 0 - self.w, self.parent.h / 2 - self.h / 2, 0.3, 0, nil, function( )
					self:Remove( )
					self.parent.createData.currentStageInt = self.parent.createData.currentStageInt + 1
					self.parent.createData.currentStage = vgui.Create( "catherine.character.stageTwo", self.parent )
				end )
			else
				self:PrintErrorMessage( LANG( "Faction_Notify_NotValid", self.data.faction ) )
			end
		else
			self:PrintErrorMessage( LANG( "Faction_Notify_SelectPlease" ) )
		end
	end
end

function PANEL:PrintErrorMessage( msg )
	Derma_Message( msg, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
	surface.PlaySound( "buttons/button2.wav" )
end

function PANEL:GetFactionList( )
	local faction = { }
	
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.isWhitelist and catherine.faction.HasWhiteList( v.uniqueID ) == false ) then continue end
		faction[ #faction + 1 ] = v
	end
	
	return faction
end

function PANEL:Paint( w, h )
	self.progressPercentAni = Lerp( 0.03, self.progressPercentAni, ( self.parent.createData.currentStageInt / self.parent.createData.maxStageInt ) * w - 5 )
	
	draw.RoundedBox( 0, 0, 0, self.progressPercentAni, 10, Color( 255, 255, 255, 200 ) )
	draw.RoundedBox( 0, self.progressPercentAni, 0, 5, 10, Color( 50, 50, 50, 255 ) )
	
	draw.RoundedBox( 0, 10, 45, w - 20, 2, Color( 50, 50, 50, 255 ) )
	draw.RoundedBox( 0, 0, 10, w, h - 20, Color( 255, 255, 255, 200 ) )
end

vgui.Register( "catherine.character.stageOne", PANEL, "DPanel" )

local PANEL = { }

function PANEL:Init( )
	self.parent = self:GetParent( )
	self.w, self.h = self.parent.w * 0.8, self.parent.h * 0.6
	self.data = {
		name = "",
		desc = "",
		model = ""
	}
	self.progressPercent, self.progressPercentAni = 0, 0
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.parent.w, self.parent.h / 2 - self.h / 2 )
	self:SetAlpha( 0 )
	self:MoveTo( self.parent.w / 2 - self.w / 2, self.parent.h / 2 - self.h / 2, 0.3, 0 )
	self:AlphaTo( 255, 0.3, 0 )
	
	self.label01 = vgui.Create( "DLabel", self )
	self.label01:SetPos( 10, 10 )
	self.label01:SetColor( Color( 50, 50, 50, 255 ) )
	self.label01:SetFont( "catherine_normal30" )
	self.label01:SetText( LANG( "Character_UI_CharInfo" ) )
	self.label01:SizeToContents( )
	
	self.name = vgui.Create( "DLabel", self )
	self.name:SetPos( 20, 60 )
	self.name:SetColor( Color( 50, 50, 50, 255 ) )
	self.name:SetFont( "catherine_normal20" )
	self.name:SetText( LANG( "Character_UI_CharName" ) )
	self.name:SizeToContents( )
	
	self.nameEnt = vgui.Create( "DTextEntry", self )
	self.nameEnt:SetPos( 40 + self.name:GetSize( ), 60 )
	self.nameEnt:SetSize( self.w - ( 40 + self.name:GetSize( ) ) - 70, 20 )	
	self.nameEnt:SetFont( "catherine_normal15" )
	self.nameEnt:SetText( "" )
	self.nameEnt:SetAllowNonAsciiCharacters( true )
	self.nameEnt.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	self.nameEnt.OnTextChanged = function( pnl )
		self.data.name = pnl:GetText( )
	end
	
	self.desc = vgui.Create( "DLabel", self )
	self.desc:SetPos( 20, 100 )
	self.desc:SetColor( Color( 50, 50, 50, 255 ) )
	self.desc:SetFont( "catherine_normal20" )
	self.desc:SetText( LANG( "Character_UI_CharDesc" ) )
	self.desc:SizeToContents( )
	
	self.descEnt = vgui.Create( "DTextEntry", self )
	self.descEnt:SetPos( 40 + self.desc:GetSize( ), 100 )
	self.descEnt:SetSize( self.w - ( 40 + self.desc:GetSize( ) ) - 70, 20 )	
	self.descEnt:SetFont( "catherine_normal15" )
	self.descEnt:SetText( "" )
	self.descEnt:SetAllowNonAsciiCharacters( true )
	self.descEnt.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	self.descEnt.OnTextChanged = function( pnl )
		self.data.desc = pnl:GetText( )
	end
	
	self.model = vgui.Create( "DPanelList", self )
	self.model:SetPos( 20, 140 )
	self.model:SetSize( self.w - 40, self.h - 190 )
	self.model:SetSpacing( 5 )
	self.model:EnableHorizontal( true )
	self.model:EnableVerticalScrollbar( false )
	
	local factionTable = catherine.faction.FindByID( self.parent.createData.datas.faction )

	if ( factionTable ) then
		for k, v in pairs( factionTable.models ) do
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( 64, 64 )
			spawnIcon:SetModel( v )
			spawnIcon:SetToolTip( false )
			spawnIcon.PaintOver = function( pnl, w, h )
				draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 0, 0, 0, 255 ) )
				
				if ( self.data.model == v ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/accept.png" ) )
					surface.DrawTexturedRect( 5, 5, 16, 16 )
				end
			end
			spawnIcon.DoClick = function( pnl )
				self.data.model = v
			end
			
			self.model:AddItem( spawnIcon )
		end
		
		if ( factionTable.PostSetName ) then
			local name = factionTable:PostSetName( self.parent.player )
			
			if ( name ) then
				self.nameEnt:SetText( name )
				self.nameEnt:SetEditable( false )
				self.data.name = self.nameEnt:GetText( )
			end
		end
		
		if ( factionTable.PostSetDesc ) then
			local desc = factionTable:PostSetDesc( self.parent.player )
			
			if ( desc ) then
				self.descEnt:SetText( desc )
				self.descEnt:SetEditable( false )
				self.data.desc = self.descEnt:GetText( )
			end
		end
	else
		self:PrintErrorMessage( LANG( "Faction_Notify_NotValid", self.parent.createData.datas.faction ) )
	end
	
	self.nextStage = vgui.Create( "catherine.vgui.button", self )
	self.nextStage:SetPos( self.w - self.w * 0.2 - 10, 15 )
	self.nextStage:SetSize( self.w * 0.2, 25 )
	self.nextStage:SetStr( LANG( "Basic_UI_Continue" ) )
	self.nextStage:SetStrFont( "catherine_normal20" )
	self.nextStage:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.nextStage:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.nextStage.Click = function( )
		local i = 0

		for k, v in pairs( self.data ) do
			local vars = catherine.character.FindVarByID( k )
			
			if ( vars and vars.checkValid ) then
				i = i + 1
				local success, reason = vars.checkValid( self.data[ k ] )
				
				if ( success == false ) then
					self:PrintErrorMessage( catherine.util.StuffLanguage( reason ) )
					return
				else
					if ( i == 3 ) then
						self:AlphaTo( 0, 0.3, 0 )
						self:MoveTo( 0 - self.w, self.parent.h / 2 - self.h / 2, 0.3, 0 )
						table.Merge( self.parent.createData.datas, self.data )
						netstream.Start( "catherine.character.Create", self.parent.createData.datas )
						return
					end
				end
			end
		end
	end
end

function PANEL:PrintErrorMessage( msg )
	Derma_Message( msg, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
	surface.PlaySound( "buttons/button2.wav" )
end

function PANEL:Paint( w, h )
	self.progressPercentAni = Lerp( 0.03, self.progressPercentAni, ( self.parent.createData.currentStageInt / self.parent.createData.maxStageInt ) * w - 5 )
	
	draw.RoundedBox( 0, 0, 0, self.progressPercentAni, 10, Color( 255, 255, 255, 200 ) )
	draw.RoundedBox( 0, self.progressPercentAni, 0, 5, 10, Color( 50, 50, 50, 255 ) )
	
	draw.RoundedBox( 0, 10, 45, w - 20, 2, Color( 50, 50, 50, 255 ) )
	draw.RoundedBox( 0, 0, 10, w, h - 20, Color( 255, 255, 255, 200 ) )
	
	draw.SimpleText( self.data.name:utf8len( ) .. "/" .. catherine.configs.characterNameMaxLen, "catherine_normal20", w - 10, 60 + 20 / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
	draw.SimpleText( self.data.desc:utf8len( ) .. "/" .. catherine.configs.characterDescMaxLen, "catherine_normal20", w - 10, 100 + 20 / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

vgui.Register( "catherine.character.stageTwo", PANEL, "DPanel" )

catherine.menu.Register( function( )
	return LANG( "Character_UI_Title" )
end, function( menuPnl, itemPnl )
	vgui.Create( "catherine.vgui.character" )
	menuPnl:Close( )
end )