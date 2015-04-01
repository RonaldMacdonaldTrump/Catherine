--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

AddCSLuaFile( )

SWEP.PrintName = "Fists"
SWEP.HoldType = "normal"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.DrawHUD = false
SWEP.ViewModel = Model( "models/weapons/c_arms_cstrike.mdl" )
SWEP.WorldModel	= ""
SWEP.ViewModelFOV = 50

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 5
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Delay = 0.5

SWEP.HitDistance = 48
SWEP.LowerAngles = Angle( 0, 5, -15 )
SWEP.UseHands = false

function SWEP:Precache( )
	util.PrecacheSound( "npc/vort/claw_swing1.wav" )
	util.PrecacheSound( "npc/vort/claw_swing2.wav" )
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard1.wav" )	
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard2.wav" )	
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard3.wav" )	
	util.PrecacheSound( "physics/plastic/plastic_box_impact_hard4.wav" )	
end

function SWEP:PreDrawViewModel( viewMdl, wep, pl )
	local fists = player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( pl:GetModel( ) ) )
	if ( fists and fists.model ) then
		viewMdl:SetModel( fists.model )
		viewMdl:SetSkin( fists.skin )
		viewMdl:SetBodyGroups( fists.body )
	end
end

function SWEP:PrimaryAttack( )
	if ( !IsFirstTimePredicted( ) or CLIENT ) then return end
	local pl = self.Owner
	local stamina = math.Clamp( catherine.character.GetCharacterVar( pl, "stamina", 100 ) - 10, 0, 100 )
	if ( !pl:GetWeaponRaised( ) or stamina < 10 ) then
		return
	end
	catherine.character.SetCharacterVar( pl, "stamina", stamina )
	
	pl:SetAnimation( PLAYER_ATTACK1 )
	
	local viewModel = pl:GetViewModel( )
	viewModel:SendViewModelMatchingSequence( viewModel:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
	
	timer.Simple( 0.1, function( )
		viewModel:SendViewModelMatchingSequence( viewModel:LookupSequence( table.Random( { "fists_left", "fists_right" } ) ) )
	end )
	
	self:EmitSound( "npc/vort/claw_swing" .. math.random( 1, 2 ) .. ".wav" )
	pl:SendLua( "surface.PlaySound(\"npc/vort/claw_swing" .. math.random( 1, 2 ) .. ".wav\")" )
	
	pl:LagCompensation( true )
	local tr = util.TraceLine( {
		start = pl:GetShootPos( ),
		endpos = pl:GetShootPos( ) + pl:GetAimVector( ) * self.HitDistance,
		filter = pl
	} )
	
	if ( tr.Hit ) then
		self:EmitSound( "Flesh.ImpactHard" )
		pl:SendLua( "surface.PlaySound( \"Flesh.ImpactHard\" )" )
		if ( tr.Entity:IsPlayer( ) ) then
			local damageInfo = DamageInfo( )
			damageInfo:SetAttacker( pl )
			damageInfo:SetInflictor( self )
			damageInfo:SetDamage( math.random( 8, 12 ) )
			tr.Entity:TakeDamageInfo( damageInfo )
		end
	end
	pl:LagCompensation( false )
	
	self:SetNextPrimaryFire( CurTime( ) + self.Primary.Delay )
end

function SWEP:SecondaryAttack( )
	if ( !IsFirstTimePredicted( ) ) then return end
	local pl = self.Owner
	local tr = util.TraceLine( {
		start = pl:GetShootPos( ),
		endpos = pl:GetShootPos( ) + pl:GetAimVector( ) * self.HitDistance,
		filter = pl
	} )
	
	if ( tr.Hit and tr.Entity:IsDoor( ) ) then
		self:EmitSound( "physics/wood/wood_crate_impact_hard2.wav" )
	end
	
	self:SetNextSecondaryFire( CurTime( ) + self.Secondary.Delay )
end

function SWEP:Deploy( )
	if ( !IsValid( self.Owner ) ) then return end

	local viewModel = self.Owner:GetViewModel()
	viewModel:SendViewModelMatchingSequence( viewModel:LookupSequence( "fists_draw" ) )
	
	timer.Simple( viewModel:SequenceDuration( ), function( ) 
		viewModel:SendViewModelMatchingSequence( viewModel:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
	end )
	
	return true
end

function SWEP:Initialize( )
	self:SetHoldType( self.HoldType )
	self.LastHand = 0
end