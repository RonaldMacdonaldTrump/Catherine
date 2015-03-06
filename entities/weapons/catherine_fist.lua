AddCSLuaFile( )

SWEP.Base = "catherine_base"
SWEP.HoldType = "fist"
SWEP.PrintName = "Fists"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV	= 52

SWEP.ViewModel	= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel	= ""

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
SWEP.Secondary.Delay = 0.15

SWEP.HitDistance = 48

SWEP.UseHands = false

function SWEP:Precache()
	util.PrecacheSound( "npc/vort/claw_swing1.wav" )
	util.PrecacheSound( "npc/vort/claw_swing2.wav" )
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard1.wav" )	
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard2.wav" )	
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard3.wav" )	
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard4.wav" )	
end

function SWEP:PrimaryAttack( )
	local pl = self.Owner
	if ( !IsFirstTimePredicted( ) ) then
		return
	end
	if ( CLIENT ) then
		return
	end
	local staminaDown = math.Clamp( catherine.character.GetCharData( pl, "stamina", 100 ) - 0, 0, 100 )
	if ( staminaDown < 10 ) then
		return
	else
		catherine.character.SetCharData( pl, "stamina", staminaDown )
		pl:SetAnimation( PLAYER_ATTACK1 )
		
		local viewModel = pl:GetViewModel( )
		viewModel:SendViewModelMatchingSequence( viewModel:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
		
		timer.Simple( 0.1, function( )
			local animTable = { "fists_left", "fists_right" }
			viewModel:SendViewModelMatchingSequence( viewModel:LookupSequence( table.Random( animTable ) ) )
		end )
		
		self:EmitSound( "npc/vort/claw_swing" .. math.random( 1, 2 ) .. ".wav" )
		pl:SendLua( "surface.PlaySound(\"npc/vort/claw_swing" .. math.random( 1, 2 ) .. ".wav\")" )
		
		timer.Simple( 0, function( )
			pl:LagCompensation( true )
			local trace = util.TraceLine( {
				start = pl:GetShootPos( ),
				endpos = pl:GetShootPos( ) + pl:GetAimVector( ) * self.HitDistance,
				filter = pl
			} )
			if ( trace.Hit ) then
				self:EmitSound( "Flesh.ImpactHard" )
				pl:SendLua( "surface.PlaySound( \"Flesh.ImpactHard\" )" )
				if ( trace.Entity:IsPlayer( ) ) then
					local damageInfo = DamageInfo( )
					damageInfo:SetAttacker( pl )
					damageInfo:SetInflictor( self )
					damageInfo:SetDamage( math.random( 8, 12 ) )
					trace.Entity:TakeDamageInfo( damageInfo )
				end
			end
			pl:LagCompensation( false )
		end )
	end
	self:SetNextPrimaryFire( CurTime( ) + self.Primary.Delay )
end

function SWEP:SecondaryAttack( )
	local pl = self.Owner
	if ( !IsFirstTimePredicted( ) ) then
		return
	end
	local trace = util.TraceLine( {
		start = pl:GetShootPos( ),
		endpos = pl:GetShootPos( ) + pl:GetAimVector( ) * self.HitDistance,
		filter = pl
	} )
	if ( trace.Hit and trace.Entity:IsDoor( ) ) then
		if ( trace.MatType == MAT_WOOD ) then
			self:EmitSound( "physics/wood/wood_box_impact_soft2.wav" )
		elseif ( trace.MatType == MAT_METAL ) then
			self:EmitSound( "physics/metal/metal_box_impact_soft2.wav" )
		else
			self:EmitSound( "physics/concrete/concrete_impact_soft3.wav" )
		end
	end
	self:SetNextSecondaryFire( CurTime( ) + self.Secondary.Delay )
end

function SWEP:Deploy()
	if ( !IsValid( self.Owner ) ) then
		return
	end

	local viewModel = self.Owner:GetViewModel()
	viewModel:SendViewModelMatchingSequence( viewModel:LookupSequence( "fists_draw" ) )
	
	timer.Simple( viewModel:SequenceDuration( ), function( ) 
		viewModel:SendViewModelMatchingSequence( viewModel:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
	end )
	
	return true
end

function SWEP:Initialize( )
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:CanPrimaryAttack( )
	return true
end

function SWEP:CanSecondaryAttack( )
	return true
end