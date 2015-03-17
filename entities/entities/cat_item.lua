AddCSLuaFile( )

DEFINE_BASECLASS( "base_gmodentity" )

ENT.Type = "anim"
ENT.PrintName = "Catherine Item"
ENT.Author = "L7D"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if ( SERVER ) then
	function ENT:Initialize( )
		self:SetModel( "models/props_junk/watermelon01.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:SetHealth( 40 )
		
		local physObject = self:GetPhysicsObject( )
		if ( IsValid( physObject ) ) then
			physObject:EnableMotion( true )
			physObject:Wake( )
		end
		self:PhysicsInitBox( Vector( -2, -2, -2 ), Vector( 2, 2, 2 ) )
	end

	function ENT:InitializeItem( itemID, itemData )
		//if ( !itemTable ) then catherine.util.ErrorPrint( "Failed to initialize item entity! [ cat_item.lua ]" ) return end
		self:SetNetVar( "uniqueID", itemID )
		self:SetNetVar( "itemData", itemData )
	end

	function ENT:Use( pl )
		netstream.Start( pl, "catherine.item.EntityUseMenu", { self, self:GetItemUniqueID( ) } )
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

function ENT:GetItemTable( )
	return catherine.item.FindByID( self:GetItemUniqueID( ) )
end

function ENT:GetItemUniqueID( )
	return self:GetNetVar( "uniqueID", nil )
end

function ENT:GetItemData( )
	return self:GetNetVar( "itemData", { } )
end