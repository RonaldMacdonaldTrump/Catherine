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
PLUGIN.name = "^Legs_Plugin_Name"
PLUGIN.author = "Chessnut" // Thx!
PLUGIN.desc = "^Legs_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "Legs_Plugin_Name" ] = "Legs",
	[ "Legs_Plugin_Desc" ] = "Increases 'immersion' by adding legs.",
	[ "Option_Str_LEG_Name" ] = "Show Legs",
	[ "Option_Str_LEG_Desc" ] = "Show legs on your body."
} )

catherine.language.Merge( "korean", {
	[ "Legs_Plugin_Name" ] = "다리",
	[ "Legs_Plugin_Desc" ] = "캐릭터 밑에 다리를 표시합니다.",
	[ "Option_Str_LEG_Name" ] = "캐릭터 다리 표시",
	[ "Option_Str_LEG_Desc" ] = "캐릭터 밑에 다리를 표시합니다."
} )

if ( SERVER ) then return end

CAT_CONVAR_LEGS = CreateClientConVar( "cat_convar_legs", "1", true, true )
catherine.option.Register( "CONVAR_LEGS", "cat_convar_legs", "^Option_Str_LEG_Name", "^Option_Str_LEG_Desc", "^Option_Category_01", CAT_OPTION_SWITCH )

local HIDDEN_BONES = {
	"ValveBiped.Bip01_Spine1",
	"ValveBiped.Bip01_Spine2",
	"ValveBiped.Bip01_Spine4",
	"ValveBiped.Bip01_Neck1",
	"ValveBiped.Bip01_Head1",
	"ValveBiped.forward",
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Anim_Attachment_RH",
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Anim_Attachment_LH",
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
	"ValveBiped.Bip01_R_Finger02",
	"ValveBiped.baton_parent"
}

function PLUGIN:CreateLeg( )
	if ( !CAT_CONVAR_LEGS.GetBool( CAT_CONVAR_LEGS ) ) then
		return
	end

	if ( IsValid( self.legEntity ) ) then
		self.legEntity:Remove( )
	end

	self.legEntity = ClientsideModel( LocalPlayer( ).GetModel( LocalPlayer( ) ), 10 )

	if ( IsValid( self.legEntity ) ) then
		for k, v in pairs( HIDDEN_BONES ) do
			local index = self.legEntity.LookupBone( self.legEntity, v )
			if ( !index ) then continue end
			
			self.legEntity:ManipulateBoneScale( index, vector_origin )
			self.legEntity:ManipulateBonePosition( index, Vector( -100, -100, 0 ) )
		end

		self.legEntity:SetNoDraw( true )
		self.legEntity:SetIK( false )
	end
end

function PLUGIN:Think( )
	local pl = LocalPlayer( )

	if ( IsValid( pl ) and CAT_CONVAR_LEGS:GetBool( CAT_CONVAR_LEGS ) ) then
		if ( !IsValid( self.legEntity ) or ( IsValid( self.legEntity ) and self.legEntity.GetModel( self.legEntity ) != pl.GetModel( pl ) ) ) then
			self:CreateLeg( )
		end
	end
end

function PLUGIN:PostDrawViewModel( )
	if ( CAT_CONVAR_LEGS.GetBool( CAT_CONVAR_LEGS ) and IsValid( self.legEntity ) ) then
		local pl = LocalPlayer( )
		local rt = RealTime( )
		local ang = pl.GetAngles( pl )

		ang.p = 0
		ang.r = 0

		self.legEntity:SetPos( pl.GetPos( pl ) + pl.GetForward( pl ) * 15 + pl.GetUp( pl ) * -17 )
		self.legEntity:SetSequence( pl.GetSequence( pl ) )
		self.legEntity:SetAngles( ang )
		self.legEntity:SetPoseParameter( "move_yaw", 360 * pl.GetPoseParameter( pl, "move_yaw" ) - 180 )
		self.legEntity:SetPoseParameter( "move_x", pl.GetPoseParameter( pl, "move_x" ) * 2 - 1 )
		self.legEntity:SetPoseParameter( "move_y", pl.GetPoseParameter( pl, "move_y" ) * 2 - 1 )
		self.legEntity:FrameAdvance( rt - ( self.lastRT or rt ) )
		self.legEntity:DrawModel( )

		self.lastRT = rt
	end
end