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

local PLUGIN = PLUGIN

netstream.Hook( "catherine.plugin.bugreport.SendResult", function( data )
	if ( type( data ) == "boolean" ) then
		if ( IsValid( catherine.vgui.bugreport ) ) then
			catherine.vgui.bugreport:SetNotify( true, "Your report has been sent, thank you! :)" )
		end
	else
		if ( IsValid( catherine.vgui.bugreport ) ) then
			catherine.vgui.bugreport:SetNotify( false, data, false, true )
		end
	end
end )