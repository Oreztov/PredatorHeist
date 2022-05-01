Hooks:PostHook(PlayerMovement, "_setup_states", "PlayerSlide_setup_states", function(self)
	self._states["slide"] = PlayerSlide:new(self._unit)
end)