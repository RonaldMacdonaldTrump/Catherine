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

local PLUGIN = PLUGIN



local vars = {
	{
		id = "name",
		default = "Johnson"
	},
	{
		id = "desc",
		default = "No desc"
	},
	{
		id = "factions",
		default = { }
	},
	{
		id = "classes",
		default = { }
	},
	{
		id = "inv",
		default = { }
	},
	{
		id = "cash",
		default = 0
	},
	{
		id = "setting",
		default = { }
	},
	{
		id = "status",
		default = false
	},
	{
		id = "items",
		default = { }
	}
}

function PLUGIN:SaveVendors( )
	local data = { }
	
	for k, v in pairs( ents.FindByClass( "cat_vendor" ) ) do
		if ( !v.vendorData ) then print("No data") continue end
		data[ #data + 1 ] = {
			name = v.vendorData.name,
			desc = v.vendorData.desc,
			factionData = v.vendorData.factions,
			classData = v.vendorData.classes,
			inv = v.vendorData.inv,
			cash = v.vendorData.cash,
			setting = v.vendorData.setting,
			status = v.vendorData.status,
			items = v.vendorData.items,
			model = v:GetModel( ),
			pos = v:GetPos( ),
			ang = v:GetAngles( )
		}
	end
	
	catherine.data.Set( "vendors", data )
end

function PLUGIN:LoadVendors( )
	local data = catherine.data.Get( "vendors", { } )
	
	for k, v in pairs( data ) do
		local ent = ents.Create( "cat_vendor" )
		ent:SetPos( v.pos )
		ent:SetAngles( v.ang )
		ent:SetModel( v.model )
		ent:Spawn( )
		ent:Activate( )
		
		self:MakeVendor( ent, v )
	end
end

--[[
name = v.vendorData.name,
desc = v.vendorData.desc,
factionData = v.vendorData.factions,
classData = v.vendorData.classes,
inv = v.vendorData.inv,
cash = v.vendorData.cash,
setting = v.vendorData.setting,
--]]

function PLUGIN:MakeVendor( ent, data )
	if ( !IsValid( ent ) or !data ) then return end

	ent.vendorData = { }
	for k, v in pairs( vars ) do
		local val = data[ v.id ] and data[ v.id ] or v.default
		ent:SetNetVar( v.id, val )
		ent.vendorData[ v.id ] = val
	end
	
	ent.isVendor = true
end

--[[
CAT_VENDOR_ACTION_BUY = 1 // Buy from player
CAT_VENDOR_ACTION_SELL = 2 // Sell to player
CAT_VENDOR_ACTION_SETTING_CHANGE = 3 // Setting change
--]]

function PLUGIN:SetVendorData( ent, id, data, noSync )
	if ( !IsValid( ent ) or !id or !data ) then return end

	ent.vendorData[ id ] = data
	ent:SetNetVar( id, data )
	
	// self:GetVendorWorkingPlayers( ) 이거 안될거같은데;;
	if ( !noSync ) then
		//netstream.Start( self:GetVendorWorkingPlayers( ), "catherine.plugin.vendor.RefreshRequest" )
	end
end

function PLUGIN:GetVendorData( ent, id, default )
	if ( !IsValid( ent ) or !id ) then return default end
	if ( !table.HasValue( vars, id ) ) then print("Unknown id") return default end
	return ent.vendorData[ id ]
end

