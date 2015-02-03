if ( !nexus.cash ) then
	nexus.util.Include( "libs/sh_cash.lua" )
end

local META = FindMetaTable( "Player" )

if ( SERVER ) then
	function META:SetCash( amount, dbSave )
		if ( amount < 0 ) then amount = 0 end
		self:SetCharacterData( "_Cash", amount, dbSave )
	end
	
	function META:GiveCash( amount, dbSave )
		self:SetCharacterData( "_Cash", self:GetCash( ) + amount, dbSave )
	end
	
	function META:TakeCash( amount, dbSave )
		self:SetCharacterData( "_Cash", self:GetCash( ) - amount, dbSave )
	end
end

function META:GetCash( )
	self:GetCharacterData( "_Cash", 0 )
end
