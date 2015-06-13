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
SWEP.PrintName = "^Weapon_Key_Name"
SWEP.Instructions = "^Weapon_Key_Instructions"
SWEP.Purpose = "^Weapon_Key_Purpose"
SWEP.Author = "L7D"
SWEP.ViewModel = Model( "models/weapons/c_arms_cstrike.mdl" )
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
	self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack( )
	if ( !IsFirstTimePredicted( ) or CLIENT ) then return end
	local pl = self.Owner
	
	local data = { }
	data.start = pl:GetShootPos( )
	data.endpos = data.start + pl:GetAimVector( ) * 40
	data.filter = pl
	local ent = util.TraceLine( data ).Entity

	if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) or ent.CAT_doorLocked ) then return end
	local has, flag = catherine.door.IsHasDoorPermission( pl, ent )
	
	if ( !has or flag == 0 ) then return end
	
	pl:Freeze( true )
	
	local time = hook.Run( "GetLockTime", pl ) or 2

	catherine.util.ProgressBar( pl, LANG( pl, "Door_Message_Locking" ), time, function( )
		if ( !IsValid( pl ) or !pl:Alive( ) ) then return end
		
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
	
	local data = { }
	data.start = pl:GetShootPos( )
	data.endpos = data.start + pl:GetAimVector( ) * 40
	data.filter = pl
	local ent = util.TraceLine( data ).Entity
	
	if ( !IsValid( ent ) or !catherine.entity.IsDoor( ent ) or !ent.CAT_doorLocked ) then return end
	local has, flag = catherine.door.IsHasDoorPermission( pl, ent )
	
	if ( !has or flag == 0 ) then return end
	
	local time = hook.Run( "GetUnlockTime", pl ) or 2
	
	pl:Freeze( true )
	
	catherine.util.ProgressBar( pl, LANG( pl, "Door_Message_UnLocking" ), time, function( )
		if ( !IsValid( pl ) or !pl:Alive( ) ) then return end
		
		if ( IsValid( ent ) ) then
			ent.CAT_doorLocked = false
			ent:Fire( "Unlock" )
			ent:EmitSound( "doors/door_latch3.wav" )
		end
		
		pl:Freeze( false )
	end )
	
	self:SetNextSecondaryFire( CurTime( ) + 4 )
end