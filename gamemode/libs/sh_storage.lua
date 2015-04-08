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

catherine.storage = catherine.storage or { }
CAT_STORAGE_ACTION_ADD = 1
CAT_STORAGE_ACTION_REMOVE = 2

if ( SERVER ) then
	catherine.storage.Lists = { }
	
	function catherine.storage.Register( name, desc, model, maxWeight )
		catherine.storage.Lists[ #catherine.storage.Lists + 1 ] = {
			name = name,
			desc = desc,
			model = model,
			maxWeight = maxWeight
		}
	end

	catherine.storage.Register( "Wardrobe", "The Wardrobe to put clothes.", "models/props_c17/FurnitureDresser001a.mdl", 8 )
	catherine.storage.Register( "Desk", "A Desk.", "models/props_interiors/Furniture_Desk01a.mdl", 12 )
	
	function catherine.storage.GetAll( )
		return catherine.storage.Lists
	end
	
	function catherine.storage.FindByModel( model )
		if ( !model ) then return end
		for k, v in pairs( catherine.storage.GetAll( ) ) do
			if ( v.model:lower( ) == model:lower( ) ) then
				return v
			end
		end
	end
	
	function catherine.storage.Make( ent, data )
		if ( !IsValid( ent ) ) then return end
		local originalData = catherine.storage.FindByModel( ent:GetModel( ) )
		if ( !data ) then
			data = catherine.storage.FindByModel( ent:GetModel( ) )
			if ( !data ) then return end
		end

		ent.name = data.name or originalData.name
		ent.desc = data.desc or originalData.desc
		ent.inv = data.inv or { }
		ent.isStorage = true
		ent.maxWeight = data.maxWeight or originalData.maxWeight

		ent:SetNetVar( "name", ent.name )
		ent:SetNetVar( "desc", ent.desc )
		ent:SetNetVar( "inv", ent.inv )
		ent:SetNetVar( "maxWeight", ent.maxWeight )
		ent:SetNetVar( "isStorage", true )
		
		ent.isCustomUse = true
		ent.customUseFunction = function( pl )
			netstream.Start( pl, "catherine.storage.Use", ent:EntIndex( ) )
		end
	end
	
	function catherine.storage.SetInv( ent, data )
		if ( !IsValid( ent ) or !data ) then return end
		ent.inv = data
		ent:SetNetVar( "inv", ent.inv )
	end
	
	function catherine.storage.GetInv( ent )
		if ( !IsValid( ent ) or !ent.isStorage ) then return { } end
		return ent.inv or { }
	end
	
	function catherine.storage.GetWeights( ent, customAdd )
		local inventory = catherine.storage.GetInv( ent )
		local weight, maxWeight = 0, ( ent.maxWeight or 0 )
		
		for k, v in pairs( inventory ) do
			local itemTable = catherine.item.FindByID( k )
			if ( !itemTable ) then continue end
			weight = weight + ( itemTable.weight * v.itemCount )
		end
		
		return weight + ( customAdd or 0 ), maxWeight
	end
	
	function catherine.storage.GetItemInt( ent, uniqueID )
		if ( !IsValid( ent ) or !uniqueID ) then return 0 end
		local inventory = catherine.storage.GetInv( ent )
		if ( !inventory[ uniqueID ] ) then return 0 end
		return inventory[ uniqueID ].itemCount or 0
	end
	
	function catherine.storage.Work( pl, ent, workID, data )
		ent = Entity( ent )
		if ( !IsValid( pl ) or !IsValid( ent ) or !workID or !data ) then return end
		
		if ( workID == CAT_STORAGE_ACTION_ADD ) then
			local itemTable = catherine.item.FindByID( data )
			if ( !itemTable ) then
				catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
				return
			end
			
			if ( !catherine.inventory.HasItem( pl, data ) ) then
				catherine.util.NotifyLang( pl, "Inventory_Notify_DontHave" )
				return
			end
			
			local weight, maxWeight = catherine.storage.GetWeights( ent, itemTable.weight )
			if ( weight >= maxWeight ) then
				catherine.util.NotifyLang( pl, "Storage_Notify_HasNotSpace" )
				return
			end
			
			local inventory = catherine.storage.GetInv( ent )
			local invData = inventory[ data ]

			if ( invData ) then
				inventory[ data ] = {
					uniqueID = invData.uniqueID,
					itemCount = invData.itemCount + 1,
					itemData = invData.itemData
				}
			else
				inventory[ data ] = {
					uniqueID = itemTable.uniqueID,
					itemCount = 1,
					itemData = itemTable.itemData or { }
				}
			end
			
			catherine.item.Take( pl, data )
			hook.Run( "ItemStorageMoved", pl, itemTable )
			catherine.storage.SetInv( ent, inventory )
		elseif ( workID == CAT_STORAGE_ACTION_REMOVE ) then
			local itemTable = catherine.item.FindByID( data )
			if ( !itemTable ) then
				catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
				return
			end
			
			local inventory = catherine.storage.GetInv( ent )
			if ( !inventory[ data ] ) then
				catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
				return
			end

			if ( !catherine.inventory.HasSpace( pl, itemTable.weight ) ) then
				catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
				return
			end
			
			local invData = inventory[ data ]

			inventory[ data ] = {
				uniqueID = invData.uniqueID,
				itemCount = math.max( invData.itemCount - 1, 0 ),
				itemData = invData.itemData
			}
			
			if ( inventory[ data ].itemCount == 0 ) then
				inventory[ data ] = nil
			end
			
			catherine.item.Give( pl, data )
			hook.Run( "ItemStorageTaked", pl, itemTable )
			catherine.storage.SetInv( ent, inventory )
		end
		
		netstream.Start( pl, "catherine.storage.ChangeResult", ent:EntIndex( ) )
	end
	
	function catherine.storage.GetDataByIndex( index, data )
		if ( !index or !data ) then return nil end
		for k, v in pairs( data ) do
			if ( v.index == index ) then
				return v
			end
		end
	end
	
	function catherine.storage.DataSave( )
		local data = { }
		
		for k, v in pairs( ents.FindByClass( "prop_physics" ) ) do
			if ( !v.isStorage ) then continue end
			data[ #data + 1 ] = {
				index = v:EntIndex( ),
				inv = v.inv
			}
		end
		
		catherine.data.Set( "storage", data )
	end
	
	function catherine.storage.DataLoad( )
		local data = catherine.data.Get( "storage", { } )

		for k, v in pairs( ents.FindByClass( "prop_physics" ) ) do
			local storage = catherine.storage.GetDataByIndex( v:EntIndex( ), data )
			catherine.storage.Make( v, storage )
		end
	end

	function catherine.storage.PlayerSpawnedProp( pl, _, ent )
		timer.Simple( 1, function( )
			catherine.storage.Make( ent )
		end )
	end

	hook.Add( "DataSave", "catherine.storage.DataSave", catherine.storage.DataSave )
	hook.Add( "DataLoad", "catherine.storage.DataLoad", catherine.storage.DataLoad )
	hook.Add( "PlayerSpawnedProp", "catherine.storage.PlayerSpawnedProp", catherine.storage.PlayerSpawnedProp )
	
	netstream.Hook( "catherine.storage.Work", function( pl, data )
		catherine.storage.Work( pl, data[ 1 ], data[ 2 ], data[ 3 ] )
	end )
