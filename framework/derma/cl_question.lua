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
	catherine.vgui.question = self

	self.answers = { }
	self.player = LocalPlayer( )
	self.w, self.h = ScrW( ), ScrH( )
	self.questionTitle = LANG( "Question_UIStr" )
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:MakePopup( )
	self:ShowCloseButton( false )
	
	self.List = vgui.Create( "DPanelList", self )
	self.List:SetSpacing( 5 )
	self.List:EnableHorizontal( false )
	self.List:EnableVerticalScrollbar( true )
	self.List:SetDrawBackground( false )
	
	self.start = vgui.Create( "catherine.vgui.button", self )
	self.start:SetPos( self.w * 0.7, self.h * 0.9 )
	self.start:SetSize( self.w * 0.2, 30 )
	self.start:SetStr( LANG( "Question_UI_Continue" ) )
	self.start:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.start.Click = function( pnl )
		if ( table.Count( self.answers ) == 0 ) then
			return
		end
		
		netstream.Start( "catherine.question.Check", self.answers )
	end
	
	self.changeLanguage = vgui.Create( "catherine.vgui.button", self )
	self.changeLanguage:SetPos( 50, 20 )
	self.changeLanguage:SetSize( self.w * 0.2, 30 )
	self.changeLanguage:SetStr( "" )
	self.changeLanguage:SetStrColor( Color( 255, 255, 255, 255 ) )
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
				RunConsoleCommand( "cat_menu_rebuild" )
				
				timer.Simple( 0, function( )
					self.start:SetStr( LANG( "Question_UI_Continue" ) )
					self.disconnect:SetStr( LANG( "Question_UI_Disconnect" ) )
					self.questionTitle = LANG( "Question_UIStr" )
					
					self.answers = { }
					self:RebuildQuestion( )
					
					hook.Run( "LanguageChanged" )
				end )
			end )
		end
		
		menu:Open( )
	end
	
	self.disconnect = vgui.Create( "catherine.vgui.button", self )
	self.disconnect:SetPos( self.w * 0.1, self.h * 0.9 )
	self.disconnect:SetSize( self.w * 0.2, 30 )
	self.disconnect:SetStr( LANG( "Question_UI_Disconnect" ) )
	self.disconnect:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.disconnect.Click = function( )
		Derma_Query( LANG( "Question_Notify_DisconnectQ" ), "", LANG( "Basic_UI_YES" ), function( )
			RunConsoleCommand( "disconnect" )
		end, LANG( "Basic_UI_NO" ), function( ) end )
	end
	
	self:RebuildQuestion( )
end

function PANEL:RebuildQuestion( )
	local questionTable = catherine.question.GetAll( )
		
	self.List:SetSize( self.w * 0.7, 60 * #questionTable + ( 5 * #questionTable ) )
	self.List:SetPos( self.w / 2 - self.List:GetWide( ) / 2, self.h * 0.45 - self.List:GetTall( ) / 2 )
		
	self.List:Clear( )
	
	for k, v in pairs( questionTable ) do
		local title = catherine.util.StuffLanguage( v.title )
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.List:GetWide( ), 60 )
		panel.Paint = function( pnl, w, h )
			draw.SimpleText( k .. ".", "catherine_normal30", 5, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			draw.SimpleText( title, "catherine_normal20", 30, 5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		end
		
		local button = vgui.Create( "DButton", panel )
		button:SetSize( panel:GetWide( ) * 0.5 - 20, 20 )
		button:SetPos( panel:GetWide( ) * 0.5, panel:GetTall( ) - 30 )
		button:SetFont( "catherine_normal15" )
		button:SetText( "" )
		button:SetTextColor( Color( 255, 255, 255 ) )
		button.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
		end
		button.DoClick = function( )
			local menu = DermaMenu( )
			
			for k1, v1 in pairs( v.answerList ) do
				local val = catherine.util.StuffLanguage( v1 )

				menu:AddOption( val, function( )
					button:SetText( val )
					self.answers[ k ] = k1
				end )
			end
			
			menu:Open( )
		end

		self.List:AddItem( panel )
	end
end

function PANEL:Paint( w, h )
	local sin = math.sin( CurTime( ) / 2 )

	surface.SetDrawColor( 90, 90, 90, 100 )
	surface.SetMaterial( Material( "gui/gradient_down" ) )
	surface.DrawTexturedRect( 0, 0, w, h )
	
	surface.SetDrawColor( 0, 0, 0, math.max( sin * 255, 50 ) )
	surface.SetMaterial( Material( "gui/gradient_up" ) )
	surface.DrawTexturedRect( 0, 0, w, h )
	
	draw.SimpleText( self.questionTitle, "catherine_normal25", w * 0.15, h * 0.35 - 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
end

function PANEL:Close( )
	if ( self.closing ) then return end
	
	self.closing = true
	
	self:Remove( )
	self = nil
end

vgui.Register( "catherine.vgui.question", PANEL, "DFrame" )