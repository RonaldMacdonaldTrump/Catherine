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
		
		local physObject = self:GetPhysicsObject( )
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
			catherine.util.Notify( pl, "You can't open this shipment!" )
			return
		end
		netstream.Start( pl, "catherine.business.EntityUseMenu", self:EntIndex( ) )
	end
	
	function ENT:OnRemove( )
		local eff = EffectData( )
		eff:SetStart( self:GetPos( ) )
		eff:SetOrigin( self:GetPos( ) )
		eff:SetScale( 8 )
		util.Effect( "GlassImpact", eff, true, true )
		self:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav" )
	end
else
	local toscreen = FindMetaTable("Vector").ToScreen
	function ENT:DrawEntityTargetID( pl, ent, a )
		if ( ent:GetClass( ) != "cat_shipment" ) then return end
		local pos = toscreen( self:LocalToWorld( self:OBBCenter( ) ) )
		local x, y = pos.x, pos.y
		
		draw.SimpleText( "Shipment", "catherine_outline25", x, y, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( "The Shipment", "catherine_outline15", x, y + 25, Color( 255, 255, 255, a ), 1, 1 )
	end
end

function ENT:GetOwner( )
	return self:GetNetVar( "owner", 0 )
end

function ENT:GetShipLists( )
	return self:GetNetVar( "shipLists", { } )
end