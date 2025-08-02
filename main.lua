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
    pockets = {}
    exile = {}
    tableImage = love.graphics.newImage("sprites/table.png")
    ballImages = {
        whiteBall  = love.graphics.newImage("sprites/bola branca.png"),
        redBall    = love.graphics.newImage("sprites/bola VERMELHA.png"),
        orangeBall = love.graphics.newImage("sprites/bola LARANJA.png"),
        yellowBall = love.graphics.newImage("sprites/bola AMARELA.png"),
        greenBall  = love.graphics.newImage("sprites/bola VERDE.png"),
        blueBall   = love.graphics.newImage("sprites/bola AZUL.png"),
        violetBall = love.graphics.newImage("sprites/bola VIOLETA.png"),
    }
    balltypes = {
        whiteBall = true,
        redBall = true,
        orangeBall = true,
        yellowBall = true,
        greenBall = true,
        blueBall = true,
        violetBall = true,
    }
    game_start(round)
    love.update = gameUpdate
end

function game_start(round)
    local function makeWall(x, y, w, h)
        local body = love.physics.newBody(world, x, y, "static")
        local shape = love.physics.newRectangleShape(w, h)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setFriction(0)
        fixture:setRestitution(0) -- handled manually
        fixture:setUserData("wall")
        table.insert(walls, {body=body, shape=shape})
    end

    local function makeBall(x, y, radius, ballType)
        local body = love.physics.newBody(world, x, y, "dynamic")
        local shape = love.physics.newCircleShape(radius)
        local fixture = love.physics.newFixture(body, shape, 1)
        fixture:setFriction(0)
        fixture:setRestitution(0) -- handled manually
        fixture:setUserData(ballType)
        body:setLinearDamping(0.5)
        return {body=body, shape=shape, type=ballType}
    end

    local function makePocket(x, y, radius)
        local body = love.physics.newBody(world, x, y, "static")
        local shape = love.physics.newCircleShape(radius)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setSensor(true) -- makes it a trigger, not a physical obstacle
        fixture:setUserData("pocket")
        table.insert(pockets, {body=body, shape=shape})
    end

    balls = {}
    walls = {}
    pockets = {}

    local radius = 4
    local minX = 10 + 10/2 + radius
    local maxX = 150 - 10/2 - radius
    local minY = 42 + 10/2 + radius
    local maxY = 108 - 10/2 - radius
    -- Create the white ball
    local x = love.math.random(minX, maxX)
    local y = love.math.random(minY, maxY)
    table.insert(balls, makeBall(x, y, radius, "whiteBall"))
    -- Create other balls
    local numBalls = math.min(5 + math.floor((round - 1) / 3), 18)
    for i = 1, numBalls do
        local x = love.math.random(minX, maxX)
        local y = love.math.random(minY, maxY)
        table.insert(balls, makeBall(x, y, radius, "greenBall"))
    end
    -- Create pockets
    local pocketRadius = 4.5
    makePocket(14, 46, pocketRadius)   -- top-left
    makePocket(146, 46, pocketRadius)  -- top-right
    makePocket(14, 104, pocketRadius)  -- bottom-left
    makePocket(146, 104, pocketRadius) -- bottom-right
    makePocket(80, 45, pocketRadius)   -- top-center
    makePocket(80, 105, pocketRadius)  -- bottom-center
    -- Create walls around the table
    makeWall(80, 39, 160, 10)   -- top wall
    makeWall(80, 111, 160, 10)  -- bottom wall
    makeWall(7, 72, 10, 144)    -- left wall
    makeWall(153, 72, 10, 144)  -- right wall
end

shotAngle = 0
function setStartingShotAngle()
    -- Set shot angle towards the ball nearest to the white ball, tracing a line between them
    local whiteBallBody = balls[1].body
    local nearestBall = nil
    local nearestDistance = math.huge
    for i = 2, #balls do
        local ballBody = balls[i].body
        local dx = ballBody:getX() - whiteBallBody:getX()
        local dy = ballBody:getY() - whiteBallBody:getY()
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestBall = ballBody
        end
    end
    if nearestBall then
        local dx = nearestBall:getX() - whiteBallBody:getX()
        local dy = nearestBall:getY() - whiteBallBody:getY()
        shotAngle = math.atan2(dy, dx)
    end
end

