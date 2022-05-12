Hooks:PostHook(CharacterTweakData, "init", "pre_init", function (self)
	-- You can name the preset whatever you want, just make sure the logic/action variants in PredatorLogicAttack and PredatorActionShoot are named the same
	self.predator = deep_clone(self.gangster)

	-- Tips for setting up Predator character preset and removing their movement slowdowns:
	-- Disable their suppression by setting `suppression = nil` in their character preset, this will prevent them from crouching when suppressed
	-- Set `no_run_start = true` and `no_run_stop = true` to disable their start and stop running animations
	-- Set `damage.hurt_severity` to something that excludes heavy or medium hurts
	self.predator.suppression = nil
	self.predator.no_run_start = true
	self.predator.no_run_stop = true
	self.predator.damage.hurt_severity = self.presets.hurt_severities.no_hurts
	self.predator.move_speed = self.presets.move_speed.lightning

	-- Used throwable needs to be loaded, molotov is loaded by default but other throwables might need loading through dynamicresourcemanager
	-- `throwable_target_verified` is custom behaviour and works as follows:
	--     true  - throws only if enemy is visible
	--     false - throws only if enemy isn't visible
	--     nil   - throws regardless of enemy visibility
	self.predator.throwable = "poison_gas_grenade"
	self.predator.throwable_target_verified = true
	self.predator.throwable_cooldown = 10

	-- hp tweak
	self.predator.HEALTH_INIT = 1000
end)

local character_map_original = CharacterTweakData.character_map
function CharacterTweakData:character_map(...)

	local char_map = character_map_original(self, ...)
	local new_map ={
		"ene_rebel_1",
		"ene_rebel_2",
		"ene_rebel_3",
		"ene_rebel_4"
	}

	for _, unit in pairs(new_map) do
		table.insert(char_map.basic.list, unit)
	end

	return char_map
end
