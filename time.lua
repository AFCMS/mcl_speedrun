local current = {}
local huds = {}

minetest.register_on_newplayer(function(player)
    local meta = player:get_meta()
    meta:set_int("mcl_speedrun:playtime", 0)
    meta:set_int("mcl_speedrun:playtime_nether", 0)
    meta:set_int("mcl_speedrun:playtime_end", 0)
    meta:set_bool("mcl_speedrun:is_nether", false)
    meta:set_bool("mcl_speedrun:is_end", false)
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local meta = player:get_meta()
    current[name] = {
        start = os.time()
        playtime = meta:get_int("mcl_speedrun:playtime"),
        playtime_nether = meta:get_int("mcl_speedrun:playtime_nether"),
        playtime_end = meta:get_int("mcl_speedrun:playtime_end"),
        is_nether = meta:get_bool("mcl_speedrun:is_nether"),
        is_end = meta:get_bool("mcl_speedrun:is_end"),
    }
    
    --os.time()
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    local meta = player:get_meta()
    meta:set_int("mcl_speedrun:playtime", current[name].playtime)
    meta:set_int("mcl_speedrun:playtime_nether", current[name].playtime_nether)
    meta:set_int("mcl_speedrun:playtime_end", current[name].playtime_end)
    meta:set_bool("mcl_speedrun:is_nether", current[name].is_nether)
    meta:set_bool("mcl_speedrun:is_end", current[name].is_end)
    current[name] = nil
end)


function mcl_speedrun.get_current_playtime(name)
    return current[name].playtime
end

minetest.register_globalstep(function(dtime)
    for _,player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        current[name].playtime = os.time() - current[name].start
    end
end)

minetest.register_chatcommand("tt", {
    params = "",
    description = "Use it to get your own playtime!",
    func = function(name)
        return true, mcl_speedrun.get_current_playtime(name)
    end,
})

--[[Function to get playtime
function playtime.get_total_playtime(name)
  return storage:get_int(name) + playtime.get_current_playtime(name)
end

function playtime.remove_playtime(name)
  storage:set_string(name, "")
end

minetest.register_on_leaveplayer(function(player)
  local name = player:get_player_name()
  storage:set_int(name, storage:get_int(name) + playtime.get_current_playtime(name))
  current[name] = nil
end)

minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  current[name] = os.time()
end)]]

local function SecondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end