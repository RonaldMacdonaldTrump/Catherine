catherine.geometry = catherine.geometry or { }

--[[
	- catherine.geometry.DrawCircle( originX, originY, radius, thick, startAng, distAng, iter ) function source -
	: Night-Eagle's circle drawing library
	: 1.1
	: https://code.google.com/p/wintersurvival/source/browse/trunk/gamemode/cl_circle.lua?r=154
--]]
function catherine.geometry.DrawCircle( originX, originY, radius, thick, startAng, distAng, iter )
	startAng = math.rad( startAng )
	distAng = math.rad( distAng )
	if ( !iter or iter <= 1 ) then
		iter = 8
	else
		iter = math.Round( iter )
	end
        
	local stepAng = math.abs( distAng ) / iter
        
	if ( thick ) then
		if ( distAng > 0 ) then
			for i = 0, iter-1 do
				local eradius = radius + thick
				local cur1 = stepAng * i + startAng
				local cur2 = cur1 + stepAng
				local points = {
					{
						x = math.cos( cur2 ) * radius + originX,
						y = -math.sin( cur2 ) * radius + originY,
						u = 0,	
						v = 0,
					},
					{
						x = math.cos( cur2 ) * eradius + originX,
						y = -math.sin( cur2 ) * eradius + originY,
						u = 1,
						v = 0,
					},
					{
						x = math.cos( cur1 ) * eradius + originX,
						y = -math.sin( cur1 ) * eradius + originY,
						u = 1,
						v = 1,
					},
					{
						x = math.cos( cur1 ) * radius + originX,
						y = -math.sin( cur1 ) * radius + originY,
						u = 0,
						v = 1,
					},
				}
                                
				surface.DrawPoly( points )
			end
		else
			for i = 0, iter - 1 do
				local eradius = radius + thick
				local cur1 = stepAng * i + startAng
				local cur2 = cur1 + stepAng
				local points = {
					{
						x = math.cos( cur1 ) * radius + originX,
						y = math.sin( cur1 ) * radius + originY,
						u = 0,
						v = 0,
					},
					{
						x = math.cos( cur1 ) * eradius + originX,
						y = math.sin( cur1 ) * eradius + originY,
						u = 1,
						v = 0,
					},
					{
						x = math.cos( cur2 ) * eradius + originX,
						y = math.sin( cur2 ) * eradius + originY,
						u = 1,
						v = 1,
					},
					{
						x = math.cos( cur2 ) * radius + originX,
						y = math.sin( cur2 ) * radius + originY,
						u = 0,
						v = 1,
					},
				}
				
				surface.DrawPoly( points )
			end
		end
	else
		if ( distAng > 0 ) then
			local points = { }
                        
			if ( math.abs( distAng ) < 360 ) then
				points[ 1 ] = {
					x = originX,
					y = originY,
					u = .5,
					v = .5,
				}
				iter = iter + 1
			end
                        
			for i = iter - 1, 0, -1 do
				local cur1 = stepAng * i + startAng
				local cur2 = cur1 + stepAng
				table.insert( points, {
					x = math.cos( cur1 ) * radius + originX,
					y = -math.sin( cur1 ) * radius + originY,
					u = ( 1 + math.cos( cur1 ) ) / 2,
					v = ( 1 + math.sin( -cur1 ) ) / 2,
				} )
			end
                        
			surface.DrawPoly( points )
		else
			local points = { }
 
			if ( math.abs( distAng ) < 360 ) then
				points[ 1 ] = {
					x = originX,
					y = originY,
					u = .5,
					v = .5,
				}
				iter = iter + 1
			end
			
			for i = 0, iter - 1 do
				local cur1 = stepAng * i + startAng
				local cur2 = cur1 + stepAng
				table.insert( points, {
				x = math.cos( cur1 ) * radius + originX,
				y = math.sin( cur1 ) * radius + originY,
				u = ( 1 + math.cos( cur1 ) ) / 2,
				v = ( 1 + math.sin( cur1 ) ) / 2,
				} )
			end
			
			surface.DrawPoly( points )
		end
	end
end