
PosTool mod for Minetest
========================

Adds configurable HUD elements for current: position (node and block) and time.
If advtrains is installed, it can also display railway time.
If mesecons_debug is installed, this info can also be displayed.

Use chat command /postool to invoke formspec to toggle elements and position of HUD.

# Screenshots
Pick a location.

![](/doc/img/s1.png)

Use the tool.

![](/doc/img/s2.png)

Invoke formspec with /postool

![](/doc/img/postool_HUD_config.png)

Example display of HUD

![](/doc/img/postool_HUD_display.png)

The progress-bar shows the mesecons usage in current block. It changes colour based on penalty.

When not disabled and user is not standing in the middle block of a chunk,
then a smaller, green grid shows in which direction the chunk borders are.
The closer to the orange grid the green one is, the closer a chunk border is in that direction.

# PosTool
Crafting recipe:
```
		|				|				| default:glass |
		|				| default:torch |				|
		| default:stick |				|				|
```
Punch or place with PosTool to show a grid of the map-block at that position.
If PosTool is used on a node, that nodes position will be used otherwise players position.

# Settings

Settings with default values:
```
# HUD offsets in screen percentage
postool.hud.offsetx						0.8
postool.hud.offsety						0.95
# HUD z_index (does not seem to work)
postool.hud.offsetz						-111
# how to separate x, y and z values
postool.hud.posseparator				' | '
# titles in HUD and formspec
postool.hud.titletrain					'Railway Time: '
postool.hud.titletime					'Time: '
postool.hud.titlenode					'Node: '
postool.hud.titleblock					'Block: '
postool.hud.titlemesecons				'Mesecons: '
# value shown in HUD when
# advtrains is not enabled
postool.hud.titletrainna				'advtrains not enabled'
# main HUD switch
postool.hud.defaultshowmain				false (0/1)
# which items to initially show
postool.hud.defaultshowtrain			false (0/1)
postool.hud.defaultshowtime				false (0/1)
postool.hud.defaultshownode				true (0/1)
postool.hud.defaultshowblock			true (0/1)
postool.hud.defaultshowmesecons			false (0/1)
postool.hud.defaultshowmeseconsdetails	false (0/1)
# wait at least this long
# before updating HUD (seconds)
postool.hud.minupdateinterval			2
# how long to show grid for
# when tool is used
postool.tool.griddisplayduration		12
postool.tool.suppresschunkindicator	false (0/1)
```
# Thanks
This mod was strongly inspired by [poshud](https://github.com/orwell96/poshud).
Some techniques I borrowed from [missions](https://github.com/thomasrudin-mt/missions).
I also want to mention [replacer](https://github.com/pandorabox-io/replacer) <- [Coil0's version](https://github.com/coil0/replacer) <- [Sokomine's version](https://github.com/Sokomine/replacer)
and [protector](https://notabug.org/TenPlus1/protector) as I used parts of them too.
[@6r1d for screenshots and support](https://github.com/6r1d)

Thanks also to the users of pandorabox.io for feedback and inspiration to actually
write this mod. @Huhhila for pushing the mapchunk indicator idea. On #minetest IRC/discord
@Warr1024, @hlqkj and @Krock for chiming in the discussion.

(If you feel I should include you by name, just submit a PR)

