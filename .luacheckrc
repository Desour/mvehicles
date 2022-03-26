
ignore = {
	"212", -- unused argument
	"21./_.*", -- unused variable/argument/etc. ("21.") if name matches "_.*" (has "_" prefix)
}

read_globals = {
	-- minetest stuff
	"minetest",
	"INIT",
	"vector",
	"ItemStack",

	-- depends
	"default",
	"player_api",
	"stairs",
	"tnt",
}

globals = {
	"mvehicles",

	-- depends
	player_api = {"player_attached"},
}
