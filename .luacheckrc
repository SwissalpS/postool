
globals = {
	"minetest",
	"postool",
	"advtrains",
	"mesecons_debug"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"vector", "ItemStack",
	"dump",

	-- deps
	"default", "advtrains", "mesecons_debug"
}
