local PLUGIN = PLUGIN
PLUGIN.name = "Good Text"
PLUGIN.author = "L7D"
PLUGIN.desc = "Write text to wall."
PLUGIN.textLists = PLUGIN.textLists or { }

catherine.util.Include( "sh_commands.lua" )
catherine.util.Include( "sv_plugin.lua" )
catherine.util.Include( "cl_plugin.lua" )