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
	util.PrecacheSound( "physics/wood/wood_crate_impact_hard2.wav" )
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
	local stamina = catherine.character.GetCharVar( pl, "stamina", 100 )
	if ( !pl:GetWeaponRaised( ) or stamina < 10 ) then
		return
	end
	
	local tr = { }
	tr.start = pl:GetShootPos( )
	tr.endpos = tr.start + pl:GetAimVector( ) * self.HitDistance
	tr.filter = pl
		
	local ent = util.TraceLine( tr ).Entity
	
	catherine.character.SetCharVar( pl, "stamina", stamina - 5 )
	
	pl:SetAnimation( PLAYER_ATTACK1 )
	
	local viewMdl = pl:GetViewModel( )
	viewMdl:SendViewModelMatchingSequence( viewMdl:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
	
	timer.Simple( 0.1, function( )
		viewMdl:SendViewModelMatchingSequence( viewMdl:LookupSequence( table.Random( { "fists_left", "fists_right" } ) ) )
	end )

	pl:EmitSound( "npc/vort/claw_swing" .. math.random( 1, 2 ) .. ".wav" )
	pl:LagCompensation( true )

	if ( IsValid( ent ) ) then
		pl:EmitSound( "Flesh.ImpactHard" )

		if ( ent:IsPlayer( ) ) then
			local dmgInfo = DamageInfo( )
			dmgInfo:SetAttacker( pl )
			dmgInfo:SetInflictor( self )
			dmgInfo:SetDamage( math.random( 8, 12 ) )
			ent:TakeDamageInfo( dmgInfo )
		end
	end
	
	pl:LagCompensation( false )
	self:SetNextPrimaryFire( CurTime( ) + self.Primary.Delay )
end

function SWEP:SecondaryAttack( )
	if ( !IsFirstTimePredicted( ) ) then return end
	local pl = self.Owner
	local ent = util.TraceLine( {
		start = pl:GetShootPos( ),
		endpos = pl:GetShootPos( ) + pl:GetAimVector( ) * self.HitDistance,
		filter = pl
	} ).Entity
	
	if ( IsValid( ent ) and catherine.entity.IsDoor( ent ) ) then
		self:EmitSound( "physics/wood/wood_crate_impact_hard2.wav", math.random( 50, 100 ) )
	end
	
	self:SetNextSecondaryFire( CurTime( ) + self.Secondary.Delay )
end

function SWEP:Deploy( )
	if ( !IsValid( self.Owner ) ) then return end

	local viewMdl = self.Owner:GetViewModel()
	viewMdl:SendViewModelMatchingSequence( viewMdl:LookupSequence( "fists_draw" ) )
	
	timer.Simple( viewMdl:SequenceDuration( ), function( ) 
		viewMdl:SendViewModelMatchingSequence( viewMdl:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
	end )
	
	return true
end

function SWEP:Initialize( )
	self:SetHoldType( self.HoldType )
end