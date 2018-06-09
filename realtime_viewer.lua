-- Realtime Viewer - DCS Mission Editor mod 1.0.0
-- Viewer Client

if not realtime_viewer then realtime_viewer = {} end
realtime_viewer.port = realtime_viewer.port or 46587

do
	local require = require
	local loadfile = loadfile
	local io = io
	local lfs = lfs
	package.path = package.path..";.\\LuaSocket\\?.lua"
	package.cpath = package.cpath..";.\\LuaSocket\\?.dll"
	local JSON = loadfile("Scripts\\JSON.lua")()
	local socket = require("socket")

	function realtime_viewer.group_update(group)
		local groupName = "gn_"..tostring(group.groupId)
		local unitsTable = {
			["units"] = {},
			["country"] = group.country,
			["category"] = group.category,
			["name"] = groupName,
			["groupId"] = group.groupId,
		}
		for _, u in pairs(group.units) do
			unitsTable.units[#unitsTable.units+1] = {
				["heading"] = u.heading,
				["type"] = u.type,
				["unitId"] = u.unitId,
				["x"] = u.x,
				["y"] = u.y,
				["playerCanDrive"] = true,
				["skill"] = "Average",	
			}
		end
		mist.dynAdd(unitsTable)
	end

	function realtime_viewer.static_update(group)
		local groupName = "gn_"..tostring(group.groupId)
		local unitsTable = {
			["type"] = group.type,
			["country"] = group.country,
			["category"] = group.category,
			["x"] = group.x,
			["y"] = group.y,
			["name"] = groupName,
			["groupId"] = group.groupId,
			["dead"] = group.dead,
			["heading"] = group.heading,
		}
		mist.dynAddStatic(unitsTable)
	end
	
	realtime_viewer.groupActions = {}
	function realtime_viewer.doGroupActions()
		for _, msg in pairs(realtime_viewer.groupActions) do
			if msg.action and msg.action == "group_update" then
				realtime_viewer.group_update(msg)
			end
			if msg.action and msg.action == "static_update" then
				realtime_viewer.static_update(msg) 
			end
			if msg.action and msg.action == "remove_group" then
				name = "gn_"..tostring(msg.groupId)
				group = StaticObject.getByName(name)
				if(group) then 
					group:destroy()
				end
				group = Group.getByName(name)
				if(group) then 
					group:destroy()
				end
			end
		end
		realtime_viewer.groupActions = {}
		mist.scheduleFunction(realtime_viewer.doGroupActions, {}, timer.getTime() + .125)
	end

	function realtime_viewer.onUdpData(d)
		log.write("Realtime",log.INFO,d)
		local msg = JSON:decode(d)
		if msg.action and msg.groupId then
			realtime_viewer.groupActions[msg.groupId] = msg
		end
	end

	function realtime_viewer.start()
		log.write("Realtime",log.INFO,"=====Realtime Viewer Start=====")
		local udp = socket.udp()
		udp:setsockname("*", realtime_viewer.port)
		udp:settimeout(0)

		local function udp_step()
			mist.scheduleFunction(udp_step, {}, timer.getTime() + 0.01)
			while true do
				local packet = udp:receive()
				if not packet then return end
				realtime_viewer.onUdpData(packet)
			end
		end

		mist.scheduleFunction(udp_step, {}, timer.getTime() + 0.1)
		mist.scheduleFunction(realtime_viewer.doGroupActions, {}, timer.getTime())
	end
end