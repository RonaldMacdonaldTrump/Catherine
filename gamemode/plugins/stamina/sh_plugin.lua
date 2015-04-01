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

local PLUGIN = PLUGIN
PLUGIN.name = "Stamina"
PLUGIN.author = "L7D"
PLUGIN.desc = "Good stuff."

if ( SERVER ) then
	function PLUGIN:PlayerSpawnedInCharacter( pl )
		local stamina = catherine.character.GetCharacterVar( pl, "stamina", 100 )
		catherine.character.SetCharacterVar( pl, "stamina", stamina )
	end
	
	function PLUGIN:PlayerDeath( pl )
		catherine.character.SetCharacterVar( pl, "stamina", 100 )
	end

	function PLUGIN:Think( )
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( v:GetMoveType( ) == MOVETYPE_NOCLIP ) then continue end
			if ( !v.nextStaminaDown or !v.nextStaminaUp ) then
				v.nextStaminaDown = CurTime( ) + 1
				v.nextStaminaUp = CurTime( ) + 3
			end
			if ( v:IsRunning( ) and v.nextStaminaDown <= CurTime( ) ) then
				local staminaDown = math.Clamp( catherine.character.GetCharacterVar( v, "stamina", 100 ) + ( -10 + math.min( ( catherine.attribute.GetProgress( v, CAT_ATT_STAMINA ) ) * 0.25, 7.5 ) ), 0, 100 )
				if ( math.Round( staminaDown ) < 5 ) then
					v.runSpeed = v:GetRunSpeed( )
					v:SetRunSpeed( v:GetWalkSpeed( ) )
					catherine.attribute.AddProgress( v, CAT_ATT_STAMINA, 0.05 )
				else
					catherine.character.SetCharacterVar( v, "stamina", staminaDown )
				end
				v.nextStaminaDown = CurTime( ) + 1
			else
				if ( v.nextStaminaUp <= CurTime( ) ) then
					local staminaUp = math.Clamp( catherine.character.GetCharacterVar( v, "stamina", 100 ) + 5, 0, 100 )
					if ( staminaUp >= 100 ) then
						v:SetRunSpeed( catherine.configs.playerDefaultRunSpeed )
					end
					
					if ( staminaUp != catherine.character.GetCharacterVar( v, "stamina", 100 ) ) then
						catherine.character.SetCharacterVar( v, "stamina", staminaUp )
					end
					v.nextStaminaUp = CurTime( ) + 3
				end
			end
		end
	end
else
	do
		catherine.bar.Register( function( )
			return catherine.character.GetCharacterVar( LocalPlayer( ), "stamina", 100 )
		end, function( )
			return 100
		end, Color( 0, 206, 209 ), "stamina" )
	end
end

CAT_ATT_STAMINA = catherine.attribute.Register( "stamina", "Stamina", "How long you can run for.", "CAT/attribute/stamina.png", 0, 100 )