local Utils = require("utility.utils")

local refArtilleryWagon = data.raw["artillery-wagon"]["artillery-wagon"]

local cannonScale = 1.5 -- Make the cannon bigger on the ship. Some of the graphics fixes are hard coded approx values.

-- Make base artillery ship.
local artilleryCargoShip_entity = Utils.DeepCopy(data.raw["cargo-wagon"]["cargo_ship"])
artilleryCargoShip_entity.name = "artilery_ship"
artilleryCargoShip_entity.type = "artillery-wagon"
artilleryCargoShip_entity.minable = {mining_time = 1, result = "artilery_ship"}
artilleryCargoShip_entity.pictures.layers[3] = Utils.DeepCopy(refArtilleryWagon.pictures.layers[1])
artilleryCargoShip_entity.pictures.layers[3].scale = cannonScale
artilleryCargoShip_entity.pictures.layers[3].hr_version.scale = cannonScale / 2
artilleryCargoShip_entity.pictures.layers[4] = Utils.DeepCopy(refArtilleryWagon.pictures.layers[2])
artilleryCargoShip_entity.pictures.layers[4].scale = cannonScale
artilleryCargoShip_entity.pictures.layers[4].hr_version.scale = cannonScale / 2
artilleryCargoShip_entity.ammo_stack_limit = 1000 -- Increased max ammo count.
artilleryCargoShip_entity.gun = refArtilleryWagon.gun
artilleryCargoShip_entity.inventory_size = 1 -- Same as regular artillery wagon.
artilleryCargoShip_entity.manual_range_modifier = refArtilleryWagon.manual_range_modifier
artilleryCargoShip_entity.turret_rotation_speed = refArtilleryWagon.turret_rotation_speed
artilleryCargoShip_entity.cannon_barrel_light_direction = refArtilleryWagon.cannon_barrel_light_direction
artilleryCargoShip_entity.cannon_barrel_pictures = Utils.DeepCopy(refArtilleryWagon.cannon_barrel_pictures)
artilleryCargoShip_entity.cannon_barrel_pictures.layers[1].scale = cannonScale
artilleryCargoShip_entity.cannon_barrel_pictures.layers[1].hr_version.scale = cannonScale / 2
artilleryCargoShip_entity.cannon_barrel_pictures.layers[2].scale = cannonScale
artilleryCargoShip_entity.cannon_barrel_pictures.layers[2].hr_version.scale = cannonScale / 2
artilleryCargoShip_entity.cannon_barrel_recoil_shiftings = Utils.DeepCopy(refArtilleryWagon.cannon_barrel_recoil_shiftings)
artilleryCargoShip_entity.cannon_barrel_recoil_shiftings_load_correction_matrix = Utils.DeepCopy(refArtilleryWagon.cannon_barrel_recoil_shiftings_load_correction_matrix)
artilleryCargoShip_entity.cannon_base_pictures = Utils.DeepCopy(refArtilleryWagon.cannon_base_pictures)
artilleryCargoShip_entity.cannon_base_pictures.layers[1].scale = cannonScale
artilleryCargoShip_entity.cannon_base_pictures.layers[1].hr_version.scale = cannonScale / 2
artilleryCargoShip_entity.cannon_base_pictures.layers[2].scale = cannonScale
artilleryCargoShip_entity.cannon_base_pictures.layers[2].hr_version.scale = cannonScale / 2
artilleryCargoShip_entity.cannon_base_shiftings = Utils.DeepCopy(refArtilleryWagon.cannon_base_shiftings)
artilleryCargoShip_entity.cannon_parking_frame_count = refArtilleryWagon.cannon_parking_frame_count
artilleryCargoShip_entity.cannon_parking_speed = refArtilleryWagon.cannon_parking_speed
artilleryCargoShip_entity.disable_automatic_firing = refArtilleryWagon.disable_automatic_firing
artilleryCargoShip_entity.rotating_sound = refArtilleryWagon.rotating_sound
artilleryCargoShip_entity.rotating_stopped_sound = refArtilleryWagon.rotating_stopped_sound
artilleryCargoShip_entity.turn_after_shooting_cooldown = refArtilleryWagon.turn_after_shooting_cooldown
artilleryCargoShip_entity.horizontal_doors = nil -- Don't have the doors open when stopped as under turret and open graphics draw over turret graphics.
artilleryCargoShip_entity.vertical_doors = nil -- Don't have the doors open when stopped as under turret and open graphics draw over turret graphics.

-- Fix graphics positioning (hard coded approx fixes by trial and error).
for _, shifting in pairs(artilleryCargoShip_entity.cannon_base_shiftings) do
    shifting[1] = shifting[1] * cannonScale
    shifting[2] = shifting[2] * cannonScale
end
artilleryCargoShip_entity.cannon_barrel_pictures.layers[1].shift = {
    artilleryCargoShip_entity.cannon_barrel_pictures.layers[1].shift[1],
    artilleryCargoShip_entity.cannon_barrel_pictures.layers[1].shift[2] - 0.25
}
artilleryCargoShip_entity.cannon_barrel_pictures.layers[1].hr_version.shift = {
    artilleryCargoShip_entity.cannon_barrel_pictures.layers[1].hr_version.shift[1],
    artilleryCargoShip_entity.cannon_barrel_pictures.layers[1].hr_version.shift[2] - 0.25
}
artilleryCargoShip_entity.cannon_barrel_pictures.layers[2].shift = {
    artilleryCargoShip_entity.cannon_barrel_pictures.layers[2].shift[1],
    artilleryCargoShip_entity.cannon_barrel_pictures.layers[2].shift[2] - 0.25
}
artilleryCargoShip_entity.cannon_barrel_pictures.layers[2].hr_version.shift = {
    artilleryCargoShip_entity.cannon_barrel_pictures.layers[2].hr_version.shift[1],
    artilleryCargoShip_entity.cannon_barrel_pictures.layers[2].hr_version.shift[2] - 0.25
}

-- Make item to place artillery ship.
local artilleryCargoShip_item = Utils.DeepCopy(data.raw["item-with-entity-data"]["cargo_ship"])
artilleryCargoShip_item.name = "artilery_ship"
artilleryCargoShip_item.order = "a[water-system]-f[cargo_ship]zzz"
artilleryCargoShip_item.place_result = "artilery_ship"

data:extend({artilleryCargoShip_entity, artilleryCargoShip_item})
