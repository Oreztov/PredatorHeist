Hooks:PostHook(PoisonGasEffect, "init", "pre_init", function (self)
	local thrower = self._grenade_unit and self._grenade_unit:base():thrower_unit()
	self._is_enemy_grenade = thrower and managers.enemy:is_enemy(thrower)
	self._damage_slotmask = self._is_enemy_grenade and managers.slot:get_mask("players") or managers.slot:get_mask("enemies")
end)

function PoisonGasEffect:update(t, dt)
	if self._timer then
		self._timer = self._timer - dt

		if not self._started_fading and self._timer <= self._fade_time then
			World:effect_manager():fade_kill(self._effect)
			self._started_fading = true
		end

		if self._timer <= 0 then
			self._timer = nil
			if alive(self._grenade_unit) and Network:is_server() then
				managers.enemy:add_delayed_clbk("PoisonGasEffect", callback(PoisonGasEffect, PoisonGasEffect, "remove_grenade_unit"), TimerManager:game():time() + self._dot_data.dot_length)
			end
		end

		if self._is_local_player or self._is_enemy_grenade then
			self._damage_tick_timer = self._damage_tick_timer - dt

			if self._damage_tick_timer <= 0 then
				self._damage_tick_timer = self._tweak_data.poison_gas_tick_time or 0.1
				local nearby_units = World:find_units_quick("sphere", self._position, self._range, self._damage_slotmask)

				for _, unit in ipairs(nearby_units) do
					if unit:base().is_local_player then
						unit:character_damage():damage_dot({
							variant = "poison",
							attacker_unit = self._grenade_unit and self._grenade_unit:base():thrower_unit(),
							weapon_unit = self._grenade_unit,
							damage = self._dot_data.dot_damage * 0.1
						})
					elseif self._is_local_player and not table.contains(self._unit_list, unit) then
						local hurt_animation = not self._dot_data.hurt_animation_chance or math.rand(1) < self._dot_data.hurt_animation_chance
						managers.dot:add_doted_enemy(unit, TimerManager:game():time(), self._grenade_unit, self._dot_data.dot_length, self._dot_data.dot_damage, hurt_animation, "poison", self._grenade_id, true)
						table.insert(self._unit_list, unit)
					end
				end
			end
		end
	end
end
