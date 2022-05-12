PlayerDamage.POISON_DMG_MUL = 0.35

function PlayerDamage:damage_dot(attack_data)
	local damage_info = {
		result = {
			type = "hurt",
			variant = attack_data.variant
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)
		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	end

	self._unit:sound():play("player_hit")

	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data) * PlayerDamage.POISON_DMG_MUL

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)
		return
	end

	self:_check_chico_heal(attack_data)

	local health_subtracted = self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end
