AddCSLuaFile( )

DEFINE_BASECLASS( "base_gmodentity" )

ENT.PrintName = "Catherine Item"
ENT.Author = "L7D, Fristet"
ENT.Type = "anim"

if ( SERVER ) then
	function ENT:Initialize()
		self:SetModel( "models/props_junk/watermelon01.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:SetHealth( 100 )
		
		local physicsObject = self:GetPhysicsObject( )

		if ( IsValid( physicsObject ) ) then
			physicsObject:EnableMotion( true )
			physicsObject:Wake( )
		else
			self:PhysicsInitBox( Vector( -2, -2, -2 ), Vector( 2, 2, 2 ) )
		end
	end
	
	function ENT:SetItemUniqueID( id )
		catherine.network.SetNetVar( self, "itemUniqueID", id )
	end

	function ENT:Use( pl )
		netstream.Start( pl, "catherine.item.EntityUseMenu", { self, self.itemID } )
	end
	
	function ENT:Bomb( )
		local eff = EffectData( )
		eff:SetStart( self:GetPos( ) )
		eff:SetOrigin( self:GetPos( ) )
		eff:SetScale( 8 )
		util.Effect( "GlassImpact", eff, true, true )
		
		self:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav" )
	end

	function ENT:OnTakeDamage( dmg )
		self:SetHealth( math.max( self:Health( ) - dmg:GetDamage( ), 0 ) )
		
		if ( self:Health( ) <= 0 ) then
			self:Bomb( )
			self:Remove( )
		end
	end
else

end

function ENT:GetItemUniqueID( )
	return self:GetNetworkValue( "itemUniqueID", nil )
end