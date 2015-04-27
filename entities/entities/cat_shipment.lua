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

AddCSLuaFile( )

DEFINE_BASECLASS( "base_gmodentity" )

ENT.Type = "anim"
ENT.PrintName = "Catherine Shipment"
ENT.Author = "L7D"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if ( SERVER ) then
	function ENT:Initialize( )
		self:SetModel( "models/Items/item_item_crate.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:PrecacheGibs( )
		
		local physObject = self.GetPhysicsObject( self )
		if ( IsValid( physObject ) ) then
			physObject:EnableMotion( true )
			physObject:Wake( )
		end
	end
	
	function ENT:InitializeShipment( pl, shipLists )
		self:SetNetVar( "owner", pl:GetCharacterID( ) )
		self:SetNetVar( "shipLists", shipLists )
	end

	function ENT:Use( pl )
		if ( pl:GetCharacterID( ) != self:GetNetVar( "owner", 0 ) ) then
			catherine.util.NotifyLang( pl, "Business_Notify_CantOpenShipment" )
			return
		end
		
		netstream.Start( pl, "catherine.business.EntityUseMenu", self:EntIndex( ) )
	end
	
	function ENT:OnRemove( )
		local eff = EffectData( )
		eff:SetStart( self.GetPos( self ) )
		eff:SetOrigin( self.GetPos( self ) )
		eff:SetScale( 8 )
		util.Effect( "GlassImpact", eff, true, true )
		self:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav" )
	end
else
	local toscreen = FindMetaTable( "Vector" ).ToScreen
	
	function ENT:DrawEntityTargetID( pl, ent, a )
		local pos = toscreen( self.LocalToWorld( self, self.OBBCenter( self ) ) )
		local x, y = pos.x, pos.y
		
		draw.SimpleText( LANG( "Business_UI_Shipment_Title" ), "catherine_outline25", x, y, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( LANG( "Business_UI_Shipment_Desc" ), "catherine_outline15", x, y + 25, Color( 255, 255, 255, a ), 1, 1 )
	end
end

function ENT:GetOwner( )
	return self:GetNetVar( "owner", 0 )
end

function ENT:GetShipLists( )
	return self:GetNetVar( "shipLists", { } )
end