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

	local Window = vgui.Create( "DFrame" )
		Window:SetTitle( "" )
		Window:SetDraggable( false )
		Window:ShowCloseButton( false )
		Window:SetBackgroundBlur( true )
		Window:SetDrawOnTop( true )
		Window.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 200 ) )
			
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( Material( "CAT/ui/icon_warning2.png" ) )
			surface.DrawTexturedRect( 30, h / 2 - 64 / 2, 64, 64 )

			draw.SimpleText( strText, "catherine_normal25", w / 2, h / 2, Color( 50, 50, 50, 255 ), 1, 1 )
		end

	local ButtonPanel = vgui.Create( "DPanel", Window )
		ButtonPanel:SetTall( 30 )
		ButtonPanel:SetDrawBackground( false )
		
		
	local Okay = vgui.Create( "catherine.vgui.button", ButtonPanel )
	Okay:SetPos( 5, 5 )
	Okay:SetSize( 100, 25 )
	Okay:SetStr( strButtonText or "OK" )
	Okay:SetStrColor( Color( 50, 50, 50, 255 ) )
	Okay:SetGradientColor( Color( 50, 50, 50, 255 ) )
	Okay:SetStrFont( "catherine_normal20" )
	Okay.Click = function( )
		Window:Close( )
	end
		
	ButtonPanel:SetWide( Okay:GetWide( ) + 10 )

	Window:SetSize( ScrW( ), ScrH( ) * 0.15 )
	Window:Center( )

	ButtonPanel:CenterHorizontal( )
	ButtonPanel:AlignBottom( 8 )
	
	Window:MakePopup( )
	Window:DoModal( )
	
	return Window
end