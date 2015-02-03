AddCSLuaFile( )

SWEP.Base = "nexus_base"
SWEP.HoldType = "normal"
SWEP.PrintName = "Fists"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 5
SWEP.Primary.Delay = 0.75

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.UseHands = false

function SWEP:PreDrawViewModel(viewModel, weapon, pl)
	local hands = player_manager.RunClass( pl, "GetHandsModel" )

	if ( hands and hands.model ) then
		viewModel:SetModel( hands.model )
		viewModel:SetSkin( hands.skin )
		viewModel:SetBodyGroups( hands.body )
	end
end

function SWEP:Precache()
	util.PrecacheSound( "npc/vort/claw_swing1.wav" )
	util.PrecacheSound( "npc/vort/claw_swing2.wav" )
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard1.wav" )	
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard2.wav" )	
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard3.wav" )	
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard4.wav" )	
end

function SWEP:Reload( )
	if ( self:GetHoldType( ) == "normal" ) then
		self:SetHoldType( "fist" )
	else
		self:SetHoldType( "normal" )
	end
end

function SWEP:CanPrimaryAttack( )
	if ( self:IsValid( ) or self:GetHoldType( ) == "fist" ) then	
		return false			
	end
	return true	
end

function SWEP:PrimaryAttack( )
	if ( !IsFirstTimePredicted( ) ) then
		return
	end
	self:SetNextPrimaryFire( CurTime( ) + self.Primary.Delay )
	if ( self:GetHoldType( ) == "fist" ) then
		self:EmitSound( "npc/vort/claw_swing" .. math.random( 1, 2 ) .. ".wav" )
	else
		return false
	end
end

function SWEP:Deploy()
	if ( !IsValid( self.Owner ) ) then
		return
	end

	local viewModel = self.Owner:GetViewModel( )

	if ( IsValid( viewModel ) ) then
		viewModel:SetPlaybackRate( 1 )
		viewModel:ResetSequence( ACT_VM_FISTS_DRAW )
	end

	return true
end

function SWEP:Initialize( )
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:CanPrimaryAttack( )
	return false
end

function SWEP:CanSecondaryAttack( )
	return false
end