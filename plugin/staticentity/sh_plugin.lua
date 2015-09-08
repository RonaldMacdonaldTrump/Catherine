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
PLUGIN.name = "^StaticE_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^StaticE_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "StaticE_Notify_Add" ] = "You are added this entity in static props.",
	[ "StaticE_Notify_Remove" ] = "You are removed this entity in static props.",
	[ "StaticE_Notify_IsNotProp" ] = "This entity is not prop!",
	[ "StaticE_Plugin_Name" ] = "Static Prop",
	[ "StaticE_Plugin_Desc" ] = "Good stuff."
} )

catherine.language.Merge( "korean", {
	[ "StaticE_Notify_Add" ] = "당신은 이 물체를 고정식 프롭에 추가했습니다.",
	[ "StaticE_Notify_Remove" ] = "당신은 이 물체의 고정식 프롭 설정을 해제했습니다.",
	[ "StaticE_Notify_IsNotProp" ] = "이 물체는 프롭이 아닙니다!",
	[ "StaticE_Plugin_Name" ] = "고정식 프롭",
	[ "StaticE_Plugin_Desc" ] = "프롭이 영구적으로 저장되게 할 수 있습니다.",
} )

catherine.util.Include( "sv_plugin.lua" )

catherine.command.Register( {
	uniqueID = "&uniqueID_staticEntity",
	command = "staticentity",
	desc = "Add / Remove the Static Entity list.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity

		if ( IsValid( ent ) ) then
			if ( ent:IsProp( ) and !ent:IsDoor( ) ) then
				local curStatus = ent:GetNetVar( "isStatic" )

				ent:SetNetVar( "isStatic", !curStatus )

				catherine.util.NotifyLang( pl, !curStatus and "StaticE_Notify_Add" or "StaticE_Notify_Remove" )
				
				PLUGIN:DataSave( )
			else
				catherine.util.NotifyLang( pl, "StaticE_Notify_IsNotProp" )
			end
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotValid" )
		end
	end
} )