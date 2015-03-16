local Plugin = Plugin

Plugin.name = "Save Item"
Plugin.author = "L7D"
Plugin.desc = "Good stuff."

if ( SERVER ) then
	function Plugin:SaveItems( )
		// 아이팀 데이터 까지 저장되게 수정할것;
		local data = { }
		for k, v in pairs( ents.FindByClass( "cat_item" ) ) do
			data[ #data + 1 ] = {
				uniqueID = v:GetItemUniqueID( ),
				pos = v:GetPos( ),
				ang = v:GetAngles( )
			}
		end
		
		catherine.data.Set( "items", data )
	end

	function Plugin:LoadItems( )
		local data = catherine.data.Get( "items", { } )

		for k, v in pairs( data ) do
			catherine.item.Spawn( v.uniqueID, v.pos, v.ang )
		end
	end
	
	function Plugin:DataSave( )
		self:SaveItems( )
	end
	
	function Plugin:DataLoad( )
		self:LoadItems( )
	end
end