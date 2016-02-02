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
	hook.Run( "CharacterMenuJoined", catherine.pl )
	
	catherine.vgui.character = self
	
	self.player = catherine.pl
	self.w, self.h = ScrW( ), ScrH( )
	self.blurAmount = 0
	self.mainAlpha = 0
	self.mainButtons = { }
	self.mode = 0
	self.backgroundPanelH = 0
	
	local schemaTitle = catherine.util.StuffLanguage( Schema and Schema.Title or "Example" )
	local schemaDesc = catherine.util.StuffLanguage( Schema and Schema.Desc or "Test" )
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:MakePopup( )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.3, 0 )
	self.Paint = function( pnl, w, h )
		if ( self.mode == 0 ) then
			self.mainAlpha = Lerp( 0.03, self.mainAlpha, 255 )
		else
			self.mainAlpha = Lerp( 0.08, self.mainAlpha, 0 )
		end
		
		if ( !catherine.character.IsCustomBackground( ) ) then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 255 ) )
			
			surface.SetDrawColor( 235, 235, 235, 255 )
			surface.SetMaterial( Material( "gui/gradient_up" ) )
			surface.DrawTexturedRect( 0, pnl.backgroundPanelH, w, h - pnl.backgroundPanelH )
		else
			if ( catherine.configs.enableCharacterPanelBlur ) then
				if ( self.closing ) then
					self.blurAmount = Lerp( 0.03, self.blurAmount, 0 )
				else
					self.blurAmount = Lerp( 0.03, self.blurAmount, 3 )
				end
				
				catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
			end
		end
		
		if ( pnl.closing ) then
			pnl.backgroundPanelH = Lerp( 0.05, pnl.backgroundPanelH, 0 )
		else
			pnl.backgroundPanelH = Lerp( 0.05, pnl.backgroundPanelH, h * 0.1 )
		end
		
		draw.RoundedBox( 0, 0, 0, w, pnl.backgroundPanelH, Color( 235, 235, 235, 255 ) )
		draw.RoundedBox( 0, 0, h - pnl.backgroundPanelH, w, pnl.backgroundPanelH, Color( 235, 235, 235, 255 ) )
		
		draw.SimpleText( schemaTitle, "catherine_normal25", 30, h * 0.1 / 3, Color( 0, 0, 0, self.mainAlpha ), TEXT_ALIGN_LEFT, 1 )
		draw.SimpleText( schemaDesc, "catherine_normal15", 30, h * 0.1 / 3 + 25, Color( 50, 50, 50, self.mainAlpha ), TEXT_ALIGN_LEFT, 1 )
	end
	
	self.changeLanguage = vgui.Create( "catherine.vgui.button", self )
	self.changeLanguage:SetPos( self.w - ( self.w * 0.2 ) - 30, self.h * 0.1 / 2 - 30 / 2 )
	self.changeLanguage:SetSize( self.w * 0.2, 30 )
	self.changeLanguage:SetStr( "" )
	self.changeLanguage:SetStrColor( Color( 0, 0, 0, 255 ) )
	self.changeLanguage:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.changeLanguage.PaintOverAll = function( pnl )
		local languageTable = catherine.language.FindByID( GetConVarString( "cat_convar_language" ) )
		
		if ( languageTable ) then
			pnl:SetStr( languageTable.name )
		end
	end
	self.changeLanguage.Click = function( pnl )
		local menu = DermaMenu( )
			
		for k, v in pairs( catherine.language.GetAll( ) ) do
			menu:AddOption( v.name, function( )
				RunConsoleCommand( "cat_convar_language", k )
				catherine.help.lists = { }
				catherine.menu.Rebuild( )

				timer.Simple( 0, function( )
					hook.Run( "LanguageChanged" )
					schemaTitle = catherine.util.StuffLanguage( Schema and Schema.Title or "Example" )
					schemaDesc = catherine.util.StuffLanguage( Schema and Schema.Desc or "Test" )
					
					self.createCharacter:SetStr( LANG( "Character_UI_CreateCharStr" ) )
					self.useCharacter:SetStr( LANG( "Character_UI_LoadCharStr" ) )
					//self.changeLog:SetStr( LANG( "Character_UI_ChangeLogStr" ) )
					self.back:SetStr( LANG( "Character_UI_BackStr" ) )
				end )
			end )
		end
		
		menu:Open( )
	end
	self.mainButtons[ #self.mainButtons + 1 ] = self.changeLanguage

	self.createCharacter = vgui.Create( "catherine.vgui.button", self )
	self.createCharacter:SetPos( 30, self.h - self.h * 0.1 / 2 - 30 / 2 )
	self.createCharacter:SetSize( self.w * 0.2, 30 )
	self.createCharacter:SetStr( LANG( "Character_UI_CreateCharStr" ) )
	self.createCharacter:SetStrColor( Color( 0, 0, 0, 255 ) )
	self.createCharacter:SetGradientColor( Color( 50, 50, 50, 150 ) )
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
	self.useCharacter:SetPos( 60 + self.w * 0.2, self.h - self.h * 0.1 / 2 - 30 / 2 )
	self.useCharacter:SetSize( self.w * 0.2, 30 )
	self.useCharacter:SetStr( LANG( "Character_UI_LoadCharStr" ) )
	self.useCharacter:SetStrColor( Color( 0, 0, 0, 255 ) )
	self.useCharacter:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.useCharacter.Click = function( )
		self:JoinMenu( function( )
			self:UseCharacterPanel( )
		end )
	end
	self.mainButtons[ #self.mainButtons + 1 ] = self.useCharacter
	--[[
	self.changeLog = vgui.Create( "catherine.vgui.button", self )
	self.changeLog:SetPos( 30, self.h * 0.75 + 80 )
	self.changeLog:SetSize( self.w * 0.2, 30 )
	self.changeLog:SetStr( LANG( "Character_UI_ChangeLogStr" ) )
	self.changeLog:SetStrColor( Color( 0, 0, 0, 255 ) )
	self.changeLog:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.changeLog.Click = function( )
		self:JoinMenu( function( )
			self:UpdateLogPanel( )
		end )
	end
	self.mainButtons[ #self.mainButtons + 1 ] = self.changeLog
	--]]
	self.disconnect = vgui.Create( "catherine.vgui.button", self )
	self.disconnect:SetPos( self.w - self.w * 0.2 - 30, self.h - self.h * 0.1 / 2 - 30 / 2 )
	self.disconnect:SetSize( self.w * 0.2, 30 )
	self.disconnect:SetStr( "" )
	self.disconnect.PaintOverAll = function( pnl )
		if ( self.player:IsCharacterLoaded( ) ) then
			pnl:SetStr( LANG( "Character_UI_Close" ) )
		else
			pnl:SetStr( LANG( "Character_UI_ExitServerStr" ) )
		end
	end
	self.disconnect:SetStrColor( Color( 0, 0, 0, 255 ) )
	self.disconnect:SetGradientColor( Color( 50, 50, 50, 150 ) )
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
	self.back:SetPos( 30, self.h * 0.1 / 2 - 30 / 2 )
	self.back:SetSize( self.w * 0.2, 30 )
	self.back:SetStr( LANG( "Character_UI_BackStr" ) )
	self.back:SetStrColor( Color( 0, 0, 0, 255 ) )
	self.back:SetGradientColor( Color( 50, 50, 50, 150 ) )
	self.back:SetVisible( false )
	self.back:SetAlpha( 0 )
	self.back.Click = function( )
		if ( self.mode == 0 ) then return end
		
		self:BackToMainMenu( )
	end
	
	self:PlayMusic( )
	self:ShowHint( )
end

function PANEL:ShowHint( )
	if ( catherine.catData.GetVar( "charHintShowed", "0" ) == "0" ) then
		Derma_Message( LANG( "Character_UI_Hint01" ), "", LANG( "Basic_UI_OK" ) )
		
		catherine.catData.SetVar( "charHintShowed", "1", false, true )
	end
end

function PANEL:PlayMusic( )
	local musicDir = catherine.configs.characterMenuMusic
	musicDir = type( musicDir ) == "table" and table.Random( musicDir ) or musicDir
	
	if ( musicDir and type( musicDir ) == "string" ) then
		if ( musicDir:find( "http://" ) or musicDir:find( "https://" ) ) then
			sound.PlayURL( musicDir, "noblock", function( musicEnt, errorID, errorCode )
				if ( IsValid( musicEnt ) ) then
					musicEnt:Play( )
					
					if ( catherine.configs.enabledCharacterMenuMusicLooping ) then
						musicEnt:EnableLooping( true )
					end
					
					catherine.character.panelMusic = musicEnt
				else
					Derma_Message( LANG( "Character_UI_MusicError", errorCode ), "", LANG( "Basic_UI_OK" ) )
				end
			end )
		else
			sound.PlayFile( musicDir, "", function( musicEnt, errorID, errorCode )
				if ( IsValid( musicEnt ) ) then
					musicEnt:Play( )
					
					if ( catherine.configs.enabledCharacterMenuMusicLooping ) then
						musicEnt:EnableLooping( true )
					end
					
					catherine.character.panelMusic = musicEnt
				else
					Derma_Message( LANG( "Character_UI_MusicError", errorCode ), "", LANG( "Basic_UI_OK" ) )
				end
			end )
		end
	end
end

function PANEL:CreateCharacterPanel( )
	self.createData = { datas = { } }
	self.createData.currentStageInt = 1
	self.createData.maxStageInt = 2
	self.createData.currentStage = vgui.Create( "catherine.character.stageOne", self )
end

function PANEL:UseCharacterPanel( )
	self.loadCharacter = { Lists = { }, curr = 1 }
	
	local baseW, errMsg = 300, nil
	local pl = catherine.pl
	
	for k, v in pairs( catherine.character.localCharacters ) do
		self.loadCharacter.Lists[ #self.loadCharacter.Lists + 1 ] = {
			characterDatas = v,
			panel = nil
		}
	end
	
	self.CharacterPanel = vgui.Create( "DPanel", self )
	self.CharacterPanel:SetPos( 0, self.h * 0.1 )
	self.CharacterPanel:SetSize( self.w, self.h - ( self.h * 0.2 ) )
	self.CharacterPanel:SetAlpha( 0 )
	self.CharacterPanel:AlphaTo( 255, 0.2, 0 )
	self.CharacterPanel:SetDrawBackground( false )
	self.CharacterPanel.Paint = function( pnl, w, h )
		if ( errMsg ) then
			draw.SimpleText( errMsg, "catherine_normal30", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
			return
		end
		
		if ( #self.loadCharacter.Lists == 0 ) then
			draw.SimpleText( LANG( "Character_UI_DontHaveAny" ), "catherine_normal30", w / 2, h / 2, catherine.character.IsCustomBackground( ) and Color( 255, 255, 255, 255 ) or Color( 0, 0, 0, 255 ), 1, 1 )
		end
	end
	
	local function SetTargetPanelPos( pnl, pos, a )
		if ( !IsValid( pnl ) ) then return end
		
		if ( !pnl.targetPos ) then
			pnl.targetPos = pos
		end
		
		pnl.targetPos = Lerp( 0.2, pnl.targetPos, pos )
		
		pnl:SetPos( pnl.targetPos, 30 )
	end
	
	for k, v in pairs( self.loadCharacter.Lists ) do
		local factionData = catherine.faction.FindByID( v.characterDatas._faction )
		
		if ( !factionData ) then continue end
		
		local factionName = catherine.util.StuffLanguage( factionData.name )
		local overrideModel = hook.Run( "GetCharacterPanelLoadModel", v.characterDatas ) or v.characterDatas._model
		
		v.panel = vgui.Create( "DPanel", self.CharacterPanel )
		v.panel:SetSize( baseW, self.CharacterPanel:GetTall( ) - 60 )
		v.panel.x = 0
		v.panel.y = 0
		v.panel:Center( )
		v.panel.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
		end
		
		local panel = v.panel
		local panel_w, panel_h = panel:GetWide( ), panel:GetTall( )
		
		panel.factionName = vgui.Create( "DLabel", panel )
		panel.factionName:SetTextColor( Color( 0, 0, 0 ) )
		panel.factionName:SetFont( "catherine_normal20" )
		panel.factionName:SetText( factionName )
		panel.factionName:SizeToContents( )
		panel.factionName:SetPos( panel_w / 2 - panel.factionName:GetWide( ) / 2, 10 )
		panel.factionName.PerformLayout = function( pnl, w, h )
			if ( w >= panel_w ) then
				pnl:SetWide( panel_w - 15 )
				pnl:SetPos( panel_w / 2 - pnl:GetWide( ) / 2, 10 )
			end
		end
		
		panel.charName = vgui.Create( "DLabel", panel )
		panel.charName:SetTextColor( Color( 0, 0, 0 ) )
		panel.charName:SetFont( "catherine_normal25" )
		panel.charName:SetText( v.characterDatas._name )
		panel.charName:SizeToContents( )
		panel.charName:SetPos( panel_w / 2 - panel.charName:GetWide( ) / 2, panel_h - 110 )
		panel.charName.PerformLayout = function( pnl, w, h )
			if ( w >= panel_w ) then
				pnl:SetWide( panel_w - 15 )
				pnl:SetPos( panel_w / 2 - pnl:GetWide( ) / 2, panel_h - 110 )
			end
		end
		
		panel.charDesc = vgui.Create( "DLabel", panel )
		panel.charDesc:SetTextColor( Color( 60, 60, 60 ) )
		panel.charDesc:SetFont( "catherine_normal15" )
		panel.charDesc:SetText( v.characterDatas._desc )
		panel.charDesc:SizeToContents( )
		panel.charDesc:SetPos( panel_w / 2 - panel.charDesc:GetWide( ) / 2, panel_h - 70 )
		panel.charDesc.PerformLayout = function( pnl, w, h )
			if ( w >= panel_w ) then
				pnl:SetWide( panel_w - 15 )
				pnl:SetPos( panel_w / 2 - pnl:GetWide( ) / 2, panel_h - 70 )
			end
		end
		
		local acceptMaterial = Material( "CAT/ui/accept_2_32.png" )
		
		panel.useCharacter = vgui.Create( "DButton", panel )
		panel.useCharacter:SetSize( 32, 32 )
		panel.useCharacter:SetPos( panel_w * 0.3, panel_h - 39 )
		panel.useCharacter:SetText( "" )
		panel.useCharacter:SetToolTip( LANG( "Character_UI_UseCharacter" ) )
		panel.useCharacter.Paint = function( pnl, w, h )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( acceptMaterial )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		panel.useCharacter.DoClick = function( )
			netstream.Start( "catherine.character.Use", v.characterDatas._id )
		end
		
		local deleteMaterial = Material( "CAT/ui/x_32.png" )
		
		panel.deleteCharacter = vgui.Create( "DButton", panel )
		panel.deleteCharacter:SetSize( 32, 32 )
		panel.deleteCharacter:SetPos( panel_w * 0.6, panel_h - 39 )
		panel.deleteCharacter:SetText( "" )
		panel.deleteCharacter:SetToolTip( LANG( "Character_UI_DeleteCharacter" ) )
		panel.deleteCharacter.Paint = function( pnl, w, h )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( deleteMaterial )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		panel.deleteCharacter.DoClick = function( )
			Derma_Query( LANG( "Character_Notify_DeleteQ" ), "", LANG( "Basic_UI_YES" ), function( )
				netstream.Start( "catherine.character.Delete", v.characterDatas._id )
			end, LANG( "Basic_UI_NO" ), function( ) end )
		end
		
		panel.model = vgui.Create( "DModelPanel", panel )
		panel.model:SetSize( panel_w, panel_h - 160 )
		panel.model:SetPos( panel_w / 2 - panel.model:GetWide( ) / 2, 40 )
		panel.model:MoveToBack( )
		panel.model:SetModel( overrideModel )
		panel.model:SetDrawBackground( false )
		panel.model:SetDisabled( true )
		panel.model:SetFOV( 40 )
		panel.model.LayoutEntity = function( pnl, ent )
			ent:SetAngles( Angle( 0, 45, 0 ) )
			ent:SetIK( false )
			
			if ( k == self.loadCharacter.curr ) then
				pnl:RunAnimation( )
			end
		end
		
		panel.button = vgui.Create( "DButton", panel )
		panel.button:SetSize( panel_w, panel_h )
		panel.button:Center( )
		panel.button:SetText( "" )
		panel.button:SetDrawBackground( false )
		panel.button.DoClick = function( )
			self.loadCharacter.curr = k
		end
		
		if ( IsValid( panel.model.Entity ) ) then
			local min, max = panel.model.Entity:GetRenderBounds( )
			
			panel.model:SetCamPos( min:Distance( max ) * Vector( 0.5, 0.5, 0.5 ) )
			panel.model:SetLookAt( ( max + min ) / 2 )
		end
		
		hook.Run( "PostInitLoadCharacterList", pl, panel, v.characterDatas )
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
			pnl.loadingAni = math.Approach( pnl.loadingAni, pnl.loadingAni - 9, 9 )
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 255, 255, pnl.loadingAlpha )
			catherine.geometry.DrawCircle( w / 2, h / 2, 20, 5, pnl.loadingAni, 50, 100 )
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
		local vol = 1
		
		hook.Remove( "Think", "catherine.character.FadeOutBackgroundMusic" )
		
		hook.Add( "Think", "catherine.character.FadeOutBackgroundMusic", function( )
			if ( vol > 0 ) then
				vol = vol - 0.005
			else
				hook.Remove( "Think", "catherine.character.FadeOutBackgroundMusic" )
				music:Stop( )
				catherine.character.panelMusic = nil
				return
			end
			
			music:SetVolume( vol )
		end )
	end
	
	self:AlphaTo( 0, 0.3, 0, function( )
		hook.Run( "CharacterMenuExited", self.player )
		
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.character", PANEL, "DFrame" )

local PANEL = { }

function PANEL:Init( )
	self.parent = self:GetParent( )
	self.w, self.h = self.parent.w, self.parent.h - ( self.parent.h * 0.2 )
	self.data = { faction = nil }
	self.factionList = catherine.faction.GetPlayerUsableFaction( self.parent.player )
	self.factionImage = nil

	self:SetSize( self.w, self.h )
	self:SetPos( self.parent.w / 2 - self.w / 2, self.parent.h * 0.1 )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.3, 0 )
	
	self.label01 = vgui.Create( "DLabel", self )
	self.label01:SetPos( 15, 15 )
	self.label01:SetColor( Color( 0, 0, 0, 255 ) )
	self.label01:SetFont( "catherine_normal25" )
	self.label01:SetText( LANG( "Faction_UI_Title" ) )
	self.label01:SizeToContents( )

	self.selectFaction = vgui.Create( "catherine.vgui.button", self )
	self.selectFaction:SetSize( self.w * 0.3, 50 )
	self.selectFaction:SetPos( 50, self.h / 2 - 50 / 2 )
	self.selectFaction:SetStr( LANG( "Character_UI_SelectFaction" ) )
	self.selectFaction:SetStrFont( "catherine_normal20" )
	self.selectFaction:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.selectFaction:SetGradientColor( Color( 50, 50, 50, 255 ) )
	self.selectFaction.Click = function( )
		local menu = DermaMenu( )
		
		for k, v in pairs( self.factionList ) do
			local factionName = catherine.util.StuffLanguage( v.name )
			
			menu:AddOption( factionName, function( )
				self.selectFaction:SetStr( factionName )
				self.data.faction = v.uniqueID
				
				if ( v.factionImage ) then
					self.factionImage = v.factionImage
				elseif ( !v.factionImage ) then
					self.factionImage = nil
				end
			end )
		end
		
		menu:Open( )
	end
	self.selectFaction.PaintBackground = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end

	self.nextStage = vgui.Create( "catherine.vgui.button", self )
	self.nextStage:SetPos( self.w - self.w * 0.2 - 10, 15 )
	self.nextStage:SetSize( self.w * 0.2, 30 )
	self.nextStage:SetStr( LANG( "Basic_UI_Continue" ) )
	self.nextStage:SetStrFont( "catherine_normal20" )
	self.nextStage:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.nextStage:SetGradientColor( Color( 50, 50, 50, 255 ) )
	self.nextStage.Click = function( )
		if ( self.data.faction ) then
			if ( catherine.faction.FindByID( self.data.faction ) ) then
				self.parent.createData.datas.faction = self.data.faction
				self.parent.createData.currentStageInt = self.parent.createData.currentStageInt + 1
				self.parent.createData.currentStage = vgui.Create( "catherine.character.stageTwo", self.parent )
				self:AlphaTo( 0, 0.3, 0, function( )
					self:Remove( )
				end )
			else
				self:PrintErrorMessage( LANG( "Faction_Notify_NotValid", self.data.faction ) )
			end
		else
			self:PrintErrorMessage( LANG( "Faction_Notify_SelectPlease" ) )
		end
	end
	self.nextStage.PaintBackground = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end
end

function PANEL:PrintErrorMessage( msg )
	Derma_Message( msg, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
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
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 200 ) )
	
	if ( self.factionImage ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material( self.factionImage ) )
		surface.DrawTexturedRect( w * 0.7 - 512 / 2, h / 2 - 256 / 2, 512, 256 )
	end
end

vgui.Register( "catherine.character.stageOne", PANEL, "DPanel" )

local PANEL = { }

function PANEL:Init( )
	self.parent = self:GetParent( )
	self.w, self.h = self.parent.w, self.parent.h - ( self.parent.h * 0.2 )
	self.data = {
		name = "",
		desc = "",
		model = ""
	}
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.parent.w / 2 - self.w / 2, self.parent.h * 0.1 )
	
	self.label01 = vgui.Create( "DLabel", self )
	self.label01:SetPos( 15, 15 )
	self.label01:SetColor( Color( 0, 0, 0, 255 ) )
	self.label01:SetFont( "catherine_normal25" )
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
		local delta = 0
		
		for k, v in pairs( factionTable.models ) do
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( 64, 64 )
			spawnIcon:SetModel( v )
			spawnIcon:SetToolTip( false )
			spawnIcon:SetAlpha( 0 )
			spawnIcon:AlphaTo( 255, 0.3, delta )
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
			
			delta = delta + 0.03
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
	self.nextStage:SetSize( self.w * 0.2, 30 )
	self.nextStage:SetStr( LANG( "Basic_UI_Continue" ) )
	self.nextStage:SetStrFont( "catherine_normal20" )
	self.nextStage:SetStrColor( Color( 50, 50, 50, 255 ) )
	self.nextStage:SetGradientColor( Color( 50, 50, 50, 255 ) )
	self.nextStage.Click = function( )
		local i = 0
		local pl = self.parent.player
		
		for k, v in pairs( self.data ) do
			local vars = catherine.character.FindVarByID( k )
			
			if ( vars and vars.checkValid ) then
				i = i + 1
				
				local success, reason = vars.checkValid( pl, self.data[ k ] )
				
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
	self.nextStage.PaintBackground = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end
end

function PANEL:PrintErrorMessage( msg )
	Derma_Message( msg, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 200 ) )
	
	draw.SimpleText( self.data.name:utf8len( ) .. "/" .. catherine.configs.characterNameMaxLen, "catherine_normal20", w - 10, 60 + 20 / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
	draw.SimpleText( self.data.desc:utf8len( ) .. "/" .. catherine.configs.characterDescMaxLen, "catherine_normal20", w - 10, 100 + 20 / 2, Color( 50, 50, 50, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

vgui.Register( "catherine.character.stageTwo", PANEL, "DPanel" )

catherine.menu.Register( function( )
	return LANG( "Character_UI_Title" )
end, "character", function( menuPnl, itemPnl )
	vgui.Create( "catherine.vgui.character" )
	menuPnl:Close( )
end )