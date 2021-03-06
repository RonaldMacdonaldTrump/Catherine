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
PLUGIN.name = "^ACT_Plugin_Name"
PLUGIN.author = "L7D, Chessnut"
PLUGIN.desc = "^ACT_Plugin_Desc"
PLUGIN.actions = { }

catherine.language.Merge( "english", {
	[ "ACT_Plugin_Name" ] = "Action",
	[ "ACT_Plugin_Desc" ] = "Good stuff.",
	[ "ACT_Plugin_Notify_Cant01" ] = "You can't do this now!",
	[ "ACT_Plugin_Notify_Cant02" ] = "You can't do this action!",
	[ "ACT_Plugin_Notify_Cant03" ] = "Please action at the facing the wall and little bit a back at wall!",
	[ "ACT_Plugin_Notify_Cant04" ] = "Please action at the facing back the wall!"
} )

catherine.language.Merge( "korean", {
	[ "ACT_Plugin_Name" ] = "액션",
	[ "ACT_Plugin_Desc" ] = "RP 에 맞는 액션을 취할 수 있습니다.",
	[ "ACT_Plugin_Notify_Cant01" ] = "당신은 지금 액션을 취할 수 없습니다!",
	[ "ACT_Plugin_Notify_Cant02" ] = "당신은 이 액션을 취할 수 없습니다!",
	[ "ACT_Plugin_Notify_Cant03" ] = "벽을 보고 조금 벽에서 떨어진 후 액션을 다시 취하세요!",
	[ "ACT_Plugin_Notify_Cant04" ] = "벽을 등에 대고 액션을 다시 취하세요!"
} )

catherine.util.Include( "sh_actions.lua" )

if ( SERVER ) then
	function PLUGIN:StartAction( pl, seq )
		if ( pl:IsActioning( ) or !pl:Alive( ) or pl:IsRagdolled( ) ) then
			return false, "ACT_Plugin_Notify_Cant01"
		end

		if ( pl:IsTied( ) ) then
			return false, "Item_Notify03_ZT"
		end
		
		local class = catherine.animation.Get( pl:GetModel( ):lower( ) )
		local actionData = { }
		
		if ( self.actions[ seq ] ) then
			for k, v in pairs( self.actions[ seq ] ) do
				if ( k == "actions" ) then
					if ( v[ class ] ) then
						actionData = v[ class ]
					else
						return false, "ACT_Plugin_Notify_Cant02"
					end
				end
			end
		else
			return false
		end
		
		if ( actionData.OnCheck and type( actionData.OnCheck ) == "function" ) then
			local success, langKey = actionData.OnCheck( pl )
			
			if ( !success ) then
				return false, langKey
			end
		end
		
		pl:SetNetVar( "isActioning", true )
		pl:SetNetVar( "actionAngles", pl:GetAngles( ) )
		pl:SetMoveType( MOVETYPE_NONE )

		if ( actionData.doStartSeq ) then
			pl:SetNetVar( "doingAction", true )
			
			catherine.animation.SetSeqAnimation( pl, actionData.doStartSeq, pl:SequenceDuration( actionData.doStartSeq ), nil, function( )
				catherine.animation.SetSeqAnimation( pl, actionData.seq, actionData.noAutoExit and 0 or nil, function( )
					pl:SetNetVar( "doingAction", nil )
				end, function( )
					if ( actionData.doExitSeq ) then
						catherine.animation.SetSeqAnimation( pl, actionData.doExitSeq, pl:SequenceDuration( actionData.doExitSeq ), nil, function( )
							self:ExitAction( pl )
						end )
					end
				end )
			end )
		else
			catherine.animation.SetSeqAnimation( pl, actionData.seq, actionData.noAutoExit and 0 or nil, nil, function( )
				self:ExitAction( pl )
			end )
		end
		
		return true
	end
	
	function PLUGIN:ExitAction( pl )
		if ( !pl:IsActioning( ) ) then
			return false, "ACT_Plugin_Notify_Cant01"
		end
		
		local class = catherine.animation.Get( pl:GetModel( ):lower( ) )
		
		for k, v in pairs( self.actions ) do
			if ( v.actions ) then
				if ( v.actions[ class ] ) then
					local exitSeq = v.actions[ class ].doExitSeq

					if ( exitSeq ) then
						catherine.animation.SetSeqAnimation( pl, exitSeq, pl:SequenceDuration( exitSeq ), nil, function( )
							catherine.animation.ResetSeqAnimation( pl )
							pl:SetMoveType( MOVETYPE_WALK )
							pl:SetNetVar( "isActioning", nil )
							pl:SetNetVar( "actionAngles", nil )
						end )
					end
				else
					catherine.animation.ResetSeqAnimation( pl )
					pl:SetMoveType( MOVETYPE_WALK )
					pl:SetNetVar( "isActioning", nil )
					pl:SetNetVar( "actionAngles", nil )
					return
				end
			end
		end
	end
	
	function PLUGIN:PlayerDeath( pl )
		self:ExitAction( pl )
	end
	
	function PLUGIN:PlayerSpawnedInCharacter( pl )
		self:ExitAction( pl )
	end

	concommand.Add( "cat_action_exit", function( pl )
		PLUGIN:ExitAction( pl )
	end )
else
	function PLUGIN:PlayerBindPress( pl, bind, pressed )
		if ( pl:IsActioning( ) and bind == "+jump" ) then
			if ( pl:GetNetVar( "doingAction" ) and pl.CAT_leavingAction ) then
				pl.CAT_leavingAction = nil
				timer.Remove( "Catherine.plugin.action.timer.WaitAction" )
			else
				pl.CAT_leavingAction = true
				
				timer.Create( "Catherine.plugin.action.timer.WaitAction", 1, 1, function( )
					RunConsoleCommand( "cat_action_exit" )
				end )
			end
			
			return true
		end
	end
	
	function PLUGIN:CalcView( pl, pos, ang, fov )
		if ( pl:IsActioning( ) ) then
			local tr = util.TraceLine( {
				start = pos,
				endpos = pos - ( ang:Forward( ) * 100 ),
				filter = pl
			} )
		
			return {
				origin = tr.Fraction < 1 and ( tr.HitPos + tr.HitNormal * 5 ) or tr.HitPos,
				angles = ang,
				fov = fov
			}
		end
	end

	function PLUGIN:ShouldDrawLocalPlayer( pl )
		if ( pl:IsActioning( ) ) then
			return true
		end
	end
end

function PLUGIN:UpdateAnimation( pl, moveData )
	local ang = pl:GetNetVar( "actionAngles" )

	if ( ang ) then
		pl:SetRenderAngles( ang )
	end
end

local META = FindMetaTable( "Player" )

function META:IsActioning( )
	return self:GetNetVar( "isActioning" )
end

for k, v in pairs( PLUGIN.actions ) do
	catherine.command.Register( {
		uniqueID = "&uniqueID_" .. k,
		command = "act" .. k,
		runFunc = function( pl, args )
			local success, langKey = PLUGIN:StartAction( pl, k )

			if ( !success ) then
				catherine.util.NotifyLang( pl, langKey )
			end
		end
	} )
end