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
					catherine.util.Notify( pl, "This isn't a valid entity!" )
					return
				end
				if ( !catherine.inventory.HasSpace( pl, itemTable.weight ) ) then
					catherine.util.Notify( pl, "You don't have inventory space!" )
					return
				end
				catherine.inventory.Work( pl, CAT_INV_ACTION_ADD, {
					uniqueID = itemTable.uniqueID,
					itemData = ( itemTable.useDynamicItemData and ent:GetItemData( ) ) or itemTable.itemData
				} )
				ent:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav", 40 )
				ent:Remove( )
				hook.Run( "ItemTaked", pl, itemTable )
			end,
			canLook = function( pl, itemTable )
				return true
			end
		},
		drop = {
			text = "Drop",
			icon = "icon16/basket_remove.png",
			canShowIsMenu = true,
			func = function( pl, itemTable )
				local eyeTr = pl:GetEyeTrace( )
				if ( pl:GetPos( ):Distance( eyeTr.HitPos ) > 100 ) then
					catherine.util.Notify( pl, "Can't drop far away!" )
					return
				end
				pl:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav", 40 )
				catherine.item.Spawn( itemTable.uniqueID, eyeTr.HitPos, nil, itemTable.useDynamicItemData and catherine.inventory.GetItemDatas( pl, itemTable.uniqueID ) or { } )
				catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, itemTable.uniqueID )
				hook.Run( "ItemDroped", pl, itemTable )
			end,
			canLook = function( pl, itemTable )
				return catherine.inventory.HasItem( itemTable.uniqueID )
			end
		}
	}
	itemTable.func = table.Merge( funcBuffer, itemTable.func or { } )

	catherine.item.items[ itemTable.uniqueID ] = itemTable
end

function catherine.item.New( uniqueID, base_uniqueID, isBase )
	return { uniqueID = uniqueID, base = base_uniqueID, isBase = isBase }
end

function catherine.item.FindByID( id )
	return catherine.item.items[ id ]
end

function catherine.item.GetAll( )
	return catherine.item.items
end

function catherine.item.FindBaseByID( id )
	return catherine.item.bases[ id ]
end

function catherine.item.Include( dir )
	if ( !dir ) then return end

	for k, v in pairs( file.Find( dir .. "/items/base/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/items/base/" .. v, "SHARED" )
	end
	
	local itemFiles, itemFolders = file.Find( dir .. "/items/*", "LUA" )
	for k, v in pairs( itemFolders ) do
		if ( v == "base" ) then continue end
		local itemFiles2 = file.Find( dir .. "/items/" .. v .. "/*.lua", "LUA" )
		for k1, v1 in pairs( itemFiles2 ) do
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
		if ( !itemTable ) then return end
		if ( !itemTable.func or !itemTable.func[ funcID ] ) then return end
		itemTable.func[ funcID ].func( pl, itemTable, ent_isMenu )
	end
	
	function catherine.item.Give( pl, uniqueID, itemCount, force )
		if ( !IsValid( pl ) or !uniqueID ) then return end
		if ( !force ) then
			local itemTable = catherine.item.FindByID( uniqueID )
			if ( !catherine.inventory.HasSpace( pl, itemTable.weight ) ) then
				catherine.util.Notify( pl, "You don't have inventory space!" )
				return
			end
		end
		catherine.inventory.Work( pl, CAT_INV_ACTION_ADD, {
			uniqueID = uniqueID,
			itemCount = itemCount
		} )
	end
	
	function catherine.item.Take( pl, uniqueID )
		if ( !IsValid( pl ) or !uniqueID ) then return end
		catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, uniqueID )
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
	end

	netstream.Hook( "catherine.item.Work", function( pl, data )
		catherine.item.Work( pl, data[ 1 ], data[ 2 ], data[ 3 ], data[ 4 ] )
	end )
	
	netstream.Hook( "catherine.item.Give", function( pl, data )
		catherine.item.Give( pl, data )
	end )
else
	function catherine.item.OpenMenuUse( uniqueID )
		if ( !uniqueID ) then return end
		local itemTable = catherine.item.FindByID( uniqueID )
		if ( !itemTable ) then return end
		local menu = DermaMenu( )
		for k, v in pairs( itemTable.func ) do
			if ( !v.canShowIsMenu ) then continue end
			if ( v.canLook and v.canLook( LocalPlayer( ), itemTable ) == false ) then continue end
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
		if ( !itemTable ) then return end
		local menu = DermaMenu( )
		for k, v in pairs( itemTable.func ) do
			if ( !v.canShowIsWorld ) then continue end
			if ( v.canLook and v.canLook( LocalPlayer( ), itemTable ) == false ) then continue end
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
	syntax = "[Item id]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			catherine.item.Spawn( args[ 1 ], pl:GetEyeTrace( ).HitPos )
		else
			catherine.util.Notify( pl, catherine.language.GetValue( pl, "ArgError", 1 ) )
		end
	end
} )