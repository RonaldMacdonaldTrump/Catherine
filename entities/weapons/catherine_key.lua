AddCSLuaFile( )

SWEP.Base = "catherine_base"
SWEP.HoldType = "normal"
SWEP.PrintName = "Key"
SWEP.ViewModel = "models/weapons/v_punch.mdl"
SWEP.WorldModel = ""
SWEP.AlwaysLowered = true
SWEP.CanFireLowered = true
SWEP.DrawHUD = false

function SWEP:Deploy( )
	local pl = self.Owner
	if ( CLIENT or !IsValid( pl ) ) then return true end
	
	pl:DrawWorldModel( false )
	pl:DrawViewModel( false )
	
	return true
end

function SWEP:Initialize( )
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack( )
	if ( !IsFirstTimePredicted( ) ) then return end
	if ( CLIENT ) then return end
	
	local pl = self.Owner
	local ent = pl:GetEyeTrace( 70 ).Entity
	
	if ( !ent:IsDoor( ) or ent.Locked ) then return end
	if ( ent:GetDoorOwner( ) != pl or pl:GetPos( ):Distance( ent:GetPos( ) ) > 100 ) then return end
	
	catherine.util.ProgressBar( pl, "You are locking this door.", 4 )
	
	pl:Freeze( true )
	
	timer.Simple( 4, function( )
		ent.Locked = true
		ent:Fire( "lock" )
		ent:EmitSound( "doors/door_latch3.wav" )
		pl:Freeze( false )
	end )
	
	self:SetNextPrimaryFire( CurTime( ) + 4 )
end

function SWEP:SecondaryAttack( )
	if ( !IsFirstTimePredicted( ) ) then return end
	if ( CLIENT ) then return end
	
	local pl = self.Owner
	local ent = pl:GetEyeTrace( 70 ).Entity
	
	if ( !ent:IsDoor( ) or !ent.Locked ) then return end
	if ( ent:GetDoorOwner( ) != pl or pl:GetPos( ):Distance( ent:GetPos( ) ) > 100 ) then return end
	
	catherine.util.ProgressBar( pl, "You are unlocking this door.", 4 )
	
	pl:Freeze( true )
	
	timer.Simple( 4, function( )
		ent.Locked = false
		ent:Fire( "unlock" )
		ent:EmitSound( "doors/door_latch3.wav" )
		pl:Freeze( false )
	end )
	
	self:SetNextSecondaryFire( CurTime( ) + 4 )
end