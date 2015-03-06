AddCSLuaFile( )

SWEP.Base = "weapon_base"
SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

function SWEP:Initialize( )
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy( )
	return true
end

function SWEP:Holster( )
	return true
end

function SWEP:PrimaryAttack( )
end

function SWEP:SecondaryAttack( )
end

function SWEP:Reload( )
end

/*local addAngle = 0

function SWEP:GetViewModelPosition( pos, ang )
	if ( self:GetHoldType( ) == "normal" ) then
		addAngle = math.Clamp( addAngle + FrameTime( ), 0, 10 )
	else
		addAngle = math.Clamp( addAngle - FrameTime( ), 0, 10 )
	end
	return pos, ang + Angle( 0, addAngle, 0 )
end*/