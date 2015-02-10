if ( !catherine.cash ) then
	catherine.util.Include( "libs/sh_cash.lua" )
end

local META = FindMetaTable( "Player" )

if ( SERVER ) then
	function META:SetCash( amount, dbSave )
		if ( amount < 0 ) then amount = 0 end
		self:SetCharacterGlobalData( "_cash", amount, dbSave )
	end
	
	function META:GiveCash( amount, dbSave )
		self:SetCharacterGlobalData( "_cash", self:GetCash( ) + amount, dbSave )
	end
	
	function META:TakeCash( amount, dbSave )
		self:SetCharacterGlobalData( "_cash", self:GetCash( ) - amount, dbSave )
	end
end

function META:GetCash( )
	return self:GetCharacterGlobalData( "_cash", 0 )
end
