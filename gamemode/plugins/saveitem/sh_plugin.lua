local Plugin = Plugin

Plugin.name = "Save Item"
Plugin.author = "L7D"
Plugin.desc = "Good stuff."

if ( SERVER ) then
	function Plugin:DataSave( )
		local data = { }
		for k, v in pairs( ents.FindByClass( "cat_item" ) ) do
			data[ #data + 1 ] = {
				uniqueID = v:GetItemUniqueID( ),
				itemData = v:GetItemData( ),
				pos = v:GetPos( ),
				ang = v:GetAngles( )
			}
		end
		catherine.data.Set( "items", data )
	end
	
	function Plugin:DataLoad( )
		for k, v in pairs( catherine.data.Get( "items", { } ) ) do
			catherine.item.Spawn( v.uniqueID, v.pos, v.ang, v.itemData )
		end
	end
end