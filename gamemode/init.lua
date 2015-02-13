catherine = catherine or GM

function DownloadListAdd( path )
	local files, dirs = file.Find( path .. "/*", "GAME" )
	for _, fdir in pairs( dirs ) do
		if ( fdir != ".svn" ) then   
			DownloadListAdd( path .. "/" .. fdir )
		end
	end
	for k, v in pairs( files ) do
		resource.AddFile( path .. "/" .. v )
	end
end

DownloadListAdd( "materials/catherine" )
DownloadListAdd( "materials/catherine_hl2rp" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )