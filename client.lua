require "constants"
Engine = require "engine"

WorldSize = 20

function resetGame()
   
end

function ground()
    local textureSize = 0.2

    rect({
        {WorldSize, -1, -WorldSize,  0,0,  0,1,0},
        {WorldSize, -1, WorldSize,  0,WorldSize * textureSize,  0,1,0},
        {-WorldSize, -1, WorldSize,  WorldSize * textureSize,WorldSize * textureSize,  0,1,0},
        {-WorldSize, -1, -WorldSize,  WorldSize * textureSize,0,  0,1,0}
    }, groundImage, 1.0)
end

function box()
    rect({
        {-1, -1, 1,  0,1,  0,0,1},
        {-1, 1, 1,  0,0,  0,0,1},
        {1, 1, 1,  1,0,  0,0,1},
        {1, -1, 1,  1,1,  0,0,1}
    }, wallImage, 1.0)

    rect({
        {1, -1, -1,  0,1,  1,0,0},
        {1, 1, -1,  0,0,  1,0,0},
        {1, 1, 1,  1,0,  1,0,0},
        {1, -1, 1,  1,1,  1,0,0}
    }, wallImage, 1.0)

    rect({
        {-1, -1, -1,  0,1,  -1,0,0},
        {-1, 1, -1,  0,0,  -1,0,0},
        {-1, 1, 1,  1,0,  -1,0,0},
        {-1, -1, 1,  1,1,  -1,0,0}
    }, wallImage, 1.0)

    rect({
        {-1, -1, -1,  0,1,  0,0,-1},
        {-1, 1, -1,  0,0,  0,0,-1},
        {1, 1, -1,  1,0,  0,0,-1},
        {1, -1, -1,  1,1,  0,0,-1}
    }, wallImage, 1.0)
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

    skyboxImage = love.graphics.newImage("assets/skybox.png")
    skyboxImage:setWrap('repeat','repeat')

    groundImage = love.graphics.newImage("assets/ground.png")
    groundImage:setWrap('repeat','repeat')

    ground()
    box()
    skybox()
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

    --local turnDirection = love.keyboard.isDown("left") and -1 or (love.keyboard.isDown("right") and 1 or 0)
end

function love.update(dt)
    TimeElapsed = TimeElapsed + dt
    Scene:basicCamera(dt)
    
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
        end, true
    )
end

function love.mousemoved(x,y, dx,dy)
    -- forward mouselook to Scene object for first person camera control
    Scene:mouseLook(x,y, dx,dy)
end
