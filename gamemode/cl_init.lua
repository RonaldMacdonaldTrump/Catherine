catherine = catherine or GM
catherine.vgui = catherine.vgui or { }

include( "shared.lua" )

timer.Remove( "HintSystem_Annoy1" )
timer.Remove( "HintSystem_Annoy2" )
timer.Remove( "HintSystem_OpeningMenu" )

hook.Add( "AddHelpItem", "catherine.AddHelpItem.01", function( data )
	data:AddItem( "Credit", [[
		<b>L7D</b><br><i>Develop and Design.</i><br><br>
		<b>Chessnut</b><br><i>Good helper.</i><br><br>
		<b>Kyle Smith</b><br><i>UTF-8 module.</i><br><br>
		<b>thelastpenguin™</b><br><i>pON module.</i><br><br>
		<b>Alexander Grist-Hucker</b><br><i>netstream 2 module.</i><br><br><br>
		
		<b>Thanks for using Catherine!</b>
	]] )
	data:AddItem( "Catherine update log", "http://github.com/L7D/Catherine/commits/master" )
end )