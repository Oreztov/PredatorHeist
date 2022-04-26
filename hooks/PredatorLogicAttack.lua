PredatorLogicAttack = PredatorLogicAttack or class(TankCopLogicAttack)

-- Adds this logic as a logic variant
-- This allows setting up units using "predator" charactertweakdata
CopBrain._logic_variants.predator = clone(CopBrain._logic_variants.security)
CopBrain._logic_variants.predator.attack = PredatorLogicAttack


function PredatorLogicAttack.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit
	end

	local key_str = tostring(data.key)
	my_data.detection_task_key = "PredatorLogicAttack._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, PredatorLogicAttack._upd_enemy_detection, data)
	CopLogicIdle._chk_has_old_action(data, my_data)

	my_data.attitude = "engage"
	my_data.weapon_range = { close = 0, optimal = 50, far = 100 }

	data.unit:brain():set_update_enabled_state(false)

	my_data.update_queue_id = "PredatorLogicAttack.queued_update" .. key_str

	PredatorLogicAttack.queue_update(data, my_data)
	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	data.unit:brain():set_attention_settings({ cbt = true })
end

function PredatorLogicAttack._upd_aim(data, my_data)
	local focus_enemy = data.attention_obj
	if focus_enemy and PredatorLogicAttack._chk_use_throwable(data) then
		return
	end

	if focus_enemy and AIAttentionObject.REACT_AIM <= focus_enemy.reaction and focus_enemy.dis < 1000 then
		if my_data.attention_unit ~= focus_enemy.u_key then
			CopLogicBase._set_attention(data, focus_enemy)
			my_data.attention_unit = focus_enemy.u_key
		end

		if not my_data.shooting and not data.unit:movement():chk_action_forbidden("action") then
			my_data.shooting = data.unit:brain():action_request({
				body_part = 3,
				type = "shoot"
			})
		end

		CopLogicAttack.aim_allow_fire(focus_enemy.verified, true, data, my_data)
	else
		if my_data.shooting then
			my_data.shooting = not data.unit:brain():action_request({
				body_part = 3,
				type = "idle"
			})
		end

		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)
			my_data.attention_unit = nil
		end

		CopLogicAttack.aim_allow_fire(false, false, data, my_data)
	end
end

local tmp_vec = Vector3()
function PredatorLogicAttack._chk_use_throwable(data)
	local throwable = data.char_tweak.throwable
	local throwable_tweak = tweak_data.projectiles[throwable]
	if not throwable_tweak then
		return
	end

	if data.used_throwable_t and data.t < data.used_throwable_t then
		return
	end

	local focus = data.attention_obj
	if not focus.criminal_record or focus.is_deployable or (not focus.verified) == data.char_tweak.throwable_target_verified then
		return
	end

	if not focus.verified_t or not focus.last_verified_pos or not focus.identified_t or data.t - focus.identified_t < 2 then
		return
	end

	if not focus.verified and (data.t - focus.verified_t < 2 or data.t - focus.verified_t > 8) then
		return
	end

	local mov_ext = data.unit:movement()
	local is_throwable = tweak_data.blackmarket.projectiles[throwable].throwable
	if mov_ext:chk_action_forbidden("action") or data.unit:anim_data().reload or not is_throwable and not mov_ext._allow_fire then
		return
	end

	local throw_dis = focus.verified_dis
	if throw_dis < 400 or throw_dis > (throwable_tweak.launch_speed or 600) * 3 then
		return
	end

	local throw_from
	if is_throwable then
		throw_from = mov_ext:m_rot():y()
		mvector3.multiply(throw_from, 40)
		mvector3.add(throw_from, mov_ext:m_head_pos())
		local offset = mov_ext:m_rot():x()
		mvector3.multiply(offset, -20)
		mvector3.add(throw_from, offset)
	else
		throw_from = data.unit:inventory():equipped_unit():position()
	end

	local throw_to = focus.verified and focus.m_pos or focus.last_verified_pos
	local slotmask = managers.slot:get_mask("world_geometry")
	mvector3.set(tmp_vec, throw_to)
	mvector3.set_z(tmp_vec, tmp_vec.z - 200)
	local ray = data.unit:raycast("ray", throw_to, tmp_vec, "slot_mask", slotmask)
	if not ray then
		return
	end
	throw_to = ray.hit_position

	local compensation = throwable_tweak.adjust_z ~= 0 and (((throw_dis - 400) / 10) ^ 2) / ((throwable_tweak.launch_speed or 250) / 10) or 0
	mvector3.set_z(throw_to, throw_to.z + compensation)
	mvector3.lerp(tmp_vec, throw_from, throw_to, 0.5)
	if data.unit:raycast("ray", throw_from, tmp_vec, "sphere_cast_radius", 15, "slot_mask", slotmask, "report") then
		return
	end

	data.used_throwable_t = data.t + (data.char_tweak.throwable_cooldown or 15)

	local action_data = {
		body_part = 3,
		type = "act",
		variant = is_throwable and "throw_grenade" or "recoil_single"
	}
	if not data.unit:brain():action_request(action_data) then
		return
	end

	local throw_dir = tmp_vec
	mvector3.direction(throw_dir, throw_from, throw_to)
	ProjectileBase.throw_projectile_npc(throwable, throw_from, throw_dir, data.unit)

	return true
