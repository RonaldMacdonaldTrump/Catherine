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

CAT_DOOR_CHANGEPERMISSION = 1

CAT_DOOR_FLAG_MASTER = 1
CAT_DOOR_FLAG_ALL = 2
CAT_DOOR_FLAG_BASIC = 3

if ( SERVER ) then
	function catherine.door.Work( pl, ent, workID, data )
		if ( !IsValid( pl ) or !workID ) then return end
		if ( !IsValid( ent ) ) then
			catherine.util.NotifyLang( pl, "Entity_Notify_NotDoor" )
			return
		end
		
		if ( workID == CAT_DOOR_CHANGEPERMISSION ) then
			if ( !catherine.door.IsDoorOwner( pl, ent ) ) then
				catherine.util.NotifyLang( pl, "Door_Notify_NoOwner" )
				return
			end
			local target = catherine.util.FindPlayerByStuff( "SteamID", data[ 1 ] )
			
			if ( !IsValid( target ) ) then
				catherine.util.NotifyLang( pl, "Entity_Notify_NotPlayer" )
				return
			end
			
			local newData = ent:GetNetVar( "permission_guys", { } )
			
			//if ( newData[ 
			
			ent:SetNetVar( "permission_guys", newData )
			
		else
		
		end
	end
	
	function catherine.door.Buy( pl, ent )
		if ( !IsValid( pl ) ) then print("!")return end
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end
		
		if ( !catherine.door.IsBuyableDoor( ent ) ) then
			return false, "Door_Notify_CantBuyable"
		end

		if ( ent:GetNetVar( "owner" ) ) then
			return false, "Door_Notify_AlreadySold"
		end
		
		local cost = catherine.door.GetDoorCost( pl, ent )
		if ( !catherine.cash.Has( pl, cost ) ) then
			return false, "Cash_Notify_HasNot", { catherine.cash.GetOnlyName( ) }
		end
		
		catherine.cash.Take( pl, cost )
		ent:SetNetVar( "owners", {
			master = pl:GetCharacterID( ),
			all = { },
			basic = { }
		} )
		
		print("Fin")
		return true
	end
	
	function catherine.door.Sell( pl, ent )
		if ( !IsValid( pl ) ) then return end
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end

		if ( !catherine.door.IsDoorOwner( pl, ent, CAT_DOOR_FLAG_MASTER ) ) then
			return false, "Door_Notify_NoOwner"
		end
		
		catherine.cash.Give( pl, catherine.door.GetDoorCost( pl, ent ) / 2 )
		ent:SetNetVar( "owners", nil )
		
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
			if ( !catherine.door.IsDoorOwner( pl, ent, CAT_DOOR_FLAG_MASTER, CAT_DOOR_FLAG_ALL ) ) then
				return false, "Door_Notify_NoOwner"
			end
			ent:SetNetVar( "title", title )
		end
		
		return true
	end

	function catherine.door.GetDoorCost( pl, ent )
		return catherine.configs.doorCost // to do;;
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
	
	netstream.Hook( "catherine.door.Work", function( pl, data )
		catherine.door.Work( pl, data[ 1 ], data[ 2 ], data[ 3 ] )
	end )
else
	netstream.Hook( "catherine.door.DoorMenu", function( data )
		if ( IsValid( catherine.vgui.door ) ) then
			catherine.vgui.door:Remove( )
			catherine.vgui.door = nil
		end
		
		catherine.vgui.door = vgui.Create( "catherine.vgui.door" )
		catherine.vgui.door:InitializeDoor( Entity( data ) )
	end )
	
	local toscreen = FindMetaTable("Vector").ToScreen
	
	function catherine.door.GetDetailString( ent )
		local owner = ent:GetNetVar( "owners" )
		
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

function catherine.door.IsDoorOwner( pl, ent, ... )
	local ownerTable = ent:GetNetVar( "owners" )
	if ( !ownerTable ) then return end

	for k, v in pairs( { ... } ) do
		if ( v == CAT_DOOR_FLAG_MASTER ) then
			return ownerTable.master == pl:GetCharacterID( ), CAT_DOOR_FLAG_MASTER
		elseif ( v == CAT_DOOR_FLAG_ALL ) then
			return table.HasValue( ownerTable.all, pl:GetCharacterID( ) ), CAT_DOOR_FLAG_ALL
		elseif ( v == CAT_DOOR_FLAG_BASIC ) then
			return table.HasValue( ownerTable.basic, pl:GetCharacterID( ) ), CAT_DOOR_FLAG_BASIC
		end
	end
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
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
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
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
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