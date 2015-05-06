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
	if ( !IsFirstTimePredicted( ) or CLIENT ) then return end
	local pl = self.Owner
	local ent = pl:GetEyeTrace( 70 ).Entity

	if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) or ent.CAT_doorLocked ) then return end
	local has, flag = catherine.door.IsHasDoorPermission( pl, ent )
	if ( !has or flag == 0 ) then return end
	
	pl:Freeze( true )
	catherine.util.ProgressBar( pl, LANG( pl, "Door_Message_Locking" ), 2, function( )
		if ( IsValid( ent ) ) then
			ent.CAT_doorLocked = true
			ent:Fire( "Lock" )
			ent:EmitSound( "doors/door_latch3.wav" )
		end
		pl:Freeze( false )
	end )

	self:SetNextPrimaryFire( CurTime( ) + 4 )
end

function SWEP:SecondaryAttack( )
	if ( !IsFirstTimePredicted( ) or CLIENT ) then return end
	local pl = self.Owner
	local ent = pl:GetEyeTrace( 70 ).Entity
	
	if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) or !ent.CAT_doorLocked ) then return end
	local has, flag = catherine.door.IsHasDoorPermission( pl, ent )
	if ( !has or flag == 0 ) then return end
	
	pl:Freeze( true )
	catherine.util.ProgressBar( pl, LANG( pl, "Door_Message_UnLocking" ), 2, function( )
		if ( IsValid( ent ) ) then
			ent.CAT_doorLocked = false
			ent:Fire( "Unlock" )
			ent:EmitSound( "doors/door_latch3.wav" )
		end
		pl:Freeze( false )
	end )
	
	self:SetNextSecondaryFire( CurTime( ) + 4 )
end