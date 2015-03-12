catherine = catherine or GM
catherine.vgui = catherine.vgui or { }

include( "shared.lua" )

function Derma_Message( strText, strTitle, strButtonText )

	local Window = vgui.Create( "DFrame" )
		Window:SetTitle( "" )
		Window:SetDraggable( false )
		Window:ShowCloseButton( false )
		Window:SetBackgroundBlur( true )
		Window:SetDrawOnTop( true )
		Window.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 200 ) )

			draw.SimpleText( strTitle or "", "catherine_normal20", 30, 25, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, 1 )
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
		Window:Close()
	end
		
	ButtonPanel:SetWide( Okay:GetWide() + 10 )

	Window:SetSize( ScrW( ), ScrH( ) * 0.15 )
	Window:Center()

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )
	
	Window:MakePopup()
	Window:DoModal()
	return Window
end