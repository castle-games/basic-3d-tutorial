require "constants"
Engine = require "engine"
cpml = require "cpml"

EndPosition = {0, 0}
WorldSize = 20
Map =  [[
        e   
xxxxxxxx xxx
xx x       x
xx xx  xxx x
xxxxxx   xxx
x    xxx   x
x xxxx   x x
x      x   x
xx xxxxxxxxx
            
            
            
            
  s         
]]

Blocks = {}
Ghosts = {}
WonGame = false

function resetGame()
    Engine.camera.pos.x = StartPosition[1] + 0.5
    Engine.camera.pos.z = StartPosition[2] + 0.5
    Engine.camera.angle = cpml.vec3(0, 0, 0)
    WonGame = false
end

function ground()
    local textureSize = 0.2

    rect({
        {WorldSize, 0, -WorldSize,  0,0,  0,1,0},
        {WorldSize, 0, WorldSize,  0,WorldSize * textureSize,  0,1,0},
        {-WorldSize, 0, WorldSize,  WorldSize * textureSize,WorldSize * textureSize,  0,1,0},
        {-WorldSize, 0, -WorldSize,  WorldSize * textureSize,0,  0,1,0}
    }, groundImage, 1.0)
end


function ghost(x, z)
    local model = rect({
        {-0.5, 0, 0,  0,1,  10,10,10},
        {-0.5, 1.2, 0,  0,0,  10,10,10},
        {0.5, 1.2, 0,  1,0,  10,10,10},
        {0.5, 0, 0,  1,1,  10,10,10}
    }, ghostImage, 1.0)
    
    table.insert(Ghosts, {x, z, model, true})
    model:setTransform({x, 0, z})
end

function box(x, z)
    table.insert(Blocks, {x, z})

    local m1 = rect({
        {0, 0, 1,  0,1,  0,0,1},
        {0, 1, 1,  0,0,  0,0,1},
        {1, 1, 1,  1,0,  0,0,1},
        {1, 0, 1,  1,1,  0,0,1}
    }, wallImage, 1.0)

    local m2 = rect({
        {1, 0, 0,  0,1,  1,0,0},
        {1, 1, 0,  0,0,  1,0,0},
        {1, 1, 1,  1,0,  1,0,0},
        {1, 0, 1,  1,1,  1,0,0}
    }, wallImage, 1.0)

    local m3 = rect({
        {0, 0, 0,  0,1,  -1,0,0},
        {0, 1, 0,  0,0,  -1,0,0},
        {0, 1, 1,  1,0,  -1,0,0},
        {0, 0, 1,  1,1,  -1,0,0}
    }, wallImage, 1.0)

    local m4 = rect({
        {0, 0, 0,  0,1,  0,0,-1},
        {0, 1, 0,  0,0,  0,0,-1},
        {1, 1, 0,  1,0,  0,0,-1},
        {1, 0, 0,  1,1,  0,0,-1}
    }, wallImage, 1.0)

    local models = {m1, m2, m3, m4}

    for k,v in pairs(models) do
        v:setTransform({x, 0, z})
    end
end

function skybox()
    local bottom = -15
    local top = 15
    local dy = 0.2

    -- front
    rect({
        {-WorldSize, bottom, -WorldSize,     0.25, 0.6666,   0,0,0},
        {-WorldSize, top, -WorldSize,      0.25, 0.3333,   0,0,0},
        {WorldSize, top, -WorldSize,       0.5, 0.3333,   0,0,0},
        {WorldSize, bottom, -WorldSize,      0.5, 0.6666,   0,0,0}
    }, skyboxImage, 1.0)

    -- top
    rect({
        {-WorldSize, top - dy, -WorldSize,     0.25, 0.3333,   0,0,0},
        {WorldSize, top - dy, -WorldSize,      0.5, 0.3333,   0,0,0},
        {WorldSize, top - dy, WorldSize,       0.5, 0,   0,0,0},
        {-WorldSize, top - dy, WorldSize,      0.25, 0,   0,0,0}
    }, skyboxImage, 1.0)

    -- right
    rect({
        {WorldSize, bottom, -WorldSize,     0.5, 0.6666,   0,0,0},
        {WorldSize, top, -WorldSize,      0.5, 0.3333,   0,0,0},
        {WorldSize, top, WorldSize,       0.75, 0.3333,   0,0,0},
        {WorldSize, bottom, WorldSize,      0.75, 0.6666,   0,0,0}
    }, skyboxImage, 1.0)

    -- back
    rect({
        {WorldSize, bottom, WorldSize,     0.75, 0.6666,   0,0,0},
        {WorldSize, top, WorldSize,      0.75, 0.3333,   0,0,0},
        {-WorldSize, top, WorldSize,     1, 0.3333,   0,0,0},
        {-WorldSize, bottom, WorldSize,    1, 0.66666,   0,0,0}
    }, skyboxImage, 1.0)

    -- left
    rect({
        {-WorldSize, bottom, WorldSize,     0, 0.6666,   0,0,0},
        {-WorldSize, top, WorldSize,      0, 0.3333,   0,0,0},
        {-WorldSize, top, -WorldSize,     0.25, 0.3333,   0,0,0},
        {-WorldSize, bottom, -WorldSize,    0.25, 0.6666,   0,0,0}
    }, skyboxImage, 1.0)

    -- bottom
    rect({
        {-WorldSize, bottom + dy, -WorldSize - 0.1,     0.25, 0.6666,   0,0,0},
        {-WorldSize, bottom + dy, WorldSize + 0.1,      0.25, 1.0,   0,0,0},
        {WorldSize, bottom + dy, WorldSize + 0.1,       0.5, 1.0,   0,0,0},
        {WorldSize, bottom + dy, -WorldSize - 0.1,      0.5, 0.6666,   0,0,0}
    }, skyboxImage, 1.0)
