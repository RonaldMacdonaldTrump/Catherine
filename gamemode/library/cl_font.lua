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

catherine.font = catherine.font or { lists = { } }

function catherine.font.Register( uniqueID, font, size, weight, fontTable )
	fontTable = fontTable or { }
	
	table.Merge( fontTable, {
		uniqueID = uniqueID,
		font = font,
		size = size,
		weight = weight
	} )
	
	catherine.font.lists[ uniqueID ] = fontTable
	surface.CreateFont( uniqueID, fontTable )
end

function catherine.font.GetAll( )
	return catherine.font.lists
end

function catherine.font.GetByID( uniqueID )
	return catherine.font.lists[ uniqueID ]
end

local font = catherine.configs.Font
catherine.font.Register( "catherine_menuTitle", font, 20, 1000 )
catherine.font.Register( "catherine_button20", font, 20, 1000 )
catherine.font.Register( "catherine_normal15", font, 15, 1000 )
catherine.font.Register( "catherine_normal17", font, 17, 1000 )
catherine.font.Register( "catherine_normal20", font, 20, 1000 )
catherine.font.Register( "catherine_normal25", font, 25, 1000 )
catherine.font.Register( "catherine_normal30", font, 30, 1000 )
catherine.font.Register( "catherine_normal35", font, 35, 1000 )
catherine.font.Register( "catherine_normal40", font, 40, 1000 )
catherine.font.Register( "catherine_normal50", font, 50, 1000 )
catherine.font.Register( "catherine_schema_title", font, 50, 1000 )
catherine.font.Register( "catherine_good15", font, 15, 1000 )
catherine.font.Register( "catherine_hostname", font, 25, 1000 )
catherine.font.Register( "catherine_outline30", font, 30, 1000, { outline = true } )
catherine.font.Register( "catherine_outline25", font, 25, 1000, { outline = true } )
catherine.font.Register( "catherine_outline20", font, 20, 1000, { outline = true } )
catherine.font.Register( "catherine_outline15", font, 15, 1000, { outline = true } )
catherine.font.Register( "catherine_introTitle", "Garamond", ScreenScale( 50 ), 1000 )
catherine.font.Register( "catherine_introSchema", "Garamond", 30, 1000 )