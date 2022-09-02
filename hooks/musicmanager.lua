Hooks:PostHook(MusicManager, "jukebox_default_tracks", "PRE_default_track", function(self)
    self:track_attachment_add("heist_pre_name1", "jungle")
    self:track_attachment_add("heist_pre_name2", "synth")
end)