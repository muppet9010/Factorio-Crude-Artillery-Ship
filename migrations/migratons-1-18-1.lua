for _, force in pairs(game.forces) do
    if force.technologies["artillery"].researched then
        force.recipes["artillery_ship"].enabled = true
    end
end
