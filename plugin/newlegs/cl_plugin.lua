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

local PLUGIN = PLUGIN
PLUGIN.legEnt = PLUGIN.legEnt or nil
PLUGIN.playBackRate = 1
PLUGIN.sequence = nil
PLUGIN.velocity = 0
PLUGIN.oldWeapon = nil
PLUGIN.holdType = nil
PLUGIN.boneHoldTypes = {
	[ "none" ] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
	[ "default" ] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
		"ValveBiped.Bip01_L_Hand",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Upperarm",
		"ValveBiped.Bip01_L_Clavicle",
		"ValveBiped.Bip01_R_Hand",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Upperarm",
		"ValveBiped.Bip01_R_Clavicle",
		"ValveBiped.Bip01_L_Finger4",
		"ValveBiped.Bip01_L_Finger41",
		"ValveBiped.Bip01_L_Finger42",
		"ValveBiped.Bip01_L_Finger3",
		"ValveBiped.Bip01_L_Finger31",
		"ValveBiped.Bip01_L_Finger32",
		"ValveBiped.Bip01_L_Finger2",
		"ValveBiped.Bip01_L_Finger21",
		"ValveBiped.Bip01_L_Finger22",
		"ValveBiped.Bip01_L_Finger1",
		"ValveBiped.Bip01_L_Finger11",
		"ValveBiped.Bip01_L_Finger12",
		"ValveBiped.Bip01_L_Finger0",
		"ValveBiped.Bip01_L_Finger01",
		"ValveBiped.Bip01_L_Finger02",
		"ValveBiped.Bip01_R_Finger4",
		"ValveBiped.Bip01_R_Finger41",
		"ValveBiped.Bip01_R_Finger42",
		"ValveBiped.Bip01_R_Finger3",
		"ValveBiped.Bip01_R_Finger31",
		"ValveBiped.Bip01_R_Finger32",
		"ValveBiped.Bip01_R_Finger2",
		"ValveBiped.Bip01_R_Finger21",
		"ValveBiped.Bip01_R_Finger22",
		"ValveBiped.Bip01_R_Finger1",
		"ValveBiped.Bip01_R_Finger11",
		"ValveBiped.Bip01_R_Finger12",
		"ValveBiped.Bip01_R_Finger0",
		"ValveBiped.Bip01_R_Finger01",
		"ValveBiped.Bip01_R_Finger02"
	},
	[ "vehicle" ] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	}
}
PLUGIN.bonesToRemove = { }
PLUGIN.boneMatrix = nil

local META = FindMetaTable( "Player" )

function META:ShouldDrawLegs( )
	return IsValid( PLUGIN.legEnt ) and
	self:Alive( ) and
	!self:InVehicle( ) and
	self:GetViewEntity( ) == self and
	!self:ShouldDrawLocalPlayer( ) and
	!self:GetObserverTarget( )
end

function PLUGIN:CreateLegs( )
	local pl = catherine.pl
	
	local legEnt = ClientsideModel( pl:GetModel( ), RENDER_GROUP_OPAQUE_ENTITY )
	legEnt:SetNoDraw( true )
	legEnt:SetSkin( pl:GetSkin( ) or 0 )
	legEnt:SetMaterial( pl:GetMaterial( ) )
	legEnt:SetColor( pl:GetColor( ) )
	
	local bodyGroups = string.Explode( " ", pl:GetBodyGroups( ) or "" )
	
	for i = 0, pl:GetNumBodyGroups( ) - 1 do
		legEnt:SetBodygroup( i, tonumber( bodyGroups[ i + 1 ] ) or 0 )
	end
	
	legEnt.GetPlayerColor = function( )
		return Vector( GetConVarString( "cl_playercolor" ) )
	end
	
	legEnt.lastTick = 0
	
	self.legEnt = legEnt
end

PLUGIN.breathScale = 0.5
PLUGIN.nextBreath = 0

function PLUGIN:LegsWork( pl, speed )
	if ( !pl:Alive( ) ) then
		self:CreateLegs( )
		return
	end
	
	if ( !IsValid( self.legEnt ) ) then return end
	local legEnt = self.legEnt
	local curTime = CurTime( )
	
	if ( pl:GetActiveWeapon( ) != self.oldWeapon ) then
		self.oldWeapon = pl:GetActiveWeapon( )
		self:PlayerWeaponChanged( self.oldWeapon )
	end
	
	if ( legEnt:GetModel( ) != pl:GetModel( ) ) then
		legEnt:SetModel( pl:GetModel( ) )
	end
	
	if ( legEnt:GetMaterial( ) != pl:GetMaterial( ) ) then
		legEnt:SetMaterial( pl:GetMaterial( ) )
	end
	
	if ( legEnt:GetSkin( ) != pl:GetSkin( ) ) then
		legEnt:SetSkin( pl:GetSkin( ) )
	end
	
	self.velocity = pl:GetVelocity( ):Length2D( )
	self.playBackRate = 1
	
	if ( self.velocity > 0.5 ) then
		self.playBackRate = speed < 0.001 and 0.01 or math.Clamp( self.velocity / speed, 0.01, 10 )
	end
	
	legEnt:SetPlaybackRate( self.playBackRate )
	self.sequence = pl:GetSequence( )
	
	if ( legEnt.Anim != self.sequence ) then
		legEnt.Anim = self.sequence // Change?
		legEnt:ResetSequence( self.sequence )
	end
	
	legEnt:FrameAdvance( curTime - legEnt.lastTick )
	legEnt.lastTick = curTime // Change?
	//self.breathScale = sharpeye and sharpeye.GetStamina and math.Clamp( math.floor( sharpeye.GetStamina() * 5 * 10 ) / 10, 0.5, 5 ) or 0.5
	
	if ( self.nextBreath <= curTime ) then
		self.nextBreath = curTime + 1.95 / self.breathScale
		self.legEnt:SetPoseParameter( "breathing", self.breathScale )
	end
	
	legEnt:SetPoseParameter( "move_x", ( pl:GetPoseParameter( "move_x" ) * 2 ) - 1 )
	legEnt:SetPoseParameter( "move_y", ( pl:GetPoseParameter( "move_y" ) * 2 ) - 1 )
	legEnt:SetPoseParameter( "move_yaw", ( pl:GetPoseParameter( "move_yaw" ) * 360 ) - 180 )
	legEnt:SetPoseParameter( "body_yaw", ( pl:GetPoseParameter( "body_yaw" ) * 180 ) - 90 )
	legEnt:SetPoseParameter( "spine_yaw",( pl:GetPoseParameter( "spine_yaw" ) * 180 ) - 90 )
	
	if ( pl:InVehicle( ) ) then
		legEnt:SetColor( color_transparent )
		legEnt:SetPoseParameter( "vehicle_steer", ( pl:GetVehicle( ):GetPoseParameter( "vehicle_steer" ) * 2 ) - 1 )
	end
end