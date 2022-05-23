local offset = {}
offset[0] = {x = 0, y = 9.5}
offset[1] = {x = -7, y = 7}
offset[2] = {x = -9.5, y = 0}
offset[3] = {x = -7, y = -7}
offset[4] = {x = 0, y = -9.5}
offset[5] = {x = 7, y = -7}
offset[6] = {x = 9.5, y = 0}
offset[7] = {x = 7, y = 7}

function localize_engine(ent)
  local i = (math.floor((ent.orientation*8)+0.5))%8

  local mult = ((ent.name == "indep-boat" or ent.name == "boat") and -0.3) or 1
  local pos = {x = ent.position.x + offset[i].x*mult, y = ent.position.y + offset[i].y*mult}
  --game.players[1].print("x_off: " .. offset[i].x*mult .. " y_off: " .. offset[i].y*mult)

  -- switch ne and sw (messed up factorio directions)
  if i == 1 then
    i = 5
  elseif i == 5 then
    i = 1
  end
  return pos, i
end

local function has_connected_stock(wagon)
  local train = wagon.train
  local wagon_pos = 0
  for i=1, #train.carriages do
    if train.carriages[i].unit_number == wagon.unit_number then
      wagon_pos = i
      break
    end
  end
  if wagon_pos > 0 then
    if wagon.name == "cargo_ship" or wagon.name == "oil_tanker" then
      if wagon_pos < #train.carriages and train.carriages[wagon_pos+1].name == "cargo_ship_engine" then
        --game.print("found "..train.carriages[wagon_pos+1].name.." in back of "..wagon.name)
        return true
      end
    elseif wagon.name == "boat" then
      if wagon_pos > 1 and train.carriages[wagon_pos-1].name == "boat_engine" then
        --game.print("found "..train.carriages[wagon_pos-1].name.." in front of "..wagon.name)
        return true
      end
    elseif wagon.name == "cargo_ship_engine" then
      if wagon_pos > 1 and (train.carriages[wagon_pos-1].name == "cargo_ship" or train.carriages[wagon_pos-1].name == "oil_tanker") then
        --game.print("found "..train.carriages[wagon_pos-1].name.." in front of "..wagon.name)
        return true
      end
    elseif wagon.name == "boat_engine" then
      if wagon_pos < #train.carriages and train.carriages[wagon_pos+1].name == "boat" then
        --game.print("found "..train.carriages[wagon_pos+1].name.." in back of "..wagon.name)
        return true
      end
    end
  end
  --game.print("didn't find matching entity for "..wagon.name.." in train of "..#train.carriages.." wagons")
  return false
end

local function cancelPlacement(entity, player, robot)
  if entity.name ~= "cargo_ship_engine" and entity.name ~= "boat_engine" then
    if player and player.valid then
      player.insert{name=entity.name, count=1}
      if entity.name == "cargo_ship" or entity.name == "oil_tanker" or entity.name == "boat" then
        player.print{"cargo-ship-message.error-ship-no-space", entity.localised_name}
      else
        player.print{"cargo-ship-message.error-train-on-waterway", entity.localised_name}
      end
    elseif robot and robot.valid then
      -- Give the robot back the thing
      robot.get_inventory(defines.inventory.robot_cargo).insert{name=entity.name, count=1}
      if entity.name == "cargo_ship" or entity.name == "oil_tanker" or entity.name == "boat" then
        game.print{"cargo-ship-message.error-ship-no-space", entity.localised_name}
      else
        game.print{"cargo-ship-message.error-train-on-waterway", entity.localised_name}
      end
    else
      game.print{"cargo-ship-message.error-canceled", entity.localised_name}
    end
  end
  entity.destroy()
end


function CheckBoatPlacement(entity, player, robot)
  -- check if waterways present
  local pos = entity.position
  local surface = entity.surface
  local local_name = entity.localised_name
  local ww = surface.find_entities_filtered{area={{pos.x-1, pos.y-1}, {pos.x+1, pos.y+1}}, name="straight-water-way-placed"}

  -- if so place waterway bound version of boat
  if #ww >= 1 then
    local force = entity.force
    local eng_pos
    local dir
    eng_pos, dir = localize_engine(entity)
    entity.destroy()
    local boat = surface.create_entity{name="boat", position=pos, direction=dir, force=force}
    if boat then
      if player then
        player.print{"cargo-ship-message.place-on-waterway", local_name}
      else
        game.print{"cargo-ship-message.place-on-waterway", local_name}
      end
      eng_pos, dir = localize_engine(boat)  -- Get better position for engine now that boat is on rails
      local engine = surface.create_entity{name="boat_engine", position=eng_pos, direction=dir, force=force}
      table.insert(global.check_entity_placement, {boat, engine, player})
    else
      if player then
        player.insert{name="boat", count=1}
        player.print{"cargo-ship-message.error-place-on-waterway", local_name}
      else
        if robot then
          robot.get_inventory(defines.inventory.robot_cargo).insert{name="boat", count=1}
        end
        game.print{"cargo-ship-message.error-place-on-waterway", local_name}
      end
    end
  else
    if player then
      player.print{"cargo-ship-message.place-independent", local_name}
    else
      game.print{"cargo-ship-message.place-independent", local_name}
    end
  end
end

-- checks placement of rolling stock, and returns the placed entities to the player if necessary
function checkPlacement()
  global.connection_counter = 0
  for _, entry in pairs(global.check_entity_placement) do
    local entity = entry[1]
    local engine = entry[2]
    local player = entry[3]
    local robot = entry[4]

    if entity and entity.valid then
      if entity.name == "cargo_ship" or entity.name == "oil_tanker" or entity.name == "boat" then
        -- check for too many connections
        -- check for correct engine placement
        if not engine then
          -- See if there is already an engine connected to this ship
          if not has_connected_stock(entity) then
            cancelPlacement(entity, player, robot)
          end
        elseif entity.orientation ~= engine.orientation then
          cancelPlacement(entity, player, robot)
          cancelPlacement(engine, player)
        elseif entity.train then
          -- check if connected to too many carriages
          if #entity.train.carriages > 2 then
            cancelPlacement(entity, player, robot)
            cancelPlacement(engine, player)
          -- check if on rails
          elseif entity.train.front_rail then
            if entity.train.front_rail.name ~= "straight-water-way-placed" and entity.train.front_rail.name ~= "curved-water-way-placed" then
              cancelPlacement(entity, player, robot)
              cancelPlacement(engine, player)
            end
          elseif entity.train.back_rail then
            if entity.train.back_rail.name ~= "straight-water-way-placed" and entity.train.back_rail.name ~= "curved-water-way-placed" then
              cancelPlacement(entity, player, robot)
              cancelPlacement(engine, player)
            end
          end
        end

      elseif entity.name == "cargo_ship_engine" or entity.name == "boat_engine" then
        if not has_connected_stock(entity) then
          game.print{"cargo-ship-message.error-unlinked-engine", entity.localised_name}
          cancelPlacement(entity, player)
        end

      -- else: trains
      elseif entity.train then
        -- check if on waterways
        if entity.train.front_rail then
          if entity.train.front_rail.name == "straight-water-way-placed" or entity.train.front_rail.name == "curved-water-way-placed" then
            cancelPlacement(entity, player, robot)
          end
        elseif entity.train.back_rail then
          if entity.train.back_rail.name == "straight-water-way-placed" or entity.train.back_rail.name == "curved-water-way-placed" then
            cancelPlacement(entity, player, robot)
          end
        end
      end
    end
  end
  global.check_entity_placement = {}
end



-- Disconnects/reconnects rolling stocks if they get wrongly connected/disconnected
function On_Train_Created(e)
  -- hacky guardian to make sure we don't ge caught in endless loop of connecting and disconnecting
  global.connection_counter = global.connection_counter + 1
  if global.connection_counter > 5 then return end

  local contains_ship_engine = false
  local parts = e.train.carriages

  -- check if rolling stock contains any ships (engines)
  for i = 1, #parts do
    if parts[i].name == "boat_engine" or parts[i].name == "cargo_ship_engine" then
      contains_ship_engine = true
      break
    end
  end

  --if no ships involved return
  if contains_ship_engine then
    -- if ship  has been split reconnect
    if #parts == 1 then
      -- reconnect!
      local engine = parts[1]
      local dir = engine.direction
      if engine.name == "boat_engine" then
        dir = (dir + 1) %2
      end
      engine.connect_rolling_stock(dir)

    -- else if ship has been overconnected split again
    elseif #parts > 2 then
      for i = 1, #parts do
        local check = false
        -- if front of ship-tuple, disconnect towards front (in direction)
        if parts[i].name == "cargo_ship" or parts[i].name == "oil_tanker" or parts[i].name == "boat_engine" then
          check = parts[i].disconnect_rolling_stock(parts[i].direction)

        -- if back of ship-tuple, disconnect towards back (in reverse direction)
        elseif parts[i].name == "boat" or parts[i].name == "cargo_ship_engine" then
          check = parts[i].disconnect_rolling_stock((parts[i].direction+1)%2)
        end
        -- stop when successful
        if check then
          break
        end
      end
    end
  end
end
