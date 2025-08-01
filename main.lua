function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)

    -- Register collision callback
    world:setCallbacks(beginContact)

    gameCanvas = love.graphics.newCanvas(160, 144)
    local scale = 3
    love.window.setMode(160 * scale, 144 * scale, {resizable=false, vsync=false})
    gameScale = scale
    round = 1
    balls = {}
    walls = {}
    tableImage = love.graphics.newImage("sprites/table.png")

    game_start(round)
end

function game_start(round)
    balls = {}
    walls = {}

    local numBalls = math.min(5 + math.floor((round - 1) / 3), 18)
    for i = 1, numBalls do
        local radius = 3
        local minX = 10 + 10/2 + radius
        local maxX = 150 - 10/2 - radius
        local minY = 42 + 10/2 + radius
        local maxY = 108 - 10/2 - radius
        local x = love.math.random(minX, maxX)
        local y = love.math.random(minY, maxY)

        local body = love.physics.newBody(world, x, y, "dynamic")
        local shape = love.physics.newCircleShape(radius)
        local fixture = love.physics.newFixture(body, shape, 1)
        fixture:setFriction(0)
        fixture:setRestitution(0) -- handled manually
        fixture:setUserData("ball")

        body:setLinearDamping(0.5)
        table.insert(balls, {body=body, shape=shape})
    end

    local function makeWall(x, y, w, h)
        local body = love.physics.newBody(world, x, y, "static")
        local shape = love.physics.newRectangleShape(w, h)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setFriction(0)
        fixture:setRestitution(0) -- handled manually
        fixture:setUserData("wall")
        table.insert(walls, {body=body, shape=shape})
    end

    -- Create walls around the table
    makeWall(80, 39, 160, 10)   -- top wall
    makeWall(80, 111, 160, 10)  -- bottom wall
    makeWall(7, 72, 10, 144)    -- left wall
    makeWall(153, 72, 10, 144)  -- right wall
end

-- Timer for applying force
i = 0
function love.update(dt)
    i = i + dt
    if i > 5 then
        if #balls > 0 then
            local ball = balls[1]
            local vx, vy = ball.body:getLinearVelocity()
            if vx == 0 and vy == 0 then
                local forceX = love.math.random(0, 1) == 0 and -500 or 500
                local forceY = love.math.random(0, 1) == 0 and -500 or 500
                ball.body:applyForce(forceX, forceY)
            end
        end
        i = 0
    end
    world:update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(gameScale, gameScale)
    love.graphics.draw(tableImage, 0, 0)
    for _, ball in ipairs(balls) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    end
    love.graphics.pop()
end

-- BEGIN CONTACT: Manual reflection bounce
function beginContact(fixtureA, fixtureB, contact)
    local ballFixture, wallFixture

    -- Identify which is ball and which is wall
    if fixtureA:getUserData() == "ball" and fixtureB:getUserData() == "wall" then
        ballFixture, wallFixture = fixtureA, fixtureB
    elseif fixtureB:getUserData() == "ball" and fixtureA:getUserData() == "wall" then
        ballFixture, wallFixture = fixtureB, fixtureA
    else
        return
    end

    local ballBody = ballFixture:getBody()
    local nx, ny = contact:getNormal()

    -- Flip normal if needed (ensure it points toward ball)
    if ballFixture == fixtureB then
        nx, ny = -nx, -ny
    end

    -- Reflect velocity
    local vx, vy = ballBody:getLinearVelocity()
    local dot = vx * nx + vy * ny
    local rvx = vx - 2 * dot * nx
    local rvy = vy - 2 * dot * ny
    ballBody:setLinearVelocity(rvx, rvy)
end
