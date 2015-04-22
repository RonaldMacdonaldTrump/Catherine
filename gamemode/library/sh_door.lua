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

catherine.door = catherine.door or { }

CAT_DOOR_CHANGEPERMISSION = 1
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
		
		if ( workID == CAT_DOOR_CHANGEPERMISSION ) then
			if ( !catherine.door.IsDoorOwner( pl, ent, CAT_DOOR_FLAG_OWNER ) ) then
				print( "you are not owner")
				return
			end
			
			local permissions = ent:GetNetVar( "permissions" )
			
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
			
			if ( has and flag == data[ 2 ] ) then
				print("Already has")
				return
			end
			
			permissions[ #permissions + 1 ] = {
				id = target:GetCharacterID( ),
				permission = data[ 2 ]
			}

			ent:SetNetVar( "permissions", permissions )
			print("Fin!")
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

		if ( ent:GetNetVar( "permissions" ) ) then
			return false, "Door_Notify_AlreadySold"
		end
		
		local cost = catherine.door.GetDoorCost( pl, ent )
		if ( !catherine.cash.Has( pl, cost ) ) then
			return false, "Cash_Notify_HasNot"
		end
		
		catherine.cash.Take( pl, cost )
		ent:SetNetVar( "permissions", {
			{
				id = pl:GetCharacterID( ),
				permission = CAT_DOOR_FLAG_OWNER
			}
		} )
		
		print("Fin")
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
	
	function catherine.door.SetDoorStatus( pl, ent )
		local curStatus = ent:GetNetVar( "cantBuy", false )
		
		if ( curStatus ) then
			ent:SetNetVar( "cantBuy", false )
			
			return true, "Door_Notify_SetStatus_False"
		else
			ent:SetNetVar( "cantBuy", true )
			
			return true, "Door_Notify_SetStatus_True"
		end
	end
	
	function catherine.door.DoorSpamProtection( pl, ent )
		local steamID = pl:SteamID( )
		
		if ( !pl.CAT_lastDoor ) then
			pl.CAT_lastDoor = ent
		end
		
		pl.CAT_doorSpamCount = pl.CAT_doorSpamCount + 1 or 1
		
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
			local title = v:GetNetVar( "title", "Door" )
			local cantBuy = v:GetNetVar( "cantBuy", false )
			if ( title == "Door" or !cantBuy ) then continue end
			
			data[ #data + 1 ] = {
				title = title,
				cantBuy = cantBuy,
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
					v:SetNetVar( "cantBuy", v1.cantBuy )
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

	function catherine.door.GetDetailString( ent )
		local owner = ent:GetNetVar( "permissions" )
		
		if ( owner ) then
			return LANG( "Door_Message_AlreadySold" )
		elseif ( !owner and catherine.door.IsBuyableDoor( ent ) ) then
			return LANG( "Door_Message_Buyable" )
		else
			return LANG( "Door_Message_CantBuy" )
		end
	end

	function catherine.door.CalcDoorTextPos( ent, rev )
		local max = ent:OBBMaxs( )
		local min = ent:OBBMins( )
		
		local data = { }
		data.endpos = ent:LocalToWorld( ent:OBBCenter( ) )
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
				data.start = data.endpos - ( ent:GetUp( ) * len )
			else
				data.start = data.endpos + ( ent:GetUp( ) * len )
			end
		elseif ( size.x < size.y ) then
			len = size.x
			w = size.y
			
			if ( rev ) then
				data.start = data.endpos - ( ent:GetForward( ) * len )
			else
				data.start = data.endpos + ( ent:GetForward( ) * len )
			end
		elseif ( size.y < size.x ) then
			len = size.y
			w = size.x
			
			if ( rev ) then
				data.start = data.endpos - ( ent:GetRight( ) * len )
			else
				data.start = data.endpos + ( ent:GetRight( ) * len )
			end
		end

		local tr = util.TraceLine( data )

		if ( tr.HitWorld and !rev ) then
			return catherine.door.CalcDoorTextPos( ent, true )
		end

		local ang = tr.HitNormal:Angle( )
		local pos = tr.HitPos - ( ( ( data.endpos - tr.HitPos ):Length( ) * 2 ) + 2 ) * tr.HitNormal
		local angBack = tr.HitNormal:Angle( )
		local posBack = tr.HitPos + ( tr.HitNormal * 2 )
		
		ang:RotateAroundAxis( ang:Forward( ), 90 )
		ang:RotateAroundAxis( ang:Right( ), 90 )
		angBack:RotateAroundAxis( angBack:Forward( ), 90 )
		angBack:RotateAroundAxis( angBack:Right( ), -90 )
		
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
	for k, v in pairs( ent:GetNetVar( "permissions", { } ) ) do
		if ( !v.id != pl:GetCharacterID( ) ) then continue end
		
		return flag == v.permission
	end
	
	return false
end

function catherine.door.IsHasDoorPermission( pl, ent )
	for k, v in pairs( ent:GetNetVar( "permissions", { } ) ) do
		if ( !v.id != pl:GetCharacterID( ) ) then continue end
		
		return true, v.permission
	end
	
	return false
end

function catherine.door.IsBuyableDoor( ent )
	return !ent:GetNetVar( "cantBuy", false )
end