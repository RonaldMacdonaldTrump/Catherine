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

DeriveGamemode( "sandbox" )

GM.Name = "Catherine"
GM.Desc = "A free role-playing framework for Garry's Mod."
GM.Author = "L7D"

AddCSLuaFile( "sh_util.lua" )
include( "sh_util.lua" )
catherine.util.Include( "config/sh_config.lua" )
catherine.util.Include( "sv_data.lua" )
catherine.util.IncludeInDir( "gamemode/library", true )
catherine.util.IncludeInDir( "gamemode/core", true )
catherine.util.IncludeInDir( "gamemode/derma", true )
catherine.util.Include( "command/sh_commands.lua" )