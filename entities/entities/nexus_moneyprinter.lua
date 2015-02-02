
AddCSLuaFile( )

ENT.Type = "anim"

function ENT:Initialize( )
	if ( CLIENT ) then return end
	
	self:SetModel( "models/props_c17/consolebox01a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	local phys = self:GetPhysicsObject( )
	phys:Wake( )
	
	self.spawnTime = 5
	self.curTime = CurTime( ) + self.spawnTime
end

function ENT:SpawnMoney( )
	local money = ents.Create( "nexus_money" )
	money:SetPos( self:GetPos( ) + self:GetUp( ) * 16 )
	money:SetAngles( self:GetAngles( ) )
	money:Spawn( )
end

function ENT:Think( )
	if ( CLIENT ) then return end
	
	if self.curTime <= CurTime( ) then
		self:SpawnMoney( )
		self.curTime = CurTime( ) + self.spawnTime
	end
	
	self:NextThink( CurTime( ) )
	return true
end