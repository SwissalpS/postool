
globals = {
	"postool",
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"minetest",
	"vector", "ItemStack",
	"dump",

	-- deps
	"default", "advtrains", "mesecons_debug", "unified_inventory"
}
