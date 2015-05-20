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

local PLUGIN = PLUGIN
PLUGIN.name = "^VED_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^VED_Plugin_Desc"
PLUGIN.randModels = { }
PLUGIN.VENDOR_SOLD_DISCOUNTPER = 2
local varsID = {
	"name",
	"desc",
	"factions",
	"classes",
	"inv",
	"cash",
	"setting",
	"status",
	"model"
}
CAT_VENDOR_ACTION_BUY = 1 // Buy from player
CAT_VENDOR_ACTION_SELL = 2 // Sell to player
CAT_VENDOR_ACTION_SETTING_CHANGE = 3
CAT_VENDOR_ACTION_ITEM_CHANGE = 4
CAT_VENDOR_ACTION_ITEM_UNCHANGE = 5

function PLUGIN:GetVendorDatas( ent )
	local data = { }

	for k, v in pairs( varsID ) do
		data[ v ] = ent:GetNetVar( v )
	end
	
	return data
end

function PLUGIN:GetVendorWorkingPlayers( )
	local players = { }

	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( !v:GetNetVar( "vendor_work" ) ) then continue end
		
		players[ #players + 1 ] = v
	end
	
	return players
end

catherine.language.Merge( "english", {
	[ "VED_Plugin_Name" ] = "Vendor",
	[ "VED_Plugin_Desc" ] = "Good stuff.",
	[ "Vendor_Notify_Buy" ] = "You are brought '%s' at '%s' from this vendor!",
	[ "Vendor_Notify_Sell" ] = "You are sold '%s' at '%s' from this vendor!",
	[ "Vendor_Notify_VendorNoHasCash" ] = "This vendor has not enough %s!",
	[ "Vendor_Notify_NoHasStock" ] = "This vendor don't have this kind of item anymore!",
	[ "Vendor_Notify_NotValid" ] = "This is not vendor!",
	[ "Vendor_Notify_Add" ] = "You are added vendor.",
	[ "Vendor_Notify_Remove" ] = "You are removed this vendor.",
	[ "Vendor_Message_CantUse" ] = "You don't have permission using this vendor!",
	[ "Vendor_NameQ" ] = "What are you want vendor name?"
} )

catherine.language.Merge( "korean", {
	[ "VED_Plugin_Name" ] = "상인",
	[ "VED_Plugin_Desc" ] = "맵에 NPC 상인을 추가합니다.",
	[ "Vendor_Notify_Buy" ] = "당신은 '%s' 를 '%s' 에 구입하였습니다.",
	[ "Vendor_Notify_Sell" ] = "당신은 '%s' 를 '%s' 에 파셨습니다.",
	[ "Vendor_Notify_VendorNoHasCash" ] = "이 상인은 %s 가 없습니다!",
	[ "Vendor_Notify_NoHasStock" ] = "이 상인은 재고가 없습니다!",
	[ "Vendor_Notify_NotValid" ] = "이것은 상인이 아닙니다!",
	[ "Vendor_Notify_Add" ] = "상인을 추가했습니다.",
	[ "Vendor_Notify_Remove" ] = "상인을 제거했습니다.",
	[ "Vendor_Message_CantUse" ] = "이 상인을 사용할 권한이 없습니다!",
	[ "Vendor_NameQ" ] = "상인의 이름을 무엇으로 하시겠습니까?"
} )

catherine.util.Include( "sv_plugin.lua" )
catherine.util.Include( "cl_plugin.lua" )

catherine.command.Register( {
	command = "vendoradd",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		catherine.util.StringReceiver( pl, "Vendor_SpawnFunc_Name", "^Vendor_NameQ", "Johnson", function( _, val )
			local pos, ang = pl:GetEyeTraceNoCursor( ).HitPos, pl:EyeAngles( )
			ang.p = 0
			ang.y = ang.y - 180
			
			local ent = ents.Create( "cat_vendor" )
			ent:SetPos( pos )
			ent:SetAngles( ang )
			ent:Spawn( )
			ent:Activate( )
			
			PLUGIN:MakeVendor( ent, { name = val } )
			PLUGIN:SaveVendors( )
			
			catherine.util.NotifyLang( pl, "Vendor_Notify_Add" )
		end )
	end
} )

catherine.command.Register( {
	command = "vendorremove",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity
		
		if ( IsValid( ent ) and ent:GetClass( ) == "cat_vendor" ) then
			ent:Remove( )
			catherine.util.NotifyLang( pl, "Vendor_Notify_Remove" )
		else
			catherine.util.NotifyLang( pl, "Vendor_Notify_NotValid" )
		end
	end
} )