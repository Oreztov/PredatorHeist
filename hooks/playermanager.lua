Hooks:PostHook(PlayerManager, "init", "PlayerSlide_setup_player_states", function(self)
	self._player_states["slide"] = "ingame_standard"
end)