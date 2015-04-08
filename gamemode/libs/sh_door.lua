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


catherine.command.Register( {
	command = "doorbuy",
	syntax = "[none]",
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
	syntax = "[none]",
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
	syntax = "[text]",
	runFunc = function( pl, args )
		catherine.door.SetDoorTitle( pl, ent, title, force )
	end
} )

if ( SERVER ) then
	function catherine.door.Buy( pl, ent )
		if ( !IsValid( pl ) ) then return end
		if ( !IsValid( ent ) ) then
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
		if ( !IsValid( ent ) ) then
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
		if ( !IsValid( ent ) ) then
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
		//if ( !IsValid( pl ) or !IsValid( ent ) ) then return end
		return pl:GetCharacterID( ) == ent:GetNetVar( "owner" )
	end
	
	
	/*
	function catherine.door.Buy( pl )
		local ent = pl:GetEyeTrace( 70 ).Entity
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		if ( catherine.network.GetNetVar( ent, "owner", nil ) != nil ) then
			return catherine.util.Notify( pl, "This door has already bought by unknown guy." )
		end
		if ( catherine.cash.Get( pl ) >= catherine.configs.doorCost ) then
			catherine.door.SetDoorOwner( ent, pl )
			catherine.util.Notify( pl, "You have purchased this door." )
			catherine.cash.Take( pl, catherine.configs.doorCost )
		elseif ( catherine.cash.Get( pl ) < catherine.configs.doorCost ) then
			catherine.util.Notify( pl, "You need " .. catherine.cash.GetName( catherine.configs.doorCost - pl:GetCash( ) ) .. "(s) more!" )
		end
	end
	
	function catherine.door.Sell( pl )
		local ent = pl:GetEyeTrace( 70 ).Entity
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		if ( catherine.network.GetNetVar( ent, "owner", nil ) != pl ) then
			return catherine.util.Notify( pl, "You do not have permission!" )
		end
		catherine.door.SetDoorOwner( ent, nil )
		catherine.cash.Give( pl, catherine.configs.doorSellCost )
		catherine.util.Notify( pl, "You are sold this door." )
	end
	
	function catherine.door.SetDoorTitle( pl, title )
		if ( !title ) then title = "Door" end
		local ent = pl:GetEyeTrace( 70 ).Entity
		if ( !IsValid( ent ) ) then return catherine.util.Notify( pl, "Please look valid entity!" ) end
		if ( !ent:IsDoor( ) ) then return catherine.util.Notify( pl, "Please look valid door!" ) end
		if ( catherine.network.GetNetVar( ent, "owner", nil ) != pl ) then return catherine.util.Notify( pl, "You do not have permission!" ) end
		catherine.network.SetNetVar( ent, "title", title )
		catherine.util.Notify( pl, "You are setting this door title to \"" .. title .. "\"" )
	end
	
	function catherine.door.SetDoorOwner( ent, pl )
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		catherine.network.SetNetVar( ent, "owner", pl )
	end
	
	function catherine.door.GetDoorOwner( ent )
		if ( !IsValid( ent ) ) then
			return catherine.util.Notify( pl, "Please look valid entity!" )
		end
		if ( !ent:IsDoor( ) ) then
			return catherine.util.Notify( pl, "Please look valid door!" )
		end
		return catherine.network.GetNetVar( ent, "owner", nil )
	end
	
	*/

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
	
	hook.Add( "DrawEntityTargetID", "catherine.door.DrawEntityTargetID", function( pl, ent, a )
		if ( !ent:IsDoor( ) ) then return end
		local position = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		draw.SimpleText( catherine.network.GetNetVar( ent, "owner", nil ) == nil and "This door can purchase." or "This door has already been purchased.", "catherine_outline15", position.x, position.y + 20, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( catherine.network.GetNetVar( ent, "title", "Door" ), "catherine_outline20", position.x, position.y, Color( 255, 255, 255, a ), 1, 1 )
	end )
end

function catherine.door.IsBuyableDoor( ent )
	return ent:GetNetVar( "buyable", true )
end
