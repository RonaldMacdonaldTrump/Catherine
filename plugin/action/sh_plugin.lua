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
PLUGIN.author = "L7D & Chessnut"
PLUGIN.desc = "^ACT_Plugin_Desc"
PLUGIN.actions = { }

catherine.language.Merge( "english", {
	[ "ACT_Plugin_Name" ] = "Action",
	[ "ACT_Plugin_Desc" ] = "Good stuff.",
} )

catherine.language.Merge( "korean", {
	[ "ACT_Plugin_Name" ] = "액션",
	[ "ACT_Plugin_Desc" ] = "RP 에 맞는 액션을 취할 수 있습니다.",
} )

catherine.util.Include( "sh_actions.lua" )
catherine.util.Include( "sh_commands.lua" )

if ( SERVER ) then
	function PLUGIN:StartAction( pl, seq )
		if ( pl.GetNetVar( pl, "isActioning" ) ) then
			return false
		end
		
		if ( !pl.Alive( pl ) ) then
			return false
		end
		
		if ( catherine.player.IsRagdolled( pl ) ) then
			return false
		end
		
		if ( catherine.player.IsTied( pl ) ) then
			return false
		end
		
		local class = catherine.animation.Get( pl.GetModel( pl ):lower( ) )
		local actionData = { }
		
		if ( self.actions[ seq ] ) then
			for k, v in pairs( self.actions[ seq ] ) do
				if ( k == "actions" ) then
					if ( v[ class ] ) then
						actionData = v[ class ]
					else
						return false
					end
				end
			end
		else
			return false
		end
		
		pl:SetNetVar( "isActioning", true )

		if ( actionData.doStartSeq ) then
			pl:SetNetVar( "doingAction", true )
			
			catherine.animation.SetSeqAnimation( pl, actionData.doStartSeq, pl.SequenceDuration( pl, actionData.doStartSeq ), nil, function( )
				catherine.animation.SetSeqAnimation( pl, actionData.seq, actionData.noAutoExit and 0 or nil, function( )
					pl:SetNetVar( "doingAction", nil )
				end, function( )
					if ( actionData.doExitSeq ) then
						catherine.animation.SetSeqAnimation( pl, actionData.doExitSeq, pl.SequenceDuration( pl, actionData.doExitSeq ), nil, function( )
							self:ExitAction( pl )
						end )
					end
				end )
			end )
		else
			catherine.animation.SetSeqAnimation( pl, actionData.seq, actionData.noAutoExit and 0 or nil, function( )
					
			end, function( )
				self:ExitAction( pl )
			end )
		end
		
		return true
	end
	
	function PLUGIN:ExitAction( pl )
		if ( !pl.GetNetVar( pl, "isActioning" ) ) then
			return
		end
		
		local class = catherine.animation.Get( pl.GetModel( pl ):lower( ) )
		
		for k, v in pairs( self.actions ) do
			if ( v.actions ) then
				if ( v.actions[ class ] ) then
					local exitSeq = v.actions[ class ].doExitSeq

					if ( exitSeq ) then
						catherine.animation.SetSeqAnimation( pl, exitSeq, pl.SequenceDuration( pl, exitSeq ), nil, function( )
							catherine.animation.ResetSeqAnimation( pl )
							pl:SetNetVar( "isActioning", nil )
						end )
					end
				else
					catherine.animation.ResetSeqAnimation( pl )
					pl:SetNetVar( "isActioning", nil )
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
	PLUGIN.AngData = Angle( 0, 0, 0 )
	PLUGIN.MouseSensitive = 20
	
	function PLUGIN:PlayerBindPress( pl, bind, pressed )
		if ( pl.GetNetVar( pl, "isActioning" ) and bind == "+jump" ) then
			if ( pl.GetNetVar( pl, "doingAction" ) and pl.CAT_leavingAction ) then
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
	
	function PLUGIN:InputMouseApply( command, x, y, ang )
		if ( LocalPlayer( ):GetNetVar( "isActioning" ) ) then
			self.AngData = self.AngData - Angle( -y / self.MouseSensitive, x / self.MouseSensitive, 0 )
			self.AngData.p = math.Clamp( self.AngData.p, -80, 80 )
		else
			self.AngData = Angle( 0, 0, 0 )
		end
	end
	
	function PLUGIN:CalcView( pl, pos, ang, fov )
		if ( pl.GetViewEntity( pl ) == pl and pl.GetNetVar( pl, "isActioning" ) ) then
			local la = pl.LookupAttachment( pl, "eyes" )
			
			if ( la == 0 ) then
				la = pl.LookupAttachment( pl, "eyes" )
			end
			
			local ga = pl.GetAttachment( pl, la ) 
			local newAng = Angle( 0, pl.GetAngles( pl ).y, 0 ) + self.AngData
			local data = util.TraceLine( {
				start = ga.Pos,
				endpos = ga.Pos + newAng.Forward( newAng ) * -80 + newAng.Up( newAng ) * 20 + newAng.Right( newAng ) * 0
			} )

			return {
				origin = data.HitPos + data.HitNormal * 4,
				angles = newAng
			}
		end
	end
end