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
	catherine.vgui.news = self
	
	self:SetMenuSize( ScrW( ) * 0.7, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "News_UI_Title" ) )

	self.currPage = 0
	self.maxPages = 0
	self.pages = { }
	self.mode = 0
	self.currNewsPage = nil
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 75 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
		
		if ( self.currPage == 0 ) then
			draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 50, 50, 50, 255 ), 1, 1 )
			draw.SimpleText( LANG( "News_UI_SelectPage" ), "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end
	end
	
	self.Pages = vgui.Create( "DPanelList", self )
	self.Pages.barX = 0
	self.Pages:SetPos( 10, self.h - 30 )
	self.Pages:SetSize( self.w - 20, 20 )
	self.Pages:SetSpacing( 0 )
	self.Pages:EnableHorizontal( true )
	self.Pages:EnableVerticalScrollbar( false )
	self.Pages.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end
	self.Pages.PaintOver = function( pnl, w, h )
		if ( self.currPage == 0 ) then return end
		
		pnl.barX = Lerp( 0.05, pnl.barX, ( self.currPage * 50 ) - 50 )
		
		draw.RoundedBox( 0, pnl.barX, h - 2, 50, 2, Color( 50, 50, 50, 255 ) )
	end
	
	self.back = vgui.Create( "catherine.vgui.button", self )
	self.back:SetPos( self.w - ( self.w * 0.2 ), 0 )
	self.back:SetSize( self.w * 0.2, 25 )
	self.back:SetStr( LANG( "News_UI_Back" ) )
	self.back:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.back.Click = function( pnl )
		if ( self.mode == 1 ) then
			self.mode = 0
			self.currNewsPage = nil
		end
	end
	self.back:SetVisible( false )
	
	self.newsBase = vgui.Create( "DPanelList", self )
	self.newsBase:SetPos( 10, 80 )
	self.newsBase:SetSize( self.w - 20, self.h - 90 )
	self.newsBase:SetSpacing( 0 )
	self.newsBase:EnableHorizontal( false )
	self.newsBase:EnableVerticalScrollbar( true )
	self.newsBase.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_PNLLIST, w, h )
	end
	self.newsBase:SetVisible( false )
	
	self.Pages.VBar:SetVisible( false )
end

function PANEL:OnMenuRecovered( )
	self:InitializeNews( )
end

function PANEL:MenuPaint( w, h )
	if ( self.mode == 1 ) then
		self.back:SetVisible( true )
		self.Lists:SetVisible( false )
		self.Pages:SetVisible( false )
		self.newsBase:SetVisible( true )
		
		local pageData = self.currNewsPage
		
		if ( pageData ) then
			draw.SimpleText( pageData.title or "ERROR", "catherine_normal25", 10, 45, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( pageData.author or "ERROR", "catherine_normal15", w - 10, 60, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, 1 )
			draw.SimpleText( pageData.time or "ERROR", "catherine_normal25", w - 10, 40, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, 1 )
			draw.RoundedBox( 0, 10, 70, w - 20, 1, Color( 180, 180, 180, 255 ) )
		end
	else
		self.back:SetVisible( false )
		self.Lists:SetVisible( true )
		self.Pages:SetVisible( true )
		self.newsBase:SetVisible( false )
	end
end

function PANEL:InitializeNews( )
	local newsData = catherine.net.GetNetGlobalVar( "cat_news", { } )
	local currCalc = 15
	local currPage = 1
	
	for k, v in pairs( newsData ) do
		self.pages[ currPage ] = self.pages[ currPage ] or { }
		self.pages[ currPage ][ #self.pages[ currPage ] + 1 ] = v
		
		if ( k == #newsData ) then
			self.maxPages = k
			
			break
		end
		
		if ( k >= currCalc ) then
			currCalc = currCalc + 15
			currPage = currPage + 1
		end
	end
	
	self.currPage = 0
	self:BuildPages( )
end

function PANEL:JoinPage( pageID )
	if ( !self.pages[ pageID ] ) then return end
	
	self.currPage = pageID
	self.Lists:Clear( )
	
	for k, v in pairs( self.pages[ pageID ] ) do
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( 50, 50 )
		panel.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
			
			draw.SimpleText( v.title, "catherine_normal25", 10, h / 2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( v.author, "catherine_normal15", w - 10, 10, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, 1 )
			draw.SimpleText( v.time, "catherine_normal25", w - 10, 30, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, 1 )
		end
		
		local button = vgui.Create( "DButton", panel )
		button:SetText( "" )
		button:Dock( FILL )
		button:SetDrawBackground( false )
		button.DoClick = function( )
			self.mode = 1
			self.currNewsPage = v
			self:BuildNewsBase( v )
		end
		
		self.Lists:AddItem( panel )
	end
end

function PANEL:BuildNewsBase( data )
	self.newsBase:Clear( )
	
	local convert = string.Explode( "<;>", data.val )
	
	for k, v in pairs( convert ) do
		local panel = vgui.Create( "DPanel" )
		panel:SetTall( 25 )
		panel:SetDrawBackground( false )
		
		if ( v:find( "<img>" ) ) then
			local imageData = util.JSONToTable( v:gsub( "<img>", "" ) )
			
			if ( !imageData ) then continue end
			
			local htmlData = [[
				<a href="url"><img src="]] .. imageData.imgURL .. [[" width="]] .. imageData.w .. [[" height="]] .. imageData.h .. [[" border="0"></a>
			]]

			local html = vgui.Create( "DHTML", panel )
			panel:SetSize( self.newsBase:GetWide( ), imageData.h + 20 )
			html:Dock( FILL )
			html:SetHTML( htmlData )
			html.Paint = function( pnl, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
				draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
			end
		else
			local textEnt = vgui.Create( "DTextEntry", panel )
			textEnt:Dock( FILL )
			textEnt:SetText( v )
			textEnt:SetEditable( false )
			textEnt:SetFont( "catherine_normal15" )
			textEnt.Paint = function( pnl, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
				draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 255 ) )
				
				pnl:DrawTextEntryText( color_black, color_black, color_black )
			end
		end
		
		self.newsBase:AddItem( panel )
	end
end

function PANEL:BuildPages( )
	self.Pages:Clear( )
	
	for k, v in pairs( self.pages ) do
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( 50, self.Pages:GetTall( ) )
		panel.Paint = function( pnl, w, h )
			draw.SimpleText( k, "catherine_normal20", w / 2, h / 2, Color( 0, 0, 0, 255 ), 1, 1 )
		end
		
		local button = vgui.Create( "DButton", panel )
		button:SetText( "" )
		button:Dock( FILL )
		button:SetDrawBackground( false )
		button.DoClick = function( )
			self:JoinPage( k )
		end
		
		self.Pages:AddItem( panel )
	end
end

vgui.Register( "catherine.vgui.news", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "News_UI_Title" )
end, function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.news ) and catherine.vgui.news or vgui.Create( "catherine.vgui.news", menuPnl )
end )