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

catherine.menu = catherine.menu or {
	activeButtonData = { },
	activePanel = nil,
	activePanelName = nil
}
catherine.menu.lists = { }
CAT_MENU_STATUS_SAMEMENU = 1
CAT_MENU_STATUS_SAMEMENU_NO = 2
CAT_MENU_STATUS_NOTSAMEMENU = 3
CAT_MENU_STATUS_NOTSAMEMENU_NO = 4

function catherine.menu.Register( name, func, canLook )
	catherine.menu.lists[ #catherine.menu.lists + 1 ] = {
		name = name,
		func = func,
		canLook = canLook
	}
end

function catherine.menu.GetAll( )
	return catherine.menu.lists
end

function catherine.menu.GetPanel( )
	return catherine.vgui.menu
end

function catherine.menu.GetActivePanel( )
	return catherine.menu.activePanel
end

function catherine.menu.GetActiveButtonData( )
	return catherine.menu.activeButtonData.w, catherine.menu.activeButtonData.x
end

function catherine.menu.GetActivePanelName( )
	return catherine.menu.activePanelName
end

function catherine.menu.SetActivePanel( pnl )
	catherine.menu.activePanel = pnl
end

function catherine.menu.SetActiveButton( pnl )
	catherine.menu.activeButton = pnl
end

function catherine.menu.SetActivePanelName( name )
	catherine.menu.activePanelName = name
end

function catherine.menu.SetActivePanelData( w, x )
	catherine.menu.activeButtonData = {
		w = w,
		x = x
	}
end

function catherine.menu.RecoverLastActivePanel( menuPanel )
	local activePanel = catherine.menu.GetActivePanel( )

	if ( IsValid( activePanel ) and type( activePanel ) == "Panel" and activePanel:IsHiding( ) ) then
		local w, x = catherine.menu.GetActiveButtonData( )
		
		activePanel:Show( )
		activePanel:OnMenuRecovered( )
		
		menuPanel.activePanelShowTargetX = x
		menuPanel.activePanelShowTargetW = w
	end
end

function catherine.menu.Rebuild( )
	if ( IsValid( catherine.vgui.menu ) ) then
		catherine.vgui.menu:Remove( )
	end
end

function catherine.menu.VGUIMousePressed( pnl, code )
	local menuPanel = catherine.menu.GetPanel( )
	local activePanel = catherine.menu.GetActivePanel( )
	
	if ( IsValid( menuPanel ) and IsValid( activePanel ) and menuPanel == pnl ) then
		activePanel:Close( )
		catherine.menu.SetActivePanel( nil )
		catherine.menu.SetActivePanelName( nil )
		catherine.menu.SetActivePanelData( 0, 0 )
		
		menuPanel.activePanelShowTargetX = 0
		menuPanel.activePanelShowTargetW = 0
	end
end

hook.Add( "VGUIMousePressed", "catherine.menu.VGUIMousePressed", catherine.menu.VGUIMousePressed )

concommand.Add( "cat_menu_rebuild", function( )
	catherine.menu.Rebuild( )
end )