AddCSLuaFile( )

DEFINE_BASECLASS( "base_gmodentity" )

ENT.Type = "anim"
ENT.PrintName = "Catherine Money"
ENT.Author = "L7D"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if ( SERVER ) then
	function ENT:Initialize( )
		self:SetModel( catherine.configs.cashModel )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetHealth( 20 )
		self:SetUseType( SIMPLE_USE )
		
		local physObject = self:GetPhysicsObject( )
		if ( IsValid( physObject ) ) then
			physObject:EnableMotion( true )
			physObject:Wake( )
		end
	end

	function ENT:SetCash( int )
		int = tonumber( int )
		if ( int <= 0 ) then
			self:Remove( )
			return
		end
		self:SetNetVar( "cash", int )
	end

	function ENT:Use( activator )
		catherine.cash.Give( activator, self:GetCash( ) )
		catherine.util.Notify( activator, "You got a " .. catherine.cash.GetName( self:GetCash( ) ) .. "." )
		self:Remove( )
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

function ENT:GetCash( )
	return self:GetNetVar( "cash", 0 )
end