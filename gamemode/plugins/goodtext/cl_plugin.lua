local PLUGIN = PLUGIN

netstream.Hook( "catherine.plugin.goodtext.SyncText", function( data )
	local index = data.index
	if ( !PLUGIN.textLists[ index ] or ( PLUGIN.textLists[ index ] and PLUGIN.textLists[ index ].text != data.text ) ) then
		PLUGIN:DrawText( data )
	end
end )

netstream.Hook( "catherine.plugin.goodtext.RemoveText", function( data )
	if ( !PLUGIN.textLists[ data ] ) then return end
	PLUGIN.textLists[ data ] = nil
end )

function PLUGIN:DrawText( data )
	local object = catherine.markup.Parse( "<font=catherine_goodtext>" .. data.text .. "</font>" )
	function object:DrawText( text, font, x, y, col, hA, vA, a )
		col.a = a
		draw.SimpleText( text, font, x, y, col, 0, 1, 2, Color( 0, 0, 0, a ) )
	end
	
	self.textLists[ data.index ] = {
		pos = data.pos,
		ang = data.ang,
		text = data.text,
		object = object,
		size = data.size
	}
end

function PLUGIN:PostDrawTranslucentRenderables( )
	local pos = LocalPlayer( ):GetPos( )
	for k, v in pairs( self.textLists ) do
		local a = catherine.util.GetAlphaFromDistance( pos, v.pos, 1000 )
		if ( a > 0 ) then
			cam.Start3D2D( v.pos, v.ang, v.size or 0.25 )
				v.object:Draw( 0, 0, 1, 1, a )
			cam.End3D2D( )
		end
	end
end

catherine.font.Register( "catherine_goodtext", catherine.configs.Font, 150, 1000, { outline = true } )