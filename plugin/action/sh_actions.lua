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

CAT_ACT_STARTANI = 1
CAT_ACT_EXITANI = 2

local actionTable = {
	[ "sit" ] = {
		catText = "Sit!",
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
	}
}

PLUGIN.actions = actionTable