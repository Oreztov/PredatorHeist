
Hooks:PostHook(VehicleTweakData,"init","wz_init",function(self, tweak_data)

	self:_init_wz_cargo_truck()
	self:_init_wz_jeep_willy()
	self:_init_wz_motorcross_bike()
	
end)

function VehicleTweakData:_init_wz_cargo_truck()
	self.wz_cargo_truck = {
		name = "",
		hud_label_offset = 0,
		animations = {
			passenger_back_right = "drive_muscle_back_right",
			vehicle_id = "muscle",
			passenger_back_left = "drive_muscle_back_left",
			passenger_front = "drive_muscle_passanger",
			driver = "drive_muscle_driver"
		},
		sound = {
			broken_engine = "falcogini_engine_broken_loop",
			bump = "car_bumper_01",
			lateral_slip_treshold = 0.35,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 8,
			slip_stop = "car_skid_stop_01",
			slip = "car_skid_01",
			hit_rtpc = "car_hit_vel",
			engine_rpm_rtpc = "car_falcogini_rpm",
			longitudal_slip_treshold = 0.98,
			engine_speed_rtpc = "car_falcogini_speed",
			door_close = "car_door_open",
			engine_sound_event = "drive_truck",
			hit = "car_hit_gen_01"
		},
		seats = {
			driver = {
				driving = true,
				name = "driver"
			},
			passenger_front = {
				name = "passenger_front",
				has_shooting_mode = true,
				allow_shooting = false,
				driving = false,
				shooting_pos = Vector3(50, 0, 50)
			},
			passenger_back_left = {
				name = "passenger_back_left",
				driving = false,
				allow_shooting = true,
				has_shooting_mode = true
			},
			passenger_back_right = {
				name = "passenger_back_right",
				driving = false,
				allow_shooting = true,
				has_shooting_mode = true
			}
		},
		loot_points = {
			loot_left = {
				name = "loot_left"
			},
			loot_right = {
				name = "loot_right"
			}
		},
		damage = {
			max_health = 1200
		},
		camera_limits = {
			driver = {
				pitch = 45,
				yaw = 100
			},
			passenger = {
				pitch = 80,
				yaw = 140
			}
		},
		max_speed = 180,
		max_rpm = 6500,
		loot_drop_point = "interact_loot",
		max_loot_bags = 0,
		interact_distance = 400,
		driver_camera_offset = Vector3(0, 0.2, 2.5),
		fov = 75
	}
end

function VehicleTweakData:_init_wz_jeep_willy()
	self.wz_jeep_willy = {
		name = "",
		hud_label_offset = 0,
		animations = {
			passenger_back_right = "drive_boat_rib_1_back_right",
			vehicle_id = "muscle",
			passenger_back_left = "drive_boat_rib_1_back_left",
			passenger_front = "drive_muscle_passanger",
			driver = "drive_muscle_driver"
		},
		sound = {
			broken_engine = "falcogini_engine_broken_loop",
			bump = "car_bumper_01",
			lateral_slip_treshold = 0.35,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 8,
			slip_stop = "car_skid_stop_01",
			slip = "car_skid_01",
			hit_rtpc = "car_hit_vel",
			engine_rpm_rtpc = "car_falcogini_rpm",
			longitudal_slip_treshold = 0.8,
			engine_speed_rtpc = "car_falcogini_speed",
			door_close = "car_door_open",
			engine_sound_event = "muscle",
			hit = "car_hit_gen_01"
		},
		seats = {
			driver = {
				name = "driver",
				fov = 75,
				driving = true
			},
			passenger_front = {
				name = "passenger_front",
				has_shooting_mode = false,
				allow_shooting = true,
				driving = false
			},
			passenger_back_right = {
				name = "passenger_back_right",
				has_shooting_mode = false,
				allow_shooting = true,
				driving = false
			},
			passenger_back_left = {
				name = "passenger_back_left",
				has_shooting_mode = false,
				allow_shooting = true,
				driving = false
			}
		},
		loot_points = {
			loot = {
				name = "loot"
			}
		},
		repair_point = "v_repair_engine",
		trunk_point = "interact_trunk",
		damage = {
			max_health = 10
		},
		max_speed = 160,
		max_rpm = 8000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 4,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0.2, 2.5),
		fov = 75
	}
end

function VehicleTweakData:_init_wz_motorcross_bike()
	self.wz_motorcross_bike = {
		name = "",
		hud_label_offset = 220,
		animations = {
			driver = "drive_bike_1_driver",
			vehicle_id = "bike_1"
		},
		sound = {
			slip = "mc_skid",
			hit_rtpc = "car_hit_vel",
			lateral_slip_treshold = 0.35,
			bump_rtpc = "car_bump_vel",
			bump_treshold = 6,
			slip_stop = "mc_skid_stop",
			bump = "mc_bumper_01",
			engine_rpm_rtpc = "car_falcogini_rpm",
			engine_start = "mc_harley_start",
			longitudal_slip_treshold = 0.95,
			engine_speed_rtpc = "car_falcogini_speed",
			engine_sound_event = "mc_harley",
			hit = "mc_hit_gen_01"
		},
		seats = {
			driver = {
				driving = true,
				name = "driver"
			}
		},
		loot_points = {
			loot_left = {
				name = "loot"
			}
		},
		damage = {
			max_health = 10
		},
		max_speed = 180,
		max_rpm = 3000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 0,
		interact_distance = 250,
		driver_camera_offset = Vector3(0, 0, 0),
		fov = 75,
		camera_limits = {
			driver = {
				pitch = 30,
				yaw = 55
			}
		}
	}
end

