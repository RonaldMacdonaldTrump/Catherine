
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
			draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 235 ) )
			
			draw.RoundedBox( 0, 0, 0, w, 1, Color( 255, 255, 255, 255 ) )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
			
			draw.SimpleText( strText, "catherine_normal25", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end

	local ButtonPanel = vgui.Create( "DPanel", Window )
		ButtonPanel:SetTall( 30 )
		ButtonPanel:SetDrawBackground( false )
		
		
	local Okay = vgui.Create( "catherine.vgui.button", ButtonPanel )
	Okay:SetPos( 5, 5 )
	Okay:SetSize( 50, 20 )
	Okay:SetStr( strButtonText or "OK" )
	Okay:SetFont( "catherine_normal15" )
	Okay:SetOutlineColor( Color( 255, 255, 255, 255 ) )
	Okay.Click = function( )
		Window:Close()
	end
		
	ButtonPanel:SetWide( Okay:GetWide() + 10 )

	Window:SetSize( ScrW( ), ScrH( ) * 0.2 )
	Window:Center()

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )
	
	Window:MakePopup()
	Window:DoModal()
	return Window

end