--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

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
PLUGIN.name = "Good Text"
PLUGIN.author = "L7D"
PLUGIN.desc = "Write text to wall."
PLUGIN.textLists = PLUGIN.textLists or { }

catherine.util.Include( "sh_commands.lua" )
catherine.util.Include( "sv_plugin.lua" )
catherine.util.Include( "cl_plugin.lua" )