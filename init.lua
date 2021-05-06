--local S = minetest.get_modpath(minetest.get_current_modname())
local modpath = minetest.get_modpath(minetest.get_current_modname())

mcl_speedrun = {}



minetest.register_chatcommand("playtime", {
  params = "",
  description = "Use it to get your own playtime!",
  func = function(name)
    minetest.chat_send_player(name, "Total: "..SecondsToClock(playtime.get_total_playtime(name)).." Current: "..SecondsToClock(playtime.get_current_playtime(name)))
  end,
})

dofile(modpath.."/time.lua")