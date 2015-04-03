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

function GM:ShowTeam( pl )
	netstream.Start( pl, "catherine.ShowTeam" )
end

if ( SERVER ) then
	function catherine.recognize.DoKnow( pl, talkCode, target )
		target = target or { }
		
		local classTab = catherine.chat.FindByClass( talkCode )
		if ( !classTab or ( classTab and !classTab.canHearRange ) ) then return end
		
		if ( type( target ) == "table" ) then
			for k, v in pairs( player.GetAll( ) ) do
				if ( !v:IsCharacterLoaded( ) ) then continue end
				if ( !v:Alive( ) or v == pl ) then continue end
				if ( pl:GetPos( ):Distance( v:GetPos( ) ) <= classTab.canHearRange and !catherine.recognize.IsKnowTarget( pl, v ) ) then
					target[ #target + 1 ] = v
				end
			end
		end

		if ( type( target ) == "table" ) then
			for k, v in pairs( target ) do
				if ( !IsValid( v ) ) then continue end
				catherine.recognize.DoDataSave( pl, v )
				catherine.recognize.DoDataSave( v, pl )
			end
		elseif ( type( target ) == "Player" ) then
			catherine.recognize.DoDataSave( pl, target )
			catherine.recognize.DoDataSave( target, pl )
		end
	end
	
	function catherine.recognize.DoDataSave( pl, target )
		if ( catherine.recognize.IsKnowTarget( pl, target ) ) then return end
		local recognizeLists = catherine.character.GetCharacterVar( pl, "recognize", { } )
		if ( type( target ) == "table" ) then
			for k, v in pairs( target ) do
				recognizeLists[ #recognizeLists + 1 ] = v:GetCharacterID( )
			end
		elseif ( type( target ) == "Player" ) then
			recognizeLists[ #recognizeLists + 1 ] = target:GetCharacterID( )
		end
		
		catherine.character.SetCharacterVar( pl, "recognize", recognizeLists )
	end
	
	function catherine.recognize.Init( pl )
		catherine.character.SetCharacterVar( pl, "recognize", { } )
	end
	
	netstream.Hook( "catherine.recognize.DoKnow", function( pl, data )
		catherine.recognize.DoKnow( pl, data[ 1 ], data[ 2 ] or nil )
	end )
	
	hook.Add( "PlayerDeath", "catherine.recognize.PlayerDeath", function( pl )
		catherine.recognize.Init( pl )
	end )
else
	netstream.Hook( "catherine.ShowTeam", function( )
		local Menu = DermaMenu( )
		Menu:AddOption( "Recognize for looking player.", function( )
			local ent = LocalPlayer( ):GetEyeTrace( 70 ).Entity
			if ( IsValid( ent ) ) then
				netstream.Start( "catherine.recognize.DoKnow", { "ic", ent } )
			else
				catherine.notify.Add( "Please look player!", 5 )
			end
		end )
		Menu:AddOption( "All characters within talking range", function( )
			netstream.Start( "catherine.recognize.DoKnow", { "ic" } )
		end )
		Menu:AddOption( "All characters within whispering range.", function( )
			netstream.Start( "catherine.recognize.DoKnow", { "whisper" } )
		end )
		Menu:AddOption( "All characters within yelling range.", function( )
			netstream.Start( "catherine.recognize.DoKnow", { "yell" } )
		end )
		Menu:Open( )
		Menu:Center( )
	end )
end

function catherine.recognize.IsKnowTarget( pl, target )
	if ( !IsValid( pl ) or !IsValid( target ) ) then return false end
	local factionTable = catherine.faction.FindByIndex( target:Team( ) )
	if ( factionTable and factionTable.alwaysRecognized ) then
		return true
	end
	local recognizeLists = catherine.character.GetCharacterVar( pl, "recognize", { } )
	return table.HasValue( recognizeLists, target:GetCharacterID( ) )
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

function GM:GetUnknownTargetName( pl, target )
	return "Unknown"
end