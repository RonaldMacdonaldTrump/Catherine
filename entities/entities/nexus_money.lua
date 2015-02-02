AddCSLuaFile()

ENT.Type = "anim"

function ENT:Initialize()
	if CLIENT then return end
	
	self:SetModel( nexus.configs.moneyModel )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	phys:Wake()
end

function ENT:Use(activator)
	local amt = math.random( 100, 500 )

	activator:AddMoney(amt)

	GAMEMODE:Notify(activator, 2, 5, "You got a " .. amt .. nexus.configs.moneyName .. "s!" )

	self:Remove()
end