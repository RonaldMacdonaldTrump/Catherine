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

if ( !catherine.data ) then
	catherine.util.Include( "sv_data.lua" )
end
catherine.door = catherine.door or { }

if ( SERVER ) then
	function catherine.door.Buy( pl, ent )
		if ( !IsValid( pl ) ) then return end
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end
		
		if ( !catherine.door.IsBuyableDoor( ent ) ) then
			return false, "Door_Notify_CantBuyable"
		end

		if ( catherine.door.GetDoorOwner( ent ) ) then
			return false, "Door_Notify_AlreadySold"
		end
		
		local cost = catherine.door.GetDoorCost( pl, ent )
		if ( !catherine.cash.Has( pl, cost ) ) then
			return false, "Cash_Notify_HasNot", { catherine.cash.GetOnlyName( ) }
		end
		
		catherine.cash.Take( pl, cost )
		ent:SetNetVar( "owner", pl:GetCharacterID( ) )
		
		return true
	end
	
	function catherine.door.Sell( pl, ent )
		if ( !IsValid( pl ) ) then return end
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end

		if ( !catherine.door.GetDoorOwner( ent ) or !catherine.door.IsDoorOwner( pl, ent ) ) then
			return false, "Door_Notify_NoOwner"
		end
		
		catherine.cash.Give( pl, catherine.door.GetDoorCost( pl, ent ) / 2 )
		ent:SetNetVar( "owner", nil )
		
		return true
		// 판매시 주인이 임의로 설정한 커스텀 타이틀이 복귀되어야함 ^_^
	end
	
	function catherine.door.SetDoorTitle( pl, ent, title, force )
		if ( !IsValid( pl ) or !title ) then return end
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end
		
		if ( force ) then
			ent:SetNetVar( "title", title )
		else
			if ( !catherine.door.GetDoorOwner( ent ) or !catherine.door.IsDoorOwner( pl, ent ) ) then
				return false, "Door_Notify_NoOwner"
			end
			ent:SetNetVar( "title", title )
		end
		
		return true
	end

	function catherine.door.GetDoorCost( pl, ent )
		return catherine.configs.doorCost // to do;;
	end
	
	function catherine.door.GetDoorOwner( ent )
		return ent:GetNetVar( "owner" )
	end
	
	function catherine.door.IsDoorOwner( pl, ent )
		return pl:GetCharacterID( ) == ent:GetNetVar( "owner" )
	end

	function catherine.door.DataSave( )
		local data = { }
		
		for k, v in pairs( ents.GetAll( ) ) do
			if ( !catherine.entity.IsDoor( v ) ) then continue end
			local title = v:GetNetVar( "title", "Door" )
			local buyable = v:GetNetVar( "buyable", true )
			if ( title == "Door" or buyable ) then continue end
			
			data[ #data + 1 ] = {
				title = title,
				buyable = buyable,
				index = v:EntIndex( )
			}
		end
		
		catherine.data.Set( "doors", data )
	end
	
	function catherine.door.DataLoad( )
		for k, v in pairs( ents.GetAll( ) ) do
			for k1, v1 in pairs( catherine.data.Get( "doors", { } ) ) do
				if ( IsValid( v ) and catherine.entity.IsDoor( v ) and v:EntIndex( ) == v1.index ) then
					v:SetNetVar( "title", v1.title )
					v:SetNetVar( "buyable", v1.buyable )
				end
			end
		end
	end
	
	hook.Add( "DataSave", "catherine.door.DataSave", catherine.door.DataSave )
	hook.Add( "DataLoad", "catherine.door.DataLoad", catherine.door.DataLoad )
else
	local toscreen = FindMetaTable("Vector").ToScreen
	
	function catherine.door.GetDetailString( ent )
		local owner = ent:GetNetVar( "owner" )
		if ( owner ) then
			return LANG( "Door_Message_AlreadySold" )
		elseif ( !owner and catherine.door.IsBuyableDoor( ent ) ) then
			return LANG( "Door_Message_Buyable" )
		else
			return LANG( "Door_Message_CantBuy" )
		end
	end
	
	function catherine.door.DrawEntityTargetID( pl, ent, a )
		if ( !catherine.entity.IsDoor( ent ) ) then return end
		local pos = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		local x, y = pos.x, pos.y
		
		draw.SimpleText( ent:GetNetVar( "title", "Door" ), "catherine_outline20", x, y, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( catherine.door.GetDetailString( ent ), "catherine_outline15", x, y + 20, Color( 255, 255, 255, a ), 1, 1 )
	end
	
	hook.Add( "DrawEntityTargetID", "catherine.door.DrawEntityTargetID", catherine.door.DrawEntityTargetID )
end

function catherine.door.IsBuyableDoor( ent )
	return ent:GetNetVar( "buyable", true )
end

catherine.command.Register( {
	command = "doorbuy",
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.Buy( pl, pl:GetEyeTrace( 70 ).Entity )
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_Buy" )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par ) )
		end
	end
} )

catherine.command.Register( {
	command = "doorsell",
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.Sell( pl, pl:GetEyeTrace( 70 ).Entity )
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_Sell" )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par ) )
		end
	end
} )

catherine.command.Register( {
	command = "doorsettitle",
	syntax = "[Text]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local success, langKey, par = catherine.door.SetDoorTitle( pl, pl:GetEyeTrace( 70 ).Entity, args[ 1 ], true )
			if ( success ) then
				catherine.util.NotifyLang( pl, "Door_Notify_SetTitle" )
			else
				catherine.util.NotifyLang( pl, langKey, unpack( par ) )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )