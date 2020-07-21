require "glua"
glua.patch()

local vec = Vector(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

print(Scene():isA("Scene"))

local clickp = Particle({0.5,0.5,0.5}, {1,0,0,0}, {0,0,1,0}, 1, 0.5, 2, love.graphics.newImage("test.png"), 1, 1, -1, 1, -1, 1, 0.98, 0, nil, 0, 0, 0)

function love.mousepressed(x, y, button)
	if button == 1 then
		addParticle(clickp, x, y)
	end
end

function love.update(dt)
	vec.x = dt + vec.x
	vec.y = vec.x * vec.z + 0.1
	vec.z = dt * vec.y + 0.1
	vec.r = vec.q / vec.z
	vec.q = (vec.sum / vec.q) * vec.z / vec.x
	updateParticles(dt)
end

function love.draw()
	love.graphics.print(love.timer.getFPS())
	for i, v in ipairs(vec) do
		love.graphics.line(10, i*10 + 0.5, 10 + (v * 100), i*10 + 0.5)
	end
	drawParticles()
end