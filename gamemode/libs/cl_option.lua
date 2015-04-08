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

catherine.option = catherine.option or { }
catherine.option.Lists = { }
CAT_OPTION_SWITCH = 0
CAT_OPTION_LIST = 1

function catherine.option.Register( uniqueID, conVar, name, desc, category, typ, data )
	local optionTable = { }
	table.Merge( optionTable, { uniqueID = uniqueID, name = name, desc = desc, conVar = conVar, typ = typ, category = category, data = data } )
	catherine.option.Lists[ uniqueID ] = optionTable
end

function catherine.option.Remove( uniqueID )
	if ( !catherine.option.FindByID( uniqueID ) ) then return end
	catherine.option.Lists[ uniqueID ] = nil
end

function catherine.option.Set( uniqueID, val )
	local optionTable = catherine.option.FindByID( uniqueID )
	if ( !optionTable or !optionTable.onSet ) then return end
	optionTable.onSet( optionTable.conVar, val )
end

function catherine.option.Toggle( uniqueID )
	local optionTable = catherine.option.FindByID( uniqueID )
	if ( !optionTable or optionTable.typ != CAT_OPTION_SWITCH or !optionTable.conVar ) then return end
	RunConsoleCommand( optionTable.conVar, tostring( tobool( GetConVarString( optionTable.conVar ) ) == true and 0 or 1 ) )
end

function catherine.option.Get( uniqueID )
	local optionTable = catherine.option.FindByID( uniqueID )
	if ( !optionTable ) then return nil end
	if ( optionTable.onGet ) then
		return optionTable.onGet( optionTable )
	else
		return GetConVarString( optionTable.conVar )
	end
end

function catherine.option.FindByID( uniqueID )
	if ( !uniqueID ) then return nil end
	return catherine.option.Lists[ uniqueID ]
end

function catherine.option.GetAll( )
	return catherine.option.Lists
end

local lang = { data = { }, curVal = catherine.language.FindByID( GetConVarString( "cat_convar_language" ) ).name }
for k, v in pairs( catherine.language.GetAll( ) ) do
	lang.data[ #lang.data + 1 ] = {
		func = function( )
			RunConsoleCommand( "cat_convar_language", k )
		end,
		name = v.name
	}
end

catherine.option.Register( "CONVAR_BAR", "cat_convar_bar", "Bar", "Displays the Bar.", "Framework Settings", CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_MAINHUD", "cat_convar_hud", "Main HUD", "Displays the main HUD.", "Framework Settings", CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_LANGUAGE", "cat_convar_language", "Language", "Language.", "Framework Settings", CAT_OPTION_LIST, lang )