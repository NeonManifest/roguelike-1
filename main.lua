function love.load()
    love.physics.setMeter(1)  -- 1 pixel = 1 meter
    world = love.physics.newWorld(0, 0, true)
    gameCanvas = love.graphics.newCanvas(160, 144)
    local scale = 3
    love.window.setMode(160 * scale, 144 * scale, {resizable=false, vsync=false})
    gameScale = scale
    round = 1
    balls = {}
    walls = {}
    game_start(round)
end

function game_start(round)
    balls = {}
    walls = {}

    for i=1,5 do
        local body = love.physics.newBody(world, 40 + i*20, 100, "dynamic")
        local shape = love.physics.newCircleShape(4)
        local fixture = love.physics.newFixture(body, shape, 1)
        fixture:setRestitution(0.9)
        body:setLinearDamping(0.5)
        table.insert(balls, {body=body, shape=shape})
    end

    local function makeWall(x, y, w, h)
        local body = love.physics.newBody(world, x, y, "static")
        local shape = love.physics.newRectangleShape(w, h)
        love.physics.newFixture(body, shape)
        table.insert(walls, {body=body, shape=shape})
    end

    makeWall(80, 88, 128, 20)
    makeWall(80, 128, 128, 20)
    makeWall(26, 108, 20, 40)
    makeWall(134, 108, 20, 40)
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    love.graphics.scale(gameScale, gameScale)
    for _, b in ipairs(balls) do
        love.graphics.circle("fill", b.body:getX(), b.body:getY(), b.shape:getRadius())
    end
    for _, w in ipairs(walls) do
        love.graphics.polygon("line", w.body:getWorldPoints(w.shape:getPoints()))
    end
end