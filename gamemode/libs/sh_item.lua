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

catherine.item = catherine.item or { bases = { }, items = { } }

function catherine.item.Register( itemTable )
	if ( !itemTable ) then
		catherine.util.ErrorPrint( "Item register error, can't found item table!" )
		return
	end
	
	if ( itemTable.isBase ) then
		catherine.item.bases[ itemTable.uniqueID ] = itemTable
		return
	end
	
	if ( itemTable.base ) then
		local base = catherine.item.bases[ itemTable.base ]
		if ( !base ) then return end
		itemTable = table.Inherit( itemTable, base )
	end
	
	itemTable.name = itemTable.name or "A Name"
	itemTable.desc = itemTable.desc or "A Desc"
	itemTable.weight = itemTable.weight or 0
	itemTable.useDynamicItemData = itemTable.useDynamicItemData or true
	itemTable.itemData = itemTable.itemData or { }
	itemTable.cost = itemTable.cost or 0
	itemTable.category = itemTable.category or "Other"
	local funcBuffer = {
		take = {
			text = "Take",
			icon = "icon16/basket_put.png",
			canShowIsWorld = true,
			func = function( pl, itemTable, ent )
				if ( !IsValid( ent ) ) then
					catherine.util.NotifyLang( pl, "Entity_Notify_NotValid" )
					return
				end
				
				if ( !catherine.inventory.HasSpace( pl, itemTable.weight ) ) then
					catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
					return
				end
				
				catherine.inventory.Work( pl, CAT_INV_ACTION_ADD, {
					uniqueID = itemTable.uniqueID,
					itemData = ( itemTable.useDynamicItemData and ent:GetItemData( ) ) or itemTable.itemData
				} )
				ent:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav", 70 )
				ent:Remove( )
				
				hook.Run( "ItemTaked", pl, itemTable )
			end
		},
		drop = {
			text = "Drop",
			icon = "icon16/basket_remove.png",
			canShowIsMenu = true,
			func = function( pl, itemTable )
				local uniqueID = itemTable.uniqueID

				local ent = catherine.item.Spawn( uniqueID, catherine.util.GetItemDropPos( pl ), nil, itemTable.useDynamicItemData and catherine.inventory.GetItemDatas( pl, itemTable.uniqueID ) or { } )
				catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, {
					uniqueID = uniqueID
				} )
				ent:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav", 70 )
				
				hook.Run( "ItemDroped", pl, itemTable )
			end,
			canLook = function( pl, itemTable )
				return catherine.inventory.HasItem( itemTable.uniqueID )
			end
		}
	}
	itemTable.func = table.Merge( funcBuffer, itemTable.func or { } )
	
	catherine.item.items[ itemTable.uniqueID ] = itemTable
	
	if ( itemTable.OnRegistered ) then
		itemTable:OnRegistered( )
	end
end

function catherine.item.New( uniqueID, base_uniqueID, isBase )
	return { uniqueID = uniqueID, base = base_uniqueID, isBase = isBase }
end

function catherine.item.GetAll( )
	return catherine.item.items
end

function catherine.item.FindByID( id )
	return catherine.item.items[ id ]
end

function catherine.item.FindBaseByID( id )
	return catherine.item.bases[ id ]
end

function catherine.item.Include( dir )
	for k, v in pairs( file.Find( dir .. "/items/base/*", "LUA" ) ) do
		catherine.util.Include( dir .. "/items/base/" .. v, "SHARED" )
	end
	
	local itemFiles, itemFolders = file.Find( dir .. "/items/*", "LUA" )
	
	for k, v in pairs( itemFolders ) do
		if ( v == "base" ) then continue end
		
		for k1, v1 in pairs( file.Find( dir .. "/items/" .. v .. "/*.lua", "LUA" ) ) do
			catherine.util.Include( dir .. "/items/" .. v .. "/" .. v1, "SHARED" )
		end
	end
	
	for k, v in pairs( itemFiles ) do
		catherine.util.Include( dir .. "/items/" .. v, "SHARED" )
	end
end

catherine.item.Include( catherine.FolderName .. "/gamemode" )

