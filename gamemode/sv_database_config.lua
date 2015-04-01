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

if ( CLIENT ) then return end // for security ^ㅡ^;

catherine.database.information = {
	db_module = "sqlite", -- Set 'Module' for connect to Database ( sqlite or mysqloo )
	db_hostname = "127.0.0.1", -- Set 'Hostname' for connect to Database ( 127.0.0.1 )
	db_account_id = "", -- Set 'Account ID' for connect to Database ( root )
	db_account_password = "", -- Set 'Account Password' for connect to Database ( 12345 )
	db_name = "", -- Set 'Database Name' for connect to Database ( catherine )
	db_port = 3306 -- Set 'Port' for connect to Database ( 3306 )
}