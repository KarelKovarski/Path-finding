function find_path(from, to)
	distance = 0
	from_id = from
	width = 16
	local rot = 0
	local length = vmath.length(from - to)
	local lengths = {}
	local option_angles = {}
	local positions = {}
	local way_points = { from }
	local dir = from - to

	while true do
		local x = dir.x*math.cos(math.rad(rot)) - dir.y*math.sin(math.rad(rot))
		local y = dir.y*math.cos(math.rad(rot)) + dir.x*math.sin(math.rad(rot))
		local x = x + from.x
		local y = y + from.y
		local pos = vmath.vector3(x, y, 0)
		local result = physics.raycast(from, pos, { hash("island") })
		
		if result then
			table.insert(lengths, vmath.length(from - result.position))
			table.insert(positions, result.position)
		else
			table.insert(positions, pos)
			table.insert(lengths, length)
			if rot == 180 then table.insert(option_angles, 1, rot) end
		end	
		
		if last_length ~= nil then
			if lengths[#lengths] ~= last_length then
				if lengths[#lengths] == length then
					print("clear!")	
					table.insert(option_angles, rot)
				elseif last_length >= lengths[#lengths] + width then
					print("less")
					table.insert(option_angles, rot - 1)
				elseif last_length <= lengths[#lengths] - width then
					print("more")
					table.insert(option_angles, rot)
					end
				end
			end
		last_length = lengths[#lengths]
		rot = rot + 1
		if rot == 361 then print(unpack(option_angles)) break end
	end

	for i = 1, #option_angles do
		local min, max = 0, 360
		local angle = option_angles[i]
		for i = 1, #lengths do
			if lengths[i] ~= length then
				local from_right = i + math.deg(math.asin(width/2/lengths[i]))
				local from_left = i - math.deg(math.asin(width/2/lengths[i]))
				if i <=  angle then
					if from_right > min then
						min = from_right
					end
				elseif i >= angle then
					if from_left < max then							
						max = from_left
					end
				end
			end
		end
		if max > min then
			if max >= 180 and min <= 180 then
				table.insert(way_points, to)
				msg.post(from_id, "finded!", { way_points = way_points })
				break
			elseif angle < 180 then
				local direction = vmath.normalize(positions[math.floor(math.max(max, min))] - from)
				table.insert(way_points, from + direction * (lengths[math.floor(math.max(max, min))] - 8))
				cuntinue_finding(way_points, to)
				way_points = { from }
			elseif angle > 180 then
				local direction = vmath.normalize(positions[math.floor(math.min(max, min))] - from)
				table.insert(way_points, from + direction * (lengths[math.floor(math.min(max, min))] - 8))
				cuntinue_finding(way_points, to)
				way_points = { from }
			end
		end
	end	
end 

function cuntinue_finding(way_points, to)
	local start_pos = way_points[#way_points]
	local length = vmath.length(start_pos - to)
	local lengths = {}
	local option_angles = {}
	local positions = {}
	local last_length = nil
	local rot = 0

	local dir = start_pos - to

	while true do
		local x = dir.x*math.cos(math.rad(rot)) - dir.y*math.sin(math.rad(rot))
		local y = dir.y*math.cos(math.rad(rot)) + dir.x*math.sin(math.rad(rot))
		local x = x + start_pos.x
		local y = y + start_pos.y
		local pos = vmath.vector3(x, y, 0)
		local result = physics.raycast(start_pos, pos, { hash("island") })

		if result then
			table.insert(lengths, vmath.length(start_pos - result.position))
			table.insert(positions, result.position)
		else
			table.insert(positions, pos)
			table.insert(lengths, length)
			if rot == 180 then table.insert(option_angles, 1, rot) end
		end	

		if last_length ~= nil then
			if lengths[#lengths] ~= last_length then
				if lengths[#lengths] == length then
					print("clear!")	
					table.insert(option_angles, rot)
				elseif last_length >= lengths[#lengths] + width then
					print("less")
					table.insert(option_angles, rot - 1)
				elseif last_length <= lengths[#lengths] - width then
					print("more")
					table.insert(option_angles, rot)
				end
			end
		end
		last_length = lengths[#lengths]
		rot = rot + 1
		if rot == 361 then print(unpack(option_angles)) break end
	end

	for i = 1, #option_angles do
		local min, max = 0, 360
		local angle = option_angles[i]
		for i = 1, #lengths do
			if lengths[i] ~= length then
				local from_right = i + math.deg(math.asin(width/2/lengths[i]))
				local from_left = i - math.deg(math.asin(width/2/lengths[i]))
				if i <=  angle then
					if from_right > min then
						min = from_right
					end
				elseif i >= angle then
					if from_left < max then							
						max = from_left
					end
				end
			end
		end
		if max > min then
			if max >= 180 and min <= 180 then
				table.insert(way_points, to)
				distance = 0
				for i = 2, #way_points do
					distance = distance + vmath.length(way_points[i-1] - way_points[i])
				end
				if final_distance == nil or distance < final_distance then
					final_distance = distance
					final_way = way_points
					msg.post("ship", "finded!", { way_points = way_points })
				end
				way_points = { go.get_position(".") }
				break
			elseif angle < 180 then
				local direction = vmath.normalize(positions[math.floor(math.max(max, min))] - go.get_position(from))
				table.insert(way_points, start_pos + direction * (lengths[math.floor(math.max(max, min))] - 8))
				distance = 0
				for i = 2, #way_points do
					distance = distance + vmath.length(way_points[i-1] - way_points[i])
				end
				if final_distance == nil or distance < final_distance then
					cuntinue_finding(way_points)
				end
			elseif angle > 180 then
				local direction = vmath.normalize(positions[math.floor(math.min(max, min))] - go.get_position(from))
				table.insert(way_points, start_pos + direction * (lengths[math.floor(math.max(max, min))] - 8))
				distance = 0
				for i = 2, #way_points do
					distance = distance + vmath.length(way_points[i-1] - way_points[i])
				end
				if final_distance == nil or distance < final_distance then
					cuntinue_finding(way_points)
				end
			end
		end
	end	
end

-- coded by Karel Kovarski