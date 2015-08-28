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

end

vgui.Register( "catherine.vgui.system", PANEL, "DFrame" )

catherine.menu.Register( function( )
	return "System"
end, function( menuPnl, itemPnl )
	vgui.Create( "catherine.vgui.system" )
	menuPnl:Close( )
end, function( pl )
	return pl:IsSuperAdmin( )
end )