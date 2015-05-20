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
PLUGIN.name = "^SP_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^SP_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "SP_Plugin_Name" ] = "Static Prop",
	[ "SP_Plugin_Desc" ] = "Good stuff.",
	[ "Staticprop_Notify_Add" ] = "You are added this entity in static props.",
	[ "Staticprop_Notify_Remove" ] = "You are removed this entity in static props.",
	[ "Staticprop_Notify_IsNotProp" ] = "This entity is not prop!"
} )

catherine.language.Merge( "korean", {
	[ "SP_Plugin_Name" ] = "고정식 프롭",
	[ "SP_Plugin_Desc" ] = "프롭이 영구적으로 저장되게 할 수 있습니다.",
	[ "Staticprop_Notify_Add" ] = "당신은 이 물체를 고정식 프롭에 추가했습니다.",
	[ "Staticprop_Notify_Remove" ] = "당신은 이 물체의 고정식 프롭 설정을 해제했습니다.",
	[ "Staticprop_Notify_IsNotProp" ] = "이 물체는 프롭이 아닙니다!"
} )

catherine.command.Register( {
	command = "staticprop",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity

		if ( IsValid( ent ) ) then
			if ( catherine.entity.IsProp( ent ) and !catherine.entity.IsDoor( ent ) ) then
				local curStatus = ent:GetNetVar( "isStatic", false )
				
				ent:SetNetVar( "isStatic", !curStatus )
				
				if ( curStatus ) then
					catherine.util.NotifyLang( pl, "Staticprop_Notify_Add" )
				else
					catherine.util.NotifyLang( pl, "Staticprop_Notify_Remove" )
				end
				
				PLUGIN:DataSave( )
			else
				catherine.util.NotifyLang( pl, "Staticprop_Notify_IsNotProp" )
			end
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotValid" )
		end
	end
} )

if ( CLIENT ) then return end

function PLUGIN:DataSave( )
	local data = { }
	
	for k, v in pairs( ents.GetAll( ) ) do
		if ( !v:GetNetVar( "isStatic" ) ) then continue end
		
		data[ #data + 1 ] = v
	end
	
	if ( #data == 0 ) then return end
	local persistentData = duplicator.CopyEnts( data )
	
	if ( persistentData ) then
		catherine.data.Set( "staticprops", persistentData )
	end
end

function PLUGIN:DataLoad( )
	local data = catherine.data.Get( "staticprops" )
	if ( !data ) then return end
	
	local ents, consts = duplicator.Paste( nil, data.Entities or { }, data.Contraints or { } )
	
	for k, v in pairs( ents ) do
		v:SetNetVar( "isStatic", true )
	end
end