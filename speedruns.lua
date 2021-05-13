local speedruntype = minetest.settings:get("mcl_speedrun.speedrun_type") or "dragon"

if speedruntype == "dragon" then
    mcl_speedrun.description = "Kill the dragon"
    mcl_speedrun.checkpoints = {
        {name = "START", desc = "Overworld", icon = "default_dirt.png^default_dry_grass_side.png"},
        {name = "nether_enter", desc = "Enter the Nether", icon = "mcl_nether_netherrack.png"},
        {name = "end_enter", desc = "Enter the End", icon = "mcl_end_ender_eye.png"},
        {name = "dragon_kill", desc = "Kill the dragon", icon = "mobs_mc_dragon_fireball.png"},
    }
    mcl_speedrun.required = {["dragon_kill"] = true}
    mcl_worlds.register_on_dimension_change(function(player, dimension, last_dimension)
        if last_dimension == "overworld" and dimension == "nether" then
            mcl_speedrun.checkpoint(player, "nether_enter")
        end
    end)
    mcl_worlds.register_on_dimension_change(function(player, dimension, last_dimension)
        if last_dimension == "overworld" and dimension == "end" then
            mcl_speedrun.checkpoint(player, "end_enter")
        end
    end)
    --[[mcl_worlds.register_on_dimension_change(function(player, dimension, last_dimension)
        if last_dimension == "end" and dimension == "overworld" then
            mcl_speedrun.checkpoint(player, "dragon_kill")
        end
    end)]]

    -- FIXME: be sure a better check apply (maybe mcl2 changes)
    minetest.register_globalstep(function(dtime)
        for _,player in pairs(minetest.get_connected_players()) do
            if mcl_worlds.pos_to_dimension(player:get_pos()) == "end" and mcl_playerinfo[player:get_player_name()].node_feet == "mcl_portals:portal_end" then
                mcl_speedrun.checkpoint(player, "dragon_kill")
            end
        end
    end)
end