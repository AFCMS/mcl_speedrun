--https://youtu.be/MnQqXQTfhco?t=20

local data = {points = {}}
local huds = {}

local math = math

if not minetest.is_singleplayer() then
	error("This mod can only be played in singleplayer")
end

mcl_speedrun.text_color = 0x52ca46
mcl_speedrun.title = "Mineclone2:"

function mcl_speedrun.checkpoint(player, checkpoint)
    if data.points[checkpoint] then
        data.points[checkpoint].checked = true
        data.points[checkpoint].checked = data.elapsed
        player:hud_change(huds[checkpoint].time, "text", mcl_speedrun.time_to_string(data.elapsed))
        if mcl_speedrun.required[checkpoint] then
            local tous = true
            for name,_ in pairs(mcl_speedrun.required) do
                if not data.points[name].checked then
                    tous = false
                    break
                end
            end
			data.win = tous
        end
    else
        minetest.log("error", "[mcl_speedrun] Trying to check invalid checkpoint")
    end
end

function mcl_speedrun.has_checkpoint(player, checkpoint)
    if data.points[checkpoint] then
        if data.points[checkpoint].checked then
			return true
		end
    else
        minetest.log("error", "[mcl_speedrun] Trying to get invalid checkpoint")
		return nil
    end
end

function mcl_speedrun.time_to_string(time)
	return string.format('%02d:%02d:%02d', math.floor(time / 3600), math.floor(time / 60 % 60), math.floor(time % 60))
end

--[[
| description             |
| checkpoint1: icon, time |
| total time              |
]]

local function init_hud(player)
    huds.desc_bg = player:hud_add({
        hud_elem_type = "image",
        position  = {x=0, y=0.05},
        offset    = {x=5, y=10},
        text      = "mcl_speedrun_text_bg.png",
        scale     = { x = 2, y = 2},
        alignment = { x = 1, y = 1 },
        z_index = 2000,
    })
    huds.desc = player:hud_add({
        hud_elem_type = "text",  -- See HUD element types
        position = {x=0, y=0.05},
        -- Left corner position of element
        name = "desc",
        text = mcl_speedrun.title.." "..mcl_speedrun.description,
        number = mcl_speedrun.text_color,
        alignment = {x=1, y=1},
        offset = {x=10, y=15},
        size = { x=1 },
        z_index = 2010,
    })
    local count = 0
    for _,def in pairs(mcl_speedrun.checkpoints) do
        count = count + 1
        huds[def.name] = {}
        huds[def.name].bg = player:hud_add({
            hud_elem_type = "image",
            position  = {x=0, y=0.05},
            offset    = {x=5, y=10+40*count},
            text      = "mcl_speedrun_text_bg.png",
            scale     = { x = 2, y = 2},
            alignment = { x = 1, y = 1 },
            z_index = 2000,
        })
        huds[def.name].icon = player:hud_add({
            hud_elem_type = "image",
            position  = {x=0, y=0.05},
            offset    = {x=10, y=12+40*count},
            text      = def.icon,
            scale     = { x = 2, y = 2},
            alignment = { x = 1, y = 1 },
            z_index = 2010,
        })
        huds[def.name].desc = player:hud_add({
            hud_elem_type = "text",
            position = {x=0, y=0.05},
            offset    = {x=10+32+4, y=15+40*count},
            text = def.desc,
            number = mcl_speedrun.text_color,
            alignment = {x=1, y=1},
            size = { x=1 },
            z_index = 2010,
        })
        huds[def.name].time = player:hud_add({
            hud_elem_type = "text",
            position = {x=0, y=0.05},
            offset    = {x=10+32+4+150, y=15+40*count},
            text = "--:--:--",
            number = mcl_speedrun.text_color,
            alignment = {x=1, y=1},
            size = { x=1 },
            z_index = 2010,
        })
    end
    count = count + 1
    huds.base_bg = player:hud_add({
        hud_elem_type = "image",
        position  = {x=0, y=0.05},
        offset = {x=5, y=10+40*count},
        text      = "mcl_speedrun_text_bg.png",
        scale     = { x = 2, y = 2.1},
        alignment = { x = 1, y = 1 },
        z_index = 2000,
    })
    huds.base = player:hud_add({
        hud_elem_type = "text",  -- See HUD element types
        -- Type of element, can be "image", "text", "statbar", "inventory",
        -- "compass" or "minimap"
        position = {x=0, y=0.05},
        name = "base",
        text = mcl_speedrun.time_to_string(0),
        number = mcl_speedrun.text_color,
        alignment = {x=1, y=1},
        offset = {x=10, y=4+40*count},
        size = { x=3 },
        z_index = 2010,
    })
end

minetest.register_on_joinplayer(function(player)
	--local playername = player:get_player_name()
	--local meta = player:get_meta()
	--if meta:get_int("mcl_speedrun:has_speedruned") == 0 then
    if true then
		for _,def in pairs(mcl_speedrun.checkpoints) do
			data.points[def.name] = {checked = false, time = nil}
		end
		data.elapsed = 0
		data.win = false
		--meta:set_int("mcl_speedrun:has_speedruned", 1)
        init_hud(player)
        for _,def in pairs(mcl_speedrun.checkpoints) do
			if def.name == "START" then
                data.points.START.checked = true
                data.points.START.time = 0
                player:hud_change(huds["START"].time, "text", mcl_speedrun.time_to_string(0))
                break
            end
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
    data[player:get_player_name()] = nil
end)

minetest.register_globalstep(function(dtime)
    for _,player in pairs(minetest.get_connected_players()) do
        --local playername = player:get_player_name()
		if not data.win then
			data.elapsed = data.elapsed + dtime
            player:hud_change(huds.base, "text", mcl_speedrun.time_to_string(data.elapsed))
		elseif player:hud_get(huds.base).number ~= 0x6e6e6e then
			player:hud_change(huds.base, "number", 0x6e6e6e)
		end
    end
end)