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

if ( CLIENT ) then return end

catherine.database.information = {
	db_module = "sqlite", --[[ Database module (mysqloo or sqlite) ]]--
	db_hostname = "127.0.0.1", --[[ Database hostname (127.0.0.1) ]]--
	db_account_id = "", --[[ Database account ID (root) ]]--
	db_account_password = "", --[[ Database account Password ]]--
	db_name = "", --[[ Database name ]]--
	db_port = 3306 --[[ Database port (3306) ]]--
}