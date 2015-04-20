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

--[[ // to do...; maybe :)
catherine.body = catherine.body or { }
CAT_BODY_ID_HEAD = 1
CAT_BODY_ID_CHEST = 2
CAT_BODY_ID_L_ARM = 3
CAT_BODY_ID_R_ARM = 4
CAT_BODY_ID_STOMACH = 5
CAT_BODY_ID_L_LEG = 6
CAT_BODY_ID_R_LEG = 7

local work = {
	[ CAT_BODY_ID_HEAD ] = { "body_head", function( pl, per )
		catherine.util.ScreenColorEffect( pl, nil, 2, 0.005 )
	end },
	[ CAT_BODY_ID_CHEST ] = { "body_chest", function( pl, per )
	
	end },
	[ CAT_BODY_ID_L_ARM ] = { "body_l_arm", function( pl, per )
	
	end },
	[ CAT_BODY_ID_R_ARM ] = { "body_r_arm", function( pl, per )
	
	end },
	[ CAT_BODY_ID_STOMACH ] = { "body_stomach", function( pl, per )
	
	end },
	[ CAT_BODY_ID_L_LEG ] = { "body_l_leg", function( pl, per )
	
	end },
	[ CAT_BODY_ID_R_LEG ] = { "body_r_leg", function( pl, per )
	
	end }
}

if ( SERVER ) then
	catherine.body.NextTick = catherine.body.NextTick or CurTime( ) + 1
	
	function catherine.body.AddPercent( pl, bodyID, per )
		if ( !IsValid( pl ) or !bodyID or !per ) then return end
		local varID = work[ bodyID ][ 1 ]
		if ( !varID ) then return end
		local curr = catherine.character.GetCharVar( pl, varID, 100 )
		catherine.character.SetCharVar( pl, varID, math.Clamp( curr + per, 0, 100 ) )
	end
	
	function catherine.body.RunFunction( pl, bodyID )
		if ( !IsValid( pl ) or !bodyID ) then return end
		local per = catherine.body.GetPercent( pl, bodyID, default )
		work[ bodyID ][ 2 ]( pl, per )
	end
	
	function catherine.body.TakePercent( pl, bodyID, per )
		if ( !IsValid( pl ) or !bodyID or !per ) then return end
		local varID = work[ bodyID ][ 1 ]
		if ( !varID ) then return end
		local curr = catherine.character.GetCharVar( pl, varID, 100 )
		catherine.character.SetCharVar( pl, varID, math.Clamp( curr - per, 0, 100 ) )
	end
	
	function catherine.body.SetPercent( pl, bodyID, per )
		if ( !IsValid( pl ) or !bodyID or !per ) then return end
		local varID = work[ bodyID ][ 1 ]
		if ( !varID ) then return end
		catherine.character.SetCharVar( pl, varID, math.Clamp( per, 0, 100 ) )
	end
	
	function catherine.body.GetPercent( pl, bodyID, default )
		if ( !IsValid( pl ) or !bodyID or !per ) then return end
		local varID = work[ bodyID ][ 1 ]
		if ( !varID ) then return end
		return catherine.character.GetCharVar( pl, varID, default or 100 )
	end
	
	function catherine.body.Work( )
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( !v.CAT_bodyCur ) then v.CAT_bodyCur = CurTime( ) + 1 end
			
			if ( v.CAT_bodyCur <= CurTime( ) ) then
				
				v.CAT_bodyCur = CurTime( ) + 1
			end
		end
	end
	
	hook.Add( "Think", "catherine.body.Work", catherine.body.Work )
else
	function catherine.body.SetPercent( bodyID, default )
		if ( !bodyID ) then return end
		local varID = work[ bodyID ]
		if ( !varID ) then return end
		return catherine.character.GetCharVar( LocalPlayer( ), varID, default or 100 )
	end
end

--]]