end

function love.load()
    GraphicsWidth = love.graphics.getWidth()
    GraphicsHeight = love.graphics.getHeight()
    InterfaceWidth, InterfaceHeight = GraphicsWidth, GraphicsHeight
    OffsetX = 0
    OffsetY = 0
    TimeElapsed = 0.0
    love.graphics.setBackgroundColor(0,0.7,0.95)
    love.graphics.setDefaultFilter("linear", "linear")
    love.graphics.setLineStyle("rough")

    love.graphics.setCanvas()

    Scene = Engine.newScene(GraphicsWidth, GraphicsHeight)

    wallImage = love.graphics.newImage("assets/wall.png")
    wallImage:setWrap('repeat','repeat')

    ghostImage = love.graphics.newImage("assets/ghost.png")

    skyboxImage = love.graphics.newImage("assets/skybox.png")
    skyboxImage:setWrap('repeat','repeat')

    groundImage = love.graphics.newImage("assets/ground.png")
    groundImage:setWrap('repeat','repeat')

    local z = 0
    for line in Map:gmatch("[^\r\n]+") do
        for x = 0, string.len(line) do
            local char = string.sub(line, x, x)
            if char == 'x' then
                box(x, z)
            elseif char == 's' then
                StartPosition = {x, z}
            elseif char == 'e' then
                EndPosition = {x, z}
            end
        end

        z = z + 1
    end

    ground()
    skybox()
    ghost(3, 8)

    for i = 1, 100 do
        ghost(math.random( 0, 10 ), math.random( 0, 10 ))
    end
    
    resetGame()
end

function love.mousepressed( x, y, button, istouch, presses )
    if button == 1 then
        local Camera = Engine.camera
        local pos = Camera.pos

        local cameraAngle = Camera.angle.x - math.pi/2.0
        local distance = 40.0

        local startBulletVec = {math.cos(Camera.angle.x) * 0.3, math.sin(Camera.angle.x) * 0.3}
        Scene:shoot(pos.x + startBulletVec[1], pos.y- 0.1, pos.z + startBulletVec[2], pos.x + math.cos(cameraAngle) * distance, pos.y, pos.z + math.sin(cameraAngle) * distance)
        Scene:shoot(pos.x - startBulletVec[1], pos.y- 0.1, pos.z - startBulletVec[2], pos.x + math.cos(cameraAngle) * distance, pos.y, pos.z + math.sin(cameraAngle) * distance)

        local pos = {pos.x, pos.z}
        local shootVec = {math.cos(cameraAngle) * 0.1, math.sin(cameraAngle) * 0.1}

        for i = 0, 10 * 10 do
            pos[1] = pos[1] + shootVec[1]
            pos[2] = pos[2] + shootVec[2]

            for k,v in pairs(Ghosts) do
                local ghostX = v[1] + 0.5
                local ghostZ = v[2] + 0.5
                local dist = math.sqrt(math.pow(pos[1] - ghostX, 2.0) + math.pow(pos[2] - ghostZ, 2.0))
                if dist < 0.2 then
                    v[4] = false
                end
            end
        end
    end
end

function isInSquare(pos, x, z)
    local d = 0.1

    local camX = pos.x
    local camZ = pos.z

    return camX >= x - d and camX <= x + 1 + d and camZ >= z - d and camZ <= z + 1 + d
end

