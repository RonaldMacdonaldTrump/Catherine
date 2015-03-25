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
	local toscreen = FindMetaTable("Vector").ToScreen
	function ENT:DrawEntityTargetID( pl, _, a )
		local pos = toscreen( self:LocalToWorld( self:OBBCenter( ) ) )
		local x, y, x2, y2 = pos.x, pos.y
		local itemTable = self:GetItemTable( )
		if ( !itemTable ) then return end
		local customDesc = itemTable.GetDesc and itemTable:GetDesc( pl, itemTable, self:GetItemData( ) ) or nil
		
		draw.SimpleText( itemTable.name, "catherine_outline25", x, y, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( itemTable.desc, "catherine_outline15", x, y + 25, Color( 255, 255, 255, a ), 1, 1 )
		if ( customDesc ) then
			draw.SimpleText( customDesc, "catherine_outline15", x, y + 45, Color( 255, 255, 255, a ), 1, 1 )
		end
	end
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