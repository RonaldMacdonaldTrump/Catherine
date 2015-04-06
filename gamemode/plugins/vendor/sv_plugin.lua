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

function PLUGIN:SaveVendors( )
	local data = { }
	
	for k, v in pairs( ents.FindByClass( "cat_vendor" ) ) do
		if ( !v.vendorData ) then print("No data") continue end
		data[ #data + 1 ] = {
			name = v.vendorData.name,
			desc = v.vendorData.desc,
			factionData = v.vendorData.factions,
			classData = v.vendorData.classes,
			inv = v.vendorData.inv,
			cash = v.vendorData.cash,
			setting = v.vendorData.setting,
			status = v.vendorData.status,
			
			model = v:GetModel( ),
			pos = v:GetPos( ),
			ang = v:GetAngles( )
		}
	end
	
	catherine.data.Set( "vendors", data )
end

function PLUGIN:LoadVendors( )
	local data = catherine.data.Get( "vendors", { } )
	
	for k, v in pairs( data ) do
		local ent = ents.Create( "cat_vendor" )
		ent:SetPos( v.pos )
		ent:SetAngles( v.ang )
		ent:SetModel( v.model )
		ent:Spawn( )
		ent:Activate( )
		
		self:MakeVendor( ent, v )
	end
end

--[[
name = v.vendorData.name,
desc = v.vendorData.desc,
factionData = v.vendorData.factions,
classData = v.vendorData.classes,
inv = v.vendorData.inv,
cash = v.vendorData.cash,
setting = v.vendorData.setting,
--]]

function PLUGIN:MakeVendor( ent, data )
	if ( !IsValid( ent ) or !data ) then return end
	local vars = {
		{
			id = "name",
			default = "Johnson"
		},
		{
			id = "desc",
			default = "No desc"
		},
		{
			id = "factions",
			default = { }
		},
		{
			id = "classes",
			default = { }
		},
		{
			id = "inv",
			default = { }
		},
		{
			id = "cash",
			default = 0
		},
		{
			id = "setting",
			default = { }
		},
		{
			id = "status",
			default = false
		}
	}
	
	ent.vendorData = { }
	for k, v in pairs( vars ) do
		local val = data[ v.id ] and data[ v.id ] or v.default
		ent:SetNetVar( v.id, val )
		ent.vendorData[ v.id ] = val
	end
	
	ent.isVendor = true
end

function PLUGIN:VendorWork( pl, ent, workID, data )

end

function PLUGIN:CanUseVendor( pl, ent )
	if ( !IsValid( pl ) or !IsValid( ent ) or !ent.isVendor ) then return end
	
	if ( !ent.vendorData.status ) then
		return false, "status"
	end
	
	local factionData = v.vendorData.factions
	if ( #factionData != 0 and !table.HasValue( factionData, pl:Team( ) ) ) then
		return false, "faction"
	end
	
	local classData = v.vendorData.classes
	if ( #classData != 0 and !table.HasValue( classData, pl:Class( ) ) ) then
		return false, "class"
	end

	return true
end

function PLUGIN:DataLoad( )
	self:LoadVendors( )
end

function PLUGIN:DataSave( )
	self:SaveVendors( )
end