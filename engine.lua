-- Super Simple 3D Engine v1
-- groverburger 2019
-- https://raw.githubusercontent.com/groverburger/ss3d/master/engine.lua

cpml = require "cpml"

local engine = {}

-- create a new Model object
-- given a table of verts for example: { {0,0,0}, {0,1,0}, {0,0,1} }
-- each vert is its own table that contains three coordinate numbers, and may contain 2 extra numbers as uv coordinates
-- another example, this with uvs: { {0,0,0, 0,0}, {0,1,0, 1,0}, {0,0,1, 0,1} }
-- polygons are automatically created with three consecutive verts
function engine.newModel(verts, texture, coords, color, format, scale)
    local m = {}

    -- default values if no arguments are given
    if coords == nil then
        coords = {0,0,0}
    end
    if scale == nil then
        scale = 1.0
    end
    if color == nil then
        color = {1,1,1}
    end
    if format == nil then
        format = { 
            {"VertexPosition", "float", 3},
            {"VertexTexCoord", "float", 2},
            {"VertexNormal", "float", 3},
        }
    end
    if texture == nil then
        texture = love.graphics.newCanvas(1,1)
        love.graphics.setCanvas(texture)
        love.graphics.clear(unpack(color))
        love.graphics.setCanvas()
    end
    if verts == nil then
        verts = {}
    end

    -- translate verts by given coords
    for i=1, #verts do
        if coords[1] ~= 0.0 or coords[2] ~= 0.0 or coords[3] ~= 0.0 or scale ~= 1.0 then
            local newVert = {}
            newVert[1] = (verts[i][1] + coords[1]) * scale
            newVert[2] = (verts[i][2] + coords[2]) * scale
            newVert[3] = (verts[i][3] + coords[3]) * scale
            newVert[4] = verts[i][4]
            newVert[5] = verts[i][5]
            verts[i] = newVert
        end

        -- if not given uv coordinates, put in random ones
        if #verts[i] < 5 then
            verts[i][4] = love.math.random()
            verts[i][5] = love.math.random()
        end

        -- if not given normals, figure it out
        if #verts[i] < 8 then
            local polyindex = math.floor((i-1)/3)
            local polyfirst = polyindex*3 +1
            local polysecond = polyindex*3 +2
            local polythird = polyindex*3 +3

            local sn1 = {}
            sn1[1] = verts[polythird][1] - verts[polysecond][1]
            sn1[2] = verts[polythird][2] - verts[polysecond][2]
            sn1[3] = verts[polythird][3] - verts[polysecond][3]

            local sn2 = {}
            sn2[1] = verts[polysecond][1] - verts[polyfirst][1]
            sn2[2] = verts[polysecond][2] - verts[polyfirst][2]
            sn2[3] = verts[polysecond][3] - verts[polyfirst][3]

            local cross = UnitVectorOf(CrossProduct(sn1,sn2))

            verts[i][6] = cross[1]
            verts[i][7] = cross[2]
            verts[i][8] = cross[3]
        end
    end

    -- define the Model object's properties
    m.mesh = nil
    if #verts > 0 then
        m.mesh = love.graphics.newMesh(format, verts, "triangles")
        m.mesh:setTexture(texture)
    end
    m.texture = texture
    m.format = format
    m.verts = verts
    m.transform = TransposeMatrix(cpml.mat4.identity())
    m.color = color
    m.visible = true
    m.dead = false
    m.wireframe = false
    m.culling = false
    m.timeOffset = math.random(0, 10)

    m.setVerts = function (self, verts)
        if #verts > 0 then
            self.mesh = love.graphics.newMesh(self.format, verts, "triangles")
            self.mesh:setTexture(self.texture)
        end
        self.verts = verts
    end

    -- translate and rotate the Model
    m.setTransform = function (self, coords, rotations)
        if angle == nil then
            angle = 0
            axis = cpml.vec3.unit_y
        end
        self.transform = cpml.mat4.identity()
        self.transform:translate(self.transform, cpml.vec3(unpack(coords)))
        if rotations ~= nil then
            for i=1, #rotations, 2 do
                self.transform:rotate(self.transform, rotations[i],rotations[i+1])
            end
        end
        self.transform = TransposeMatrix(self.transform)
    end

    -- returns a list of the verts this Model contains
    m.getVerts = function (self)
        local ret = {}
        for i=1, #self.verts do
            ret[#ret+1] = {self.verts[i][1], self.verts[i][2], self.verts[i][3]}
        end

        return ret
    end

    -- prints a list of the verts this Model contains
    m.printVerts = function (self)
        local verts = self:getVerts()
        for i=1, #verts do
            print(verts[i][1], verts[i][2], verts[i][3])
            if i%3 == 0 then
                print("---")
            end
        end
    end

    -- set a texture to this Model
    m.setTexture = function (self, tex)
        self.mesh:setTexture(tex)
    end

    -- check if this Model must be destroyed
    -- (called by the parent Scene model's update function automatically)
    m.deathQuery = function (self)
        return not self.dead
    end

    return m
end

-- create a new Scene object with given canvas output size
function engine.newScene(renderWidth, renderHeight)
	love.graphics.setDepthMode("lequal", true)
    local scene = {}

    local particleVerts = {}
    for i = 0, 100000 do
        table.insert(particleVerts, {
            math.random() * 100 - 50,
            math.random() * 1 - 100,
            math.random() * 100 - 50,
        })
    end
    scene.particles = love.graphics.newMesh({
        {"VertexPosition", "float", 3},
    }, particleVerts, "points")



    local explosionParticleVerts = {}
    for i = 0, 100000 do
        table.insert(explosionParticleVerts, {
            0.0,
            -10.0,
            0.0,
            0.0,
            -10.0,
            0.0,
            0.0,
        })
    end
    scene.explosionParticles = love.graphics.newMesh({
        {"VertexPosition", "float", 3},
        {"endPosition", "float", 3},
        {"startTime", "float", 1},
        {"explosionSize", "float", 1}
    }, explosionParticleVerts, "points")
    scene.explosionParticles:setTexture(love.graphics.newImage("assets/particle.png"))
    scene.currentExplosionIdx = 1

    SPREAD = 0.05
    scene.shoot = function (self, x, y, z, targetX, targetY, targetZ)
        for i = 1, 10 do
            local rx = (math.random() - 0.5)
            local ry = (math.random() - 0.5)
            local rz = (math.random() - 0.5)

            explosionParticleVerts[scene.currentExplosionIdx] = {
                x + rx * SPREAD,
                y + ry * SPREAD,
                z + rz * SPREAD,
                targetX + rx * SPREAD,
                targetY + ry * SPREAD,
                targetZ + rz * SPREAD,
                TimeElapsed + math.random() * 0.2,
                1.0,
            }

            scene.currentExplosionIdx = scene.currentExplosionIdx + 1
            if scene.currentExplosionIdx >= 100000 then
                scene.currentExplosionIdx = 1
            end
        end

        scene.explosionParticles:setVertices(explosionParticleVerts)
    end




    -- define the shaders used in rendering the scene
    scene.threeShader = love.graphics.newShader[[
        uniform highp mat4 view;
        uniform highp mat4 model_matrix;
        uniform highp mat4 model_matrix_inverse;
        uniform highp vec3 light_pos;
        uniform highp vec3 view_pos;
        uniform highp float time_elapsed;

        varying highp vec3 frag_pos;
        varying highp vec3 normal;

        #ifdef VERTEX
        attribute highp vec4 VertexNormal;

        vec4 position(mat4 transform_projection, vec4 vertex_position) {
            normal = vec3(model_matrix_inverse * vec4(VertexNormal));
            
            vec4 p = vertex_position;
            vec4 result = view * model_matrix * p;

            frag_pos = vec3(model_matrix * p);

            return result;
        }
        #endif

        #ifdef PIXEL
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec2 coords = texture_coords;

            // if ghost
            if (length(normal) > 9.0) {
                coords.y *= 1.2;
                coords.y += cos(coords.y + time_elapsed * 3.0) * 0.1 - 0.1;
            }

            vec4 texturecolor = Texel(texture, coords);
            // if the alpha here is close to zero just don't draw anything here
            if (texturecolor.a == 0.0)
            {
                discard;
            }

            if (length(normal) > 0.0 && length(normal) < 10.0) {
                float ambientStrength = 1.2;
                float diffuseStrength = 2.0;
                float specularStrength = 1.8;

                // the ground
                if (normal.y > 0.8) {
                    ambientStrength = 0.3;
                }

                vec3 norm = normalize(normal);
                vec3 lightDir = normalize(light_pos - frag_pos);

                float diffuse = max(dot(norm, lightDir), 0.0);

                vec3 viewDir = normalize(view_pos - frag_pos);
                vec3 reflectDir = reflect(-lightDir, normal); 
                float specular = 0.5 * pow(max(dot(viewDir, reflectDir), 0.0), 32.0);

                texturecolor.rgb *= ambientStrength + diffuse * diffuseStrength + specular * specularStrength;
            } else if (length(normal) < 10.0) {
                texturecolor.rgb *= vec3(1.8, 1.0, 1.0);
            }

            // if ghost
            float alpha = 1.0;
            if (length(normal) > 9.0) {
                alpha = (cos(time_elapsed) + 1.0) * 0.2 + 0.4;
            }

            float fogDist = length(frag_pos - view_pos);
            float fogAmount = 0.0;
            if (fogDist > 0.5) {
                fogAmount = (fogDist - 0.5) / 3.0;
            }

            if (fogAmount > 0.8) {
                fogAmount = 0.8;
            }

            if (length(normal) == 0.0) {
                fogAmount = 0.0;
            }

            vec4 result = (1.0 - fogAmount) * (color * texturecolor) + fogAmount * vec4(0.0, 0.0, 0.0, 1.0);
            result.a = alpha;
            return result;
        }
        #endif
    ]]

    scene.explosionShader = love.graphics.newShader[[
        uniform highp mat4 view;
        uniform highp float time;
        uniform highp vec3 cameraPos;
        varying highp float dist;
        varying highp float percentDone;
        varying highp float explosionSizeV;


        #ifdef VERTEX
        attribute highp vec3 endPosition;
        attribute highp float startTime;
        attribute highp float explosionSize;
        vec4 position(mat4 transform_projection, vec4 vertex_position) {
            if (time - startTime > 0.5) {
                return vec4(0.0, -1000.0, 0.0, 1.0);
            }

            float percent = (time - startTime) / 0.5;
            vec4 vec = vec4(endPosition.x, endPosition.y, endPosition.z, 1.0) - vertex_position;
            vec4 pos = vertex_position + vec * percent;
            dist = length(vec3(pos.x, pos.y, pos.z) - cameraPos);
            percentDone = percent;
            explosionSizeV = explosionSize;
            vec4 result = view * pos;
            return result;
        }
        #endif


        #ifdef PIXEL
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec2 coord = gl_PointCoord - vec2(0.5);
            float radius = 0.5;
            radius = explosionSizeV * radius / dist;
            if (radius > 0.5) {
                radius = 0.5;
            }
            if(length(coord) > radius)
                discard;

            float percentX = ((coord.x / radius) + 1.0) / 2.0;
            float percentY = ((coord.y / radius) + 1.0) / 2.0;

            vec4 result = Texel(texture, vec2(percentX, percentY));
            if (result.a < 0.01 || result.r + result.g + result.b < 0.3) {
                discard;
            }
            result.a = 0.5;

            return result;
        }
        #endif
    ]]

    scene.renderWidth = renderWidth
    scene.renderHeight = renderHeight

    -- create a canvas that will store the rendered 3d scene
    scene.threeCanvas = love.graphics.newCanvas(renderWidth, renderHeight)
    -- create a canvas that will store a 2d layer that can be drawn on top of the 3d scene
    scene.twoCanvas = love.graphics.newCanvas(renderWidth, renderHeight)
    scene.modelList = {}

    engine.camera = {
        pos = cpml.vec3(2.5, 0.3, -3.5),
        angle = cpml.vec3(0, 0, 0),
        perspective = TransposeMatrix(cpml.mat4.from_perspective(60, renderWidth/renderHeight, 0.1, 10000)),
        transform = cpml.mat4(),
    }
    -- camera.perspective = TransposeMatrix(cpml.mat4.from_perspective(90, love.graphics.getWidth()/love.graphics.getHeight(), 0.001, 10000))

    scene.lightPos = {100,10,20}

    -- should be called in love.update every frame
    scene.update = function (self)
        local i = 1
        while i<=#(self.modelList) do
            local thing = self.modelList[i]
            if thing:deathQuery() then
                i=i+1
            else
                table.remove(self.modelList, i)
            end
        end
    end

    -- renders the models in the scene to the threeCanvas
    -- will draw threeCanvas if drawArg is not given or is true (use if you want to scale the game canvas to window)
    scene.render = function (self, drawArg, timeElapsed)
        love.graphics.clear(0,0,0,0)
        love.graphics.setColor(1,1,1)
        love.graphics.setCanvas({self.threeCanvas, depth=true})
        love.graphics.clear(0,0,0,0)
        love.graphics.setShader(self.threeShader)

        local Camera = engine.camera
        Camera.transform = cpml.mat4()
        local t, a = Camera.transform, Camera.angle
        local p = {}
        p.x = Camera.pos.x
        p.y = Camera.pos.y
        p.z = Camera.pos.z

        p.x = p.x * -1
        p.y = p.y * -1
        p.z = p.z * -1
        t:rotate(t, a.y, cpml.vec3.unit_x)
        t:rotate(t, a.x, cpml.vec3.unit_y)
        t:rotate(t, a.z, cpml.vec3.unit_z)
        t:translate(t, p)
        self.threeShader:send("view", Camera.perspective * TransposeMatrix(Camera.transform))
        self.threeShader:send("light_pos", self.lightPos)
        self.threeShader:send("view_pos", {Camera.pos.x, Camera.pos.y, Camera.pos.z})

        for i=1, #self.modelList do
            local model = self.modelList[i]
            if model ~= nil and model.visible and #model.verts > 0 then
                self.threeShader:send("model_matrix", model.transform)
                self.threeShader:send("model_matrix_inverse", TransposeMatrix(InvertMatrix(model.transform)))

                local time = TimeElapsed
                if model.timeOffset then
                    time = time + model.timeOffset
                end
                self.threeShader:send("time_elapsed", time)

                love.graphics.setWireframe(model.wireframe)
                if model.culling then
                    love.graphics.setMeshCullMode("back")
                end
                love.graphics.draw(model.mesh, -self.renderWidth/2, -self.renderHeight/2)
                love.graphics.setMeshCullMode("none")
                love.graphics.setWireframe(false)
            end
        end

        love.graphics.setShader(self.explosionShader)
        self.explosionShader:send("time", TimeElapsed)
        self.explosionShader:send("view", Camera.perspective * TransposeMatrix(Camera.transform))
        self.explosionShader:send("cameraPos", {Camera.pos.x, Camera.pos.y, Camera.pos.z})
        love.graphics.setPointSize(200)
        love.graphics.draw(self.explosionParticles, -self.renderWidth/2, -self.renderHeight/2)


        love.graphics.setCanvas()
        love.graphics.setShader()

        if drawArg == nil or drawArg == true then
            love.graphics.draw(self.threeCanvas, self.renderWidth/2,self.renderHeight/2, 0, 1, -1, self.renderWidth/2-OffsetX, self.renderHeight/2 - OffsetY)
        end
    end

    -- renders the given func to the twoCanvas
    -- this is useful for drawing 2d HUDS and information on the screen in front of the 3d scene
    -- will draw threeCanvas if drawArg is not given or is true (use if you want to scale the game canvas to window)
    scene.renderFunction = function (self, func, drawArg)
        love.graphics.setColor(1,1,1)
        love.graphics.setCanvas(Scene.twoCanvas)
        love.graphics.clear(0,0,0,0)
        func()
        love.graphics.setCanvas()

        local flip = 1
        --if shouldSwitchScreen() then
        --    flip = -1
        --
        
        if drawArg == nil or drawArg == true then
            love.graphics.draw(Scene.twoCanvas, self.renderWidth/2,self.renderHeight/2, 0, 1,flip, self.renderWidth/2 - OffsetX, self.renderHeight/2 - OffsetY)
        end
    end

    -- useful if mouse relativeMode is enabled
    -- useful to call from love.mousemoved
    -- a simple first person mouse look function
    scene.mouseLook = function (self, x, y, dx, dy)
        local Camera = engine.camera
        Camera.angle.x = Camera.angle.x + math.rad(dx * 0.5)
        Camera.angle.y = math.max(math.min(Camera.angle.y + math.rad(dy * 0.5), math.pi/2), -1*math.pi/2)
    end

    return scene
