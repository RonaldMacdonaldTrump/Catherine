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

catherine.recognize = catherine.recognize or { }
// 참고 : 이 라이브러리는 최적화가 필요함;

if ( SERVER ) then
	function catherine.recognize.DoKnow( pl, code, target )
		target = { target } or nil

		if ( code == 0 and !target ) then
			target = catherine.chat.GetListener( pl, "ic" )
		elseif ( code == 1 ) then
			target = catherine.chat.GetListener( pl, "whisper" )
		elseif ( code == 2 ) then
			target = catherine.chat.GetListener( pl, "yell" )
		end

		for k, v in pairs( target or { } ) do
			if ( !IsValid( v ) or v == pl ) then continue end
			
			catherine.recognize.RegisterKnowDouble( pl, v )
		end
	end
	
	function catherine.recognize.RegisterKnowSingle( pl, target )
		local recognizeLists = catherine.character.GetCharVar( pl, "recognize", { } )
		
		recognizeLists[ #recognizeLists + 1 ] = target:GetCharacterID( )
		
		catherine.character.SetCharVar( pl, "recognize", recognizeLists )
	end
	
	function catherine.recognize.RegisterKnowDouble( pl, target )
		local player_recognizeLists = catherine.character.GetCharVar( pl, "recognize", { } )
		local target_recognizeLists = catherine.character.GetCharVar( target, "recognize", { } )
		
		player_recognizeLists[ #player_recognizeLists + 1 ] = target:GetCharacterID( )
		target_recognizeLists[ #target_recognizeLists + 1 ] = pl:GetCharacterID( )
		
		catherine.character.SetCharVar( pl, "recognize", player_recognizeLists )
		catherine.character.SetCharVar( target, "recognize", target_recognizeLists )
	end
	
	function catherine.recognize.Initialize( pl )
		catherine.character.SetCharVar( pl, "recognize", { } )
	end

	function GM:GetUnknownTargetName( pl, target )
		return LANG( pl, "Recognize_UI_Unknown" )
	end

	function catherine.recognize.PlayerDeath( pl )
		catherine.recognize.Initialize( pl )
	end
	
	hook.Add( "PlayerDeath", "catherine.recognize.PlayerDeath", catherine.recognize.PlayerDeath )
	
	netstream.Hook( "catherine.recognize.DoKnow", function( pl, data )
		catherine.recognize.DoKnow( pl, data[ 1 ], data[ 2 ] )
	end )
else
	netstream.Hook( "catherine.recognize.SelectMenu", function( )
		local menu = DermaMenu( )
		
		menu:AddOption( LANG( "Recognize_UI_Option_LookingPlayer" ), function( )
			local ent = LocalPlayer( ):GetEyeTrace( 70 ).Entity
			
			if ( IsValid( ent ) ) then
				netstream.Start( "catherine.recognize.DoKnow", { 0, ent } )
			else
				catherine.notify.Add( LANG( "Entity_Notify_NotPlayer" ), 5 )
			end
		end )
		
		menu:AddOption( LANG( "Recognize_UI_Option_TalkRange" ), function( )
			netstream.Start( "catherine.recognize.DoKnow", { 0 } )
		end )
		
		menu:AddOption( LANG( "Recognize_UI_Option_WhisperRange" ), function( )
			netstream.Start( "catherine.recognize.DoKnow", { 1 } )
		end )
		
		menu:AddOption( LANG( "Recognize_UI_Option_YellRange" ), function( )
			netstream.Start( "catherine.recognize.DoKnow", { 2 } )
		end )
		
		Menu:Open( )
		Menu:Center( )
	end )

	function GM:GetUnknownTargetName( pl, target )
		return LANG( "Recognize_UI_Unknown" )
	end
end

function catherine.recognize.IsKnowTarget( pl, target )
	local factionTable = catherine.faction.FindByIndex( target:Team( ) )
	
	if ( factionTable and factionTable.alwaysRecognized ) then
		return true
	end

	return table.HasValue( catherine.character.GetCharVar( pl, "recognize", { } ), target:GetCharacterID( ) )
end

local META = FindMetaTable( "Player" )

function META:IsKnow( target )
	return catherine.recognize.IsKnowTarget( self, target )
end

function GM:GetPlayerInformation( pl, target )
	if ( pl == target ) then
		return target:Name( ), target:Desc( )
	end
	
	if ( pl:IsKnow( target ) ) then
		return target:Name( ), target:Desc( )
	end
	
	return hook.Run( "GetUnknownTargetName", pl, target ), target:Desc( )
end
