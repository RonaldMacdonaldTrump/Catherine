catherine.command = catherine.command or { }
catherine.command.Lists = catherine.command.Lists or { }

function catherine.command.Register( tab )
	tab.syntax = tab.syntax or "[none]"
	catherine.command.Lists[ tab.command ] = tab
end

function catherine.command.FindByCMD( id )
	if ( !id ) then return nil end
	
	for k, v in pairs( catherine.command.Lists ) do
		if ( v.command == id ) then
			return v
		end
	end
	
	return nil
end

function catherine.command.IsCommand( text )
	if ( text:sub( 1, 1 ) == "/" ) then
		local toArgs = catherine.command.TransferToArgsTab( text )
		local id = toArgs[ 1 ]:sub( 2, #toArgs[ 1 ] )
		if ( catherine.command.Lists[ id ] ) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function catherine.command.TransferToArgsTab( text )
	local skip, args, curstr = 0, { }, ""
	
	for i = 1, #text do
		if ( i <= skip ) then continue end
		local k = text:sub( i, i )

		if ( k == "\"" or k == "'" ) then
			local match = text:sub( i ):match( "%b" .. k .. k )
			if ( match ) then
				curstr = ""
				skip = i + #match
				args[ #args + 1 ] = match:sub( 2, -2 )
			else
				curstr = curstr .. k
			end
		elseif ( k == " " and curstr != "" ) then
			args[#args + 1] = curstr
			curstr = ""
		else
			if ( k == " " and curstr == "" ) then continue end
			curstr = curstr .. k
		end 
	end

	if ( curstr != "" ) then
		args[#args + 1] = curstr
	end

	return args
end

if ( SERVER ) then
	function catherine.command.Run( pl, id, args )
		local cmdTab = catherine.command.FindByCMD( id )
		if ( !cmdTab ) then return "Command not found!" end
		if ( cmdTab.canAdmin and !pl:IsAdmin( ) ) then return end
		if ( cmdTab.canSUAdmin and !pl:IsSuperAdmin( ) ) then return end
		if ( !cmdTab.runFunc ) then return end
		cmdTab.runFunc( pl, args )
	end
	
	function catherine.command.DoByText( pl, text )
		if ( text:sub( 1, 1 ) == "/" ) then
			local toArgs = catherine.command.TransferToArgsTab( text )
			local id = toArgs[ 1 ]:sub( 2, #toArgs[ 1 ] )
			table.remove( toArgs, 1 )
			local result = catherine.command.Run( pl, id, toArgs )
			if ( result ) then
				catherine.util.Notify( pl, result )
				return
			end
			
			return ""
		end
	end
end