--[[
1     2

4     3
]]--
function rect(coords, texture, scale)
    local model = Engine.newModel({ coords[1], coords[2], coords[4], coords[2], coords[3], coords[4] }, texture, nil, nil, nil, scale)
    table.insert(Scene.modelList, model)
    return model
end
function modelFromCoords(coords, texture, scale)
    local model = Engine.newModel(coords, texture, nil, nil, nil, scale)
    table.insert(Scene.modelList, model)
    return model
end

function modelFromCoordsColor(coords, color, scale)
    local model = Engine.newModel(coords, nil, nil, color, nil, scale)
    table.insert(Scene.modelList, model)
    return model
end
function addRectVerts(obj, coords)
    table.insert(obj, coords[1])
    table.insert(obj, coords[2])
    table.insert(obj, coords[4])
    table.insert(obj, coords[2])
    table.insert(obj, coords[3])
    table.insert(obj, coords[4])
end

function rectColor(coords, color, scale)
    local model = Engine.newModel({ coords[1], coords[2], coords[4], coords[2], coords[3], coords[4] }, nil, nil, color, nil, scale)
    table.insert(Scene.modelList, model)
    return model
end

function triColor(coords, color, scale)
    local model = Engine.newModel({ coords[1], coords[2], coords[3] }, nil, nil, color, nil, scale)
    table.insert(Scene.modelList, model)
    return model
end


function love.keypressed(key)
    if love.keyboard.isDown("c") then
        local isRelative = love.mouse.getRelativeMode()
        love.mouse.setRelativeMode(not isRelative)
    end

    if love.keyboard.isDown("space") and WonGame then
        resetGame()
    end
end

function love.update(dt)
    TimeElapsed = TimeElapsed + dt
    
    LogicAccumulator = LogicAccumulator+dt

    -- update 3d scene
    PhysicsStep = false
    if LogicAccumulator >= 1/LogicRate then
        dt = 1/LogicRate
        LogicAccumulator = LogicAccumulator - 1/LogicRate
        PhysicsStep = true
    else
        return
    end

    local speed = 2 * dt
    if love.keyboard.isDown("lctrl") then
        speed = speed * 10
    end
    local Camera = Engine.camera
    local pos = Camera.pos
    local newPos = {}
    
    local mul = (love.keyboard.isDown("w") or love.keyboard.isDown("up")) and 1 or ((love.keyboard.isDown("s") or love.keyboard.isDown("down")) and -1 or 0)
    newPos.x = pos.x + math.sin(math.pi - Camera.angle.x) * mul * speed
    newPos.z = pos.z + math.cos(math.pi - Camera.angle.x) * mul * speed
    
    local mul = (love.keyboard.isDown("d") or love.keyboard.isDown("right")) and -1 or ((love.keyboard.isDown("a") or love.keyboard.isDown("left")) and 1 or 0)
    newPos.x = newPos.x + math.cos(math.pi + Camera.angle.x) * mul * speed
    newPos.z = newPos.z + math.sin(math.pi + Camera.angle.x) * mul * speed

    local canMove = true
    for k,v in pairs(Blocks) do
        if isInSquare(newPos, v[1], v[2]) then
            canMove = false
        end
    end

    if canMove then
        pos.x = newPos.x
        pos.z = newPos.z
    end

    local cameraAngle = Camera.angle.x
    for k,v in pairs(Ghosts) do
        local y = math.cos(TimeElapsed * 1.2) * -0.05 - 0.2
        if not v[4] then
            y = -10
        end

        v[3]:setTransform({v[1] + 0.5, y, v[2] + 0.5}, {-cameraAngle, cpml.vec3.unit_y})
    end

    if isInSquare(Engine.camera.pos, EndPosition[1], EndPosition[2]) then
        WonGame = true
    end
end

function love.draw()
    Scene:render(true, TimeElapsed)

    -- draw HUD
    Scene:renderFunction(
        function ()
            love.graphics.setColor(FontColor[1], FontColor[2], FontColor[3], 1)
            love.graphics.print("FPS: " .. love.timer.getFPS(), 20, 20)
            love.graphics.print("[c] to capture or release mouse input", GraphicsWidth - 350, 20)
            
            love.graphics.setColor(1, 1, 1, 1)

            if WonGame then
                love.graphics.print("You won! Press space to restart", GraphicsWidth * 0.5 - 100, GraphicsHeight * 0.5 - 20)
            end
        end, true
    )
end

function love.mousemoved(x,y, dx,dy)
    -- forward mouselook to Scene object for first person camera control
    Scene:mouseLook(x,y, dx,dy)
end
