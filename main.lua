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
    mushroomImages = {
        redMushroom = love.graphics.newImage("sprites/cogumelo grande vermelho 1.png"),
        redToadstool = love.graphics.newImage("sprites/cogumelo grande vermelho 2.png"),
        redAgaric = love.graphics.newImage("sprites/cogumelo grande vermelho 3.png"),
        orangeMushroom = love.graphics.newImage("sprites/cogumelo grande violeta 3.png"),
        orangeToadstool = love.graphics.newImage("sprites/cogumelo grande violeta 3.png"),
        orangeAgaric = love.graphics.newImage("sprites/cogumelo grande violeta 3.png"),
        yellowMushroom = love.graphics.newImage("sprites/cogumelo grande amarelo 1.png"),
        yellowToadstool = love.graphics.newImage("sprites/cogumelo grande amarelo 2.png"),
        yellowAgaric = love.graphics.newImage("sprites/cogumelo grande amarelo 3.png"),
        greenMushroom = love.graphics.newImage("sprites/cogumelo grande verde 1.png"),
        blueMushroom = love.graphics.newImage("sprites/cogumelo grande violeta 3.png"),
        blueToadstool = love.graphics.newImage("sprites/cogumelo grande violeta 3.png"),
        violetMushroom = love.graphics.newImage("sprites/cogumelo grande violeta 1.png"),
        violetToadstool = love.graphics.newImage("sprites/cogumelo grande violeta 2.png"),
    }
    mushroomThumbnails = {
        redMushroom = love.graphics.newImage("sprites/cogumelo vermelho 1.png"),
        redToadstool = love.graphics.newImage("sprites/cogumelo vermelho 2.png"),
        redAgaric = love.graphics.newImage("sprites/cogumelo vermelho 3.png"),
        orangeMushroom = love.graphics.newImage("sprites/cogumelo laranja 1.png"),
        orangeToadstool = love.graphics.newImage("sprites/cogumelo laranja 2.png"),
        orangeAgaric = love.graphics.newImage("sprites/cogumelo laranja 3 .png"),
        yellowMushroom = love.graphics.newImage("sprites/cogumelo amarelo 1.png"),
        yellowToadstool = love.graphics.newImage("sprites/cogumelo amarelo 2.png"),
        yellowAgaric = love.graphics.newImage("sprites/cogumelo amarelo 3.png"),
        greenMushroom = love.graphics.newImage("sprites/cogumelo verde 1.png"),
        blueMushroom = love.graphics.newImage("sprites/cogumelo azul 1.png"),
        blueToadstool = love.graphics.newImage("sprites/cogumelo azul 2.png"),
        violetMushroom = love.graphics.newImage("sprites/cogumelo violeta 2.png"),
        violetToadstool = love.graphics.newImage("sprites/cogumelo violeta 3.png")
    }
    exileMarker = love.graphics.newImage("sprites/x (bloqueio de buraco).png")
    lifeIcon = love.graphics.newImage("sprites/icone de vida.png")
    lifeIconEmpty = love.graphics.newImage("sprites/icone de vida  vazio.png")
    moneyIcon = love.graphics.newImage("sprites/icone money.png")
    player = {
        lives = 3,
        maxLives = 3,
        score = 0,
        money = 0,
        moneyPerBall = 1,
        moneyPerPrizePocket = 1,
        strength = 1,
        priceMod = 0,
        mushrooms = {},
        redDrop = 1,
        orangeDrop = 1,
        yellowDrop = 1,
        greenDrop = 1,
        blueDrop = 1,
        violetDrop = 1,
        redBallPower = 1,
        orangeBallPower = 1,
        moneyPerRound = 0,
        ballDampingModifier = 1,
        ballRestitutionModifier = 1,
        violetBallPower = 1,
        violetBallSpread = 1
    }

    shopItems = {
        {
            name = "Red Mushroom",
            desc = "+10% strength",
            graphic = mushroomImages.redMushroom,
            thumbnail = mushroomThumbnails.redMushroom,
            price = function() return 3 + player.priceMod end,
            effect = function() player.strength = player.strength * 1.1 end
        },
        {
            name = "Red Toadstool",
            desc = "Increases red ball power",
            graphic = mushroomImages.redToadstool,
            thumbnail = mushroomThumbnails.redToadstool,
            price = function() return 4 + player.priceMod end,
            effect = function() player.redBallPower = player.redBallPower + 0.25 end
        },
        {
            name = "Red Agaric",
            desc = "Red balls appear more often",
            graphic = mushroomImages.redAgaric,
            thumbnail = mushroomThumbnails.redAgaric,
            price = function() return 5 + player.priceMod end,
            effect = function() player.redDrop = player.redDrop + 1 end
        },
        {
            name = "Orange Mushroom",
            desc = "+1 Max Lives",
            graphic = mushroomImages.orangeMushroom,
            thumbnail = mushroomThumbnails.orangeMushroom,
            price = function() return 4 + player.priceMod end,
            effect = function()
                player.maxLives = player.maxLives + 1
                player.lives = player.lives + 1
            end
        },
        {
            name = "Orange Toadstool",
            desc = "Increases orange ball power",
            graphic = mushroomImages.orangeToadstool,
            thumbnail = mushroomThumbnails.orangeToadstool,
            price = function() return 4 + player.priceMod end,
            effect = function() player.orangeBallPower = player.orangeBallPower + 0.25 end
        },
        {
            name = "Orange Agaric",
            desc = "Orange balls appear more often",
            graphic = mushroomImages.orangeAgaric,
            thumbnail = mushroomThumbnails.orangeAgaric,
            price = function() return 5 + player.priceMod end,
            effect = function() player.orangeDrop = player.orangeDrop + 1 end
        },
        {
            name = "Yellow Mushroom",
            desc = "Gain +1$ money per round",
            graphic = mushroomImages.yellowMushroom,
            thumbnail = mushroomThumbnails.yellowMushroom,
            price = function() return 2 + player.priceMod end,
            effect = function() player.moneyPerRound = player.moneyPerRound + 1 end
        },
        {
            name = "Yellow Toadstool",
            desc = "Gain +$1 money per ball pocketed",
            graphic = mushroomImages.yellowToadstool,
            thumbnail = mushroomThumbnails.yellowToadstool,
            price = function() return 2 + player.priceMod end,
            effect = function() player.moneyPerBall = (player.moneyPerBall or 0) + 1 end
        },
        {
            name = "Yellow Agaric",
            desc = "Gain +$2 money per prize pocket",
            graphic = mushroomImages.yellowAgaric,
            thumbnail = mushroomThumbnails.yellowAgaric,
            price = function() return 2 + player.priceMod end,
            effect = function() player.moneyPerPrizePocket = player.moneyPerPrizePocket + 2 end
        },
        {
            name = "Green Mushroom",
            desc = "Gain +$2 money per prize pocket",
            graphic = mushroomImages.greenMushroom,
            thumbnail = mushroomThumbnails.greenMushroom,
            price = function() return 2 + player.priceMod end,
            effect = function() player.lives = math.min(player.lives + 1, player.maxLives) end
        },
        {
            name = "Blue Mushroom",
            desc = "Reduces friction",
            graphic = mushroomImages.blueMushroom,
            thumbnail = mushroomThumbnails.blueMushroom,
            price = function() return 4 + player.priceMod end,
            effect = function() player.ballDampingModifier = player.ballDampingModifier * 1.1 end
        },
        {
            name = "Blue Toadstool",
            desc = "Makes every ball bouncier",
            graphic = mushroomImages.blueToadstool,
            thumbnail = mushroomThumbnails.blueToadstool,
            price = function() return 4 + player.priceMod end,
            effect = function() player.ballRestitutionModifier = player.ballRestitutionModifier * 1.1 end
        },
        {
            name = "Violet Mushroom",
            desc = "Gives violet balls red power",
            graphic = mushroomImages.violetMushroom,
            thumbnail = mushroomThumbnails.violetMushroom,
            price = function() return 5 + player.priceMod end,
            effect = function() player.violetBallPower = player.violetBallPower + 0.25 end
        },
        {
            name = "Violet Toadstool",
            desc = "Gives violet balls orange power",
            graphic = mushroomImages.violetToadstool,
            thumbnail = mushroomThumbnails.violetToadstool,
            price = function() return 5 + player.priceMod end,
            effect = function() player.violetBallSpread = player.violetBallSpread * 0.25 end
        }
    }

    local font = love.graphics.newFont("font/EnterCommand-Bold.ttf", 16)
    font:setFilter("nearest")
    love.graphics.setFont(font)

    --initializeShop()
    --love.update = shopUpdate
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
        if ballType == "blueBall" then
            fixture:setFriction(0)
            fixture:setRestitution(0) -- handled manually
            fixture:setUserData(ballType)
            body:setLinearDamping(0.25)
            return {body=body, shape=shape, type=ballType}
        end
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
    local numBalls = math.min(5 + math.floor((round - 1) / 3), 16)
    local ballTypeList = {}
    for ballName in pairs(balltypes) do
        if ballName ~= "whiteBall" then
            table.insert(ballTypeList, ballName)
        end
    end
    for i = 1, numBalls do
        local x = love.math.random(minX, maxX)
        local y = love.math.random(minY, maxY)
        -- Randomly choose ball type
        local ballType = ballTypeList[love.math.random(1, #ballTypeList)]
        table.insert(balls, makeBall(x, y, radius, ballType))
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

function loseLife(amount)
    player.lives = player.lives - amount
    if player.lives <= 0 then
        player.lives = 0
        -- Reset the game state
        love.load()
    end
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
ballPocketed = true
function shotStrengthUpdate(dt)
    shotStrength = shotStrength + (dt * 500)
    if shotStrength > 1000 then
        shotStrength = 0
    end
    world:update(dt)
end

function shotUpdate(dt)
    ballPocketed = false
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
                ballPocketed = true
                ball.body:destroy()
                table.remove(balls, i)
                -- Remove all pockets from exile and add them back to pockets
                for _, ex in ipairs(exile) do table.insert(pockets, ex) end
                exile = {}
                if ball.type == "whiteBall" then
                    -- If the white ball is pocketed, lose a life
                    loseLife(1)
                    -- balls[1]'s type changes to "whiteBall" again
                    balls[1].type = "whiteBall"
                    return
                end
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
                player.money = player.money + player.moneyPerBall
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
            player.money = player.money + player.moneyPerRound
            initializeShop()
            love.update = shopUpdate
            return
        end
        if not ballPocketed then
            player.lives = player.lives - 1
            if player.lives <= 0 then
                love.load()
            end
        end
        -- If all balls are stationary, switch to shot update
        love.update = shotUpdate
        setStartingShotAngle()
        return
    end
end

rerollPrice = 3
availableItems = {}
selectedIndexX = 2
selectedIndexY = 2
function initializeShop()
    rerollPrice = 3
    availableItems = {}
    for i = 1, 3 do
        local randomIndex = love.math.random(1, #shopItems)
        table.insert(availableItems, shopItems[randomIndex])
    end
end

function rerollShop()
    if player.money >= rerollPrice then
        availableItems = {}
        for i = 1, 3 do
            local randomIndex = love.math.random(1, #shopItems)
            table.insert(availableItems, shopItems[randomIndex])
        end
        player.money = player.money - rerollPrice
        return true
    else
        return false
    end
end

function buy(item)
    if player.money >= item.price() then
        item.effect()
        player.money = player.money - item.price()
        player.priceMod = player.priceMod + 1 -- Increase price for next items
        return true
    else
        return false 
    end
end

function finalizeShop()
    round = round + 1
    -- Reset the game state for the next round
    game_start(round)
    love.update = gameUpdate
end

function shopUpdate(dt)
end

function love.keypressed(key)
    if love.update == shopUpdate then
        local topRowCount = 2  -- buttons count (no items here)
        local bottomRowCount = #availableItems  -- all items on row 2
        if key == "left" then
            if selectedIndexY == 1 then
                -- toggle between 1 and 2 for buttons
                selectedIndexX = 3 - selectedIndexX
            elseif selectedIndexY == 2 and bottomRowCount > 0 then
                selectedIndexX = selectedIndexX - 1
                if selectedIndexX < 1 then
                    selectedIndexX = bottomRowCount -- wrap left
                end
            end
        elseif key == "right" then
            if selectedIndexY == 1 then
                selectedIndexX = 3 - selectedIndexX
            elseif selectedIndexY == 2 and bottomRowCount > 0 then
                selectedIndexX = selectedIndexX + 1
                if selectedIndexX > bottomRowCount then
                    selectedIndexX = 1 -- wrap right
                end
            end
        elseif key == "down" then
            if selectedIndexY == 1 and bottomRowCount > 0 then
                selectedIndexY = 2
                selectedIndexX = math.floor((bottomRowCount + 1) / 2)
            end
        elseif key == "up" then
            if selectedIndexY == 2 then
                selectedIndexY = 1
                local midpoint = math.ceil(bottomRowCount / 2)
                if selectedIndexX <= midpoint then
                    selectedIndexX = 1
                else
                    selectedIndexX = 2
                end
            end
        elseif key == "space" then
            -- Buy the selected item
            if selectedIndexY == 2 and availableItems[selectedIndexX] then
                local item = availableItems[selectedIndexX]
                if buy(item) then
                    -- Successfully bought item, remove it from available items
                    table.remove(availableItems, selectedIndexX)
                    -- Reset selection
                    selectedIndexX = 1
                end
            end
        end
        return
    end
    -- Gameplay space handling
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
    -- Render player money
    local moneyX = 130
    local moneyY = 130
    local moneyIconSize = 8
    love.graphics.draw(moneyIcon, moneyX, moneyY, 0, moneyIconSize / moneyIcon:getWidth(), moneyIconSize / moneyIcon:getHeight())
    love.graphics.print(player.money, moneyX + moneyIconSize + 2, moneyY - moneyIconSize / 2)
    -- Render player lives
    local livesX = 10
    local livesY = 130
    local livesIconSize = 8
    for i = 1, player.maxLives do
        if i <= player.lives then
            love.graphics.draw(lifeIcon, livesX + (i-1) * (livesIconSize + 2), livesY, 0, livesIconSize / lifeIcon:getWidth(), livesIconSize / lifeIcon:getHeight())
        else
            love.graphics.draw(lifeIconEmpty, livesX + (i-1) * (livesIconSize + 2), livesY, 0, livesIconSize / lifeIconEmpty:getWidth(), livesIconSize / lifeIconEmpty:getHeight())
        end
    end
    if love.update == shopUpdate then
        local w, h = 160, 144
        local font = love.graphics.getFont()
        -- Bottom row items
        local itemsY = 50
        local itemCount = #availableItems
        local spacing = w / (itemCount + 1)
        for i, item in ipairs(availableItems) do
            local img = item.graphic
            local iw, ih = img:getDimensions()
            local x = spacing * i - iw/2
            love.graphics.draw(img, x, itemsY)
            -- Price centered above
            local priceText = "$" .. item.price()
            local ptw = font:getWidth(priceText)
            love.graphics.print(priceText, x + iw/2 - ptw/2, itemsY - 16)
        end
        -- Highlight selected item (selectedIndexX only, on bottom row)
        if selectedIndexY == 2 then
            local sel = selectedIndexX or 1
            if availableItems[sel] then
                local img = availableItems[sel].graphic
                local iw, ih = img:getDimensions()
                local x = spacing * sel - iw/2
                love.graphics.setColor(1, 1, 0, 0.5)
                love.graphics.rectangle("fill", x, itemsY, iw, ih)
                love.graphics.setColor(1, 1, 1)
            end
        end
        -- Text box with highlighted item info
        local infoX = 10
        local infoY = 76
        local infoWidth = w - 20
        local infoHeight = 30
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", infoX, infoY, infoWidth, infoHeight)
        love.graphics.setColor(1, 1, 1)
        if selectedIndexY == 2 and availableItems[selectedIndexX] then
            local item = availableItems[selectedIndexX]
            love.graphics.printf(item.name, infoX + 5, infoY + 5, infoWidth - 10, "left")
            love.graphics.printf(item.desc, infoX + 5, infoY + 20, infoWidth - 10, "left")
        else
            love.graphics.printf("Select an item to see details", infoX + 5, infoY + 5, infoWidth - 10, "left")
        end
        love.graphics.pop()
        return
    end

    love.graphics.setColor(1,1,1)
    love.graphics.draw(tableImage, 0, 0)
    for _, exile in ipairs(exile) do
        -- Exiled pocket indicator graphic
        love.graphics.draw(exileMarker, exile.body:getX() - 3, exile.body:getY() - 3)
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
        local e = 0.95
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