shotStrength = 0
hasShot = false
redPower = true
function shotStrengthUpdate(dt)
    shotStrength = shotStrength + (dt * 500)
    if shotStrength > 1000 then
        shotStrength = 0
    end
    world:update(dt)
end

function shotUpdate(dt)
    if love.keyboard.isDown("left") or  love.keyboard.isDown("up") then
        shotAngle = shotAngle - 0.0025  -- Adjust angle counter-clockwise
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("down") then
        shotAngle = shotAngle + 0.0025 -- Adjust angle clockwise
    end
    if love.keyboard.isDown("space") then
        love.update = shotStrengthUpdate
    end
    -- Update physics world
    world:update(dt)
end

function gameUpdate(dt)
    world:update(dt)
    -- Check every frame if a ball fell into a pocket
    for i = #balls, 1, -1 do
        local ball = balls[i]
        local ballX, ballY = ball.body:getPosition()
        for _, pocket in ipairs(pockets) do
            local px, py = pocket.body:getPosition()
            local dx, dy = ballX - px, ballY - py
            local distSq = dx*dx + dy*dy
            if distSq < (6 * 6) then
                ball.body:destroy()
                table.remove(balls, i)
                -- Remove all pockets from exile and add them back to pockets
                for _, ex in ipairs(exile) do table.insert(pockets, ex) end
                exile = {}
                if ball.type == "greenBall" then
                    -- Exile the pocket used
                    for i, p in ipairs(pockets) do
                        if p == pocket then
                            table.insert(exile, p)
                            table.remove(pockets, i)
                            break
                        end
                    end
                    -- Exile another random pocket if any remain
                    if #pockets > 0 then
                        local randomIndex = love.math.random(1, #pockets)
                        local randomPocket = pockets[randomIndex]
                        table.insert(exile, randomPocket)
                        table.remove(pockets, randomIndex)
                    end
                end
                break
            end
        end
    end
    -- Check if all balls in play are stationary
    local allStationary = true
    for _, ball in ipairs(balls) do
        local vx, vy = ball.body:getLinearVelocity()
        local speed = math.sqrt(vx*vx + vy*vy)
        if speed > 0.1 then
            allStationary = false
            break
        end
    end
    if allStationary then
        -- If there is only one ball left, start another round
        if #balls == 1 then
            round = round + 1
            game_start(round)
            return
        end
        -- If all balls are stationary, switch to shot update
        love.update = shotUpdate
        setStartingShotAngle()
        return
    end
end

function love.keypressed(key)
    if key == "space" then
        if love.update == shotUpdate then
            love.update = shotStrengthUpdate
            shotStrength = 0
            redPower = false
            hasShot = false
        elseif love.update == shotStrengthUpdate and not hasShot then
            local forceMagnitude = shotStrength
            local fx = forceMagnitude * math.cos(shotAngle)
            local fy = forceMagnitude * math.sin(shotAngle)
            balls[1].body:applyForce(fx, fy)
            hasShot = true
            redPower = true -- Reset red power for next shot
            shotStrength = 0
            love.update = gameUpdate
        end
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(gameScale, gameScale)
    love.graphics.draw(tableImage, 0, 0)
    for _, exile in ipairs(exile) do
        -- Exiled pocket indicator graphic
    end
    love.graphics.setColor(1, 1, 1)
    for _, ball in ipairs(balls) do
        img = ballImages[ball.type]
        love.graphics.draw(img, ball.body:getX()-4, ball.body:getY()-4)
    end
    if love.update == shotUpdate or love.update == shotStrengthUpdate then
        local whiteBallBody = balls[1].body
        local lineLength = 160
        local startX = whiteBallBody:getX()
        local startY = whiteBallBody:getY()
        local dirX = math.cos(shotAngle)
        local dirY = math.sin(shotAngle)
        local endX = startX + lineLength * dirX
        local endY = startY + lineLength * dirY
        -- Check for collision with walls using rayCast
        local hitX, hitY = nil, nil
        world:rayCast(startX, startY, endX, endY,
            function(fixture, x, y, xn, yn, fraction)
                -- stop at the first hit
                hitX, hitY = x, y
                return fraction -- returning fraction stops at first hit
            end
        )
        -- Use hit point if we found one
        if hitX and hitY then
            endX, endY = hitX, hitY
        end
        love.graphics.setColor(1, 0, 0)
        love.graphics.setLineWidth(1)
        love.graphics.line(startX, startY, endX, endY)
    end
    if love.update == shotStrengthUpdate then
        love.graphics.setColor(1, 1, 1)
        local whiteBallBody = balls[1].body
        local startX = whiteBallBody:getX()
        local startY = whiteBallBody:getY()
        -- draw shot strength bar
        local barWidth = 4
        local barHeight = 20
        local barX = startX + 5
        local barY = startY - barHeight
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
        love.graphics.setColor(1, 0, 0)
        local filledHeight = (shotStrength / 1000) * barHeight
        love.graphics.rectangle("fill", barX, barY + barHeight - filledHeight, barWidth, filledHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
    end
    love.graphics.setColor(1, 1, 1) -- Reset color
    love.graphics.pop()
end

function beginContact(fixtureA, fixtureB, contact)
    local function handleBallWallCollision(ballFixture, wallFixture, contact, inverse)
        local type = ballFixture:type()
        local ballBody = ballFixture:getBody()
        local nx, ny = contact:getNormal()
        -- Flip normal if needed (ensure it points toward ball)
        if inverse then
            nx, ny = -nx, -ny
        end
        -- Reflect velocity
        local vx, vy = ballBody:getLinearVelocity()
        local dot = vx * nx + vy * ny
        local rvx = vx - 2 * dot * nx
        local rvy = vy - 2 * dot * ny
        ballBody:setLinearVelocity(rvx, rvy)
    end
    local function handleBallBallCollision(ballFixtureA, ballFixtureB, contact)
        local ballA = ballFixtureA:getBody()
        local ballB = ballFixtureB:getBody()
        local ax, ay = ballA:getPosition()
        local bx, by = ballB:getPosition()
        local avx, avy = ballA:getLinearVelocity()
        local bvx, bvy = ballB:getLinearVelocity()
        local ma = ballA:getMass()
        local mb = ballB:getMass()
        -- Collision normal (unit vector)
        local nx, ny = bx - ax, by - ay
        local dist = math.sqrt(nx*nx + ny*ny)
        if dist == 0 then return end -- avoid division by zero
        nx, ny = nx/dist, ny/dist
        -- Relative velocity along the normal
        local relVel = (bvx - avx) * nx + (bvy - avy) * ny
        if relVel > 0 then return end -- balls are separating
        -- Coefficient of restitution (1 = perfectly bouncy)
        local e = 0.8
        -- Impulse scalar
        local j = -(1 + e) * relVel / (1/ma + 1/mb)
        -- Apply impulse along the normal
        local jx, jy = j * nx, j * ny
        -- If red ball is hitting another ball, apply extra force to both
        if ballFixtureA:getUserData() == "redBall" and redPower then
            ballA:setLinearVelocity(avx - 2 * jx/ma, avy - 2 * jy/ma)
            ballB:setLinearVelocity(bvx + 4 * jx/mb, bvy + 4 * jy/mb)
            redPower = false
        else
            ballA:setLinearVelocity(avx - jx/ma, avy - jy/ma)
            ballB:setLinearVelocity(bvx + jx/mb, bvy + jy/mb)
        end
        -- If the ball that was hit is an orange ball, it will emit a radial force to other nearby balls
        if ballFixtureA:getUserData() == "orangeBall" or ballFixtureB:getUserData() == "orangeBall" then
            local radius = 16
            for _, otherBall in ipairs(balls) do
                if otherBall.body ~= ballA and otherBall.body ~= ballB then
                    local ox, oy = otherBall.body:getPosition()
                    local dx, dy = ox - ax, oy - ay
                    local distSq = dx*dx + dy*dy
                    if distSq < radius * radius then
                        local forceMagnitude = 500 / math.sqrt(distSq)
                        otherBall.body:applyForce(forceMagnitude * dx, forceMagnitude * dy)
                    end
                end
            end
        end
    end
    -- Identify which is ball and which is wall
    if (balltypes[fixtureA:getUserData()]) and fixtureB:getUserData() == "wall" then
        handleBallWallCollision(fixtureA, fixtureB, contact, false)
    elseif (balltypes[fixtureB:getUserData()]) and fixtureA:getUserData() == "wall" then
        handleBallWallCollision(fixtureB, fixtureA, contact, true)
    else
        handleBallBallCollision(fixtureA, fixtureB, contact)
    end
end
