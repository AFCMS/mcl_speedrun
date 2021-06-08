local speedruntype = minetest.settings:get("mcl_speedrun.speedrun_type") or "dragon"

if speedruntype == "any-glitchless" then
    mcl_speedrun.description = "Any% Glitchless "
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
    local old_end_teleport = mcl_portals.end_teleport
    function mcl_portals.end_teleport(obj, pos)
        if mcl_worlds.pos_to_dimension(pos) == "end" then
            mcl_speedrun.checkpoint(obj, "dragon_kill")
        end
        return old_end_teleport(obj, pos)
    end
elseif speedruntype == "bosses" then
    mcl_speedrun.description = "Kill Bosses"
    mcl_speedrun.checkpoints = {
        {name = "guardian_kill", desc = "Kill the Guardian", icon = "mcl_ocean_prismarine_bricks.png"},
        {name = "wither_kill", desc = "Kill the Wither", icon = "mcl_nether_soul_sand.png"},
        {name = "dragon_kill", desc = "Kill the dragon", icon = "mobs_mc_dragon_fireball.png"},
    }
    mcl_speedrun.required = {["guardian_kill"] = true, ["wither_kill"] = true, ["dragon_kill"] = true}
    -- There is no register_on_kill in mobs API, so, to complete chalenge, you must get the drops of bosses
    minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
        if inventory_info.stack then
            local itemname = inventory_info.stack:get_name()
            if itemname == "mcl_sponges:sponge_wet" then
                mcl_speedrun.checkpoint(player, "guardian_kill")
            elseif itemname == "mcl_mobitems:nether_star" then
                mcl_speedrun.checkpoint(player, "wither_kill")
            elseif itemname == "mcl_end:dragon_egg" then
                mcl_speedrun.checkpoint(player, "dragon_kill")
            end
        end
    end)
elseif speedruntype == "all-achievements" then
    mcl_speedrun.description =  "All Achievements"
    mcl_speedrun.checkpoints = {}
    mcl_speedrun.required = {}
    for name, def in pairs(awards.def) do
        table.insert(mcl_speedrun.checkpoints, {name=name, desc=def.title, icon=def.icon})
        mcl_speedrun.required[name] = true
    end
    -- HACK!!!!
    -- Needs mcl2 awards API changes (on the TODO list)
    awards.register_on_unlock(function(playername, awdef)
        for name, def in pairs(awards.def) do
            if def.title == awdef.title then
                mcl_speedrun.checkpoint(minetest.get_player_by_name(playername), name)
                break
            end
        end
    end)
else
	error("[mcl_speedrun] Speedrun Type is invalid!")
end