function PLUGIN:VendorWork( pl, ent, workID, data )
	if ( !IsValid( pl ) or !IsValid( ent ) or !workID or !data ) then return end
	if ( workID == CAT_VENDOR_ACTION_BUY ) then
		local uniqueID = data.uniqueID
		local itemTable = catherine.item.FindByID( uniqueID )
		local count = math.max( data.count or 1, 1 )
		
		if ( !itemTable ) then
			print("Item table error")
			return
		end
		
		if ( catherine.inventory.GetItemInt( pl, uniqueID ) < count ) then
			print("!?")
			return
		end
		
		local itemCost = itemTable.cost
		
		if ( data.count > 1 ) then
			itemCost = itemTable.cost * count
		end
		
		local playerCash, vendorCash, vendorInv = catherine.cash.Get( pl ), self:GetVendorData( ent, "cash", 0 ), table.Copy( self:GetVendorData( ent, "inv", { } ) )
		
		if ( vendorCash < itemCost ) then
			print("vendor no money!")
			return
		end

		if ( !vendorInv[ uniqueID ] ) then
			vendorInv[ uniqueID ] = {
				uniqueID = uniqueID,
				count = count
			}
		else
			vendorInv[ uniqueID ] = {
				uniqueID = uniqueID,
				count = vendorInv[ uniqueID ].count + count
			}
		end
		
		catherine.item.Take( pl, uniqueID, data.count )
		self:SetVendorData( ent, "inv", vendorInv )
		self:SetVendorData( ent, "cash", vendorCash - itemCost )
	elseif ( workID == CAT_VENDOR_ACTION_SELL ) then
		local uniqueID = data.uniqueID
		local itemTable = catherine.item.FindByID( uniqueID )
		local count = math.max( data.count or 1, 1 )
		
		if ( !itemTable ) then
			print("Item table error")
			return
		end
		
		if ( catherine.inventory.GetItemInt( pl, uniqueID ) < count ) then
			print("!?")
			return
		end
		
		local itemCost = itemTable.cost
		
		if ( data.count > 1 ) then
			itemCost = itemTable.cost * count
		end
		
		local playerCash, vendorCash, vendorInv = catherine.cash.Get( pl ), self:GetVendorData( ent, "cash", 0 ), table.Copy( self:GetVendorData( ent, "inv", { } ) )
		
		if ( playerCash < itemCost ) then
			print("player no money!")
			return
		end

		if ( !vendorInv[ uniqueID ] ) then
			print("Vendor no zago!")
			return
		end
		
		if ( vendorInv[ uniqueID ].count < count ) then
			print("Vendor no count!")
			count = vendorInv[ uniqueID ].count
		end
		
		vendorInv[ uniqueID ] = {
			uniqueID = uniqueID,
			count = vendorInv[ uniqueID ].count - count
		}
		
		if ( vendorInv[ uniqueID ].count <= 0 ) then
			vendorInv[ uniqueID ] = nil
		end
		
		catherine.item.Give( pl, uniqueID, data.count )
		catherine.cash.Take( pl, itemCost )
		self:SetVendorData( ent, "inv", vendorInv )
		self:SetVendorData( ent, "cash", vendorCash + itemCost )
	elseif ( workID == CAT_VENDOR_ACTION_SETTING_CHANGE ) then
	
	elseif ( workID == CAT_VENDOR_ACTION_ITEM_CHANGE ) then
		//PrintTable(data)
		local uniqueID = data.uniqueID
		local itemTable = catherine.item.FindByID( uniqueID )
		
		local stock = data.stock
		local cost = data.cost
		local type = data.type
		
		if ( !itemTable ) then
			print("Item table error")
			return
		end

		local vendorItem = table.Copy( self:GetVendorData( ent, "items", { } ) )
		
		vendorItem[ uniqueID ] = {
			uniqueID = uniqueID,
			stock = stock,
			cost = cost,
			type = type
		}
		
		PrintTable(vendorItem)
		
		self:SetVendorData( ent, "items", vendorItem )
	else
		// ;;
		print("?")
	end
end

function PLUGIN:CanUseVendor( pl, ent )
	if ( !IsValid( pl ) or !IsValid( ent ) or !ent.isVendor ) then return end
	
	if ( !ent.vendorData.status ) then
		//return false, "status"
	end
	
	local factionData = ent.vendorData.factions
	if ( #factionData != 0 and !table.HasValue( factionData, pl:Team( ) ) ) then
		return false, "faction"
	end
	
	local classData = ent.vendorData.classes
	if ( #classData != 0 and !table.HasValue( classData, pl:Class( ) ) ) then
		return false, "class"
	end

	return true
end

function PLUGIN:DataLoad( )
	self:LoadVendors( )
end

function PLUGIN:DataSave( )
	self:SaveVendors( )
end

netstream.Hook( "catherine.plugin.vendor.VendorWork", function( pl, data )
	PLUGIN:VendorWork( pl, data[ 1 ], data[ 2 ], data[ 3 ] )
end )