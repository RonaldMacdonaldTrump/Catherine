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

DownloadListAdd( "materials/CAT" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

concommand.Add( "get", function( pl )
	local trace = pl:GetEyeTraceNoCursor();
	local data = {
	angles = trace.HitNormal:Angle(),
	position = trace.HitPos + (trace.HitNormal * 1.25)
	}
	data.angles:RotateAroundAxis(data.angles:Forward(), 90);
	data.angles:RotateAroundAxis(data.angles:Right(), 270);
	
	PrintTable(data)
end )