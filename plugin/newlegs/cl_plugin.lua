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
		if not pl:Alive() then
			self:CreateLegs( )
			return
		end
			
        if IsValid( self.LegEnt ) then
			
            if LocalPlayer():GetActiveWeapon() != self.OldWeapon then
                self.OldWeapon = LocalPlayer():GetActiveWeapon()
                self:WeaponChanged( self.OldWeapon )
            end

                     
            if self.LegEnt:GetModel() != self:FixModelName( LocalPlayer():GetModel() ) then
                self.LegEnt:SetModel( self:FixModelName( LocalPlayer():GetModel() ) )
            end
             
            self.LegEnt:SetMaterial( LocalPlayer():GetMaterial() )
            self.LegEnt:SetSkin( LocalPlayer():GetSkin() )
     
            self.Velocity = LocalPlayer():GetVelocity():Length2D()
             
            self.PlaybackRate = 1
     
            if self.Velocity > 0.5 then
                if maxseqgroundspeed < 0.001 then
                    self.PlaybackRate = 0.01
                else
                    self.PlaybackRate = self.Velocity / maxseqgroundspeed
                    self.PlaybackRate = math.Clamp( self.PlaybackRate, 0.01, 10 )
                end
            end
             
            self.LegEnt:SetPlaybackRate( self.PlaybackRate )
             
            self.Sequence = LocalPlayer():GetSequence()
             
            if ( self.LegEnt.Anim != self.Sequence ) then
                self.LegEnt.Anim = self.Sequence
                self.LegEnt:ResetSequence( self.Sequence )
            end
             
            self.LegEnt:FrameAdvance( CurTime() - self.LegEnt.LastTick )
            self.LegEnt.LastTick = CurTime()
             
            Legs.BreathScale = sharpeye and sharpeye.GetStamina and math.Clamp( math.floor( sharpeye.GetStamina() * 5 * 10 ) / 10, 0.5, 5 ) or 0.5
             
            if Legs.NextBreath <= CurTime() then
                Legs.NextBreath = CurTime() + 1.95 / Legs.BreathScale
                self.LegEnt:SetPoseParameter( "breathing", Legs.BreathScale )
            end
             
            self.LegEnt:SetPoseParameter( "move_x", ( LocalPlayer():GetPoseParameter( "move_x" ) * 2 ) - 1 )
            self.LegEnt:SetPoseParameter( "move_y", ( LocalPlayer():GetPoseParameter( "move_y" ) * 2 ) - 1 )
            self.LegEnt:SetPoseParameter( "move_yaw", ( LocalPlayer():GetPoseParameter( "move_yaw" ) * 360 ) - 180 )
            self.LegEnt:SetPoseParameter( "body_yaw", ( LocalPlayer():GetPoseParameter( "body_yaw" ) * 180 ) - 90 )
            self.LegEnt:SetPoseParameter( "spine_yaw",( LocalPlayer():GetPoseParameter( "spine_yaw" ) * 180 ) - 90 )
             
            if ( LocalPlayer():InVehicle() ) then
                self.LegEnt:SetColor( color_transparent )
                self.LegEnt:SetPoseParameter( "vehicle_steer", ( LocalPlayer():GetVehicle():GetPoseParameter( "vehicle_steer" ) * 2 ) - 1 )
            end
        end
    end