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

function Derma_Message( strText, strTitle, strButtonText )
	surface.PlaySound( "CAT/notify02.wav" )
	local imageWAni = 0
	local imageHAni = 0
	
	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( "" )
	Window:SetSize( ScrW( ), ScrH( ) * 0.15 )
	Window:Center( )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:MakePopup( )
	Window:SetAlpha( 0 )
	Window:AlphaTo( 255, 0.1, 0 )
	Window.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 200 ) )
		
		local sin = math.sin( CurTime( ) * 5 )
		local imageW, imageH = 64 + ( 5 * sin ), 64 + ( 5 * sin )
		
		imageWAni = Lerp( 0.06, imageWAni, imageW )
		imageHAni = Lerp( 0.06, imageHAni, imageH )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material( "CAT/ui/icon_warning2.png", "smooth" ) )
		surface.DrawTexturedRect( 50 - imageWAni / 2 / 2, ( h / 2 - imageHAni / 2 ), imageWAni, imageHAni )
		
		local wrapTexts = catherine.util.GetWrapTextData( strText, w / 3, "catherine_normal20" )

		if ( #wrapTexts == 1 ) then
			draw.SimpleText( wrapTexts[ 1 ], "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		else
			local textY = ( ( h / 2 ) - ( #wrapTexts * 25 ) / 2 / 2 ) / 2
			
			for k, v in pairs( wrapTexts ) do
				draw.SimpleText( v, "catherine_normal20", w / 2, textY + k * 25, Color( 50, 50, 50, 255 ), 1, 1 )
			end
		end
	end

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )
	ButtonPanel:SetDrawBackground( false )

	local Okay = vgui.Create( "catherine.vgui.button", ButtonPanel )
	Okay:SetPos( 5, 5 )
	Okay:SetSize( 100, 25 )
	Okay:SetStr( strButtonText or LANG( "Basic_UI_OK" ) )
	Okay:SetStrColor( Color( 50, 50, 50, 255 ) )
	Okay:SetGradientColor( Color( 50, 50, 50, 255 ) )
	Okay:SetStrFont( "catherine_normal15" )
	Okay:SetAlpha( 0 )
	Okay:AlphaTo( 255, 0.2, 0.2 )
	Okay.Click = function( )
		Window:AlphaTo( 0, 0.1, 0, function( )
			Window:Close( )
		end )
	end
	
	ButtonPanel:SetWide( Okay:GetWide( ) + 10 )
	ButtonPanel:CenterHorizontal( )
	ButtonPanel:AlignBottom( 8 )

	return Window
end

function Derma_Query( strText, strTitle, ... )
	surface.PlaySound( "CAT/notify02.wav" )
	local imageWAni = 0
	local imageHAni = 0
	
	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( "" )
	Window:SetSize( ScrW( ), ScrH( ) * 0.15 )
	Window:Center( )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:MakePopup( )
	Window:SetAlpha( 0 )
	Window:AlphaTo( 255, 0.1, 0 )
	Window.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 200 ) )
		
		local sin = math.sin( CurTime( ) * 5 )
		local imageW, imageH = 64 + ( 5 * sin ), 64 + ( 5 * sin )
		
		imageWAni = Lerp( 0.06, imageWAni, imageW )
		imageHAni = Lerp( 0.06, imageHAni, imageH )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material( "CAT/ui/icon_warning2.png", "smooth" ) )
		surface.DrawTexturedRect( 50 - imageWAni / 2 / 2, ( h / 2 - imageHAni / 2 ), imageWAni, imageHAni )

		local wrapTexts = catherine.util.GetWrapTextData( strText, w / 3, "catherine_normal20" )

		if ( #wrapTexts == 1 ) then
			draw.SimpleText( wrapTexts[ 1 ], "catherine_normal20", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		else
			local textY = ( ( h / 2 ) - ( #wrapTexts * 25 ) / 2 / 2 ) / 2
			
			for k, v in pairs( wrapTexts ) do
				draw.SimpleText( v, "catherine_normal20", w / 2, textY + k * 25, Color( 50, 50, 50, 255 ), 1, 1 )
			end
		end
	end

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )
	ButtonPanel:SetDrawBackground( false )

	local NumOptions = 0
	local x = 5
	local delta = 0.2
	
	for k = 1, 8, 2 do
		local Text = select( k, ... )
		if ( Text == nil ) then break end
		
		local Func = select( k + 1, ... ) or function( ) end
	
		local Button = vgui.Create( "catherine.vgui.button", ButtonPanel )
		Button:SetSize( 100, 20 )
		Button:SetStr( Text or LANG( "Basic_UI_OK" ) )
		Button:SetStrColor( Color( 50, 50, 50, 255 ) )
		Button:SetGradientColor( Color( 50, 50, 50, 255 ) )
		Button:SetStrFont( "catherine_normal15" )
		Button:SetAlpha( 0 )
		Button:AlphaTo( 255, 0.2, delta )
		Button.Click = function( )
			Window:AlphaTo( 0, 0.1, 0, function( )
				Window:Close( )
				Func( )
			end )
		end
		Button:SetPos( x, 5 )
		
		x = x + Button:GetWide( ) + 5
		delta = delta + 0.1
		
		ButtonPanel:SetWide( x ) 
		NumOptions = NumOptions + 1
	end

	ButtonPanel:CenterHorizontal( )
	ButtonPanel:AlignBottom( 8 )

	if ( NumOptions == 0 ) then
		Window:Close( )
		
		return nil
	end
	
	return Window
end

function Derma_StringRequest( strTitle, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText )
	surface.PlaySound( "CAT/notify02.wav" )
	local imageWAni = 0
	local imageHAni = 0
	
	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( "" )
	Window:SetSize( ScrW( ), ScrH( ) * 0.15 )
	Window:Center( )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:MakePopup( )
	Window:SetAlpha( 0 )
	Window:AlphaTo( 255, 0.1, 0 )
	Window.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 200 ) )
		
		local sin = math.sin( CurTime( ) * 5 )
		local imageW, imageH = 64 + ( 5 * sin ), 64 + ( 5 * sin )
		
		imageWAni = Lerp( 0.06, imageWAni, imageW )
		imageHAni = Lerp( 0.06, imageHAni, imageH )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material( "CAT/ui/icon_warning2.png", "smooth" ) )
		surface.DrawTexturedRect( 50 - imageWAni / 2 / 2, ( h / 2 - imageHAni / 2 ), imageWAni, imageHAni )

		draw.SimpleText( strText, "catherine_normal20", w / 2, h * 0.2, Color( 50, 50, 50, 255 ), 1, 1 )
	end

	local TextEntry = vgui.Create( "DTextEntry", Window )
	TextEntry:SetText( strDefaultText or "" )
	TextEntry.OnEnter = function( pnl )
		Window:Close( )
		fnEnter( pnl:GetText( ) )
	end
	TextEntry.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 50, 50, 50 ), Color( 45, 45, 45 ), Color( 50, 50, 50 ) )
	end
	TextEntry:SetSize( ScrW( ) * 0.7, 30 )
	TextEntry:SetPos( Window:GetWide( ) / 2 - TextEntry:GetWide( ) / 2, Window:GetTall( ) / 2 - TextEntry:GetTall( ) / 2 )
	TextEntry:SetFont( "catherine_normal15" )
	
	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 20 )
	ButtonPanel:SetDrawBackground( false )
	
	local Button = vgui.Create( "catherine.vgui.button", ButtonPanel )
	Button:SetSize( 100, 20 )
	Button:SetStr( strButtonText or LANG( "Basic_UI_OK" ) )
	Button:SetStrColor( Color( 50, 50, 50, 255 ) )
	Button:SetGradientColor( Color( 50, 50, 50, 255 ) )
	Button:SetStrFont( "catherine_normal15" )
	Button:SetAlpha( 0 )
	Button:AlphaTo( 255, 0.2, 0.2 )
	Button.DoClick = function( )
		Window:AlphaTo( 0, 0.1, 0, function( )
			Window:Close( )
			fnEnter( TextEntry:GetText( ) )
		end )
	end
	
	local ButtonCancel = vgui.Create( "catherine.vgui.button", ButtonPanel )
	ButtonCancel:SetSize( 100, 20 )
	ButtonCancel:SetStr( strButtonCancelText or LANG( "Basic_UI_NO" ) )
	ButtonCancel:SetStrColor( Color( 50, 50, 50, 255 ) )
	ButtonCancel:SetGradientColor( Color( 50, 50, 50, 255 ) )
	ButtonCancel:SetStrFont( "catherine_normal15" )
	ButtonCancel:SetAlpha( 0 )
	ButtonCancel:AlphaTo( 255, 0.2, 0.4 )
	ButtonCancel.DoClick = function( )
		Window:AlphaTo( 0, 0.1, 0, function( )
			Window:Close( )
			
			if ( fnCancel ) then
				fnCancel( TextEntry:GetText( ) )
			end
		end )
	end
	ButtonCancel:MoveRightOf( Button, 5 )

	ButtonPanel:SetWide( Button:GetWide( ) + 5 + ButtonCancel:GetWide( ) + 10 )

	TextEntry:RequestFocus( )
	TextEntry:SelectAllText( true )
	
	ButtonPanel:CenterHorizontal( )
	ButtonPanel:AlignBottom( 8 )

	return Window
end