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

--[[ -- Deleted ^-^;
catherine.meta = catherine.meta or { }
catherine.meta.objects = { } 

function catherine.meta.New( class, data )
	local self = setmetatable( data, catherine.meta.objects[ class ] )
	catherine.meta.objects[ #catherine.meta.objects + 1 ] = self
	return self
end

function catherine.meta.Register( class, data )
	data.__index = data
	catherine.meta.objects[ class ] = data
end
--]]