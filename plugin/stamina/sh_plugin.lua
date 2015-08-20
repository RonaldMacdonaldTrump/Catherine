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
PLUGIN.name = "^ST_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^ST_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "ST_Plugin_Name" ] = "Stamina",
	[ "ST_Plugin_Desc" ] = "Good stuff.",
	[ "Stamina_Title" ] = "Stamina",
	[ "Stamina_Desc" ] = "How long you can run for."
} )

catherine.language.Merge( "korean", {
	[ "ST_Plugin_Name" ] = "기력",
	[ "ST_Plugin_Desc" ] = "RP 를 위한 기력 플러그인 입니다.",
	[ "Stamina_Title" ] = "기력",
	[ "Stamina_Desc" ] = "높을 수록 장시간을 달릴 수 있습니다."
} )

if ( SERVER ) then
	function PLUGIN:PlayerDeath( pl )
		catherine.character.SetCharVar( pl, "stamina", 100 )
	end
	
	function PLUGIN:GetCustomPlayerDefaultRunSpeed( pl )
		local stamina = catherine.character.GetCharVar( pl, "stamina", 100 )
		
		if ( math.Round( stamina ) <= 10 or pl.CAT_staminaRegaining ) then
			if ( math.Round( stamina ) >= 100 ) then
				pl.CAT_staminaRegaining = nil
				return
			end
			
			pl.CAT_staminaRegaining = true
			
			return pl:GetWalkSpeed( )
		end
	end

	function PLUGIN:PlayerThink( pl )
		if ( pl:IsNoclipping( ) ) then return end
		local curTime = CurTime( )
		
		if ( pl:IsRunning( ) ) then
			if ( ( pl.CAT_nextStaminaDown or 0 ) <= curTime ) then
				local staminaDown = math.Clamp(
					catherine.character.GetCharVar( pl, "stamina", 100 ) - ( 3 + ( 7 * ( 1 - ( catherine.attribute.GetProgress( pl, CAT_ATT_STAMINA ) / 100 ) ) ) ),
					0,
					100
				) // Old : ( -10 + math.min( catherine.attribute.GetProgress( pl, CAT_ATT_STAMINA ) * 0.25, 7.5 ) )
				
				if ( math.Round( staminaDown ) < 5 ) then
					catherine.attribute.AddProgress( pl, CAT_ATT_STAMINA, 0.8 )
					
					if ( ( pl.CAT_nextBreathingSound or 0 ) <= curTime ) then
						catherine.util.PlayAdvanceSound( pl, "ST_BreathingSound", "player/breathe1.wav", 100 )
						pl.CAT_isBreathing = true
						pl.CAT_nextBreathingSound = CurTime( ) + 1
					end
				else
					catherine.character.SetCharVar( pl, "stamina", staminaDown )
				end
				
				pl.CAT_nextStaminaDown = CurTime( ) + 1.5
			end
		else
			if ( ( pl.CAT_nextStaminaUp or 0 ) <= CurTime( ) ) then
				local staminaUp = math.Clamp( catherine.character.GetCharVar( pl, "stamina", 100 ) + 5, 0, 100 )
				
				if ( staminaUp > 30 and pl.CAT_isBreathing ) then
					catherine.util.StopAdvanceSound( pl, "ST_BreathingSound", 5 )
					pl.CAT_isBreathing = nil
				end
				
				if ( staminaUp != catherine.character.GetCharVar( pl, "stamina", 100 ) ) then
					catherine.character.SetCharVar( pl, "stamina", staminaUp )
				end
				
				pl.CAT_nextStaminaUp = CurTime( ) + 3
			end
		end
	end
else
	do
		catherine.bar.Register( "stamina", false, function( pl )
				return catherine.character.GetCharVar( pl, "stamina", 100 )
			end, function( pl )
				return 100
			end, Color( 0, 206, 209 )
		)
	end
end