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

local function facingWall( pl )
	local data = { }
	data.start = pl:GetPos( )
	data.endpos = data.start + pl:EyePos( ) * 100
	data.filter = pl
	local tr = util.TraceLine( data )

	if ( tr.HitWorld and pl:GetPos( ):Distance( tr.HitPos ) > 35 and pl:GetPos( ):Distance( tr.HitPos ) < 50 ) then
		return true
	else
		return false, "ACT_Plugin_Notify_Cant03"
	end
end

local function facingWallBack( pl )
	local data = { }
	data.start = pl:GetPos( )
	data.endpos = data.start - pl:GetAimVector( ) * 54
	data.filter = pl

	if ( util.TraceLine( data ).HitWorld ) then
		return true
	else
		return false, "ACT_Plugin_Notify_Cant04"
	end
end

PLUGIN.actions = {
	[ "sit" ] = {
		text = "Sit!",
		actions = {
			citizen_male = {
				seq = "sit_ground",
				noAutoExit = true,
				doStartSeq = "Idle_to_Sit_Ground",
				doExitSeq = "Sit_Ground_to_Idle"
			},
			citizen_felame = {
				seq = "sit_ground",
				noAutoExit = true,
				doStartSeq = "Idle_to_Sit_Ground",
				doExitSeq = "Sit_Ground_to_Idle"
			}
		}
	},
	[ "sitwall" ] = {
		text = "Sit Wall!",
		actions = {
			citizen_male = {
				seq = "plazaidle4",
				noAutoExit = true,
				OnCheck = facingWallBack
			},
			citizen_felame = {
				seq = "plazaidle4",
				noAutoExit = true,
				OnCheck = facingWallBack
			}
		}
	},
	[ "cheer" ] = {
		text = "Cheer!",
		actions = {
			citizen_male = {
				seq = "cheer1"
			},
			citizen_felame = {
				seq = "cheer1"
			}
		}
	},
	[ "stand" ] = {
		text = "Stand!",
		actions = {
			citizen_male = {
				seq = "lineidle01",
				noAutoExit = true
			},
			citizen_felame = {
				seq = "lineidle01",
				noAutoExit = true
			},
			metrocop = {
				seq = "plazathreat2",
				noAutoExit = true
			}
		}
	},
	[ "here" ] = {
		text = "Here!",
		actions = {
			citizen_male = {
				seq = "wave"
			},
			citizen_felame = {
				seq = "wave"
			}
		}
	},
	[ "comehere" ] = {
		text = "Come here!",
		actions = {
			citizen_male = {
				seq = "wave_close"
			},
			citizen_felame = {
				seq = "wave_close"
			}
		}
	},
	[ "arrest" ] = {
		text = "Arrest!",
		actions = {
			citizen_male = {
				seq = "apcarrestidle",
				noAutoExit = true,
				OnCheck = facingWall
			}
		}
	}
}