if ( SERVER ) then
	function catherine.item.Work( pl, uniqueID, funcID, ent_isMenu )
		if ( !IsValid( pl ) or !pl:IsCharacterLoaded( ) or !uniqueID or !funcID ) then return end
		local itemTable = catherine.item.FindByID( uniqueID )
		if ( !itemTable or !itemTable.func or !itemTable.func[ funcID ] ) then return end
		
		itemTable.func[ funcID ].func( pl, itemTable, ent_isMenu )
	end
	
	function catherine.item.Give( pl, uniqueID, itemCount, force )
		if ( !force ) then
			local itemTable = catherine.item.FindByID( uniqueID )
			
			if ( !catherine.inventory.HasSpace( pl, itemTable.weight ) ) then
				catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
				return false
			end
		end
		
		catherine.inventory.Work( pl, CAT_INV_ACTION_ADD, {
			uniqueID = uniqueID,
			itemCount = itemCount
		} )
		
		return true
	end
	
	function catherine.item.Take( pl, uniqueID, itemCount )
		catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, {
			uniqueID = uniqueID,
			itemCount = itemCount
		} )
		
		return true
	end

	function catherine.item.Spawn( uniqueID, pos, ang, itemData )
		if ( !uniqueID or !pos ) then return end
		local itemTable = catherine.item.FindByID( uniqueID )
		if ( !itemTable ) then return end
		
		local ent = ents.Create( "cat_item" )
		ent:SetPos( Vector( pos.x, pos.y, pos.z + 10 ) )
		ent:SetAngles( ang or Angle( ) )
		ent:Spawn( )
		ent:SetModel( itemTable.model or "models/props_junk/watermelon01.mdl" )
		ent:PhysicsInit( SOLID_VPHYSICS )
		ent:InitializeItem( uniqueID, itemData or { } )
		
		local physObject = ent:GetPhysicsObject( )
		if ( IsValid( physObject ) ) then
			physObject:EnableMotion( true )
			physObject:Wake( )
		end
		
		return ent
	end

	netstream.Hook( "catherine.item.Work", function( pl, data )
		catherine.item.Work( pl, data[ 1 ], data[ 2 ], data[ 3 ], data[ 4 ] )
	end )
	
	netstream.Hook( "catherine.item.Give", function( pl, data )
		catherine.item.Give( pl, data )
	end )
else
	function catherine.item.OpenMenuUse( uniqueID )
		local itemTable = catherine.item.FindByID( uniqueID )
		local menu = DermaMenu( )
		
		for k, v in pairs( itemTable and itemTable.func or { } ) do
			if ( !v.canShowIsMenu or ( v.canLook and v.canLook( LocalPlayer( ), itemTable ) == false ) ) then continue end
			
			menu:AddOption( v.text or "ERROR", function( )
				netstream.Start( "catherine.item.Work", { uniqueID, k, true } )
			end ):SetImage( v.icon or "icon16/information.png" )
		end
		
		menu:Open( )
	end
	
	function catherine.item.OpenEntityUseMenu( data )
		local ent = data[ 1 ]
		local uniqueID = data[ 2 ]
		if ( !IsValid( ent ) or !IsValid( LocalPlayer( ):GetEyeTrace( ).Entity ) ) then return end
		local itemTable = catherine.item.FindByID( uniqueID )
		local menu = DermaMenu( )
		
		for k, v in pairs( itemTable and itemTable.func or { } ) do
			if ( !v.canShowIsWorld or ( v.canLook and v.canLook( LocalPlayer( ), itemTable ) == false ) ) then continue end

			menu:AddOption( v.text or "ERROR", function( )
				netstream.Start( "catherine.item.Work", { uniqueID, k, ent } )
			end ):SetImage( v.icon or "icon16/information.png" )
		end
		
		menu:Open( )
		menu:Center( )
	end
	
	netstream.Hook( "catherine.item.EntityUseMenu", function( data )
		catherine.item.OpenEntityUseMenu( data )
	end )
end

catherine.command.Register( {
	command = "itemspawn",
	syntax = "[Item ID]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local success = catherine.item.Spawn( args[ 1 ], catherine.util.GetItemDropPos( pl ) )
			
			if ( !success ) then
				catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )