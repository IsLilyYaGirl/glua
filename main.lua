require "glua"
glua.patch()

local vec = Vector(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

print((Scene()):isA("Scene"))

function love.update(dt)
	vec.x = dt + vec.x
	vec.y = vec.x * vec.z + 0.1
	vec.z = dt * vec.y + 0.1
	vec.r = vec.q / vec.z
	vec.q = (vec.sum / vec.q) * vec.z / vec.x
end

function love.draw()
	for i, v in ipairs(vec) do
		love.graphics.line(10, i*10 + 0.5, 10 + (v * 100), i*10 + 0.5)
	end
end