else
	netstream.Hook( "catherine.storage.Use", function( data )
		if ( IsValid( catherine.vgui.storage ) ) then
			catherine.vgui.storage:Remove( )
			catherine.vgui.storage = nil
		end
		
		catherine.vgui.storage = vgui.Create( "catherine.vgui.storage" )
		catherine.vgui.storage:InitializeStorage( Entity( data ) )
	end )
	
	netstream.Hook( "catherine.storage.ChangeResult", function( data )
		if ( !IsValid( catherine.vgui.storage ) ) then return end
		catherine.vgui.storage:InitializeStorage( Entity( data ) )
	end )
	
	function catherine.storage.GetInv( ent )
		if ( !IsValid( ent ) or !ent:GetNetVar( "isStorage" ) ) then return { } end
		return ent:GetNetVar( "inv", { } )
	end
	
	function catherine.storage.GetWeights( ent, customAdd )
		local inventory = catherine.storage.GetInv( ent )
		local weight, maxWeight = 0, ( ent:GetNetVar( "maxWeight" ) or 0 )
		for k, v in pairs( inventory ) do
			local itemTable = catherine.item.FindByID( k )
			if ( !itemTable ) then continue end
			weight = weight + ( itemTable.weight * v.itemCount )
		end
		
		return weight + ( customAdd or 0 ), maxWeight
	end
	
	function catherine.storage.GetItemInt( ent, uniqueID )
		if ( !IsValid( ent ) or !uniqueID ) then return 0 end
		local inventory = catherine.storage.GetInv( ent )
		if ( !inventory[ uniqueID ] ) then return 0 end
		return inventory[ uniqueID ].itemCount or 0
	end

	local toscreen = FindMetaTable("Vector").ToScreen

	function catherine.storage.DrawEntityTargetID( pl, ent, a )
		if ( !ent:GetNetVar( "isStorage", false ) ) then return end
		local pos = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		local x, y = pos.x, pos.y
		
		draw.SimpleText( ent:GetNetVar( "name", "" ), "catherine_outline25", x, y, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( ent:GetNetVar( "desc", "" ), "catherine_outline20", x, y + 30, Color( 255, 255, 255, a ), 1, 1 )
	end
	
	hook.Add( "DrawEntityTargetID", "catherine.storage.DrawEntityTargetID", catherine.storage.DrawEntityTargetID )
end