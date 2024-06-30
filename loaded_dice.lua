local ld_api = {}

function ld_api.add(d,w)
	table.insert(d.weights,w)
	d.dirty = true
end

function ld_api.set(d,i,w)
	assert(d.weights[i], "can't set a weight that doesn't exist yet")
	d.weights[i] = w
	d.dirty = true
end

function ld_api.get(d,i) return d.weights[i] end

function ld_api.build_alias(d)
	local of, uf = {}, {}
	local norm = 0
	for i = 1, #d.weights do norm = norm + d.weights[i] end
	norm = #d.weights/norm
	for i = 1, #d.weights do
		local nw = d.weights[i]*norm
		d.prob[i] = nw
		d.alias[i] = 0
		if nw >= 1 then table.insert(of,i) else table.insert(uf,i) end
	end
	for i = 1, #d.weights do
		if #uf*#of == 0 then break end
		local ufid, ofid = uf[#uf], of[#of]
		d.alias[ufid] = ofid
		d.prob[ofid] = (d.prob[ofid] - 1) + d.prob[ufid]
		if d.prob[ofid] < 1 then
			uf[#uf] = table.remove(of)
		else
			table.remove(uf)
		end
	end
	for i=1,#uf do d.prob[uf[i]] = 1 end
	for i=1,#of do d.prob[of[i]] = 1 end
	d.dirty = false
end

function ld_api.sample(d,rd,rn)
	if d.dirty then d:build_alias() end
	if not rd then 
		rd = math.random(#d.weights)
		rn = math.random()
	else
		rd = 1 + math.floor(rd * #d.weights)
	end
	if rn >= d.prob[rd] then return d.alias[rd] end
	return rd
end

ld_api.random = ld_api.sample

function ld_api.random_fn(d,f)
	return d:sample(f(),f())
end

function ld_api.random_gen(d, rng, fn)
	if fn then return d:sample(rng[fn](rng), rng[fn](rng)) end
	return d:sample(rng:random(),rng:random())
end

local ld_mt = {__index = ld_api}

return {
	new_die = function(w, ...)
		local wt
		if type(w) == "table" then wt = w end
		if type(w) == "number" then wt = {w, ...} end
		return setmetatable({weights=wt or {}, alias={}, prob={}, dirty=true}, ld_mt)
	end
}
