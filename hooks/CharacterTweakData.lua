Hooks:PostHook(CharacterTweakData, "init", "wz_init", function (self)
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
	self.predator.throwable = "molotov"
	self.predator.throwable_target_verified = true
	self.predator.throwable_cooldown = 10
end)
