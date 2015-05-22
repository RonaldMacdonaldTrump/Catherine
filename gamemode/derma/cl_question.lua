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

concommand.Add( "quiz_open", function( )
	if ( IsValid( catherine.vgui.question ) ) then
		catherine.vgui.question:Remove( )
		
		catherine.vgui.question = vgui.Create( "catherine.vgui.question" )
	else
		catherine.vgui.question = vgui.Create( "catherine.vgui.question" )
	end
end )

local PANEL = { }

function PANEL:Init( )
	catherine.vgui.question = self

	self.questionType = nil
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ), ScrH( )

	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "QUESTION" )
	self:MakePopup( )
	self:ShowCloseButton( true )
	
	self.List = vgui.Create( "DPanelList", self )
	self.List:SetSize( self.w / 2, self.h / 2 )
	self.List:SetPos( self.w / 2 - self.w / 2 / 2, self.h / 2 - self.h / 2 / 2 )
	self.List:SetSpacing( 5 )
	self.List.Alpha = 255
	self.List:EnableHorizontal( false )
	self.List:EnableVerticalScrollbar( true )
	self.List.Paint = function( pnl, w, h )
		//catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end
	
	self.start = vgui.Create( "catherine.vgui.button", self )
	self.start:SetPos( self.w * 0.7, self.h * 0.9 )
	self.start:SetSize( self.w * 0.2, 30 )
	self.start:SetStr( "Continue" )
	self.start.Alpha = 255
	self.start.Cant = false
	self.start:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.start.Click = function( )
		if ( self.start.Cant ) then return end
		
		if ( self.questionType == CAT_QUESTION_MULTIPLE_CHOICE ) then
			if ( !self.answers or table.Count( self.answers ) == 0 ) then
				print("?!")
				return
			end
			
			netstream.Start( "catherine.question.CheckMultipleChoice", self.answers )
		elseif ( self.questionType == CAT_QUESTION_DESCRIPTIVE ) then
			if ( !self.answers or table.Count( self.answers ) == 0 ) then
				print("?!")
				return
			end
			
			netstream.Start( "catherine.question.StartDescriptive", self.answers )
			
		end
	end
	
	self.disconnect = vgui.Create( "catherine.vgui.button", self )
	self.disconnect:SetPos( self.w * 0.1, self.h * 0.9 )
	self.disconnect:SetSize( self.w * 0.2, 30 )
	self.disconnect:SetStr( "Disconnect" )
	self.disconnect:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.disconnect.Click = function( )
		
	end
end

function PANEL:InitializeQuestion( typ )
	self.questionType = typ

	// wtf
	if ( typ == CAT_QUESTION_MULTIPLE_CHOICE ) then
		self.answers = { }
		self:RebuildQuestion( typ )
	elseif ( typ == CAT_QUESTION_DESCRIPTIVE ) then
		self.answers = { }
		self:RebuildQuestion( typ )
	end
end

function PANEL:RebuildQuestion( typ )
	if ( typ == CAT_QUESTION_MULTIPLE_CHOICE ) then
		self.List:Clear( )
		
		for k, v in pairs( catherine.question.GetAllMultipleChoice( ) ) do
			// add language stuff.
			
			local panel = vgui.Create( "DPanel" )
			panel:SetSize( self.List:GetWide( ), 60 )
			panel.Paint = function( pnl, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 235 ) )
				
				draw.SimpleText( k .. ".", "catherine_normal30", 5, 0, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
				draw.SimpleText( v.title, "catherine_normal20", 30, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			end
			
			local button = vgui.Create( "DButton", panel )
			button:SetSize( panel:GetWide( ) * 0.5 - 20, 20 )
			button:SetPos( panel:GetWide( ) * 0.5, panel:GetTall( ) - 30 )
			button:SetFont( "catherine_normal20" )
			button:SetText( "" )
			button:SetTextColor( Color( 50, 50, 50 ) )
			button.Paint = function( pnl, w, h )
				draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
			end
			button.DoClick = function( )
				local menu = DermaMenu( )
				
				for k1, v1 in pairs( v.answerList ) do
					menu:AddOption( v1, function( )
						button:SetText( v1 )
						self.answers[ k ] = k1
					end )
				end
				
				menu:Open( )
			end
			
			
			
			self.List:AddItem( panel )
		end
	elseif ( typ == CAT_QUESTION_DESCRIPTIVE ) then
		self.List:Clear( )
		
		for k, v in pairs( catherine.question.GetAllDescriptive( ) ) do
			// add language stuff.
			
			local panel = vgui.Create( "DPanel" )
			panel:SetSize( self.List:GetWide( ), 200 )
			panel.Paint = function( pnl, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 235 ) )
				
				draw.SimpleText( k .. ".", "catherine_normal30", 5, 0, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
				draw.SimpleText( v.title, "catherine_normal20", 30, 5, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			end
			
			local textEnt = vgui.Create( "DTextEntry", panel )
			textEnt:SetSize( panel:GetWide( ) - 20, panel:GetTall( ) - 50 )
			textEnt:SetPos( 10, 40 )
			textEnt:SetFont( "catherine_normal15" )
			textEnt:SetMultiline( true )
			textEnt:SetText( v.defVal )
			textEnt.Paint = function( pnl, w, h )
				catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
				pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
				
				self.answers[ k ] = pnl:GetText( )
			end
			
			
			
			self.List:AddItem( panel )
		end
	end
end

function PANEL:GetQuestionType( )
	return self.questionType
end


function PANEL:Paint( w, h )
	local waitStatus = self.player:GetNetVar( "question_wait" )
	
	if ( waitStatus ) then
		self.start.Alpha = Lerp( 0.03, self.start.Alpha, 30 )
		self.start:SetAlpha( self.start.Alpha )
		self.start.Cant = true
		
		self.List.Alpha = Lerp( 0.03, self.List.Alpha, 0 )
		self.List:SetAlpha( self.List.Alpha )
		
		draw.SimpleText( "Waiting ...", "catherine_normal30", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
	else
		self.start.Alpha = Lerp( 0.03, self.start.Alpha, 255 )
		self.start:SetAlpha( self.start.Alpha )
		self.start.Cant = false
		
		self.List.Alpha = Lerp( 0.03, self.List.Alpha, 255 )
		self.List:SetAlpha( self.List.Alpha )
	end
end

function PANEL:Close( )
	if ( self.closeing ) then return end
	
	self.closeing = true
	self:Remove( )
	self = nil
end

vgui.Register( "catherine.vgui.question", PANEL, "DFrame" )