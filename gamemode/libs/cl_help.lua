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

catherine.help = catherine.help or { Lists = { } }
CAT_HELP_HTML = 1
CAT_HELP_WEBPAGE = 2

function catherine.help.Register( types, category, codes )
	catherine.help.Lists[ category ] = {
		types = types,
		category = category,
		codes = codes
	}
end

function catherine.help.GetAll( )
	return catherine.help.Lists
end

catherine.help.Register( CAT_HELP_HTML, "Credit", [[
	<b>Credit</b><br><br>
	<b>L7D</b><br>Development and Design.<br><br>
	<b>Chessnut</b><br>Good helper.<br><br>
	<b>Kyle Smith</b><br>UTF-8 module.<br><br>
	<b>thelastpenguin™</b><br>pON module.<br><br>
	<b>Alexander Grist-Hucker</b><br>netstream 2 module.<br><br><br>
]] )
catherine.help.Register( CAT_HELP_WEBPAGE, "Changelog", "http://github.com/L7D/Catherine/commits/master" )