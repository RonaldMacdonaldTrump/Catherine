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

catherine.accessory = catherine.accessory or { }
CAT_ACCESSORY_ACTION_WEAR = 1
CAT_ACCESSORY_ACTION_TAKEOFF = 2

if ( SERVER ) then
	function catherine.accessory.Work( pl, workID, data )
		if ( workID == CAT_ACCESSORY_ACTION_WEAR ) then
			local itemTable = data.itemTable
			local bone = itemTable.bone
			
			if ( !itemTable.model ) then
				return false, "MODEL ERROR"
			end
			
			local accessoryDatas = catherine.character.GetCharVar( pl, "accessory", { } )
			
			if ( accessoryDatas[ bone ] ) then
				return false, "BONE ALREADY EXISTS"
			end
			
			local accessoryEnt = ents.Create( "cat_accessory_base" )
			accessoryEnt:DrawShadow( false )
			accessoryEnt:SetNotSolid( true )
			accessoryEnt:SetParent( pl )
			accessoryEnt:SetModel( itemTable.model )
			
			accessoryDatas[ bone ] = accessoryEnt
			
			catherine.character.SetCharVar( pl, "accessory", accessoryDatas )
			
			return true
		elseif ( workID == CAT_ACCESSORY_ACTION_TAKEOFF ) then
			local itemTable = data.itemTable
			local bone = itemTable.bone
			
			if ( !itemTable.model ) then
				return false, "MODEL ERROR"
			end
			
			local accessoryDatas = catherine.character.GetCharVar( pl, "accessory", { } )
			local accessoryData = accessoryDatas[ bone ]
			
			if ( !accessoryData ) then
				return false, "BONE NOT EXISTS"
			end
			
			if ( IsValid( accessoryData ) ) then
				accessoryData:Remove( )
			end
			
			accessoryDatas[ bone ] = nil
			
			catherine.character.SetCharVar( pl, "accessory", accessoryDatas )
			
			return true
		end
	end
else

end

function catherine.accessory.CanWork( pl, workID, data )
	if ( workID == CAT_ACCESSORY_ACTION_WEAR ) then
		local itemTable = data.itemTable
		
		if ( !itemTable.model ) then
			return false, "MODEL ERROR"
		end

		if ( catherine.character.GetCharVar( pl, "accessory", { } )[ itemTable.bone ] ) then
			return false, "BONE ALREADY EXISTS"
		end
		
		return true
	elseif ( workID == CAT_ACCESSORY_ACTION_TAKEOFF ) then
		local itemTable = data.itemTable
		
		if ( !itemTable.model ) then
			return false, "MODEL ERROR"
		end

		if ( !catherine.character.GetCharVar( pl, "accessory", { } )[ itemTable.bone ] ) then
			return false, "BONE NOT EXISTS"
		end
		
		return true
	end
end