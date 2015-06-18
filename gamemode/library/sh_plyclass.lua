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

local PLY = { }
PLY.DisplayName = "Catherine Player"

local modelList = { }

for k, v in pairs( player_manager.AllValidModels( ) ) do
	modelList[ v:lower( ) ] = k
end

function PLY:Loadout( )
    self.Player:SetupHands( )

    return
end

function PLY:GetHandsModel( )
	local model = self.Player:GetModel( ):lower( )

	if ( model:find( "police" ) ) then
		model = "combine"
	else
		local modelConvert = model:gsub( "_", "" )

		for k, v in pairs( modelList ) do
			if ( catherine.util.CheckStringMatch( modelConvert, v ) ) then
				model = v

				break
			end
		end
	end

	return player_manager.TranslatePlayerHands( model )
end

player_manager.RegisterClass( "cat_player", PLY, "player_default" )