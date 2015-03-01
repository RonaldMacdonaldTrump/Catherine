local Plugin = Plugin

Plugin.name = "Good Text"
Plugin.author = "L7D"
Plugin.desc = "Write text to wall."
Plugin.textLists = Plugin.textLists or { }

catherine.util.Include( "sh_commands.lua" )
catherine.util.Include( "sv_plugin.lua" )
catherine.util.Include( "cl_plugin.lua" )