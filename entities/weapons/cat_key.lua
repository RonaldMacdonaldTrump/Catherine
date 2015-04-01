--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Develop by L7D.

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

SWEP.HoldType = "normal"
SWEP.PrintName = "Key"
SWEP.ViewModel = Model( "models/weapons/c_arms_cstrike.mdl" )
SWEP.WorldModel = ""
SWEP.AlwaysLowered = true
SWEP.CanFireLowered = true
SWEP.DrawHUD = false

function SWEP:PreDrawViewModel( viewMdl, wep, pl )
	local fists = player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( pl:GetModel( ) ) )
	if ( fists and fists.model ) then
		viewMdl:SetModel( fists.model )
		viewMdl:SetSkin( fists.skin )
		viewMdl:SetBodyGroups( fists.body )
	end
end

function SWEP:Deploy( )
	local pl = self.Owner
	if ( CLIENT or !IsValid( pl ) ) then return true end
	
	pl:DrawWorldModel( false )
	pl:DrawViewModel( false )
	
	return true
end

function SWEP:Initialize( )
	self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack( )
	if ( !IsFirstTimePredicted( ) ) then return end
	if ( CLIENT ) then return end
	
	local pl = self.Owner
	local ent = pl:GetEyeTrace( 70 ).Entity
	
	if ( !ent:IsDoor( ) or ent.Locked ) then return end
	if ( catherine.door.GetDoorOwner( ent ) != pl or pl:GetPos( ):Distance( ent:GetPos( ) ) > 100 ) then return end
	
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
	if ( catherine.door.GetDoorOwner( ent ) != pl or pl:GetPos( ):Distance( ent:GetPos( ) ) > 100 ) then return end
	
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