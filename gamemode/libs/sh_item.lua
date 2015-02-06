catherine.item = catherine.item or { }
catherine.item.bases = { }
catherine.item.items = { }

function catherine.item.Register( tab, isBase )
	if ( isBase ) then
		catherine.item.bases[ tab.uniqueID ] = tab
		return
	end
	if ( tab.base ) then
		local base = catherine.item.bases[ tab.base ]
		if ( !base ) then print("Base missing!") return end
		tab = table.Inherit( tab, base )
	end
	tab.weight = tab.weight or 0
	tab.itemData = tab.itemData or { }
	tab.func = tab.func or { }
	tab.desc = tab.desc or "ITEM DESC"
	tab.cost = tab.cost or 0
	tab.category = tab.category or "Other"
	
	tab.func.take = {
		text = "Take",
		viewIsEntity = true,
		func = function( pl, tab, data )
			local item = {
				uniqueID = tab.uniqueID,
				itemData = tab.itemData or { }
			}
			catherine.inventory.Update( pl, "add", item )
		end,
		viewCre = function( tab, ent, data )
			return !tab.cantTake
		end
	}
	tab.func.drop = {
		text = "Drop",
		viewIsMenu = true,
		func = function( pl, tab, data )
			local eyeTrace = pl:GetEyeTrace( )
			if ( pl:GetPos( ):Distance( eyeTrace ) > 100 ) then
				pl:ChatPrint("Error!")
				return
			end
			catherine.item.Spawn( tab, eyeTrace, pl )
		end,
		viewCre = function( tab, ent, data )
			return !tab.cantDrop
		end
	}
	
	catherine.item.items[ tab.uniqueID ] = tab
end

function catherine.item.FindByID( id )
	return catherine.item.items[ id ]
end

function catherine.item.FindBaseByID( id )
	return catherine.item.bases[ id ]
end

function catherine.item.Include( dir )
	local baseFiles = file.Find( dir .. "/items/base/*", "LUA" )
	for k, v in pairs( baseFiles ) do
		Base = { }
		Base.uniqueID = string.sub( v, 4, -5 )
		catherine.util.Include( dir .. "/items/base/" .. v )
		catherine.item.Register( Base, true )
		Base = nil
	end

	local itemFiles, itemFolders = file.Find( dir .. "/items/*", "LUA" )
	for k, v in pairs( itemFolders ) do
		if ( v == "base" ) then continue end
		local itemFile = file.Find( dir .. "/items/" .. v .. "/*", "LUA" )
		for k1, v1 in pairs( itemFile ) do
			Item = { }
			Item.uniqueID = string.sub( v1, 4, -5 )
			catherine.util.Include( dir .. "/items/" .. v .. "/" .. v1 )
			catherine.item.Register( Item )
			Item = nil
		end
	end
end

catherine.item.Include( catherine.FolderName .. "/gamemode" )

//PrintTable(catherine.item.FindByID( "weapon_pistol" ))

if ( SERVER ) then
	function catherine.item.RunFunction( pl, funcName, itemTab, itemData )
		if ( !IsValid( pl ) or !funcName or !itemTab ) then return end
		if ( !pl:IsCharacterLoaded( ) ) then return end
		if ( type( itemTab ) == "string" ) then itemTab = catherine.item.FindByID( itemTab ) end
		if ( !itemTab ) then return end
		if ( !itemData ) then itemData = { } end
		if ( !itemTab.func[ funcName ] ) then
			print("Function not found")
			return
		end
		if ( !itemTab.func[ funcName ].func ) then
			print("Function not found - 2")
			return
		end
		itemTab.func[ funcName ].func( pl, itemTab, itemData )
	end
	
	function catherine.item.GiveToCharacter( pl, itemID )
		if ( !IsValid( pl ) or !itemID ) then return end
		local itemTab = catherine.item.FindByID( itemID )
		if ( !itemTab ) then return end
		local item = {
			uniqueID = itemTab.uniqueID,
			itemData = itemTab.itemData or { }
		}
		catherine.inventory.Update( pl, "add", item )
	end
	
	function catherine.item.TakeByCharacter( pl, itemID )
		if ( !IsValid( pl ) or !itemID ) then return end
		local itemTab = catherine.item.FindByID( itemID )
		if ( !itemTab ) then return end
		catherine.inventory.Update( pl, "remove", itemTab.uniqueID )
	end
	
	netstream.Hook( "catherine.item.RunFunction", function( pl, data )
		local ent = data[ 1 ]
		catherine.item.RunFunction( pl, data[ 3 ], data[ 2 ] )
		if ( IsValid( ent ) ) then
			ent:Remove( )
		end
	end )
	
	function catherine.item.Spawn( itemTab, pos, ang, pl )
		if ( !itemTab ) then return end
		if ( type( itemTab ) == "string" ) then itemTab = catherine.item.FindByID( itemTab ) end
		if ( !itemTab ) then return end
		if ( !pos ) then return end
		local ent = ents.Create( "catherine_item" )
		ent:SetPos( pos )
		ent:SetAngles( ang or Angle( ) )
		ent:Spawn( )
		ent:SetModel( itemTab.model or "models/props_junk/watermelon01.mdl" )
		ent:PhysicsInit( SOLID_VPHYSICS )
		ent.itemTable = itemTab
		ent.itemID = itemTab.uniqueID
		ent:SetNetworkValue( "itemData", itemTab.itemData or { } )
		
		local phyO = ent:GetPhysicsObject()
		if ( IsValid( phyO ) ) then
			phyO:EnableMotion( true )
			phyO:Wake( )
		end
	end

	concommand.Add( "itemCreate", function( pl )
		catherine.item.Spawn( "weapon_pistol", pl:EyePos( ) )
	end )
	
	//catherine.item.TakeByCharacter( player.GetByID( 1 ), "weapon_pistol" )
	
	//catherine.item.RunFunction( player.GetByID( 1 ), "unequip", catherine.item.FindByID( "weapon_pistol" ) )
	//PrintTable(catherine.inventory.GetInv( player.GetByID( 1 )))
else
	function catherine.item.OpenEntityUseMenu( data )
		local ent = data[ 1 ]
		local itemID = data[ 2 ] // to do remove.;
		if ( !IsValid( ent ) or !IsValid( LocalPlayer( ):GetEyeTrace( ).Entity ) ) then return end
		local itemTab = catherine.item.FindByID( itemID )
		if ( !itemTab ) then return end
		local menu = DermaMenu( )
		for k, v in pairs( itemTab.func ) do
			if ( !v.viewIsEntity ) then continue end
			local menuAdd = menu:AddOption( v.text or "ERROR", function( )
				netstream.Start( "catherine.item.RunFunction", { ent, itemID, k } )
			end ):SetImage( "icon16/information.png" )
		end
		menu:Open( )
		menu:Center( )
	end
	
	netstream.Hook( "catherine.item.EntityUseMenu", function( data )
		catherine.item.OpenEntityUseMenu( data )
	end )
end