-- Realtime Viewer - DCS Mission Editor mod 1.0.0
-- Sender Client

local base = _G
local require = base.require

module("realtime_sender")

local HOST = "127.0.0.1"
local PORT = 46587
local me_db = require("me_db_api")
local socket = require("socket")
local JSON = base.loadfile("Scripts\\JSON.lua")()

function udpSent(obj)
	base.pcall(function()
		local udp = socket.udp()
		udp:settimeout(0)
		udp:setpeername(HOST, PORT)
		udp:send(JSON:encode(obj).."\n\n")
	end)
end

function groupUpdate(group,country)
	if group and group.units then
		local units = {}
		for _, u in base.pairs(group.units) do
			units[#units+1] = {
				type=me_db.getNameByDisplayName(u.type),
				x=u.x,
				y=u.y,
				heading=u.heading,
				unitId=u.unitId
			}
		end
		udpSent({
			action = "group_update", 
			units = units,
			country  = "USA",
			category = group.type,
			name = group.name,
			groupId = group.groupId, 
		})
	end
end

function staticGroupUpdate(group)
	if group and group.units then
		udpSent({
			action = "static_update",
			type = me_db.getNameByDisplayName(group.units[1].type),
			country = "USA",
			category = group.units[1].category,
			x = group.units[1].x,
			y = group.units[1].y,
			name = group.name,
			groupId = group.groupId,
			dead = group.dead,
			heading = group.units[1].heading,
		})
	end

end

function hook_static(panel_static)
	local ori_function = panel_static.updateHeading
	panel_static.updateHeading = function()
		ori_function()
		if panel_static.vdata.group then
			staticGroupUpdate(panel_static.vdata.group)
		end
		--udpSent("on static updateHeading()")
	end
end

function hook_ship(panel_ship)
	local ori_function = panel_ship.updateHeading
	panel_ship.updateHeading = function()
		ori_function()
		if panel_ship.vdata.group then
			groupUpdate(panel_ship.vdata.group,panel_ship.vdata.country)
		end
		--udpSent("on ship updatHeading()")
	end
end

function hook_vehicle(panel_vehicle)
	local ori_function = panel_vehicle.updateHeading
	panel_vehicle.updateHeading = function()
		ori_function()
		if panel_vehicle.vdata.group then
			groupUpdate(panel_vehicle.vdata.group,panel_vehicle.vdata.country)
		end
		--udpSent("on vehicle updateHeading()")
	end
end

function hook_mission(module_mission)
	local ori_function = module_mission.remove_group
	module_mission.remove_group = function(group)
		udpSent({
			action = "remove_group",
			 groupId = group.groupId,
			 name = group.name,
		})
		--udpSent("on remove group()")
		return ori_function(group)
	end

	local ori_function2 = module_mission.update_group_map_objects
	module_mission.update_group_map_objects = function(group)
		ori_function2(group)
		if group.type == "static" then
			staticGroupUpdate(group)
		end 
		--if group.type == "vehicle" or group.type == "vehicle" or group.type == "ship" then
		--
		--end
		--udpSent("on update_group_map_objects()")
	end
end

function hook_map_window(MapWindow)
local ori_function = MapWindow.move_unit
	MapWindow.move_unit = function(group, unit, x, y, doNotRedraw)
		ori_function(group, unit, x, y, doNotRedraw)
		groupUpdate(group,"")
	end
	--udpSent("on move_unit()")
end

function hook(self)
	--hook_map_window(self.MapWindow)
	hook_static(self.panel_static)
	hook_ship(self.panel_ship)
	hook_vehicle(self.panel_vehicle)
	hook_mission(self.module_mission)
end