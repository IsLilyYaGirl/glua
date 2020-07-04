glua = {}

glua._type = type
glua._tst = tostring
glua._tnm = tonumber
glua._mt = {}
glua.particles = {}
--glua.physicsObjects = {}

local _rawset = rawset

rawset = nil
debug = nil

function glua._tb(v)
	if type(v) == "number" then
		return v ~= 0
	elseif type(v) == "string" then
		if string.lower(v) == "false" then
			return false
		else
			return true
		end
	elseif type(v) == "boolean" then
		return v
	else
		return true
	end
end

function type(o)
	local ctype = glua._type(o)
	if ctype == "table" then
		if getmetatable(o) ~= nil then
			return getmetatable(o).type or "table"
		else
			return "table"
		end
	else
		return ctype
	end
end

function tostring(o, ...)
	if glua._type(o) == "table" then
		if getmetatable(o) ~= nil then
			if getmetatable(o).type ~= nil then
				if getmetatable(o).tostring ~= nil then
					return getmetatable(o).tostring(o, ...)
				else
					return getmetatable(o).type
				end
			else
				return glua._tst(o, ...)
			end
		else
			return glua._tst(o, ...)
		end
	else
		return glua._tst(o, ...)
	end
end

function tonumber(o, ...)
	if glua._type(o) == "table" then
		if getmetatable(o) ~= nil then
			if getmetatable(o).type ~= nil then
				if getmetatable(o).tonumber ~= nil then
					return getmetatable(o).tonumber(o, ...)
				else
					return nil
				end
			else
				return glua._tnm(o, ...)
			end
		else
			return glua._tnm(o, ...)
		end
	else
		return glua._tnm(o, ...)
	end
end

function tobool(o)
	if glua._type(o) == "table" then
		if getmetatable(o) ~= nil then
			if getmetatable(o).type ~= nil then
				if getmetatable(o).tobool ~= nil then
					return getmetatable(o).tobool(o)
				else
					return false
				end
			else
				return glua._tb(o)
			end
		else
			return glua._tb(o)
		end
	else
		return glua._tb(o)
	end
end

local function copy(obj, seen) -- snippet
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

