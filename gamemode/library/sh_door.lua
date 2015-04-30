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
// 이 라이브러리는 현재 개발중 입니다!
// This library is still developing!
catherine.door = catherine.door or { }

CAT_DOOR_CHANGE_PERMISSION = 1
CAT_DOOR_CHANGE_DESC = 2

CAT_DOOR_FLAG_OWNER = 1
CAT_DOOR_FLAG_ALL = 2
CAT_DOOR_FLAG_BASIC = 3

if ( SERVER ) then
	function catherine.door.Work( pl, ent, workID, data )
		if ( !IsValid( pl ) or !workID ) then return end
		if ( !IsValid( ent ) ) then
			catherine.util.NotifyLang( pl, "Entity_Notify_NotDoor" )
			return
		end
		
		if ( workID == CAT_DOOR_CHANGE_PERMISSION ) then
			if ( !catherine.door.IsDoorOwner( pl, ent, CAT_DOOR_FLAG_OWNER ) ) then
				catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
				return
			end
			
			local permissions = ent.GetNetVar( ent, "permissions" )
			
			if ( !permissions ) then
				catherine.util.NotifyLang( pl, "Door_Notify_NoOwner" )
				return
			end
			
			local target = catherine.util.FindPlayerByStuff( "SteamID", data[ 1 ] )
			
			if ( !IsValid( target ) ) then
				catherine.util.NotifyLang( pl, "Entity_Notify_NotPlayer" )
				return
			end
			
			local has, flag = catherine.door.IsHasDoorPermission( target, ent )
			
			if ( flag == CAT_DOOR_FLAG_OWNER ) then
				catherine.util.NotifyLang( pl, "Door_Notify_CantChangeOwner" )
				return
			else
				if ( has and flag == data[ 2 ] ) then
					catherine.util.NotifyLang( pl, "Door_Notify_AlreadyHasPer" )
					return
				elseif ( has and data[ 2 ] == 0 ) then
					permissions[ target.GetCharacterID( target ) ] = nil
					ent:SetNetVar( "permissions", permissions )
					netstream.Start( pl, "catherine.door.DoorMenuRefresh" )
					catherine.util.NotifyLang( pl, "Door_Notify_RemPer" )
					return
				end
			end

			local targetID = target.GetCharacterID( target )
			
			permissions[ targetID ] = {
				id = targetID,
				permission = data[ 2 ]
			}

			ent:SetNetVar( "permissions", permissions )
			netstream.Start( pl, "catherine.door.DoorMenuRefresh" )
			catherine.util.NotifyLang( pl, "Door_Notify_ChangePer" )
		elseif ( workID == CAT_DOOR_CHANGE_DESC ) then
			local permissions = ent.GetNetVar( ent, "permissions" )
			
			if ( !permissions ) then
				catherine.util.NotifyLang( pl, "Door_Notify_NoOwner" )
				return
			end
			
			local has, flag = catherine.door.IsHasDoorPermission( pl, ent )

			if ( !has or flag == CAT_DOOR_FLAG_BASIC ) then
				catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
				return
			end
			
			ent:SetNetVar( "customDesc", data != "" and data or nil )
			catherine.util.NotifyLang( pl, "Door_Notify_SetTitle" )
		end
	end
	
	function catherine.door.Buy( pl, ent )
		if ( !IsValid( pl ) ) then return end
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end
		
		if ( !catherine.door.IsBuyableDoor( ent ) ) then
			return false, "Door_Notify_CantBuyable"
		end

		if ( ent.GetNetVar( ent, "permissions" ) ) then
			return false, "Door_Notify_AlreadySold"
		end
		
		local cost = catherine.door.GetDoorCost( pl, ent )
		if ( !catherine.cash.Has( pl, cost ) ) then
			return false, "Cash_Notify_HasNot"
		end
		
		local id = pl.GetCharacterID( pl )

		catherine.cash.Take( pl, cost )
		ent:SetNetVar( "permissions", {
			[ id ] = {
				id = id,
				permission = CAT_DOOR_FLAG_OWNER
			}
		} )
		
		return true
	end
	
	function catherine.door.Sell( pl, ent )
		if ( !IsValid( pl ) ) then return end
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end

		if ( !catherine.door.IsDoorOwner( pl, ent, CAT_DOOR_FLAG_OWNER ) ) then
			return false, "Door_Notify_NoOwner"
		end
		
		catherine.cash.Give( pl, catherine.door.GetDoorCost( pl, ent ) / 2 )
		ent:SetNetVar( "permissions", nil )
		ent:SetNetVar( "customDesc", nil )
		
		return true
	end
	
	function catherine.door.SetDoorTitle( pl, ent, title, force )
		if ( !IsValid( pl ) or !title ) then return end
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end
		
		if ( force ) then
			ent:SetNetVar( "title", title )
		else
			local has, flag = catherine.door.IsHasDoorPermission( target, ent )
			
			if ( !has or flag == CAT_DOOR_FLAG_BASIC ) then
				return false, "Door_Notify_NoOwner"
			end
			
			ent:SetNetVar( "title", title )
		end
		
		return true
	end
	
	function catherine.door.SetDoorStatus( pl, ent )
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end
		
		local curStatus = ent.GetNetVar( ent, "cantBuy", false )
		local curOwner = ent.GetNetVar( ent, "permissions" )
		
		if ( curStatus ) then
			ent:SetNetVar( "cantBuy", false )
			
			if ( curOwner ) then
				ent:SetNetVar( "permissions", nil )
			end
			
			return true, "Door_Notify_SetStatus_False"
		else
			ent:SetNetVar( "cantBuy", true )
			
			if ( curOwner ) then
				ent:SetNetVar( "permissions", nil )
			end
			
			return true, "Door_Notify_SetStatus_True"
		end
	end
	
	function catherine.door.SetDoorActive( pl, ent )
		if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) ) then
			return false, "Entity_Notify_NotDoor"
		end
		
		local curStatus = ent.GetNetVar( ent, "disabled" )
		local curOwner = ent.GetNetVar( ent, "permissions" )
		
		if ( curStatus ) then
			ent:SetNetVar( "disabled", nil )
			
			if ( curOwner ) then
				ent:SetNetVar( "permissions", nil )
			end
			
			return true, "Door_Notify_Disabled_False"
		else
			ent:SetNetVar( "disabled", true )
			
			if ( curOwner ) then
				ent:SetNetVar( "permissions", nil )
			end
			
			return true, "Door_Notify_Disabled_True"
		end
	end
	
	function catherine.door.DoorSpamProtection( pl, ent )
		local steamID = pl.SteamID( pl )
		
		if ( !pl.CAT_lastDoor ) then
			pl.CAT_lastDoor = ent
		end
		
		if ( !pl.CAT_doorSpamCount ) then
			pl.CAT_doorSpamCount = 0
		end
		
		pl.CAT_doorSpamCount = pl.CAT_doorSpamCount + 1
		
		if ( pl.CAT_lastDoor == ent and pl.CAT_doorSpamCount >= 10 ) then
			pl.lookingDoorEntity = nil
			pl.CAT_doorSpamCount = 0
			pl.CAT_cantUseDoor = true
			catherine.util.NotifyLang( pl, "Door_Notify_DoorSpam" )
			
			timer.Create( "Catherine.timer.DoorSpamDelta_" .. steamID, 1, 1, function( )
				if ( !IsValid( pl ) ) then return end
				
				pl.CAT_cantUseDoor = nil
			end )
			
			timer.Remove( "Catherine.timer.DoorSpamCountInitizlie_" .. steamID )
		elseif ( pl.CAT_lastDoor != ent ) then
			pl.CAT_lastDoor = ent
			pl.CAT_doorSpamCount = 1
		end
		
		timer.Remove( "Catherine.timer.DoorSpamCountInitizlie_" .. steamID )
		timer.Create( "Catherine.timer.DoorSpamCountInitizlie_" .. steamID, 1, 1, function( )
			if ( !IsValid( pl ) ) then return end
			
			pl.CAT_cantUseDoor = nil
			pl.CAT_doorSpamCount = nil
		end )
	end

	function catherine.door.GetDoorCost( pl, ent )
		return catherine.configs.doorCost // 나중에 수정 -_-
	end

	function catherine.door.DataSave( )
		local data = { }
		
		for k, v in pairs( ents.GetAll( ) ) do
			if ( !catherine.entity.IsDoor( v ) ) then continue end
			local title = v.GetNetVar( v, "title", "Door" )
			local cantBuy = v.GetNetVar( v, "cantBuy", false )
			local doorDisabled = v.GetNetVar( v, "disabled" )
			if ( !doorDisabled and ( title == "Door" or !cantBuy ) ) then continue end
			
			data[ #data + 1 ] = {
				title = title,
				cantBuy = cantBuy,
				index = v.EntIndex( v ),
				doorDisabled = doorDisabled
			}
		end
		
		catherine.data.Set( "doors", data )
	end
	
	function catherine.door.DataLoad( )
		for k, v in pairs( ents.GetAll( ) ) do
			for k1, v1 in pairs( catherine.data.Get( "doors", { } ) ) do
				if ( IsValid( v ) and catherine.entity.IsDoor( v ) and v.EntIndex( v ) == v1.index ) then
					if ( v1.doorDisabled ) then
						v:SetNetVar( "disabled", true )
					else
						v:SetNetVar( "title", v1.title )
						v:SetNetVar( "cantBuy", v1.cantBuy )
					end
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
	netstream.Hook( "catherine.door.DoorMenuRefresh", function( data )
		if ( IsValid( catherine.vgui.door ) ) then
			catherine.vgui.door:Refresh( )
		end
	end )
	
	netstream.Hook( "catherine.door.DoorMenu", function( data )
		if ( IsValid( catherine.vgui.door ) ) then
			catherine.vgui.door:Remove( )
			catherine.vgui.door = nil
		end
		
		catherine.vgui.door = vgui.Create( "catherine.vgui.door" )
		catherine.vgui.door:InitializeDoor( Entity( data[ 1 ] ), data[ 2 ] )
	end )

	function catherine.door.GetDetailString( ent )
		local owner = ent.GetNetVar( ent, "permissions" )
		local customDesc = ent.GetNetVar( ent, "customDesc" )
		
		if ( customDesc ) then
			return customDesc
		else
			if ( owner ) then
				return LANG( "Door_Message_AlreadySold" )
			elseif ( !owner and catherine.door.IsBuyableDoor( ent ) ) then
				return LANG( "Door_Message_Buyable" )
			else
				return LANG( "Door_Message_CantBuy" )
			end
		end
	end

	--[[
		This function has brought from Clockwork.
		https://github.com/CloudSixteen/Clockwork
	--]]
	function catherine.door.CalcDoorTextPos( ent, rev )
		local max = ent.OBBMaxs( ent )
		local min = ent.OBBMins( ent )
		
		local data = { }
		data.endpos = ent.LocalToWorld( ent, ent.OBBCenter( ent ) )
		data.filter = ents.FindInSphere( data.endpos, 23 )
		
		for k, v in pairs( data.filter ) do
			if ( v != ent ) then continue end
			
			data.filter[ k ] = nil
		end
		
		local len = 0
		local w = 0
		local size = min - max
		
		size.x = math.abs( size.x )
		size.y = math.abs( size.y )
		size.z = math.abs( size.z )
		
		if ( size.z < size.x and size.z < size.y ) then
			len = size.z
			w = size.y
			
			if ( rev ) then
				data.start = data.endpos - ( ent.GetUp( ent ) * len )
			else
				data.start = data.endpos + ( ent.GetUp( ent ) * len )
			end
		elseif ( size.x < size.y ) then
			len = size.x
			w = size.y
			
			if ( rev ) then
				data.start = data.endpos - ( ent.GetForward( ent ) * len )
			else
				data.start = data.endpos + ( ent.GetForward( ent ) * len )
			end
		elseif ( size.y < size.x ) then
			len = size.y
			w = size.x
			
			if ( rev ) then
				data.start = data.endpos - ( ent.GetRight( ent ) * len )
			else
				data.start = data.endpos + ( ent.GetRight( ent ) * len )
			end
		end

		local tr = util.TraceLine( data )

		if ( tr.HitWorld and !rev ) then
			return catherine.door.CalcDoorTextPos( ent, true )
		end

		local ang = tr.HitNormal.Angle( tr.HitNormal )
		local pos = tr.HitPos - ( ( ( data.endpos - tr.HitPos ):Length( ) * 2 ) + 2 ) * tr.HitNormal
		local angBack = tr.HitNormal.Angle( tr.HitNormal )
		local posBack = tr.HitPos + ( tr.HitNormal * 2 )
		
		ang:RotateAroundAxis( ang.Forward( ang ), 90 )
		ang:RotateAroundAxis( ang.Right( ang ), 90 )
		angBack:RotateAroundAxis( angBack.Forward( angBack ), 90 )
		angBack:RotateAroundAxis( angBack.Right( angBack ), -90 )
		
		return {
			pos = pos,
			ang = ang,
			hitWorld = tr.HitWorld,
			w = math.abs( w ),
			posBack = posBack,
			angBack = angBack
		}
	end
end

function catherine.door.IsDoorOwner( pl, ent, flag )
	local permissions = ent.GetNetVar( ent, "permissions", { } )
	local targetID = pl.GetCharacterID( pl )

	if ( permissions[ targetID ] ) then
		return permissions[ targetID ].permission == flag
	end
	
	return false
end

function catherine.door.IsHasDoorPermission( pl, ent )
	local permissions = ent.GetNetVar( ent, "permissions", { } )
	local targetID = pl.GetCharacterID( pl )
	
	if ( permissions[ targetID ] ) then
		return true, permissions[ targetID ].permission or 0
	end
	
	return false, 0
end

function catherine.door.IsBuyableDoor( ent )
	return !ent.GetNetVar( ent, "cantBuy", false )
end

function catherine.door.IsDoorDisabled( ent )
	return ent.GetNetVar( ent, "disabled", false )
end