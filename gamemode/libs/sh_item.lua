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
	tab.desc = tab.desc or "ITEM DESC"
	tab.cost = tab.cost or 0
	tab.category = tab.category or "Other"
	tab.funcBuffer = { }
	tab.funcBuffer.take = {
		text = "Take",
		viewIsEntity = true,
		func = function( pl, tab, data )
			if ( catherine.inventory.GetInvWeight( pl ) + tab.weight > catherine.inventory.GetInvMaxWeight( pl ) ) then
				catherine.util.Notify( pl, "Bags is full!" )
				return
			end
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
	tab.funcBuffer.drop = {
		text = "Drop",
		viewIsMenu = true,
		func = function( pl, tab, data )
			local eyeTrace = pl:GetEyeTrace( )
			if ( pl:GetPos( ):Distance( eyeTrace.HitPos ) > 100 ) then
				pl:ChatPrint("Error!")
				return
			end
			catherine.item.Spawn( tab, eyeTrace.HitPos )
			catherine.inventory.Update( pl, "remove", tab.uniqueID )
		end,
		viewCre = function( tab, ent, data )
			return !tab.cantDrop
		end
	}
	tab.funcBuf = table.Copy( tab.func or { } )
	tab.func = tab.funcBuffer
	tab.func = table.Merge( tab.func, tab.funcBuf )
	
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

if ( SERVER ) then
	function catherine.item.RunFunction( pl, funcName, itemTab )
		if ( !IsValid( pl ) or !funcName or !itemTab ) then return end
		if ( !pl:IsCharacterLoaded( ) ) then return end
		if ( type( itemTab ) == "string" ) then itemTab = catherine.item.FindByID( itemTab ) end
		if ( !itemTab ) then return end
		if ( !itemData ) then itemData = { } end
		if ( !itemTab.func[ funcName ] ) then return end
		if ( !itemTab.func[ funcName ].func ) then return end
		local data = catherine.inventory.GetInvItemData( pl, itemTab.uniqueID )
		itemTab.func[ funcName ].func( pl, itemTab, data or { } )
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
	
	netstream.Hook( "catherine.item.RunFunction_Entity", function( pl, data )
		local ent = data[ 3 ]
		catherine.item.RunFunction( pl, data[ 1 ], data[ 2 ] )
		if ( type( ent ) == "Entity" and IsValid( ent ) ) then
			ent:Remove( )
		end
	end )

	netstream.Hook( "catherine.item.RunFunction_Menu", function( pl, data )
		catherine.item.RunFunction( pl, data[ 1 ], data[ 2 ] )
	end )

	concommand.Add( "itemCreate", function( pl, cmd, args )
		catherine.item.Spawn( args[1], pl:EyePos( ) )
	end )
	
	function catherine.item.Spawn( itemTab, pos, ang, pl )
		if ( !itemTab ) then return end
		if ( type( itemTab ) == "string" ) then itemTab = catherine.item.FindByID( itemTab ) end
		if ( !itemTab ) then print("2") return end
		if ( !pos ) then print("1") return end
		local ent = ents.Create( "catherine_item" )
		ent:SetPos( Vector( pos.x, pos.y, pos.z + 10 ) )
		ent:SetAngles( ang or Angle( ) )
		ent:Spawn( )
		ent:SetModel( itemTab.model or "models/props_junk/watermelon01.mdl" )
		ent:PhysicsInit( SOLID_VPHYSICS )
		ent.itemTable = itemTab
		ent.itemID = itemTab.uniqueID
		ent:SetNetworkValue( "itemData", itemTab.itemData or { } )
		ent:SetItemUniqueID( itemTab.uniqueID )
		
		local phyO = ent:GetPhysicsObject()
		if ( IsValid( phyO ) ) then
			phyO:EnableMotion( true )
			phyO:Wake( )
		end
	end
else
	function catherine.item.OpenMenu( itemID )
		if ( !itemID ) then return end
		local itemTab = catherine.item.FindByID( itemID )
		if ( !itemTab ) then return end
		local menu = DermaMenu( )
		for k, v in pairs( itemTab.func ) do
			if ( !v.viewIsMenu ) then continue end
			if ( v.showFunc and ( v.showFunc( LocalPlayer( ), itemTab ) == false ) ) then
				continue
			end
			menu:AddOption( v.text or "ERROR", function( )
				netstream.Start( "catherine.item.RunFunction_Menu", { k, itemID } )
			end ):SetImage( "icon16/information.png" )
		end
		menu:Open( )
	end
	
	function catherine.item.OpenEntityUseMenu( data )
		local ent = data[ 1 ]
		local itemID = data[ 2 ]
		if ( !IsValid( ent ) or !IsValid( LocalPlayer( ):GetEyeTrace( ).Entity ) ) then return end
		local itemTab = catherine.item.FindByID( itemID )
		if ( !itemTab ) then return end
		local menu = DermaMenu( )
		for k, v in pairs( itemTab.func ) do
			if ( !v.viewIsEntity ) then continue end
			if ( v.showFunc and v.showFunc( LocalPlayer( ), itemTab ) == false ) then continue end
			menu:AddOption( v.text or "ERROR", function( )
				netstream.Start( "catherine.item.RunFunction_Entity", { k, itemID, ent } )
			end ):SetImage( "icon16/information.png" )
		end
		menu:Open( )
		menu:Center( )
	end
	
	netstream.Hook( "catherine.item.EntityUseMenu", function( data )
		catherine.item.OpenEntityUseMenu( data )
	end )
	
	local toscreen = FindMetaTable("Vector").ToScreen
	
	hook.Add( "DrawEntityInformation", "catherine.item.DrawEntityInformation", function( ent, alpha )
		if ( ent:GetClass( ) != "catherine_item" ) then return end
		local itemTab = catherine.item.FindByID( ent:GetItemUniqueID( ) )
		if ( !itemTab ) then return end
		local position = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		draw.SimpleText( itemTab.name, "catherine_font02_20", position.x, position.y, Color( 255, 255, 255, alpha ), 1, 1 )
		if ( itemTab.GetDesc ) then
			local desc = itemTab:GetDesc( LocalPlayer( ), itemTab, ent:GetNetworkValue( "itemData", { } ) )
			draw.SimpleText( desc, "catherine_font02_15", position.x, position.y + 20, Color( 255, 255, 255, alpha ), 1, 1 )
		else
			draw.SimpleText( itemTab.desc, "catherine_font02_15", position.x, position.y + 20, Color( 255, 255, 255, alpha ), 1, 1 )
		end
	end )
end
