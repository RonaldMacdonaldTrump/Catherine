AddCSLuaFile( )

DEFINE_BASECLASS( "base_gmodentity" )

ENT.PrintName = "Nexus Money"
ENT.Author = "L7D, Fristet"
ENT.Type = "anim"

function ENT:Initialize( )
	if ( CLIENT ) then return end
	
	self:SetModel( nexus.configs.cashModel )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetHealth( 20 )
	
	self:SetUseType( SIMPLE_USE )
	
	local phys = self:GetPhysicsObject( )
	phys:Wake( )
end

function ENT:SetCash( amount )
	if ( amount == 0 ) then
		self:Remove( )
		return
	end
	self:SetNetworkValue( "Cash", amount )
end
--[[
function ENT:GetCash( )
	return self:GetNetworkValue( "Cash", 0 )
end
--]]
function ENT:Use( activator )
	activator:GiveCash( self:GetNetworkValue( "Cash", 0 ) )
	activator:ChatPrint( "You got a " .. nexus.cash.GetName( self:GetNetworkValue( "Cash", 0 ) ) .. "s!" )
	self:Bomb( )
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