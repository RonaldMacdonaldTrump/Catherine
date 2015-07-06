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

local TOOL = catherine.tool.New( "cat_staticprop" )

TOOL.Category = "Catherine"
TOOL.Name = "Static Prop"
TOOL.Desc = "Add / Remove on Static prop."
TOOL.HelpText = "Left Click : Add / Remove on Static prop."
TOOL.UniqueID = "cat_staticprop"

function TOOL:LeftClick( trace )
	if ( CLIENT ) then return true end

	local pl = self:GetOwner( )
	local ent = trace.Entity

	local staticPropPlugin = catherine.plugin.Get( "staticprop" )
	
	if ( staticPropPlugin ) then
		if ( IsValid( ent ) ) then
			if ( ent:IsProp( ) and !ent:IsDoor( ) ) then
				local curStatus = ent:GetNetVar( "isStatic" )

				ent:SetNetVar( "isStatic", !curStatus )

				catherine.util.NotifyLang( pl, !curStatus and "Staticprop_Notify_Add" or "Staticprop_Notify_Remove" )
				
				staticPropPlugin:DataSave( )
				
				return true
			else
				catherine.util.NotifyLang( pl, "Staticprop_Notify_IsNotProp" )
				
				return false
			end
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotValid" )
			
			return false
		end
	else
		return false
	end
	
	return true
end

function TOOL:RightClick( trace )
	return false
end

if ( CLIENT ) then
	function TOOL.BuildCPanel( pnl )
		pnl:AddControl( "Header", {
			Text = "Add / Remove on the Static prop.",
			Description	= "Add / Remove on the Static prop."
		} )
	end
end

catherine.tool.Register( TOOL )