function glua.drawAnim(anim, x, y, r, flip)
	local spriteNum = math.floor(anim.currentTime / anim.duration * #anim.quads) + 1
	if spriteNum < 1 then return end
	if flip then
		love.graphics.draw(anim.spriteSheet, anim.quads[spriteNum], (x or 0) + (anim.width / 2), (y or 0) + (anim.height / 2), math.rad((r or 90) - 90), -1, 1, anim.width / 2, anim.height / 2)
	else
		love.graphics.draw(anim.spriteSheet, anim.quads[spriteNum], (x or 0) + (anim.width / 2), (y or 0) + (anim.height / 2), math.rad((r or 90) - 90), 1, 1, anim.width / 2, anim.height / 2)
	end
end

function glua.drawTile(anim, x, y, r, flip)
	local spriteNum = (anim.duration - math.floor(anim.duration - anim.currentTime)) + 1
	if spriteNum < 1 then return end
	if flip then
		love.graphics.draw(anim.spriteSheet, anim.quads[spriteNum], (x or 0) + (anim.width / 2), (y or 0) + (anim.height / 2), math.rad((r or 90) - 90), -1, 1, anim.width / 2, anim.height / 2)
	else
		love.graphics.draw(anim.spriteSheet, anim.quads[spriteNum], (x or 0) + (anim.width / 2), (y or 0) + (anim.height / 2), math.rad((r or 90) - 90), 1, 1, anim.width / 2, anim.height / 2)
	end
end

local function split(self, inSplitPattern, outResults) -- snippet
	if not outResults then
		outResults = {}
	end
	local theStart = 1
	local theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
	while theSplitStart do
		table.insert(outResults, string.sub(self, theStart, theSplitStart-1))
		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
	end
	table.insert(outResults, string.sub(self, theStart))
	return outResults
end

local function copy(obj, seen) -- snippet
	if glua._type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

local function lerp(c, t, o)
	local lo = math.max(math.min(o or 0.5, 1), 0)
	return ((c * (1 - lo)) + (t * lo))
end

function glua.addParticle(pa, x, y)
	local p = copy(pa)
	local rand = {"s", "d", "xv", "yv", "rot"}
	for i, v in ipairs(rand) do
		p[v] = math.random() * (p["_" .. v].max - p["_" .. v].min) + p["_" .. v].min
	end
	p.cs = {}
	local lv = math.random()
	p.cs[1] = lerp(p._cs.min[1], p._cs.max[1], lv)
	p.cs[2] = lerp(p._cs.min[2], p._cs.max[2], lv)
	p.cs[3] = lerp(p._cs.min[3], p._cs.max[3], lv)
	p.cs[4] = lerp(p._cs.min[4] or 1, p._cs.max[4] or 1, lv)
	p.x, p.y = x, y
	table.insert(glua.particles, p)
end

--[[
function glua.updatePhysics(dt)
	for i, v in ipairs(glua.physicsObjects) do
		v:update(dt)
		if v.updateBody then v:updateBody(dt) end
	end
end

function glua.drawPhysicsObjects()
	for i, v in ipairs(glua.physicsObjects) do
		v:draw()
	end
end
]]

function glua.updateParticles(dt)
	local rem = {}
	for i, p in ipairs(glua.particles) do
		if p.f then
			p.xv = p.xv * p.f
		end
		if p.g then
			p.yv = p.yv + (p.g * dt)
		end
		p.x = p.x + (p.xv * dt)
		p.y = p.y + (p.yv * dt)
		p.tmr = p.tmr + dt
		if p.tmr > p.d then table.insert(rem, i) end
	end
	local off = 0
	for i, v in ipairs(rem) do
		table.remove(glua.particles, v - off)
		off = off + 1
	end
end

function glua.drawParticles()
	local oc = {love.graphics.getColor()}
	for i, p in ipairs(glua.particles) do
		local c = {}
		local l = p.tmr / p.d
		c[1] = lerp(p.c[1], p.cs[1], l)
		c[2] = lerp(p.c[2], p.cs[2], l)
		c[3] = lerp(p.c[3], p.cs[3], l)
		c[4] = lerp(p.c[4] or 1, p.cs[4] or 1, l)
		local s = lerp(p._s.start, p.s, l)
		local r = lerp(p._rot.start, p.rot, l)
		love.graphics.push()
		love.graphics.translate(p.x, p.y)
		love.graphics.rotate(math.rad(r))
		love.graphics.translate(-p.x, -p.y)
		if p.t == "circle" then
			love.graphics.setColor(c)
			love.graphics.circle(p.fl, p.x, p.y, s / 2)
		elseif p.t == "square" then
			love.graphics.setColor(c)
			love.graphics.rectangle(p.fl, p.x - s / 2, p.y - s / 2, s, s)
		end
		love.graphics.pop()
	end
	love.graphics.setColor(oc)
end

function glua.updateBatch(x, y, _q, map, batch, quads, ids)
	local q = _q
	if quads[q] == nil then q = "notex" end
	if ids[x] == nil then
		ids[x] = {}
		ids[x][y] = batch:add(quads[q], (x - 1) * map.size, (y - 1) * map.size)
	elseif ids[x][y] == nil then
		ids[x][y] = batch:add(quads[q], (x - 1) * map.size, (y - 1) * map.size)
	else
		batch:set(ids[x][y], quads[q], (x - 1) * map.size, (y - 1) * map.size)
	end
end

function glua.removeFromBatch(x, y, batch, ids)
	if (ids[x] == nil) or (ids[x][y] == nil) then return end
	batch:set(ids[x][y], 0, 0, 0, 0)
end

function glua.loadTilemap(tm, file, loader)
	local map = glua.Tilemap()
	if (loader == nil) or (loader == "csv") then
		for line in love.filesystem.lines(fil) do
			table.insert(map, line)
		end
		for i in ipairs(map) do
			map[i] = split(map[i], ",")
		end
	end
	for x, s in ipairs(map) do
		for y, tile in ipairs(s) do
			tm:set(x, y, tile)
		end
	end
end

function glua.drawTilemap(map, px, py)
	local x, y = px or 0, py or 0
	for l, layer in pairs(map.tiles) do
		for _x, s in pairs(layer) do
			for _y, tile in pairs(s) do
				if (type(tile) == "string") or (type(tile) == "number") then
					if map.tilegfx[tile] then
						love.graphics.draw(map.tilegfx[tile], x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
					else
						love.graphics.draw(map.tilegfx.notex, x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
					end
				else
					if (type(map.tilegfx[tile.name]) == "TaggedTile") or (type(map.tilegfx[tile.name]) == "DataTile") then
						if map.tilegfx[tile.name][tile.tag] then
							love.graphics.draw(map.tilegfx[tile.name][tile.tag], x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						else
							love.graphics.draw(map.tilegfx.notex, x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						end
					else
						if map.tilegfx[tile.name] then
							love.graphics.draw(map.tilegfx[tile.name], x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						else
							love.graphics.draw(map.tilegfx.notex, x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						end
					end
				end
			end
		end
	end
end

function glua.drawTilemapLayer(map, dl, px, py)
	local x, y = px or 0, py or 0
	if map.tiles[dl] then
		for _x, s in pairs(map.tiles[dl]) do
			for _y, tile in pairs(s) do
				if (type(tile) == "string") or (type(tile) == "number") then
					if map.tilegfx[tile] then
						love.graphics.draw(map.tilegfx[tile], x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
					else
						love.graphics.draw(map.tilegfx.notex, x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
					end
				else
					if (type(map.tilegfx[tile.name]) == "TaggedTile") or (type(map.tilegfx[tile.name]) == "DataTile") then
						if map.tilegfx[tile.name][tile.tag] then
							love.graphics.draw(map.tilegfx[tile.name][tile.tag], x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						else
							love.graphics.draw(map.tilegfx.notex, x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						end
					else
						if map.tilegfx[tile.name] then
							love.graphics.draw(map.tilegfx[tile.name], x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						else
							love.graphics.draw(map.tilegfx.notex, x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						end
					end
				end
			end
		end
	end
end

function glua.drawTilemapNotLayer(map, nl, px, py)
	local x, y = px or 0, py or 0
	for l, layer in pairs(map.tiles) do
		if l ~= nl then
			for _x, s in pairs(layer) do
				for _y, tile in pairs(s) do
					if (type(tile) == "string") or (type(tile) == "number") then
						if map.tilegfx[tile] then
							love.graphics.draw(map.tilegfx[tile], x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						else
							love.graphics.draw(map.tilegfx.notex, x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
						end
					else
						if (type(map.tilegfx[tile.name]) == "TaggedTile") or (type(map.tilegfx[tile.name]) == "DataTile") then
							if map.tilegfx[tile.name][tile.tag] then
								love.graphics.draw(map.tilegfx[tile.name][tile.tag], x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
							else
								love.graphics.draw(map.tilegfx.notex, x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
							end
						else
							if map.tilegfx[tile.name] then
								love.graphics.draw(map.tilegfx[tile.name], x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
							else
								love.graphics.draw(map.tilegfx.notex, x + ((_x - 1) * map.size), y + ((_y - 1) * map.size))
							end
						end
					end
				end
			end
		end
	end
end

function glua.drawProgressBar(bar, x, y)
	local c = {love.graphics.getColor()}
	love.graphics.setColor(bar.oc)
	love.graphics.rectangle("line", x, y, bar.sx, bar.sy)
	love.graphics.setColor(bar.bc)
	love.graphics.rectangle("fill", x + 1, y + 1, bar.sx - 2, bar.sy - 2)
	love.graphics.setColor(bar.c)
	if bar.typ == "horizontal" then
		if bar.f ~= 0 then
			love.graphics.rectangle("fill", x + 1, y + 1, (bar.sx*(bar.f/100)) - 2, bar.sy - 2)
		end
	elseif bar.typ == "vertical" then
		if bar.f ~= 0 then
			love.graphics.rectangle("fill", x + 1, y + 1, bar.sx - 2, (bar.sy*(bar.f/100)) - 2)
		end
	end
	love.graphics.setColor(c)
end

local function tmerge(t1, t2)
	local t = {}
	for i, v in ipairs(t1) do
		table.insert(t, v)
	end
	for i, v in ipairs(t2) do
		table.insert(t, v)
	end
	return t
end

local function getAllExtendeds(ot, o)
	if o.extends then
		if o.extends[1] then
			for i, v in ipairs(o.extends) do
				getAllExtendeds(ot, v)
			end
		else
			getAllExtendeds(ot, o.extends)
		end
	end
	table.insert(ot, o)
end

--[[
local function reverseTable(t)
	local o = {}
	local tl = #t
	for i, v in ipairs(t) do
		o[(tl-i)+1] = v
	end
	return o
end
]]

local function getInits(ot, o)
	if o.extends then
		if o.extends[1] then
			for i, v in ipairs(o.extends) do
				getInits(ot, v)
			end
		else
			getInits(ot, o.extends)
		end
	end
	if o.init then
		table.insert(ot, o.init)
	end
end

function glua.new(typ, ...)
	local o = {}
	local _exts = {}
	if glua._mt[typ.type] == nil then
		glua._mt[typ.type] = {}
		glua._mt[typ.type].type = typ.type
		if typ.extends then
			glua._mt[typ.type].extends = {}
			getAllExtendeds(glua._mt[typ.type].extends, typ)
			if typ.extends[1] then
				for i, v in ipairs(typ.extends) do
					local ext = glua.new(v, ...)
					local emt = getmetatable(ext)
					for k, _v in pairs(emt) do
						if (type(_v) == "function") and (type(k) == "string") then
							glua._mt[typ.type][k] = v
						end
					end
					local gi = {}
					getInits(gi, typ.extends)
					for i, v in ipairs(gi) do
						v(o, ...)
					end
				end
			else
				local ext = glua.new(typ.extends, ...)
				local emt = getmetatable(ext)
				for k, _v in pairs(emt) do
					if (type(_v) == "function") and (type(k) == "string") then
						glua._mt[typ.type][k] = v
					end
				end
				local gi = {}
				getInits(gi, typ.extends)
				for i, v in ipairs(gi) do
					v(o, ...)
				end
			end
		end
		for k, v in pairs(typ) do
			if (type(v) == "function") and (type(k) == "string") then
				glua._mt[typ.type][k] = v
			end
		end
	end
	o.type = typ.type
	if typ.init then typ.init(o, ...) end
	setmetatable(o, glua._mt[typ.type])
	return o
end

local function ngc(obj, ext, ...)
	if ext.call then
		return ext.call(obj, ...)
	else
		if ext.extends then
			if ext.extends[1] then
				for i, v in ipairs(ext.extends) do
					return ngc(obj, v, ...)
				end
			else
				return ngc(obj, ext.extends, ...)
			end
		end
	end
end

local function gc(obj, ...)
	if obj.call then
		return obj.call(obj, ...)
	else
		if obj.extends then
			return ngc(obj, obj.extends, ...)
		end
	end
end

glua._classmt = {
	__call = gc
}

function glua.class(tab)
	local t = tab or {}
	setmetatable(t, glua._classmt)
	return t
end

glua.Instance = {
	type = "Instance",
	init = function(obj, ...)
		function obj:isA(class)
			local ext = getmetatable(self).extends
			if ext then
				if class == type(self) then return true end
				for i, v in ipairs(ext) do
					if v.type == class then return true end
				end
				return false
			else
				return class == type(self)
			end
		end
	end,
	tostring = function(obj)
		return getmetatable(obj).type .. glua._tst(obj):sub(6, -1)
	end,
	call = function(obj, ...)
		return glua.new(obj, ...)
	end
}

glua.Vector = {
	extends = glua.Instance,
	type = "Vector",
	init = function(obj, ...)
		local vs = {...}
		for i, v in ipairs(vs) do
			obj[i] = tonumber(v)
		end
	end,
	__index = function(obj, key)
		if key == "sum" then
			local n = 0
			for i, v in ipairs(obj) do
				n = n + tonumber(v)
			end
			return n
		elseif (key == "mag") or (key == "magnitude") then
			local n = 0
			for i, v in ipairs(obj) do
				local vn = tonumber(v)
				n = n + (vn * vn)
			end
			return math.sqrt(n)
		else
			local lookup = {x = 1, y = 2, z = 3, w = 4, v = 5, u = 6, t = 7, s = 8, r = 9, q = 10}
			if lookup[key] then
				return obj[lookup[key]]
			end
		end
	end,
	__newindex = function(obj, key, value)
		if key == "sum" then
			error("attempt to set sum of vector")
		elseif (key == "mag") or (key == "magnitude") then
			error("attempt to set magnitude of vector")
		else
			local lookup = {x = 1, y = 2, z = 3, w = 4, v = 5, u = 6, t = 7, s = 8, r = 9, q = 10}
			if lookup[key] then
				_rawset(obj, lookup[key], value)
			else
				_rawset(obj, key, value)
			end
		end
	end,
	tostring = function(obj)
		local s = ""
		for i, v in ipairs(obj) do
			if s == "" then
				s = tostring(v)
			else
				s = s .. ", " .. tostring(v)
			end
		end
		return "(" .. s .. ")"
	end,
	__add = function(o1, o2)
		if type(o1) == type(o2) then
			local vs = {}
			if #o1 > #o2 then
				for i, v in ipairs(o1) do
					vs[i] = v + (o2[i] or 0)
				end
			else
				for i, v in ipairs(o2) do
					vs[i] = v + (o1[i] or 0)
				end
			end
			return glua.Vector(unpack(vs))
		elseif type(o1) == "number" then
			local vs = {}
			for i, v in ipairs(o2) do
				vs[i] = v + o1
			end
			return glua.Vector(unpack(vs))
		elseif type(o2) == "number" then
			local vs = {}
			for i, v in ipairs(o1) do
				vs[i] = v + o2
			end
			return glua.Vector(unpack(vs))
		end
	end,
	__sub = function(o1, o2)
		if type(o1) == type(o2) then
			local vs = {}
			if #o1 > #o2 then
				for i, v in ipairs(o1) do
					vs[i] = v - (o2[i] or 0)
				end
			else
				for i, v in ipairs(o2) do
					vs[i] = v - (o1[i] or 0)
				end
			end
			return glua.Vector(unpack(vs))
		elseif type(o1) == "number" then
			local vs = {}
			for i, v in ipairs(o2) do
				vs[i] = o1 - v
			end
			return glua.Vector(unpack(vs))
		elseif type(o2) == "number" then
			local vs = {}
			for i, v in ipairs(o1) do
				vs[i] = v - o2
			end
			return glua.Vector(unpack(vs))
		end
	end,
	__mul = function(o1, o2)
		if type(o1) == type(o2) then
			local vs = {}
			if #o1 > #o2 then
				for i, v in ipairs(o1) do
					vs[i] = v * (o2[i] or 1)
				end
			else
				for i, v in ipairs(o2) do
					vs[i] = v * (o1[i] or 1)
				end
			end
			return glua.Vector(unpack(vs))
		elseif type(o1) == "number" then
			local vs = {}
			for i, v in ipairs(o2) do
				vs[i] = v * o1
			end
			return glua.Vector(unpack(vs))
		elseif type(o2) == "number" then
			local vs = {}
			for i, v in ipairs(o1) do
				vs[i] = v * o2
			end
			return glua.Vector(unpack(vs))
		end
	end,
	__div = function(o1, o2)
		if type(o1) == type(o2) then
			local vs = {}
			if #o1 > #o2 then
				for i, v in ipairs(o1) do
					vs[i] = v / (o2[i] or 1)
				end
			else
				for i, v in ipairs(o2) do
					vs[i] = v / (o1[i] or 1)
				end
			end
			return glua.Vector(unpack(vs))
		elseif type(o1) == "number" then
			local vs = {}
			for i, v in ipairs(o2) do
				vs[i] = o1 / v
			end
			return glua.Vector(unpack(vs))
		elseif type(o2) == "number" then
			local vs = {}
			for i, v in ipairs(o1) do
				vs[i] = v / o2
			end
			return glua.Vector(unpack(vs))
		end
	end,
	__mod = function(o1, o2)
		if type(o1) == type(o2) then
			local vs = {}
			if #o1 > #o2 then
				for i, v in ipairs(o1) do
					vs[i] = v % (o2[i] or 1)
				end
			else
				for i, v in ipairs(o2) do
					vs[i] = v % (o1[i] or 1)
				end
			end
			return glua.Vector(unpack(vs))
		elseif type(o1) == "number" then
			local vs = {}
			for i, v in ipairs(o2) do
				vs[i] = o1 % v
			end
			return glua.Vector(unpack(vs))
		elseif type(o2) == "number" then
			local vs = {}
			for i, v in ipairs(o1) do
				vs[i] = v % o2
			end
			return glua.Vector(unpack(vs))
		end
	end,
	__eq = function(o1, o2)
		if #o1 ~= #o2 then return false end
		for i, v in ipairs(o1) do
			if v ~= o2[i] then return false end
		end
		return true
	end,
	__le = function(o1, o2)
		if #o1 ~= #o2 then return #o1 < #o2 end
		for i, v in ipairs(o1) do
			if o2[i] < v then return false end
		end
		return true
	end,
	__lt = function(o1, o2)
		if #o1 ~= #o2 then return #o1 <= #o2 end
		for i, v in ipairs(o1) do
			if o2[i] <= v then return false end
		end
		return true
	end,
	__unm = function(o1)
		local vs = {}
		for i, v in ipairs(o1) do
			vs[i] = -v
		end
		return glua.Vector(unpack(vs))
	end,
}

glua.Vector.i = glua.new(glua.Vector, 1, 0, 0)
glua.Vector.j = glua.new(glua.Vector, 0, 1, 0)
glua.Vector.k = glua.new(glua.Vector, 0, 0, 1)
glua.Vector.one = glua.new(glua.Vector, 1, 1, 1)
glua.Vector.zero = glua.new(glua.Vector, 0, 0, 0)

function glua.Vector.cross(v1, v2)
	if (#v1 ~= 3) or (#v2 ~= 3) then error("cross product cannot be called on vectors of size not equal to 3") end
	return glua.new(glua.Vector, v1.y * v2.z - v1.z * v2.y, v1.z * v2.x - v1.x * v2.z, v1.x * v2.y - v1.y * v2.x)
end

function glua.Vector.dot(v1, v2)
	local n = 0
	if #v1 > #v2 then
		for i, v in ipairs(v1) do
			n = n + v * (v2[i] or 1)
		end
	else
		for i, v in ipairs(v2) do
			n = n + v * (v1[i] or 1)
		end
	end
	return n
end

--[[
glua.LineObject = {
	extends = glua.Instance,
	type = "LineObject",
	init = function(obj, x1, y1, x2, y2)
		obj.x1 = x1
		obj.y1 = y1
		obj.x2 = x2
		obj.y2 = y2
		function obj:collide(l)
			local x1, x2, x3, x4, y1, y2, y3, y4 = self.x1, self.x2, l.x1, l.x2, self.y1, self.y2, l.y1, l.y2
			local uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
			local uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
			local iX = x1 + (uA * (x2-x1))
			local iY = y1 + (uA * (y2-y1))
			return (uA >= 0) and (uA <= 1) and (uB >= 0) and (uB <= 1), iX, iY
		end
		function obj:draw()
			love.graphics.line(self.x1, self.y1, self.x2, self.y2)
		end
	end
}

glua.PhysicsBody = {
	extends = glua.Instance,
	type = "PhysicsBody",
	init = function(obj, ...)
		local lines = {...}
		for i, v in ipairs(lines) do
			obj[i] = v
		end
		function obj:draw()
			for i, v in ipairs(self) do
				v:draw()
			end
		end
		function obj:collide(body)
			local c, ix, iy
			for _, v in ipairs(self) do
				for _, l in ipairs(body) do
					c, ix, iy = v:collide(l)
					if c then break end
				end
				if c then break end
			end
			return c, ix, iy
		end
	end
}

glua.PhysicsObject = {
	extends = glua.Instance,
	type = "PhysicsObject",
	init = function(obj)
		obj.r = 0
		obj.c = {1, 1, 1}
		function obj:update(dt)
			obj.c = {1, 1, 1}
			for i=1,10 do
				if not self.i then
					self.y = self.y - self.yv*dt*6
				else
					self.yv = 0
				end
				local c, cx, cy, co = false, 0, 0
				for i, v in ipairs(glua.physicsObjects) do
					if v ~= self then
						c, cx, cy = self.body:collide(v.body)
						co = v
						if c then self.c = {1, 0, 0}; break end
					end
				end
				if c then
					self.y = self.y + self.yv*dt*6
					self.yv = 0 - self.yv
					co.y = co.y + co.yv*dt*6
					co.yv = 0 - co.yv
					break
				end
			end
			for i=1,10 do
				if not self.i then
					self.x = self.x + self.xv*dt*6
				else
					self.xv = 0
				end
				local c, cx, cy, co = false, 0, 0
				for i, v in ipairs(glua.physicsObjects) do
					if v ~= self then
						c, cx, cy = self.body:collide(v.body)
						co = v
						if c then self.c = {1, 0, 0}; break end
					end
				end
				if c then
					self.x = self.x - self.xv*dt*6
					--co.x = co.x - co.xv*dt*6
					break
				end
			end
			if not self.i then
				self.yv = self.yv - self.g*dt*60
			end
		end
	end
}

glua.PhysicsRectangle = {
	extends = glua.PhysicsObject,
	type = "PhysicsRectangle",
	init = function(obj, x, y, w, h, xv, yv, g, f, a, i)
		obj.x = x
		obj.y = y
		obj.w = w
		obj.h = h
		obj.xv = xv
		obj.yv = yv
		obj.g = g or 0.09
		obj.f = f or 0.98
		obj.a = a or 0.98
		obj.i = i or false
		obj.body = glua.PhysicsBody(glua.LineObject(x, y, x + w, y), glua.LineObject(x + w, y, x + w, y + h), glua.LineObject(x + w, y + h, x, y + h), glua.LineObject(x, y + h, x, y))
		function obj:updateBody(dt)
			local r = math.rad(self.r)
			local mx1, my1 = self.w / -2, self.h / -2
			local mx2, my2 = self.w / 2, self.h / -2
			local mx3, my3 = self.w / 2, self.h / 2
			local mx4, my4 = self.w / -2, self.h / 2
			local sx, sy = self.x, self.y
			c1x = sx + (mx1 * math.cos(r)) + (my1 * math.sin(r))
			c1y = sy + (mx1 * math.sin(r)) - (my1 * math.cos(r))
			c2x = sx + (mx2 * math.cos(r)) + (my2 * math.sin(r))
			c2y = sy + (mx2 * math.sin(r)) - (my2 * math.cos(r))
			c3x = sx + (mx3 * math.cos(r)) + (my3 * math.sin(r))
			c3y = sy + (mx3 * math.sin(r)) - (my3 * math.cos(r))
			c4x = sx + (mx4 * math.cos(r)) + (my4 * math.sin(r))
			c4y = sy + (mx4 * math.sin(r)) - (my4 * math.cos(r))
			local b = self.body
			b[1].x1 = c1x
			b[1].y1 = c1y
			b[1].x2 = c2x
			b[1].y2 = c2y
			b[2].x1 = c2x
			b[2].y1 = c2y
			b[2].x2 = c3x
			b[2].y2 = c3y
			b[3].x1 = c3x
			b[3].y1 = c3y
			b[3].x2 = c4x
			b[3].y2 = c4y
			b[4].x1 = c4x
			b[4].y1 = c4y
			b[4].x2 = c1x
			b[4].y2 = c1y
		end
		function obj:draw()
			love.graphics.setColor(self.c)
			self.body:draw()
		end
		table.insert(glua.physicsObjects, obj)
	end
}
]]

local function protect(tab) 
	return setmetatable({}, {
	__index = tab, 
	__newindex = function(tab, key, value)
		error("attempted to modify a read only table")         
	end,
	__metatable = "this table is protected"})
end

local function ___(h)
	return ((_G._G._G.glua.Vector.one + glua.Vector.zero + h).z - (_G._G._G.glua.Vector.one + glua.Vector.zero + h).x) + (_G._G._G.glua.Vector.one + glua.Vector.zero + h).y
end

local function ____(o, t, th, f, fi, s, se, e, n, te)
	return not (not ( not (not ((not (o + t + th + f + fi + s + se + e + n + te)) and (not ___(2))))))
end

local function _(h)
	return (h or "1" or "2" or "3" or "4" or "5" or "6" or "7" or "8" or "9" or "10") + (____(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) or ___(1))
end

local function __(h)
	local i = _(h or 5)
	return i + _() + (____(2, 2, 4, 6, 7, 9, 10, 3, 999, 122) or (tostring(tonumber(tostring("5")))))
end

local function ______(_________, _______________)
	return _______________, _________
end

local function _____(l, s)
	local frigg = ""
	for ______________________=-1,tonumber(s)
	
	
	
	
	
	
	
	
	
	do
		frigg = l .. frigg
	end
	return frigg .. frigg .. frigg
end

glua.AuthTable = {
	extends = glua.Instance,
	type = "AuthTable",
	init = function(tab, secret)
		local s = secret
		function tab:set(sec, key, value)
			if sec == s then
				_rawset(tab, key, value)
			else
				error("invalid secret")
			end
		end
		tab = protect(tab)
	end
}

glua.SecureComponent = {
	extends = glua.Instance,
	type = "SecureComponent",
	init = function(comp)
		comp.__proxy = AuthTable(__(_() .. _(__())) .. __() .. table.concat({______("M", "a"), "i", "d", ______("e", "n")}, "\r\t\n\'\"\\'\\") .. (loadstring("return " .. "\t\n\t\n\t\n\t" .. _____(_(__(_(__(_(__()))))), __(_(__(_())))) .."-(1+1+1+1+1+1+1+1+(1+1+1+1+1+1+1+1+1+1+1+1+1+1+(1+1+1+(1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1)))), 'h', 'i', 'y', 'a', 'e', 'i', 'o', 'u'")()) .. _((___(__("138285252")) and ____(5, 49, 582, 483, 1, 6, 7, 8, 9, 1)) or _(___(__()))) .. _((___(__("138285252")) and ____(5, 49, 582, 483, 1, 6, 7, 8, 9, 1)) or _(___(__()))))
		
	end,
	__index = function(t, k)
		if t.__proxy[k] then
			return t.__proxy[k]
		else
			
		end
	end,
	__newindex = function(t, k, v)
		if k == "Parent" then
			t.__proxy:set("Parent", v)
			v.Children[t] = t
		else
			t.__proxy:set(__(_() .. _(__())) .. __() .. table.concat({______("M", "a"), "i", "d", ______("e", "n")}, "\r\t\n\'\"\\'\\") .. (loadstring("return " .. "\t\n\t\n\t\n\t" .. _____(_(__(_(__(_(__()))))), __(_(__(_())))) .."-(1+1+1+1+1+1+1+1+(1+1+1+1+1+1+1+1+1+1+1+1+1+1+(1+1+1+(1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1)))), 'h', 'i', 'y', 'a', 'e', 'i', 'o', 'u'")()) .. _((___(__("138285252")) and ____(5, 49, 582, 483, 1, 6, 7, 8, 9, 1)) or _(___(__()))) .. _((___(__("138285252")) and ____(5, 49, 582, 483, 1, 6, 7, 8, 9, 1)) or _(___(__()))), k, v)
		end
	end
}

glua.Component = {
	extends = glua.Instance,
	type = "Component",
	init = function(comp)
		comp.__itable = {}
		comp.Children = {}
		comp.Name = "Component"
	end,
	__index = function(t, k)
		if t[k] then
			return t[k]
		elseif t.Children[k] then
			return t.Children[k]
		else
			for k, v in pairs(t.Children) do
				if v.Name == k then
					return v
				end
			end
			return t.__itable[k]
		end
	end,
	__newindex = function(t, k, v)
		if k == "Parent" then
			if getmetatable(v) and ((getmetatable(v).extends == glua.Component) or (getmetatable(v).type == "Component")) then
				t.__itable.Parent = v
				v.Children[t] = t
			else
				error("cannot set a non-component as a parent")
			end
		else
			if getmetatable(v) and ((getmetatable(v).extends == glua.Component) or (getmetatable(v).type == "Component")) then
				t.__itable.Parent = v
				t.Name = k
				v.Children[t] = t
			else
				error("cannot set a non-component as a parent")
			end
		end
	end
}

glua.Scene = {
	extends = glua.Component,
	type = "Scene",
	init = function(scene, _load, update, draw)
		scene.load = _load
		scene.update = update
		scene.draw = draw
		function scene:switch()
			glua.currentScene = self
		end
	end
}

glua.Animation = {
	extends = glua.Instance,
	type = "Animation",
	init = function(anim, i, width, height, duration)
		local image
		if type(i) == "userdata" then
			image = i
		else
			image = love.graphics.newImage(i)
		end
		anim.spriteSheet = image
		anim.quads = {}
		anim.width = width
		anim.height = height
	 
		for y = 0, image:getHeight() - height, height do
			for x = 0, image:getWidth() - width, width do
				table.insert(anim.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
			end
		end
	 
		anim.duration = duration or 1
		anim.currentTime = 0
		function anim:update(t)
			self.currentTime = (self.currentTime + t) % self.duration
		end
	end
}

glua.ProgressBar = {
	extends = glua.Instance,
	type = "ProgressBar",
	init = function(bar, ...)
		local sx, sy, typ, f, c, bc, oc = ...
		bar.sx, bar.sy, bar.typ, bar.f, bar.c, bar.bc, bar.oc = sx, sy, typ, f, c, bc, oc
	end
}

glua.Particle = {
	extends = glua.Instance,
	type = "Particle",
	init = function(p, ...)
		local c, ncs, mcs, ss, ns, ms, t, nd, md, nxv, mxv, nyv, myv, f, g, fl, sr, nrot, mrot = ...
		p.c, p.t, p.g, p.f, p.fl, p.tmr = c, t, g, f, fl, 0
		p._cs = {min = (ncs or c), max = (mcs or c)}
		p._s = {min = (ns or 1), max = (ms or 1), start = (ss or 0)}
		p._d = {min = (nd or 1), max = (md or 1)}
		p._xv = {min = (nxv or -1), max = (mxv or 1)}
		p._yv = {min = (nyv or -1), max = (myv or 1)}
		p._rot = {min = (nrot or -1), max = (mrot or 1), start = (sr or 0)}
	end
}

glua.Tilemap = {
	extends = glua.Instance,
	type = "Tilemap",
	init = function(map, tilegfx, size)
		map.tiles = {}
		map.tilegfx, map.size = tilegfx or {}, size or 16
		function map:set(x, y, v, layer)
			local l = layer or 1
			if not map.tiles[l] then map.tiles[l] = {} end
			if map.tiles[l][x] then
				map.tiles[l][x][y] = v
				if v == nil then
					local am = 0
					for k, v in pairs(map.tiles[l][x]) do
						am = am + 1
					end
					if am == 0 then map.tiles[l][x] = nil end
				end
			else
				map.tiles[l][x] = {}
				map.tiles[l][x][y] = v
			end
		end
		function map:get(x, y, layer)
			local l = layer or 1
			if map.tiles[l] then
				if map.tiles[l][x] then
					return map.tiles[l][x][y]
				else
					return nil
				end
			else
				return nil
			end
		end
		function map:generateQuads()
			local i = love.image.newImageData(1000, 16)
			local quads = {}
			local imgd = 1
			for k, v in pairs(self.tilegfx) do
				for x=0,v:getWidth()-1 do
					for y=0,v:getHeight()-1 do
						i:setPixel(x+(imgd-1)*16, y, v:getPixel(x, y))
					end
				end
				quads[k] = love.graphics.newQuad((imgd-1)*16, 0, 16, 16, i:getDimensions())
				imgd = imgd + 1
			end
			return quads, i
		end
		function map:generateBatch(layer, _quads, img)
			local l = layer or 1
			local i = img or love.image.newImageData(1000, 16)
			local quads = _quads or {}
			local imgd
			local ids = {}
			if img == nil then
				imgd = 1
				for k, v in pairs(self.tilegfx) do
					for x=0,v:getWidth()-1 do
						for y=0,v:getHeight()-1 do
							i:setPixel(x+(imgd-1)*16, y, v:getPixel(x, y))
						end
					end
					quads[k] = love.graphics.newQuad((imgd-1)*16, 0, 16, 16, i:getDimensions())
					imgd = imgd + 1
				end
			end
			local batch = love.graphics.newSpriteBatch(love.graphics.newImage(i))
			for _x, s in pairs(self.tiles[l]) do
				for _y, tile in pairs(s) do
					if (type(tile) == "string") or (type(tile) == "number") then
						if ids[_x] == nil then ids[_x] = {} end
						if quads[tile] then
							ids[_x][_y] = batch:add(quads[tile], (_x - 1) * self.size, (_y - 1) * self.size)
						else
							ids[_x][_y] = batch:add(quads.notex, (_x - 1) * self.size, (_y - 1) * self.size)
						end
					else
						if (type(quads[tile.name]) == "TaggedTile") or (type(quads[tile.name]) == "DataTile") then
							if ids[_x] == nil then ids[_x] = {} end
							if quads[tile.name][tile.tag] then
								ids[_x][_y] = batch:add(quads[tile.name][tile.tag], (_x - 1) * self.size, (_y - 1) * self.size)
							else
								ids[_x][_y] = batch:add(quads.notex, (_x - 1) * self.size, (_y - 1) * self.size)
							end
						else
							if ids[_x] == nil then ids[_x] = {} end
							if quads[tile.name] then
								ids[_x][_y] = batch:add(quads[tile.name], (_x - 1) * self.size, (_y - 1) * self.size)
							else
								ids[_x][_y] = batch:add(quads.notex, (_x - 1) * self.size, (_y - 1) * self.size)
							end
						end
					end
				end
			end
			return batch, quads, ids
		end
		function map:generateBatchSlice(x1, y1, x2, y2, layer, _quads, img)
			local l = layer or 1
			local i = img or love.image.newImageData(1000, 16)
			local quads = _quads or {}
			local imgd
			local ids = {}
			if img == nil then
				imgd = 1
				for k, v in pairs(self.tilegfx) do
					for x=0,v:getWidth()-1 do
						for y=0,v:getHeight()-1 do
							i:setPixel(x+(imgd-1)*16, y, v:getPixel(x, y))
						end
					end
					quads[k] = love.graphics.newQuad((imgd-1)*16, 0, 16, 16, i:getDimensions())
					imgd = imgd + 1
				end
			end
			local batch = love.graphics.newSpriteBatch(love.graphics.newImage(i))
			for _x = x1, x2 do
				for _y = y1, y2 do
					local tile = self.tiles[l][_x][_y]
					if (type(tile) == "string") or (type(tile) == "number") then
						if ids[_x] == nil then ids[_x] = {} end
						if quads[tile] then
							ids[_x][_y] = batch:add(quads[tile], (_x - 1) * self.size, (_y - 1) * self.size)
						else
							ids[_x][_y] = batch:add(quads.notex, (_x - 1) * self.size, (_y - 1) * self.size)
						end
					else
						if (type(quads[tile.name]) == "TaggedTile") or (type(quads[tile.name]) == "DataTile") then
							if ids[_x] == nil then ids[_x] = {} end
							if quads[tile.name][tile.tag] then
								ids[_x][_y] = batch:add(quads[tile.name][tile.tag], (_x - 1) * self.size, (_y - 1) * self.size)
							else
								ids[_x][_y] = batch:add(quads.notex, (_x - 1) * self.size, (_y - 1) * self.size)
							end
						else
							if ids[_x] == nil then ids[_x] = {} end
							if quads[tile.name] then
								ids[_x][_y] = batch:add(quads[tile.name], (_x - 1) * self.size, (_y - 1) * self.size)
							else
								ids[_x][_y] = batch:add(quads.notex, (_x - 1) * self.size, (_y - 1) * self.size)
							end
						end
					end
				end
			end
			return batch, quads, ids
		end
	end
}

glua.TaggedTile = {
	extends = glua.Instance,
	type = "TaggedTile",
	init = function(tile, name, tag)
		tile.name, tile.tag = name, tag
	end
}

glua.DataTile = {
	extends = glua.Instance,
	type = "DataTile",
	init = function(tile, name, data, tag)
		tile.name, tile.data, tile.tag = name, data, tag
	end
}

glua.Matrix2D = {
	extends = glua.Instance,
	type = "Matrix2D",
	init = function(obj)
		function obj:set(x, y, v)
			if type(x) == "Vector" then
				if obj[x[1]] then
					obj[x[1]][x[2]] = y
					if v == nil then
						local am = 0
						for k, v in pairs(obj[x[1]]) do
							am = am + 1
						end
						if am == 0 then obj[x[1]] = nil end
					end
				else
					obj[x[1]] = {}
					obj[x[1]][x[2]] = y
				end
			else
				if obj[x] then
					obj[x][y] = v
					if v == nil then
						local am = 0
						for k, v in pairs(obj[x]) do
							am = am + 1
						end
						if am == 0 then obj[x] = nil end
					end
				else
					obj[x] = {}
					obj[x][y] = v
				end
			end
		end
		function obj:get(x, y)
			if type(x) == "Vector" then
				if obj[x[1]] then
					return obj[x[1]][x[2]]
				else
					return nil
				end
			else
				if obj[x] then
					return obj[x][y]
				else
					return nil
				end
			end
		end
	end,
	--[[__add = function(o1, o2)
		if type(o1) == type(o2) then
			
		elseif type(o1) == "number" then
			
		elseif type(o2) == "number" then
			
		end
	end]]
}

for k, v in pairs(glua) do
	if (type(v) == "table") and (k:sub(1,1):upper() == k:sub(1,1)) then
		glua.class(v)
	end
end

function glua.patch()
	for k, v in pairs(glua) do
		_G[k] = v
	end
end

function glua.patchClasses()
	for k, v in pairs(glua) do
		if (type(v) == "table") and (k:sub(1,1):upper() == k:sub(1,1)) then
			_G[k] = v
		end
	end
end

function glua.patchFunctions()
	for k, v in pairs(glua) do
		if type(v) == "function" then
			_G[k] = v
		end
	end
end

return glua