end

function PredatorLogicAttack.is_available_for_assignment(data, new_objective, ...)
	local interrupt_dis = new_objective and new_objective.interrupt_dis
	if interrupt_dis and interrupt_dis > 0 then
		new_objective.interrupt_dis = new_objective.interrupt_dis * 10
	end
	local available = PredatorLogicAttack.super.is_available_for_assignment(data, new_objective, ...)
	if interrupt_dis then
		new_objective.interrupt_dis = interrupt_dis
	end
	return available
end

function PredatorLogicAttack.queued_update(data)
	local my_data = data.internal_data
	my_data.update_queued = false
	data.t = TimerManager:game():time()

	PredatorLogicAttack.update(data)

	if my_data == data.internal_data then
		PredatorLogicAttack.queue_update(data, data.internal_data)
	end
end

function PredatorLogicAttack.queue_update(data, my_data)
	my_data.update_queued = true
	CopLogicBase.queue_task(my_data, my_data.update_queue_id, PredatorLogicAttack.queued_update, data, data.t + 1, data.important)
end

function PredatorLogicAttack.update(data)
	local unit = data.unit
	local my_data = data.internal_data

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)
		return
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	local focus_enemy = data.attention_obj
	if not focus_enemy or focus_enemy.reaction <= AIAttentionObject.REACT_AIM then
		PredatorLogicAttack._upd_enemy_detection(data, true)
		if my_data ~= data.internal_data or not focus_enemy or focus_enemy.reaction <= AIAttentionObject.REACT_AIM then
			return
		end
	end

	PredatorLogicAttack._process_pathing_results(data, my_data)

	if unit:movement():chk_action_forbidden("walk") then
		return
	end

	if unit:anim_data().crouch then
		PredatorLogicAttack._chk_request_action_stand(data)
	end

	if AIAttentionObject.REACT_COMBAT <= focus_enemy.reaction then
		if my_data.walking_to_chase_pos then
			local path = my_data.walking_to_chase_pos._nav_path
			if path and mvector3.distance_sq(path[#path], focus_enemy.m_pos) > 1000000 then
				PredatorLogicAttack._cancel_chase_attempt(data, my_data)
			end
		end

		if my_data.walking_to_chase_pos or my_data.pathing_to_chase_pos then
			return
		elseif not my_data.chase_path then
			if not my_data.chase_pos and focus_enemy.nav_tracker then
				my_data.chase_pos = PredatorLogicAttack._find_flank_pos(data, my_data, focus_enemy.nav_tracker, 100)
			end

			if my_data.chase_pos then
				local from_pos = unit:movement():nav_tracker():field_position()
				local to_pos = my_data.chase_pos

				my_data.chase_pos = nil

				if math.abs(from_pos.z - to_pos.z) < 100 and not managers.navigation:raycast({allow_entry = false, pos_from = from_pos, pos_to = to_pos}) then
					my_data.chase_path = {
						mvector3.copy(from_pos),
						to_pos
					}
				else
					my_data.chase_path_search_id = tostring(unit:key()) .. "chase"
					my_data.pathing_to_chase_pos = true
					data.brain:add_pos_rsrv("path", {
						radius = 30,
						position = mvector3.copy(to_pos)
					})
					unit:brain():search_for_path(my_data.chase_path_search_id, to_pos)
				end
			end
		end

		if my_data.chase_path then
			PredatorLogicAttack._chk_request_action_walk_to_chase_pos(data, my_data, "run")
		end
	else
		PredatorLogicAttack._cancel_chase_attempt(data, my_data)
	end
end

-- Make predator logic react more aggressively
local _chk_reaction_to_attention_object_original = CopLogicIdle._chk_reaction_to_attention_object
function CopLogicIdle._chk_reaction_to_attention_object(data, attention_data, ...)
	if data.unit:brain()._logics.attack ~= PredatorLogicAttack or data.unit:movement():cool() then
		return _chk_reaction_to_attention_object_original(data, attention_data, ...)
	end

	local settings = attention_data.settings
	return (settings.relation == "foe" or settings.reaction > AIAttentionObject.REACT_AIM) and AIAttentionObject.REACT_COMBAT or AIAttentionObject.REACT_IDLE
end

-- Increase objective interruption distance for predator logic so they switch to attack logic earlier
Hooks:PostHook(CopLogicBase, "on_new_objective", "on_new_objective_predators", function (data)
	if not data.objective or data.unit:movement():cool() then
		return
	end

	if data.brain._logics.attack ~= PredatorLogicAttack and not data.unit:movement()._actions.shoot ~= PredatorActionShoot then
		return
	end

	local objective = data.objective
	objective.pose = "stand"
	objective.haste = "run"
	if objective.interrupt_dis and objective.interrupt_dis > 0 then
		objective.interrupt_dis = objective.interrupt_dis * 10
	end
end)