end

-- useful functions
function TransposeMatrix(mat)
	local m = cpml.mat4.new()
	return cpml.mat4.transpose(m, mat)
end
function InvertMatrix(mat)
	local m = cpml.mat4.new()
	return cpml.mat4.invert(m, mat)
end
function CopyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[CopyTable(orig_key)] = CopyTable(orig_value)
        end
        setmetatable(copy, CopyTable(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
function GetSign(n)
    if n > 0 then return 1 end
    if n < 0 then return -1 end
    return 0
end
function CrossProduct(v1,v2)
    local a = {x = v1[1], y = v1[2], z = v1[3]}
    local b = {x = v2[1], y = v2[2], z = v2[3]}

    local x, y, z
    x = a.y * (b.z or 0) - (a.z or 0) * b.y
    y = (a.z or 0) * b.x - a.x * (b.z or 0)
    z = a.x * b.y - a.y * b.x
    return { x, y, z } 
end
function UnitVectorOf(vector)
    local ab1 = math.abs(vector[1])
    local ab2 = math.abs(vector[2])
    local ab3 = math.abs(vector[3])
    local max = VectorLength(ab1, ab2, ab3)
    if max == 0 then max = 1 end

    local ret = {vector[1]/max, vector[2]/max, vector[3]/max}
    return ret
end
function VectorLength(x2,y2,z2) 
    local x1,y1,z1 = 0,0,0
    return ((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)^0.5 
end
function ScaleVerts(verts, sx,sy,sz)
    if sy == nil then
        sy = sx
        sz = sx
    end

    for i=1, #verts do
        local this = verts[i]
        this[1] = this[1]*sx
        this[2] = this[2]*sy
        this[3] = this[3]*sz
    end

    return verts
end
function MoveVerts(verts, sx,sy,sz)
    if sy == nil then
        sy = sx
        sz = sx
    end

    for i=1, #verts do
        local this = verts[i]
        this[1] = this[1]+sx
        this[2] = this[2]+sy
        this[3] = this[3]+sz
    end

    return verts
end

return engine
